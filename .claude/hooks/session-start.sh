#!/usr/bin/env sh
# At a session's start (taro's, 2026-11-25): bring the tasks up to date,
# hand Hornero what taro left on the tasks page, and remind it to watch
# for more while it works. A hook cannot start the Monitor —that tool is
# the model's—, so it says to.
cd "$CLAUDE_PROJECT_DIR" || exit 0
git pull --rebase=merges -q >/dev/null 2>&1
inbox=$(nu tasks/tasks.nu inbox 2>&1)
python3 - "$inbox" <<'PY'
import json, sys
text = ("Tasks inbox (nu tasks/tasks.nu inbox):\n" + sys.argv[1] +
        "\n\nLaunch the inbox Monitor now: `.claude/hooks/watch-tasks.sh`, "
        "persistent, as AGENTS.md says.")
print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart",
                                         "additionalContext": text}}))
PY
