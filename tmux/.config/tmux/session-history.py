#!/usr/bin/env python3

import fcntl
import os
import re
import socket
import subprocess
import sys
import tempfile
from contextlib import contextmanager
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Iterator, Sequence

SNAPSHOT_PATTERN = re.compile(r"^tmux_resurrect_(\d{8}T\d{6})\.txt$")
PLUGIN_DIR = Path.home() / ".tmux" / "plugins" / "tmux-resurrect" / "scripts"
BACKUP_NAME = "last.session-history-backup"
LOCK_NAME = ".session-history.lock"


class HistoryError(Exception):
    pass


@dataclass(frozen=True)
class SnapshotRecords:
    panes: tuple[str, ...]
    windows: tuple[str, ...]
    directories: tuple[Path, ...]
    grouped: tuple[tuple[str, str], ...]

    @property
    def signature(self) -> tuple[tuple[str, ...], tuple[str, ...]]:
        return self.panes, self.windows


def fail(message: str) -> None:
    raise HistoryError(message)


def tmux_option(name: str) -> str:
    result = subprocess.run(
        ["tmux", "show-option", "-gqv", name],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        check=False,
    )
    return result.stdout.rstrip("\n") if result.returncode == 0 else ""


def resurrect_dir(create: bool = False) -> Path:
    configured = tmux_option("@resurrect-dir")
    if configured:
        hostname = socket.gethostname()
        expanded = configured.replace("$HOME", str(Path.home()))
        expanded = expanded.replace("$HOSTNAME", hostname).replace("~", str(Path.home()))
        directory = Path(expanded)
    else:
        legacy = Path.home() / ".tmux" / "resurrect"
        if legacy.is_dir():
            directory = legacy
        else:
            data_home = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local" / "share"))
            directory = data_home / "tmux" / "resurrect"

    if create:
        try:
            directory.mkdir(parents=True, exist_ok=True)
        except OSError as error:
            fail(f"cannot create tmux-resurrect directory {directory}: {error}")

    if not directory.is_dir():
        fail(f"tmux-resurrect directory does not exist: {directory}")
    if not os.access(directory, os.R_OK | os.X_OK):
        fail(f"tmux-resurrect directory is not readable: {directory}")
    return directory.resolve()


def plugin_script(name: str) -> Path:
    script = PLUGIN_DIR / name
    if not script.is_file() or not os.access(script, os.X_OK):
        fail(
            f"tmux-resurrect script is missing or not executable: {script}; "
            "install plugins with Prefix + I"
        )
    return script


def decode_saved_directory(value: str) -> Path:
    saved = value[1:] if value.startswith(":") else value
    saved = saved.replace(r"\ ", " ").replace("~", str(Path.home()), 1)
    return Path(saved).expanduser().resolve(strict=False)


def read_records(snapshot: Path, session: str) -> SnapshotRecords:
    panes: list[str] = []
    windows: list[str] = []
    directories: list[Path] = []
    grouped: list[tuple[str, str]] = []
    try:
        with snapshot.open("r", encoding="utf-8", errors="surrogateescape") as handle:
            for raw_line in handle:
                line = raw_line.rstrip("\n")
                fields = line.split("\t")
                if len(fields) >= 2 and fields[0] == "pane" and fields[1] == session:
                    if len(fields) < 9:
                        fail(f"malformed pane record in snapshot: {snapshot}")
                    panes.append(line)
                    directories.append(decode_saved_directory(fields[7]))
                elif len(fields) >= 2 and fields[0] == "window" and fields[1] == session:
                    if len(fields) < 7:
                        fail(f"malformed window record in snapshot: {snapshot}")
                    windows.append(line)
                elif len(fields) >= 3 and fields[0] == "grouped_session":
                    grouped.append((fields[1], fields[2]))
    except OSError as error:
        fail(f"cannot read snapshot {snapshot}: {error}")
    return SnapshotRecords(tuple(panes), tuple(windows), tuple(directories), tuple(grouped))


def belongs_to_root(directory: Path, root: Path) -> bool:
    try:
        directory.relative_to(root)
        return True
    except ValueError:
        return False


