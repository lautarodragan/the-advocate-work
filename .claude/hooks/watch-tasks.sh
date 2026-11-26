#!/usr/bin/env sh
# The inbox watch (taro's, 2026-11-25), run by Hornero with the Bash
# tool's run_in_background under `timeout 24h`: every 15 minutes a fetch,
# and it exits —waking Hornero— only when origin/main gains a commit that
# carries no agent's Co-authored-by trailer: taro's, from the tasks page or
# by hand, anywhere in the repo —one to the page's code too, so Hornero
# pulls before its own push is refused—. Not Claude Code's Monitor: that one lasts 30 minutes
# at most and wakes Hornero each time it expires, with nothing to say.
# Hornero relaunches it after reading what it printed.
cd "$(dirname "$0")/../.." || exit 1
seen=$(git rev-parse origin/main 2>/dev/null)
while :; do
  git fetch -q origin main 2>/dev/null
  now=$(git rev-parse origin/main 2>/dev/null)
  if [ -n "$seen" ] && [ "$now" != "$seen" ]; then
    git log --format='%h %an: %s%n%(trailers:key=Co-authored-by,valueonly)%x00' "$seen..$now" \
      | tr '\0' '\n' | awk 'BEGIN{RS=""} !/agents\.taro\.codes/ {print "taro on main: " $0; n++} END {exit n ? 0 : 1}' \
      && exit 0
  fi
  seen=$now
  sleep 900
done
