---
name: "Still pieces painted into a painted map"
description: "A converter feature behind a project knob: the still events of one appearance standing on a panorama fixed to the map are painted into the painted map, in RM2k's order, and lose their row; first for Desert Nightmare's towns"
type: feature
status: doing
assignee: Cardón
agents: [Cardón]
game: desert-nightmare
---

From [`desert-nightmare-can-the-towns-be-baked`](desert-nightmare-can-the-towns-be-baked.md)
(the book's `ports/desert-nightmare/research/2026-11-19-can-the-towns-be-baked.md`),
whose throwaway prototype is the-advocate's branch `cardon-dn-towns`
(`cb45d5a4`, `rm2k-snes/wally/src/town.rs`).

taro, translated, after asking how general painting into the panorama is
(the answer: a panorama fixed to the map *is* the map, RM2k's "parallax
mapping"; the port already carries such maps painted, as Sunset's):

> Okay, I'd love to try it!

**What**: the study's recommendations 1 and 2, made real:

1. Behind a project knob, paint into a painted map every still piece of
   one appearance (its pages draw the same, nothing moves, flashes or
   erases it), with the ChipSet's layers and the front mask for what RM2k
   draws over a character; the event keeps its row's pages but draws no
   object.
2. Bake before the RAM's 120-row trim, so the trimmed pieces are painted
   too (the white roofs of maps 4, 14, 61, 66).
3. Inside the knob only: a `CallEvent` counts as erasing only if what it
   reaches erases (the study's recommendation 3). Applying it to
   `posed.rs` for every game is a separate change.

On for Desert Nightmare. Which maps go painted is what fits the cartridge:
if all that benefit do not fit, the study's recommendation 4 (each distinct
cell stored once) is the next task, not this one.

**Done means**: Desert Nightmare's towns at ~1 frame per tick and no line
over the PPU's limits but the known few (measured with
`just objects-per-line` and the STAT77 counters); the white roofs gone;
captures against EasyRPG; Desert Nightmare's boot tests and a ROM test of a
town; ABL, Zounds and the other games unchanged (ROMs byte for byte, or the
reason); `just space` for every cartridge; the Known issues lines that go
away removed.
