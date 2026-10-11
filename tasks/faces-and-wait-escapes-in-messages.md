---
name: "Faces and wait escapes in messages"
description: "ChangeFaceGraphic and the escapes \\. \\! \\| in the middle of a box leave their page out; in Dooms 2 the start scene of map 2 doesn't run and nothing triggers. Cheap: accept the face as debt (without drawing it) and take the escapes as waits"
type: feature
status: testing
agents: [Aguará, Tijereta]
assignee: taro
---

From Aguará's (Sonnet) brief analysis, on 2026-10-05, of what taro saw playing the ROMs of the other games. It affects Dooms 2, Desert Nightmare and Sunset Over Imdahl.

## Done (Tijereta)

`ChangeFaceGraphic` goes into `ACCEPTED_UNDONE` and `\.`, `\!` and `\|` in the middle of a box are discarded in `escape_tail` (`without_waits`, in `rm2k-snes-text`): the ROM can't wait mid-box, so it is debt, noted in `draw-the-faces-and-really-wait-on-the-escapes.md`. EasyRPG does wait (`Window_Message`), and that is where the measure comes from: `\.` 1/4 s, `\|` 1 s, `\!` a key press.

**Verified**: tests of `rm2k-snes-text` and `rm2k-snes-events`, with the middle cases red before. ABL doesn't use faces or escapes in the middle (they are all at the tail): `release` gives `abl.sfc` `27e94e67039533a2…`, the same. The suite wasn't run. Dooms 2: with these tools the scene on map 2 runs (Jack's dialogue in a snes9x capture), **but** by compiling more pages the samples directory went past 255 entries (263) and the cartridge didn't build: to build it, maps 40 to 93 were excluded in the project's `rm2k-snes.toml` (except those already excluded). What to really exclude will have to be decided.
