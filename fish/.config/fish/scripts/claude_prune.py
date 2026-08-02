#!/usr/bin/env python3
import os
import subprocess
import sys

CLAUDE_DIR = os.path.expanduser("~/.claude")
RELATED = ["session-env", "file-history"]


def related_paths(jsonl_path):
    session_id = os.path.basename(jsonl_path)[:-6]
    paths = [jsonl_path]
    for sub in RELATED:
        candidate = os.path.join(CLAUDE_DIR, sub, session_id)
        if os.path.exists(candidate):
            paths.append(candidate)
    return paths


def main():
    jsonl_paths = [line.strip() for line in sys.stdin if line.strip()]
    if not jsonl_paths:
        print("没有匹配的会话", file=sys.stderr)
        return 0

    targets = []
    for path in jsonl_paths:
        targets.extend(related_paths(path))

    subprocess.run(["trash", *targets], check=True)
    print(f"已移到废纸篓: {len(jsonl_paths)} 个会话 ({len(targets)} 个文件/目录)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
