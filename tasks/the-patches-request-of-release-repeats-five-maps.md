---
name: "The patches request of release repeats five maps"
description: "The request the converter hands the patches stage for ABL's release carries maps 121, 133, 261, 269 and 348 twice, with identical entries; until A8 the binary wrote and counted those five files twice, and the converter.log said 313 maps where there are 308"
type: bug
status: todo
author: tijereta
links:
  found-in: [the-stages-speak-json-nobody-types]
  relates: [merge-release-and-test-main]
---

Seen by Tijereta on 2026-11-24, doing A8 of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md):
capturing the request the global `rm2k-snes-patches` received for ABL's
`release`, maps 121, 133, 261, 269 and 348 —the ones `--check` marks as
"only of the suite", see
[`merge-release-and-test-main`](merge-release-and-test-main.md)— come twice,
with identical entries. The binary wrote each of those files twice and
counted them twice: `patches of 313 map(s) … (819517 B)`. Since A8 the
answer is a map by file name, so the same build says `308 map(s) …
(812326 B)`; the 308 files are the same bytes.

Nothing breaks today: the entries are equal, and if two of the same id ever
differed the last one would win, as before. But the request should not
repeat a map, and whatever builds it may repeat it elsewhere too.

**What is asked**: find where the converter builds the patches request
—`rm2k-snes/convert/` in the-advocate— and why the suite's extra maps enter
it twice; fix it at the source, with a test that fails with the repetition.
The ROMs and `build/` must stay byte for byte equal.

## Log

### 2026-11-24, Hornero: written from Tijereta's A8 report

Promoted by Hornero to `todo`: verified by capturing the request, the fix
is not in doubt —a request without repetitions—, and nothing seen or heard
changes.

### 2026-11-24, Hornero: the events request repeats them too

Calandria met the same five maps twice in ABL release's events request,
typing it (the stages task, `e1d44127` in the-advocate): the old `Map`
collapsed them, and her `ByMap::insert` does the same, with a test. So
the repetition is upstream of both stages —the list of maps the
converter builds for `release`—, which is where this task's fix goes.
