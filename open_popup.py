#!/usr/bin/env python3
"""Open a successor popup once the command palette releases the popup slot."""

from __future__ import annotations

import json
import os
from pathlib import Path
import subprocess
import sys
import time

POPUP_WAIT_SECONDS = 10
CALL_TIMEOUT_SECONDS = 2


def popup_is_busy(result: subprocess.CompletedProcess) -> bool:
    try:
        error = json.loads(result.stderr or result.stdout)["error"]
        return (
            error.get("code") == "ui_busy"
            and error.get("message") == "a popup pane is already open"
        ) or (
            error.get("code") == "plugin_pane_open_failed"
            and error.get("message") == "popup already open"
        )
    except (KeyError, TypeError, ValueError, AttributeError):
        return False


def open_when_ready(herdr: str, args: list[str]) -> tuple[int, str]:
    deadline = time.monotonic() + POPUP_WAIT_SECONDS
    while True:
        try:
            result = subprocess.run(
                [herdr, "plugin", "pane", "open", *args], text=True,
                capture_output=True, timeout=CALL_TIMEOUT_SECONDS,
            )
        except (OSError, subprocess.TimeoutExpired) as exc:
            return 1, str(exc)
        if result.returncode == 0:
            return 0, ""
        output = (result.stdout or "") + (result.stderr or "")
        if not popup_is_busy(result):
            return result.returncode, output
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            return 1, "The command palette did not release the popup slot.\n" + output
        # Retry only an observed busy slot, never a guessed teardown duration.
        time.sleep(min(0.05, remaining))


def main() -> int:
    args = sys.argv[1:]
    if not args:
        print("Usage: open_popup.py <herdr plugin pane open options>", file=sys.stderr)
        return 2
    if args[0] != "--wait":
        try:
            subprocess.Popen(
                [sys.executable, str(Path(__file__).resolve()), "--wait", *args],
                stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL, start_new_session=True,
            )
        except OSError as exc:
            print(f"Could not start popup launcher: {exc}", file=sys.stderr)
            return 1
        return 0

    herdr = os.environ.get("HERDR_BIN_PATH", "herdr")
    code, output = open_when_ready(herdr, args[1:])
    if code:
        print(output, file=sys.stderr)
        try:
            subprocess.run(
                [herdr, "notification", "show", "Command palette popup failed", "--body", output],
                capture_output=True, timeout=CALL_TIMEOUT_SECONDS, check=False,
            )
        except (OSError, subprocess.TimeoutExpired):
            pass
    return code


if __name__ == "__main__":
    raise SystemExit(main())
