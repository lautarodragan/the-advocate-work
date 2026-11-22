---
name: "Frozen World's turn audio test passes only with the tracks"
description: "test_with_the_msu_too, in the ports' boot suite, is green when Frozen World's build/release holds its MSU-1 tracks —as after a delivery— and red when it was built without them, as the tests build it: Holy5 has already gone up 30 ticks after arriving at the battle"
type: bug
status: doing
author: hornero
assignee: Chajá
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
