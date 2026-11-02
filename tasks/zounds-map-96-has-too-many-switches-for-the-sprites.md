---
name: "Zounds' map 96 has too many switches for the sprites"
description: "Map 96 (Arriba del Cuartito) carries 58 floor-switch events drawn from a CharSet: it lags, a switch is drawn by half, the hero loses everything below the head on some rows, and an opened chest's graphic vanishes until the hero walks"
type: bug
status: doing
assignee: Cardón
agents: [Cardón]
---

taro, on 2026-11-02, in their words, translated, with captures of the
port and of the map in the EasyRPG editor:

> On that map (96, "Arriba del Cuartito") there is a lot of lag. There
> are quite a few objects on that map. And now that I look at the
> screenshot, one of the floor switches shows rendered by half. I attach
> a screenshot of how it looks in RPG Maker (EasyRPG Editor). I think all
> the `Switch`es are a copy-paste. In theory our current system should
> detect them and de-duplicate them, but maybe they are not being
> de-duplicated for some reason, or maybe even de-duplicated there is
> still lag.
>
> When opening the chest its graphic disappears. Walking a bit to the
> right, it shows again. The same happens with other events.

In their captures the hero is also drawn with his head only, on the
rows of the switches.

Measured by Hornero at ports 31fb291: the map is 30x30 with 99 events;
58 are `Switch`, all with page 1 on CharSet `object2`, still, action
key. The converter warns (`build/release/degradations.json` in
`zounds/`): "by where they start up to 64 events are on screen at once
and the cache has 28 slots: the ones drawn last wait for one" —likely
the chest—, the 8 sprite palettes used up, and the transparent sign's
picture not drawn. A half switch and the headless hero look like the
console's sprites-per-scanline limit (32 sprites, 34 8x8 slivers), but
that is a guess.

**Done**: the causes measured (lag: where the frame goes; the half
switch and the hero: scanline limit or else; the chest: the slot
cache), and what fits fixed —e.g. still CharSet events that never
change pose baked into the background, or shared sprites— so map 96
plays as in RPG_RT, or the limit measured and written as a divergence.
Captures before/after, and a ROM test where the suite can reach it.

## Cardón's notes

Worked from the-advocate 0ba09da4 and the-advocate-ports 31fb291, on
branches `cardon-map-96`.

**Measured before touching anything**, on the release cartridge in
snes9x, jumping to map 96 with the harness's `go_to_map` and reading
the OAM the ROM builds in RAM:

* **The switches are not de-duplicated.** Each one drew from a slot of
  its own: in one frame the twenty-odd switches on screen pointed at
  twenty-odd different tiles. The reason is in the switch itself: its
  action page runs `MoveEvent` on *this event* with a single
  `face left` —that is the "pressed" pose, and RPG_RT does turn a
  "fixed graphic" event with a face command: `TurnTo` sets the facing
  whatever the lock—. Wally takes every route target as one that walks,
  and in a map with a cache one that walks wants a slot of its own
  while in view. Fifty-six of them against a cache of 28: the ones the
  OAM walk reaches last never get one. That is the chest that vanishes
  when it changes pose, and the switch columns drawn with none of their
  switches.
* **The lag**: 240 frames for 120 ticks standing by the switches —half
  speed—, 122 for 120 at the top of the map, far from them.
* **The half switch is the line limit**, the 34 slivers of 8 pixels:
  every character is a 32x32 object, four slivers on each of its 32
  lines whether drawn or not, so eight and a half objects per line. A row
  of switches on screen is sixteen; two rows, 32 objects on the same
  lines. Up to 82 slivers on one line measured. The PPU drops the
  frontmost objects' —the lowest OAM indices—, and the OAM goes from
  front to back: on map 96 the lower row of switches is the one that
  vanishes where it shares lines with the upper one.
* **The headless hero is not the line limit**: put at (12, 17), (20, 17)
  or (11, 17) the hero shows his head only before the change and after,
  with no line over 34 slivers there. Those cells are the bottom edge of
  the room, whose lower tiles 16 and 17 of ChipSet 46 carry the star flag
  and are drawn above him, as RM2k does. Not checked against RPG_RT.
* **The chest**: opened from (11, 17) it did not vanish before the change
  either; with the cache full it could, because the row that changes pose
  asks for a slot again. After the change no screen of the map asks the
  cache for more than 17 slots (the converter's estimate), against 28.

## What was done

* **The still ones that routes only turn stay still in a map with a
  cache.** The event compiler's page records carry `route_turns`, the
  route targets every route of the page only turns —faces, turns, waits,
  the facing lock, speed and frequency, switches, sounds—. Wally's
  `moves` takes an event out of the walkers when every compiled page that
  routes it only turns it, it has no route of its own, it is not a test
  page's, and every page draws a CharSet that stands (not a tile, not
  nothing, not animating or spinning); only with a cache, where still
  ones key their slot by pose. The cache's still poses then carry all
  twelve poses of its characters, sorted, so they go together.
* **In the runtime**, `refresh_npc` sends a still row to `still_turn`
  (FAR, `cache_slots.s`) instead of `upload_npc_pose`: it moves the row's
  key by as much as the pose moves, reading the old pose from the key's
  entry in `cache_data` and not from +12, which a reloaded bank leaves at
  $FF. Sixteen bytes of bank 0, in `npcs.s`.
* Map 96 after: "84 events take a slot of a cache of 28 ... 32 still
  poses among them; by where they start, up to 17 are on screen at once",
  without the warning. Every switch on screen has its object; the 55
  decoys turn to their pressed pose alone when stepped on, as in RPG_RT
  (their page only turns them if they face down; one switch, event 20,
  opens the door).
* `tests/test_zounds_map_96_switches.py` in the ports: red before (16 of
  30 switches on screen without an object), green after.

## What was not done

* **The lag**: 240 frames per 120 ticks at (8, 16), (12, 17), (20, 17)
  and (9, 12), before the change and after. Measured with a temporary
  probe of the V counter after each step of the main loop: about 90
  lines go to the vblank, the music's IRQ and the rest of the loop, and
  `build_oam` costs about four lines per drawn row (`place_npc`,
  `cache_want` on its fast path, `emit_object`): 130 to 240 lines with 40
  to 64 objects.
* **The line limit**: still there, and more visible now that every
  switch is drawn. A divergence in the book, "Too many characters on one
  line", and a line in Zounds' Known issues.
* Both would go away by painting those switches into the background and
  writing their cell when their pose changes. Draft:
  [`still-events-that-change-pose-painted-into-the-background`](still-events-that-change-pose-painted-into-the-background.md).

Captures, before and after: `/shared/captures/2026-11-02-zounds-map-96/`.
