---
name: "A Blurred Line: the sixty-one torches of map 148 stand still"
description: "Map 148's Crown7 flames animate in RM2k and stand still in the port: with its ground already fused to fit, the converter gives up their two slots before fusing more"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

Seen by Calandria on 2026-10-15, measuring
[`book-of-three-the-intros-torches-stand-still`](book-of-three-the-intros-torches-stand-still.md),
with the-advocate `7aa66900` and the ports `66a83f3`.

**What the build says**: `still-animation-dropped` in `release`'s
`degradations.json`, "map 148: 61 still events animate in RM2k and stand
still here: their slots don't fit in the sprite bank (0 of 1 looks
animate)". They are 61 `Crown7` index 3 flames, 57 at speed 6 and 4 at
speed 5: two VRAM slots. The same map has `background-tiles-fused` (74
tiles).

**Why**: the converter gives up still animations before fusing the
ground, and here the map does not fit even with none animating, so the
fusion runs with the animation already given up. Before 2026-10-15 they
stood still too, by the cap of four.

Also left standing still, by the same rule or by a cache that would make
events wait: Sunset Over Imdahl's maps 1, 2, 3, 12, 13, 14, 15 and 46, and
Vampires Dawn's 201, 222, 236 and 240 (102 animates one of its three
looks).

**How to see it**: build `release` and look for `still-animation-dropped`
in `abl/build/release/degradations.json`; in the game, map 148.

## Defined (2026-10-16, Carpintero)

Still open at the-advocate `f4709d0b`. A fidelity detail: nothing stops
and the map plays. **Done** is map 148's flames animating in `release`
—no `still-animation-dropped` for it in `degradations.json`—, with the
map's background fused as much as that takes and the fusion's loss looked
at side by side. Two ways, the agent picks and measures: fuse the ground
further to free the two slots, or let the animation take its slots before
the fusion is decided. **First step**: how many more tiles the fusion has
to merge for the two slots, on 148 and on the Sunset and Vampires Dawn
maps listed above.

**Taken on 2026-10-16** at taro's request, by Calandria.

## Work (2026-10-16, Calandria)

**The cause was not the fusion.** Measured with `wally map` on the
`release` request of 148 (captured with a wrapper on the PATH): with all
the torches animating the plain conversion took **1171** sprite tiles,
and 211 with none. The two slots of the description were never there:
every torch has an empty action page, the event compiler's scan said
those pages turn toward the hero, and a still event that turns animates
in a slot of its own (`shares` in wally's `moves`), so it was sixty-one
slots. RM2k does not turn them: `ScheduleForegroundExecution` returns on
an empty list before `SetFacing`.

With `turns` false for a page without commands (the-advocate `8c6a345b`)
148 fits with every torch animating at the **same** fusion it already had
—74 tiles, to 543—: no extra fusion, so no loss to look at side by side.

The other maps, same change, `degradations.json` before and after:

* Sunset 1, 2, 3, 12, 13, 14, 15, 46: unchanged. Maps 56 and 57 get one
  more cache slot.
* Vampires Dawn 201, 222, 236, 240: unchanged in their animations (222
  gets one more cache slot). 176 animates its ten still events. Some
  thirty maps lend fewer palettes, and rain comes back on fifteen.
* But rain coming back costs: VD 51 gave up its 21 animations (the rain
  takes cache slots, 30 to 26, and events would wait) and VD 163 now has
  events waiting (14 slots to 11). Draft:
  [`rain-drops-cost-a-cache-its-slots`](rain-drops-cost-a-cache-its-slots.md),
  with a proposal on the-advocate's branch `calandria-rain-before-slots`
  (rain goes before animations and waiting) that is **not** in this task's
  branch: it takes the rain off twelve more Sunset maps, and that is
  taro's to weigh.

Why the Sunset and Vampires Dawn maps of the list still stand still: in a
cache of slots twins don't share, so each torch on screen wants a slot.
Sunset's are maps that show their panorama (2 ground tiles), so fusing
does nothing for them; Vampires Dawn's 201, 236 and 240 would need 18, 9
and 9 more fused tiles for a layout with the slots, but they fit without
fusing and the conversion only fuses a map that fits nothing; 222 has no
layout. Draft, with the table:
[`still-animation-twins-do-not-share-in-a-cache`](still-animation-twins-do-not-share-in-a-cache.md).
And Sunset's 46 gives its two animations up for a picture that is not
drawn anyway: [`animations-given-up-for-a-picture-that-is-not-drawn`](animations-given-up-for-a-picture-that-is-not-drawn.md).

The test: `tests/rpgmaker/test_still_animation_twins.py` in ABL, red with
main's tools, green with the fix: the slot of torch 3 and of its twin 4
show the same pose, and more than one in 120 frames.

## Done (2026-10-17, Calandria): to testing

Branches, all `calandria-torches-148`, with main merged:

* the-advocate: `8c6a345b` the fix (with its test, red first), `b6b9df10`
  the test game's garden and showcase goldens (People1 5 on an empty page
  no longer turns: a step of colour on one character), `477ef9c2` merge.
* the ports: `021f64c` the ROM test (red with main's tools, green with
  the fix), `33c6338` its line in the index, `b887d75`, `d42436c`,
  `520ec0c`, `e408570` the goldens that moved, by rounds (24 captures,
  still characters merged differently; the tram's passengers go from a
  lent grey to their own blue). All looked at side by side in
  `/shared/captures/2026-10-16-torches-148/`.
* the book: `43dca56` the Known issues line goes, and the divergence on
  still animations stops listing 148.
* Not to merge without taro: the-advocate `calandria-rain-before-slots`
  (`836861f0`), the rain proposal of the draft
  [`rain-drops-cost-a-cache-its-slots`](rain-drops-cost-a-cache-its-slots.md).

**To install when merging**: `just install events`. Wally is not touched.

Run, with the branch's tools: `just rust-test` (953 passed), `just test`
(29), `just test-game` with FluidR3 (38 passed, 1 skipped, after the two
goldens; on a clean main it was green with the old ones), ABL's `just
tests` until no new golden showed up (1565 passed, 2 skipped), and the
ports' `just boot` full (59 passed). `release`'s `abl.sfc` sha256 starts
`0bf476a4c25e4c9d`; `degradations.json` has no `still-animation-dropped`
for 148, and its fusion is the same 74 tiles to 543.

**To play**: map 148, Paradise Burning: the fires flicker. Pressing the
action key on a torch no longer turns it, as in RM2k.