def validate_project(records: SnapshotRecords, root: Path) -> bool:
    return any(belongs_to_root(directory, root) for directory in records.directories)


def missing_directories(records: SnapshotRecords) -> tuple[Path, ...]:
    return tuple(sorted({directory for directory in records.directories if not directory.is_dir()}))


def snapshot_path(value: str, directory: Path) -> Path:
    candidate = Path(value).expanduser()
    match = SNAPSHOT_PATTERN.fullmatch(candidate.name)
    if not match:
        fail(f"invalid tmux-resurrect snapshot filename: {candidate.name}")
    try:
        resolved = candidate.resolve(strict=True)
    except OSError as error:
        fail(f"cannot access snapshot {candidate}: {error}")
    if resolved.parent != directory or not resolved.is_file():
        fail(f"snapshot is outside tmux-resurrect directory: {candidate}")
    if not os.access(resolved, os.R_OK):
        fail(f"snapshot is not readable: {resolved}")
    return resolved


def snapshots(directory: Path) -> Iterator[tuple[Path, datetime]]:
    found: list[tuple[Path, datetime]] = []
    try:
        entries = tuple(directory.iterdir())
    except OSError as error:
        fail(f"cannot read tmux-resurrect directory {directory}: {error}")
    for entry in entries:
        match = SNAPSHOT_PATTERN.fullmatch(entry.name)
        if match and entry.is_file():
            found.append((entry.resolve(), datetime.strptime(match.group(1), "%Y%m%dT%H%M%S")))
    yield from sorted(found, key=lambda item: item[1], reverse=True)


def recover_last(directory: Path) -> None:
    last = directory / "last"
    backup = directory / BACKUP_NAME
    if os.path.lexists(backup):
        if os.path.lexists(last):
            last.unlink()
        os.replace(backup, last)


@contextmanager
def locked(directory: Path) -> Iterator[None]:
    lock_path = directory / LOCK_NAME
    try:
        with lock_path.open("a+") as lock:
            fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
            recover_last(directory)
            yield
    except OSError as error:
        fail(f"cannot lock tmux-resurrect directory {directory}: {error}")


def list_history(session: str, root_value: str) -> int:
    directory = resurrect_dir()
    root = Path(root_value).expanduser().resolve(strict=False)
    previous_signature: tuple[tuple[str, ...], tuple[str, ...]] | None = None
    with locked(directory):
        history = tuple(snapshots(directory))

    for snapshot, timestamp in history:
        records = read_records(snapshot, session)
        if not records.panes and not records.windows:
            previous_signature = None
            continue
        if not validate_project(records, root):
            previous_signature = None
            continue
        if records.signature == previous_signature:
            continue
        previous_signature = records.signature
        missing = missing_directories(records)
        status = f"missing:{len(missing)}" if missing else "ready"
        print(
            f"{snapshot}\t{timestamp:%Y-%m-%d %H:%M:%S}\t"
            f"{len(records.windows)} windows\t{len(records.panes)} panes\t{status}"
        )
    return 0


