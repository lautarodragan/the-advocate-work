---
name: "Frozen World's turn audio test passes only with the tracks"
description: "test_with_the_msu_too, in the ports' boot suite, is green when Frozen World's build/release holds its MSU-1 tracks —as after a delivery— and red when it was built without them, as the tests build it: Holy5 has already gone up 30 ticks after arriving at the battle"
type: bug
status: testing
author: hornero
assignee: taro
agents: [Hornero, Chajá]
game: frozen-world
---

Seen by Hornero on 2026-11-22, verifying the merge of
[`try-pack-picks-the-smallest-group`](try-pack-picks-the-smallest-group.md)
on the-advocate `1b8825d8` and the ports `544f9bc`, in the integration
worktree of the ports.

**What was seen**: the ports' `just boot` gave 200 passed and 1 failed,
`test_frozen_world_turn_audio.py::test_with_the_msu_too`:

    AssertionError: on arriving at the battle Holy5's sample, entry 198,
    is not waiting: [200, 201, 202, 203, 204, 207] are

It fails the same with the global tools, from before Hurón's merge
(`ec672f4c`), so it is not the merge. With Frozen World rebuilt with
`TRACKS=1 just cartridges release` —32 `.pcm` next to the ROM— both of
the file's tests pass. The run that was green on `ec672f4c`, before,
found in that worktree the build a delivery had left, with its tracks.
The file's docstring says the tests build without tracks, so the songs
play through the SPC700; the assertion holds only with them.

## Log

### 2026-11-22, Hornero: seen, taken for Chajá

### 2026-11-22, Chajá: the runtime is right, the test raced it

Reproduced in my worktree of the ports (`chaja-tfw-audio-without-tracks`
from `544f9bc`, global tools): Frozen World built by the test, without
tracks, red as Hornero saw it.

#### Why

A throwaway script over the ports' `tests/games.py` jumps onto map 1 as
the test does and prints, tick by tick, the entries marked 3 in
`FAR_WANTS`. Without the tracks the battle song plays on the SPC700 and
takes its ARAM, so map 1's package places fewer of the `.msu`'s effects:
nine wait on arrival, `[195, 198, 199, 200, 201, 202, 203, 204, 207]`,
and the idle end of the ticks uploads them in directory order: 195 at
tick 6, `Holy5` (198) at 15, 200 (`Pollen`) at 33, 201 (`Rebirth1`) at
52, all at 108. With the tracks —the 32 `.pcm` of a delivered build next
to the ROM— nothing of the music is in ARAM and sixteen wait, 193 to 208;
198 goes up at tick 48 to 57, 201 at 75.

The test waited 30 ticks after arriving, checked `Holy5` waited, then
walked 8 and waited 10 more before A: without the tracks it is gone by
that first check. With them it passed the check, but her page plays its
effect 17 ticks after A (`ShowPicture`, `MovePicture` with its wait,
then `PlaySound`, measured arriving on her cell), so at ~66 ticks, after
the idle end had most likely uploaded it already (57 standing still);
the last check only asked "up and sounding", so it could not tell. The
on-demand path my test meant to cover was probably not exercised even
when green. So the runtime does what its design says —the effects wait
past the fade and go up in the idle end, in order, or on demand—, and
the test raced it.

Even arriving on her cell and pressing A at once, `Holy5` loses without
the tracks: 15 ticks idle against 17.

#### The fix, in the test

`test_with_the_msu_too` plays her other branch: switch 209 off and 632
on, the one that raises her defence, which plays `Rebirth1` (entry 201)
and also calls common event 3. The jump puts the hero on her cell, A goes
the tick after, and the test asserts the effect waits on arrival and that
the tick it leaves `FAR_WANTS` 3 it is already sounding —so the idle end
did not get there first—. Margin: played at ~17 ticks, idle at 52
without the tracks and 75 with them. With `Holy5` and switch 209 in its
place the new assertion goes red without the tracks: "Holy5 went up 15
ticks after A without sounding".

### 2026-11-22, Chajá: run both ways, to testing

Ports branch `chaja-tfw-audio-without-tracks`, commit `1dacd94`, from
`544f9bc` (main has not moved); global tools, `ec672f4c`. Nothing in the
runtime or the tools changed, so ABL's suite, the-advocate's `just test`
and `test-game` were not run.

* Frozen World built by the test, without tracks: `just boot -k
  frozen_world_turn_audio`, 2 passed. Before the fix, 1 failed, as
  Hornero saw it.
* Frozen World built with `TRACKS=1 just cartridges release` (32 `.pcm`
  made): the same two, 2 passed. Also with the delivered build's tracks
  linked next to the ROM: 2 passed. The tracks were removed afterwards.
* The new assertion with `Holy5` and switch 209 put back, without tracks:
  red, "Holy5 went up 15 ticks after A without sounding".
* The ports' root `just boot`, whole, without tracks: 200 passed, 1
  failed, `test_zounds.py::test_the_download_room_shows_the_panoramas_its_event_sets`
  (31 of 57,344 pixels). Not this change: its golden was regenerated in
  `5c453a9` for Hurón's `try_pack` (the-advocate `1b8825d8`), and the
  global tools at `ec672f4c` are older than that merge, so they pack the
  tiles the old way. With the tools of `1b8825d8` installed it should be
  green; not run here, since nothing of the tools was mine to compile.

#### When merging

Nothing to install: only the ports' test changed.
