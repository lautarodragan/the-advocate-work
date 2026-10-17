#!/usr/bin/env python3
"""Refuses a shell wait loop that has no time limit.

A PreToolUse hook on Bash. An `until`/`while` loop that sleeps waits for a
condition, and when the condition is written wrong —a `pgrep -f` that finds
its own command line, a line the log never prints— it never ends, and it
keeps the agent that launched it alive for hours (AGENTS.md, "The background
tasks we launch, we can kill"). A loop inside a `timeout` is let through: it
dies on its own in the worst case.
"""
import json
import re
import sys

command = json.load(sys.stdin).get("tool_input", {}).get("command", "")

loops = re.search(r"\b(until|while)\b", command)
sleeps = re.search(r"\bsleep\b", command)
bounded = re.search(r"\btimeout\s+\S+", command)

if loops and sleeps and not bounded:
    print(
        "Refused: a wait loop with no time limit (`until`/`while` with "
        "`sleep`). Instead:\n"
        "* for a suite or anything long you launch yourself, run it with "
        "the Bash tool's run_in_background: you are woken up when it exits, "
        "with its output; no condition to poll;\n"
        "* to wait for a process you did not launch, wait for its PID with "
        "a limit: `timeout 2h tail --pid=<pid> -f /dev/null`;\n"
        "* if a loop is really needed, wrap it in `timeout <limit> bash -c "
        "'…'`.",
        file=sys.stderr,
    )
    sys.exit(2)
