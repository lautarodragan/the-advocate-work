---
name: "Zounds: no way back from map 189"
description: "Map 44's event 7 teleports to map 189 (5 > Arriba), whose exits back to 44 do not work on the console; EasyRPG crashes on that map"
type: bug
status: done
assignee: taro
agents: [Calandria]
---

taro, on 2026-10-17, playing Zounds on Mednafen (the-advocate `30786e0b`,
the ports `1d93da4`): event 7 of map 44 ("Main / Cave / 2") teleports to
map 189 (`[189, 6, 7]`), and from there taro cannot go back. Map 189
(20x15, 7 events) has three touch exits: event 1 at (17,8) to map 81, and
events 2 and 3 at (5,8) and (6,8) back to map 44. `degradations.json`
lists no loss on map 189. taro also says EasyRPG crashes on that map,
consistently.

## Log

**2026-10-17, Calandria — the cause.** Reproduced on snes9x with the
harness: from map 44's event 7 the hero lands on map 189 at (6,7), and
holding down does not move him. Events 2 and 3 are **tile events on the
lower layer** —no CharSet, `character_index` 38 and 44 of ChipSet 46,
both with passability 0 and not "above"— whose page's own route is a
single command 36, "walk through walls on", not repeating. RM2k's
`Game_Map::IsPassableTile` lets such an event's tile rule its cell, but
skips the events with `GetThrough()`; the console's `pass_with_event`
(`runtime/hero.s` in the-advocate) did not ask, so (5,8) and (6,8) were
walls. The route did run: both events' route slots carried the through
bit (`route_ev + 12`), read from RAM.

**The fix**, in `pass_with_event`: a row standing on the cell is skipped if
`event_crossable` says its event walks through walls —the question
`cell_blocked` already asks—. Only for a row already on the cell, so it
costs nothing per step. It covers a forced route's 36 as well as the
page's own.

**The test**: `test_from_the_cave_to_arriba_5_and_back` in the ports'
`tests/test_zounds.py` —boot, the guards' talk, a jump to map 44 below
event 7, up to map 189, down back to map 44 at (16,4)—. Red before
("the hero is on map 189 at (6, 7)"), green after.

**The other exits.** Over the nine games' `data/`, the lower-layer tile
events with a tile that closes the cell and an own route that turns 36 on
are these two pages and no other; and they are also Zounds' only touch
exits drawn with a closing tile. Forced routes that send a 36 to such an
event were not counted —the parameters are encoded—; the fix covers them.

**EasyRPG.** The binary in `~/ref/easyrpg-player-bin.tar.gz` (Player
0.8.1.1) does **not** crash on map 189: replaying input, map 44 → event 7
→ map 189 → down → map 44 works, and punching the switch at (15,7) plays
the sparks and lays the bridge. The only warning is `CharSet/object2`
missing, which is an RPG Maker 2000 RTP name (the converter takes it from
the RTP) and EasyRPG treats as a warning. So taro's crash is not
reproduced here: it may be their EasyRPG version or their copy of the
game. Wine was not tried: Zounds is RPG Maker 2003, and the recipe in
`~/wine/abl/LEEME.txt` is for 2000 runtimes. Captures in
`/shared/captures/2026-10-17-zounds-map-189/`. That crash stays as a
draft, [`zounds-easyrpg-crashes-on-map-189`](zounds-easyrpg-crashes-on-map-189.md).

**Verified**, with the-advocate `calandria-map-189` (`aaea86b1`) and
`just install-local .local-tools cartridge`: ABL's `just tests`, 1565
passed and 2 skipped, no golden moved (`abl.sfc` `8c472867e7bad5f5`, sha256
prefix); `just boot` at the ports' root (`fa9d93e`), 64 passed, the new
test among them; `just test`, 29 passed; `just test-game` with
`SOUNDFONT=FluidR3_GM.sf2`, 44 passed and 1 skipped. What the suite does
not cover: map 189's other exit, event 1 to map 81, reached only after the
switch at (15,7) lays the bridge —it has no tile, so the fix does not
touch it—; and a tile event made to walk through walls by a forced route,
which no test plays.

**To install when merging**: `just install cartridge` (only the runtime
changed; the path of `runtime/` goes into the cartridge binaries).

**2026-10-19, taro**: fixed, playing Zounds; they went on to the rest of the rift and north of the desert. Done.