def exact_session_exists(session: str) -> bool:
    result = subprocess.run(
        ["tmux", "has-session", "-t", f"={session}"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return result.returncode == 0


def plugin_environment() -> dict[str, str]:
    environment = os.environ.copy()
    if environment.get("TMUX"):
        return environment
    result = subprocess.run(
        ["tmux", "display-message", "-p", "#{socket_path},#{pid},#{session_id}"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        check=False,
    )
    value = result.stdout.strip()
    if result.returncode == 0 and value:
        environment["TMUX"] = value
    return environment


def run_plugin(script: Path, arguments: Sequence[str] = ()) -> int:
    try:
        return subprocess.run(
            [str(script), *arguments], env=plugin_environment(), check=False
        ).returncode
    except OSError as error:
        fail(f"cannot execute tmux-resurrect script {script}: {error}")


def restore_active_targets(records: SnapshotRecords) -> None:
    for line in records.windows:
        fields = line.split("\t")
        if len(fields) >= 6 and "*" in fields[5]:
            subprocess.run(
                ["tmux", "select-window", "-t", f"={fields[1]}:{fields[2]}"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )
    for line in records.panes:
        fields = line.split("\t")
        if len(fields) >= 9 and fields[8] == "1":
            subprocess.run(
                ["tmux", "select-pane", "-t", f"={fields[1]}:{fields[2]}.{fields[5]}"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )


def restore_session(session: str, root_value: str, snapshot_value: str) -> int:
    script = plugin_script("restore.sh")
    directory = resurrect_dir()
    snapshot = snapshot_path(snapshot_value, directory)
    root = Path(root_value).expanduser().resolve(strict=False)

    with locked(directory):
        if exact_session_exists(session):
            fail(f"tmux session already exists: {session}")
        records = read_records(snapshot, session)
        grouped = tuple(pair for pair in records.grouped if session in pair)
        if grouped:
            fail(f"session {session} belongs to a grouped session; use restore-global")
        if not records.panes or not records.windows:
            fail(f"snapshot has no complete pane/window records for session: {session}")
        if not validate_project(records, root):
            fail(f"snapshot session {session} does not belong to root: {root}")
        missing = missing_directories(records)
        if missing:
            joined = ", ".join(str(path) for path in missing)
            fail(f"snapshot has {len(missing)} missing pane directories: {joined}")

        last = directory / "last"
        backup = directory / BACKUP_NAME
        filtered_path: Path | None = None
        link_path: Path | None = None
        try:
            descriptor, filtered_name = tempfile.mkstemp(
                dir=directory, prefix=".session-history-", suffix=".txt"
            )
            filtered_path = Path(filtered_name)
            with os.fdopen(descriptor, "w", encoding="utf-8", errors="surrogateescape") as handle:
                for line in (*records.panes, *records.windows):
                    handle.write(f"{line}\n")
                handle.flush()
                os.fsync(handle.fileno())

            if os.path.lexists(last):
                os.replace(last, backup)
            link_path = directory / f".session-history-last-{os.getpid()}"
            if os.path.lexists(link_path):
                link_path.unlink()
            os.symlink(filtered_path.name, link_path)
            os.replace(link_path, last)
            return_code = run_plugin(script)
            if return_code != 0:
                fail(f"tmux-resurrect restore failed with status {return_code}")
            if not exact_session_exists(session):
                fail(f"tmux-resurrect did not create session: {session}")
            restore_active_targets(records)
            return 0
        finally:
            if os.path.lexists(last):
                last.unlink()
            if os.path.lexists(backup):
                os.replace(backup, last)
            if link_path is not None and os.path.lexists(link_path):
                link_path.unlink()
            if filtered_path is not None and filtered_path.exists():
                filtered_path.unlink()


def save_global(arguments: Sequence[str]) -> int:
    if len(arguments) > 1 or (arguments and arguments[0] != "quiet"):
        fail("usage: session-history.py save-global [quiet]")
    script = plugin_script("save.sh")
    directory = resurrect_dir(create=True)
    with locked(directory):
        return run_plugin(script, arguments)


def restore_global(arguments: Sequence[str]) -> int:
    if arguments:
        fail("usage: session-history.py restore-global")
    script = plugin_script("restore.sh")
    directory = resurrect_dir()
    with locked(directory):
        return run_plugin(script)


def main(arguments: Sequence[str]) -> int:
    if not arguments:
        fail(
            "usage: session-history.py "
            "{list SESSION ROOT|restore SESSION ROOT SNAPSHOT_PATH|save-global [quiet]|restore-global}"
        )
    command, *rest = arguments
    if command == "list" and len(rest) == 2:
        return list_history(rest[0], rest[1])
    if command == "restore" and len(rest) == 3:
        return restore_session(rest[0], rest[1], rest[2])
    if command == "save-global":
        return save_global(rest)
    if command == "restore-global":
        return restore_global(rest)
    fail(f"invalid arguments for command: {command}")


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except HistoryError as error:
        print(f"session-history: {error}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("session-history: interrupted", file=sys.stderr)
        sys.exit(130)
