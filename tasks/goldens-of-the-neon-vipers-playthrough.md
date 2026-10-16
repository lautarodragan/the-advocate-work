---
name: "The goldens of the Neon Vipers playthrough"
description: "The shots of the vipers playthrough have no golden: a part of playthrough-pending-goldens, which is where they are done"
type: test
status: todo
assignee: taro
---

`tests/abl/test_playthrough_vipers_golden.py` takes its shots, but none
has a golden, and a shot without a golden always passes (`tests/harness/playthrough.py`,
on purpose: nobody blessed it). Until they are frozen, the playthrough checks
what it looks at in RAM but not what is seen.

**It is blocked on taro**: freezing them is saying "this is how it has to look", and
he decides that by looking at the shots. What's needed on this side is to leave him
the current shots in `/shared/goldens/<fecha>-vipers/` so he can look at them; with
his ok, they are copied to `tests/golden/` in a commit that says he looked at them.

**Careful before freezing them (2026-09-26):** the game started through "Begin the Story" has DummyHero as leader (actor 10, with no graphic), so in the shots of `test_playthrough_vipers_golden.py` Talan doesn't appear, at least in the HQ. The new test in the other branches solves it with `set_party(14)`; this one would need the same line before taking the final shots.

## Checked on 2026-10-16 (Carpintero): a part of the playthrough's pending goldens

**Duplicate** of [`playthrough-pending-goldens`](playthrough-pending-goldens.md),
which covers every playthrough shot without a golden, the vipers' among
them: on the ports at `4b2d41e` the vipers' shots, of both tests, are
listed in `abl/tests/golden/playthrough/pending.txt`, and there is no
`vipers/` among the goldens. Do them there; the warning above about
DummyHero and `set_party(14)` still applies to them.

Two facts above are out of date: since 2026-09-29 a shot without a golden
**fails** unless it is in `pending.txt` (see that file's header), so they
no longer pass in silence; and captures for taro go to
`/shared/captures/<date>-<topic>/`, not `/shared/goldens/`.
