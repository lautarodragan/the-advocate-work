---
name: "Zounds' map 96 without its decoy switches"
description: "An experiment: map 96 patched to keep only the switch that opens the door, to measure how much of its lag the 57 decoy switches are"
type: feature
status: doing
assignee: Cardón
agents: [Cardón]
---

Follows [`zounds-map-96-has-too-many-switches-for-the-sprites`](zounds-map-96-has-too-many-switches-for-the-sprites.md),
where Cardón measured 240 frames per 120 ticks —the map runs at half
speed— before and after making the switches share their graphic, with
`build_oam` at about 4 scanlines per row drawn and 40 to 64 objects on
screen; and found that only event 20 opens the door, the other switches
only turn when looked at from above.

taro, on 2026-11-02, in their words, translated:

> I'd like to look at the lag of the Zounds map we already analysed,
> again.
>
> I'd start with the cheapest test: a patch of the map without any of the
> switch events that aren't needed to progress. Only one is needed.

**Done**: a fork of map 96 in Zounds' `patches/manual/maps/` without the
decoys —check first that none of them is read by anything else: a
switch, a variable, another page—; the lag measured with and without, at
the same spots, the same way as before; a ROM taro can play delivered to
`/shared/captures/2026-11-02-zounds-map-96-no-decoys/`. Whether the fork
stays —or the change goes to the game, which is taro's— is taro's call
after measuring; until then it lives on the branch only.

## Cardón's notes

Worked from the-advocate 244f4013 (the global tools), the-advocate-ports
6436a39 and the game at bbdaf78 —map 96 with the ingots' scene's third
page, already in the ports' `data/`—, on the ports' branch
`cardon-map-96-no-decoys`.

**Which switches are decoys.** Map 96 has 58 events named `Switch`.
Three are other things: event 6 (`object2` 3, the button that does
nothing and counts its presses in variable 49 until Kazar pays Unamë to
stop), 12 (`object2` 1, which moves the cart) and 84 (upstairs, by the
doors). Of the 56 floor switches —`object2` 4, below the hero,
touched by the hero— event 20 is the one that opens the door: it turns,
shows animation 168 on event 18 and turns switch 139 on. Events 21 to 75
are the decoys, 55 of them —74 is alone at (0, 29), off the room—, all
the same two pages: page 1 turns the event left with a sound if it faces
down; page 2, on switch 139, the same graphic facing left with nothing.

**Nothing reads them.** What a decoy writes: nothing —no switch, no
variable, no `EraseEvent`—. What reads a decoy, searched over every page
of map 96 and every common event for the commands that can name a map
event by id —`SetEventLocation`, `SwapEvents`, `SetMoveRoute`,
`ShowBattleAnimation`, `FlashSprite`, `ConditionalBranch` on an event's
facing, `ControlVariables` from an event, `CallEvent` of a map event,
`StoreEventID`—: none names 21 to 75. Their layer is below the hero, so
they block nobody: not the hero, not the statue —event 83, which moves
itself and keeps its own position in variables 52 and 53—.

**The fork**: `zounds/patches/manual/maps/Map0096.json` is
`data/maps/Map0096.json` as Ditto writes it with those 55 events cut out
as text and the top-level `"id": 96`; the `.tiles` is the dump's, as is.
44 events left of 99.

## Measured

The same way as in the previous task: the release cartridge in snes9x,
jumped to map 96 with the harness's `go_to_map`, 60 frames to settle,
then frames until `ticks` advances 120, and the OAM the ROM builds in RAM
—objects, and slivers of eight pixels on each scanline—. And a temporary
probe, never committed: a `jsl` to a FAR routine after each step of the
main loop that stores the V counter at `$7F:FE00`, averaged over 30 whole
iterations; it costs a few lines of its own. Global tools of 244f4013 for
the frame counts, the same plus the probe for the lines. Before is the
ports' 6436a39; after, the same with the fork.

| spot | frames / 120 ticks | objects | rows | max slivers on a line | lines over 34 | loop lines | `build_oam` |
|---|---|---|---|---|---|---|---|
| (8, 16) | 240 → 120 | 48 → 20 | 84 → 29 | 84 → 24 | 48 → 0 | 305 → 160 | 213 → 68 |
| (12, 17) | 240 → 120 | 60 → 20 | 84 → 29 | 110 → 22 | 48 → 0 | 333 → 162 | 241 → 70 |
| (20, 17) | 240 → 120 | 48 → 12 | 84 → 29 | 92 → 20 | 48 → 0 | 295 → 140 | 203 → 48 |
| (9, 12) | 240 → 120 | 40 → 20 | 84 → 29 | 50 → 28 | 8 → 0 | 291 → 162 | 199 → 70 |
| (15, 19) | 240 → 120 | 64 → 12 | 84 → 29 | 128 → 22 | 48 → 0 | 337 → 140 | 245 → 48 |
| (14, 12) | 240 → 120 | 40 → 12 | 84 → 29 | 70 → 24 | 8 → 0 | 284 → 142 | 192 → 50 |
| (4, 5) | 120 (122 with the probe) → 120 | 20 → 20 | 84 → 29 | 28 → 24 | 0 → 0 | 244 → 162 | 152 → 70 |

"Loop lines" is from the end of `wait_vblank` —line 225, the vblank's
start— to the end of `build_oam`: a frame is 262 lines, so past 262 the
iteration misses the next vblank and the map runs at half speed. The
rest of the loop does not move: `map_events` 55 lines, `flush_video` 7,
`move_hero` 5, `events_tick` 4, the others less, before and after.

So **the lag was the decoys, and all of it is `build_oam`**, which walks
every row of the map each frame whether it is on screen or not: at (4,
5), far from every switch and with the same 20 objects as after, it took
152 lines with 84 rows against 70 with 29 —the map was already at the
edge there, 244 of 262, and lost a frame now and then—. With the decoys
on screen it went past 262 everywhere.

**The half-cut switch and the line limit**: gone with them. No line over
28 slivers anywhere; before, up to 128 at (15, 19) —where the hero,
standing between the two rows of switches, showed his head only: that
one *was* the line limit; at (12, 17) and (20, 17) he still shows his
head only after, which is the star tiles of the room's bottom edge, as
the previous task found—.

**The converter's warnings for map 96**, before → after:

* "84 events take a slot of a cache of 28 ..., 32 still poses among
  them; by where they start, up to 17 are on screen at once" → nothing:
  the map fits without a cache.
* "its pages send 60 distinct events walking and the ROM has 12 route
  slots" → gone.
* "184 automatic event page(s)" → 74.
* The sign's and the dialogue's pictures are still not drawn, for
  another reason: before, "with their 448 tiles the map fits no VRAM
  layout"; after, "the map uses 8 sprite palettes and the battle
  animation's box one and they need 2 more".
* The battle animations, still not drawn (the 8 sprite palettes); the 9
  graphics with a lent palette, the same.

**Event 20 still opens the door**: a throwaway script put the hero below
it, at (7, 15), stepped up, and switch 139 went from off to on. Not a
test of the suite.

Captures, before and after at each spot side by side, in
`/shared/captures/2026-11-02-zounds-map-96-no-decoys/`, next to the ROM.
