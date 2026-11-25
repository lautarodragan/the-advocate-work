#!/usr/bin/env sh
# What the inbox Monitor runs (taro's, 2026-11-25): every 15 minutes a
# fetch, and each new commit on origin/main that touches tasks/ and carries
# no agent's Co-authored-by trailer —taro's, from the tasks page— printed
# once. Nothing printed, nothing wakes Hornero. Bounded, as
# bounded-waits.py asks: the Monitor's own timeout ends it; relaunch it.
cd "$(dirname "$0")/../.." || exit 1
seen=$(git rev-parse origin/main 2>/dev/null)
while :; do
  git fetch -q origin main 2>/dev/null
  now=$(git rev-parse origin/main 2>/dev/null)
  if [ -n "$seen" ] && [ "$now" != "$seen" ]; then
    git log --format='%h %an: %s%n%(trailers:key=Co-authored-by,valueonly)%x00' "$seen..$now" -- tasks/ \
      | tr '\0' '\n' | awk 'BEGIN{RS=""} !/agents\.taro\.codes/ {print "taro on the tasks page: " $0}' 
  fi
  seen=$now
  sleep 900
done
