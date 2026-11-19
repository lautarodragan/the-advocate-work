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

## Log

**2026-11-19, Cardón.** Branches `cardon-painted-pieces` from the-advocate
`62b6e5cb`, the ports `1ea90bf` and the book `93984ad`, in worktrees under
`~/scratch/cardon/pp/`. The prototype (`cardon-dn-towns`, `cb45d5a4`) is
the reference; it passes the pieces from the map's conversion to the
layers through a global and the knobs through the environment, so the
feature is written again: the pieces travel with the rest of what the map
adds to its layers (`Extra` and `LayersRequest`, as the decorations and
the posed cells do), the knob is `[graphics] painted_events` (`true` or a
list of maps, as `baked_events`), and the trim ranks the pieces it can
leave out to be painted before every other drawing.

**2026-11-19, taro's decision** (through Hornero, translated):

> If it's impossible to make a game run without the .msu, we make the .msu
> mandatory. Vampires already works that way. I think it's important that
> the .msu be optional where we can (ABL, mainly), but it isn't worth
> looking for a very complex path to satisfy that need. If we go this way,
> let's decide that the msu will be mandatory for Desert Nightmare for
> now, to reduce the challenge.

So the room is not solved inside the cartridge for Desert Nightmare, and
every map that benefits goes painted, not only the slow ones. The painted
cells themselves cannot leave the ROM: they are uploaded column by column
while the camera moves, and the `.msu` takes only what is read when a map
or a battle loads (a seek costs a frame or two; the poses stay in the ROM
for the same reason). What `[rom] msu = "required"` does instead is send
the load-time data —the maps' streams, the panoramas' tiles, the
samples— to the `.msu` until the rest fits, which leaves the room to the
painted cells. To be measured.

**The feature (2026-11-19, Cardón).** the-advocate `cardon-painted-pieces`:
`df6a7eb3` (the list-of-maps knob type renamed, mechanical) and `70c3dd8f`
(`[graphics] painted_events`, `pieces.rs` in Wally, the trim's
`Loss::Painted`). With the knob off, the 20 cartridges of the nine games
—ABL's 11, the release of the other eight and Zounds' `exits`— come out
byte for byte as with the global tools (`roms-base` against `roms-off`).

**Desert Nightmare, every map** (`painted_events = true`, `msu =
"required"`): it builds and links, 821 pieces (2.69 MB) to the `.msu`;
161 maps take pieces, 146 go painted, 17 baked; `event-left-out` 183 → 0,
`events-not-drawn` 9 → 0, `events-wait-for-a-slot` 34 → 10. But 45 maps
lose something: 18, 33 and 71 wait for slots (the painted layout's 256
sprite tiles, as the study said), and 42 one-screen interiors lose the
message box's two pictures (`TextboxInnen`, `TextboxRahmen`: "with their
272 tiles the map fits no VRAM layout"). So the list: every map with a
piece to paint but those 45 —95 maps—.
