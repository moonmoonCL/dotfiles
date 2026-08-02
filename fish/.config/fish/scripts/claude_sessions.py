#!/usr/bin/env python3
import argparse
import json
import os
import signal
import sys
from datetime import datetime, timedelta, timezone
from glob import glob

PROJECTS_DIR = os.path.expanduser("~/.claude/projects")
SEP = "\t"


def message_text(entry):
    content = entry.get("message", {}).get("content")
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return " ".join(
            part.get("text", "")
            for part in content
            if isinstance(part, dict) and part.get("type") == "text"
        )
    return ""


def is_human_prompt(entry):
    origin = entry.get("origin")
    return (
        entry.get("type") == "user"
        and isinstance(origin, dict)
        and origin.get("kind") == "human"
    )


def oneline(text):
    return " ".join(text.split())


def read_entries(path):
    for line in open(path, encoding="utf-8", errors="replace"):
        line = line.strip()
        if not line:
            continue
        try:
            yield json.loads(line)
        except json.JSONDecodeError:
            continue


def summarize(path):
    session_id = os.path.basename(path)[:-6]
    cwd = ""
    branch = ""
    first_prompt = ""
    prompt_count = 0
    last_ts = None
    for entry in read_entries(path):
        if not cwd and entry.get("cwd"):
            cwd = entry["cwd"]
        if not branch and entry.get("gitBranch"):
            branch = entry["gitBranch"]
        if is_human_prompt(entry):
            text = message_text(entry).strip()
            if text:
                prompt_count += 1
                if not first_prompt:
                    first_prompt = text
                if entry.get("timestamp"):
                    last_ts = entry["timestamp"]
    if prompt_count == 0:
        return None
    when = datetime.fromtimestamp(os.path.getmtime(path), tz=timezone.utc)
    if last_ts:
        try:
            when = datetime.fromisoformat(last_ts.replace("Z", "+00:00"))
        except ValueError:
            pass
    return {
        "id": session_id,
        "path": path,
        "cwd": cwd or "?",
        "branch": branch or "-",
        "prompts": prompt_count,
        "when": when,
        "first": first_prompt,
    }


def collect(newer_than, older_than, query):
    now = datetime.now(timezone.utc)
    rows = []
    for path in glob(os.path.join(PROJECTS_DIR, "*", "*.jsonl")):
        summary = summarize(path)
        if summary is None:
            continue
        age_days = (now - summary["when"]).total_seconds() / 86400
        summary["age_days"] = age_days
        if newer_than is not None and age_days > newer_than:
            continue
        if older_than is not None and age_days < older_than:
            continue
        if query:
            hay = f"{summary['cwd']} {summary['branch']} {summary['first']}".lower()
            if query not in hay:
                continue
        rows.append(summary)
    rows.sort(key=lambda r: r["when"], reverse=True)
    return rows


def display_line(r):
    when = r["when"].astimezone().strftime("%Y-%m-%d %H:%M")
    cwd = r["cwd"].replace(os.path.expanduser("~"), "~")
    return f"{when}  {cwd}  [{r['branch']}] ({r['prompts']}) {oneline(r['first'])[:120]}"


def cmd_list(args):
    for r in collect(args.newer_than, args.older_than, args.query.lower()):
        print(SEP.join([r["path"], display_line(r)]))


def cmd_paths(args):
    for r in collect(args.newer_than, args.older_than, ""):
        print(r["path"])


def cmd_cwd(args):
    for entry in read_entries(args.path):
        if entry.get("cwd"):
            print(entry["cwd"])
            return


def cmd_preview(args):
    for entry in read_entries(args.path):
        if is_human_prompt(entry):
            text = oneline(message_text(entry)).strip()
            if text:
                print("▸", text[:300])


def main():
    parser = argparse.ArgumentParser(description="Query local Claude sessions")
    parser.add_argument("query", nargs="*", help="filter by cwd / branch / prompt")
    parser.add_argument("--newer-than", type=float, metavar="DAYS",
                        help="only sessions active within DAYS")
    parser.add_argument("--older-than", type=float, metavar="DAYS",
                        help="only sessions idle for more than DAYS")
    parser.add_argument("--paths", action="store_true",
                        help="print matching session file paths only")
    parser.add_argument("--cwd", metavar="PATH", help=argparse.SUPPRESS)
    parser.add_argument("--preview", metavar="PATH", help=argparse.SUPPRESS)
    args = parser.parse_args()
    args.query = " ".join(args.query)

    if args.cwd:
        args.path = args.cwd
        return cmd_cwd(args)
    if args.preview:
        args.path = args.preview
        return cmd_preview(args)
    if args.paths:
        return cmd_paths(args)
    return cmd_list(args)


if __name__ == "__main__":
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    main()
