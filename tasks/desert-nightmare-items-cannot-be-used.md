---
name: "Desert Nightmare: items cannot be used"
description: "Common event 20, which uses an item where the hero stands, and 14, the map screen, do not compile: both read the hero's map id with ControlVars, which the ROM does not do. The light bulb never goes into the warehouse's lamp"
type: bug
status: done
assignee: taro
game: desert-nightmare
agents: [Hurón, Chajá]
---

Seen by Hurón on 2026-11-19, at the-advocate `62b6e5cb` and the ports
`1ea90bf`, for
[`desert-nightmare-what-it-takes-to-be-playable`](desert-nightmare-what-it-takes-to-be-playable.md).

**What is seen**: `just culprits` in `desert-nightmare/` says 28 of 30
common events compile; the two out are **20, "Sache benutzen"** (use a
thing: by the hero's map, cell and the item chosen, it sets the switch the
target's page waits for) and **14, "Menü 5 aktiv"** (the maps screen).
Both stop at `ControlVars` with operand 6, field 0 —an event's map id—
for the hero, `[0, 19, 19, 0, 6, 10001, 0]`; `degradations.json` has the
call of common 8 to 20 as `call-skipped`.

Played: the light bulb taken on map 23, the hero at the lamp on map 26
(11, 7) facing it, B, A on Inventory, A on the bulb: switch 6 (the
inventory) goes on and 242 —"the lamp now works"— never does. Every
puzzle of the game goes through 20.

The compiler leaves field 0 out on purpose (`VAR_CHARACTER`'s comment in
`compile.rs` of the event compiler): in RPG_RT it gives 0 for an event,
and A Blurred Line never asks; for the hero it is the map the party is on.

**To reproduce**: the stages `bulb` and `use_bulb` of
`~/scratch/huron/dn/stages.py`; captures in
`/shared/captures/2026-11-19-desert-nightmare/menu.png`.

## Taken (2026-11-20)

By Chajá, from Hurón's ranking in `desert-nightmare-what-it-takes-to-be-playable`. taro: "dale!".

## Work (Chajá, 2026-11-20)

From the-advocate `4f38ea03` and the ports `a34b393`, branches
`chaja-control-vars` in both.

**What the nine games ask of `ControlVars` and does not compile**, read
from each one's `culprits.json` (`rm2k-snes-events culprits` against the
`events-request.json` of its `release`, with the global tools of
`4f38ea03`), grouped by shape:

* **Operand 6, field 0, the hero's map id**: Desert Nightmare's commons 20
  and 14, five uses. The only operand-6 field missing in any game: nobody
  asks for the facing (3), nor for an event's map id; the event id (6) is
  the Maniac patch's.
* **Operand 7, "other"**: only Vampires Dawn, with 2 (party size, 6 uses),
  3 (saves), 5 (wins) and 7 (escapes); the variables they write (414, 415, 461,
  470) have slots past 255, the byte `OP_VAR` carries, so they would not
  compile for that reason either.
* **Everything else is not the operand**: Vampires Dawn's ~1,200 are its
  variables with a slot past 255 (468, 469…), past `OP_VAR`'s byte; Sunset's one and one of Vampires
  Dawn's set a **range** of variables (`[1, 1, 30, …]`, `[1, 1, 600, …]`);
  Zounds' one is a random of 500000 to 999999, past the word.

So the change is field 0, and only it: the hero's goes to the ROM, an
event's is RPG_RT 2000's constant 0 (easyrpg's
`ControlVariables::Event`, which says so). No new opcode: `OP_VAR` class 6
with `b` = 0, read from `map_rm2k` —the table `MemorizeLocation` already
uses—.

**The compiler test** (`the_heros_map_is_class_six_and_an_events_is_zero`
in `compile.rs`) was red before the change. **The ROM test**,
`tests/test_desert_nightmare_use_an_item.py` in the ports: the bulb
picked up on map 23, the hero below the lamp on map 26, switch 1 (the
menu's, which the intro turns on) set by hand, B, A, A —the menu draws
nothing, so blind—; red with the global tools at the same point Hurón saw:
variable 8 at 1 (the bulb chosen), 252 and 242 never.

**Culprits after** (with the branch's `rm2k-snes-events`, same requests):
Desert Nightmare's commons 28 → 30 of 30; the other eight games exactly as
before, as the scan said.

**Desert Nightmare then did not fit.** With the branch's tools the build
fails: "a piece of 23040 bytes needs a new bank, and the 126 banks … are
taken, even with the 1118 piece(s) that may go to the .msu". The cartridge
was already 126 of 126 since the painted pieces (0 B free but a 1,395 B
gap). What tipped it is not common 20 but **14**: it is an automatic
common with pictures, so `common_pages` copies it into 181 maps, and
until now its copy did not compile. Compiled, it is ~9 KB in every map's
bytecode (`map_code` 2,533 KB raw → 4,162 KB), which pushes the maps past
`LZ2_CAP_CODE` (`code_in_rom` in mapdata) and their code stays in the ROM
uncompressed: `map_code` in LZ2 went from 1,079.7 KB to 3.1 KB. Taking map
34 out of `painted_events` (38,400 B) did not make it fit either.

What the copy of 14 would draw is only its cursor, `Kartencursor`: its 40
maps are 320x240 pictures the console does not show ("its 40 big pictures
are not shown"). So 14 runs as the shared body, not copied: a new optional
knob, `[events] commons_not_copied`, read by the converter beside the
custom menus' and the counters' (absent = none), and `[14]` in Desert
Nightmare's `advocate.toml`.

With it Desert Nightmare builds (105 pieces, 1,037,034 B, to the `.msu`)
and **the ROM test is green**: the use runs as the game's script says
—common 20 turns on 252 and 12,
the menu closes (6 and 10 off), map 26's autostart on 252 changes the
lamp's picture to `Lichteffekt_Lager6_2` and turns on 242—. Captures of
the room before and after, ours only (EasyRPG was not replayed to that
point: it needs the bulb in hand), side by side in
`/shared/captures/2026-11-20-dn-use-an-item/`. The room is visibly lit after.

The finding about the room left is a draft:
[`desert-nightmare-the-cartridge-has-no-room-left`](desert-nightmare-the-cartridge-has-no-room-left.md).

**What is still not supported, and why it was not done** (none of it is
asked by a page that would compile otherwise):

* operand 6, field 3, the facing (8/6/2/4): no game asks;
* operand 6, field 6, the event id: the Maniac patch's;
* operand 7 (other) 2, 3, 5, 7 —party size, saves, wins, escapes—:
  only Vampires Dawn, eleven uses, whose target variables (414, 415,
  461, 470) are slots 413 to 469, past the byte `OP_VAR` carries, which is
  also what leaves out its other ~1,200 `ControlVars`;
* a range of variables as target (Sunset map 35, Vampires Dawn map 69):
  already in
  [`sunset-nine-pages-still-left-out`](sunset-nine-pages-still-left-out.md);
* a random past the word (Zounds map 2, 500000..999999): the 16-bit
  variables, `divergences/variables-saturate-at-16-bits.md` in the book.

**Done, to test (2026-11-20, Chajá).** Branches `chaja-control-vars` in
the-advocate (`b5e353b5` the field, `13d31d21` the knob, merged with main
`4d8f5157`), the ports (`06ea78a`, merged with `1b33f2f`) and the book
(`5c86fe4`, merged with `833d5ec`: the Known issue goes —its conflict
with Calandria's removal resolved by dropping both lines— and the
converter's stages name the knob). No new opcode. **To install when
merging**: `just install events convert` (the runtime change goes in
from the checkout).

Run on the merged tree with the branch's `events convert cartridge`:
`just test` 29 passed; `crate-test events` 200 + 13 passed, `convert` 69;
ABL's `just tests` 1722 passed, 2 skipped; `test_cores.py` 24 passed;
`just boot` 172 passed (with the new Desert Nightmare test).
`just space`: Desert Nightmare 126 of 126, a 4,436 B gap (1,395 before);
bank 0 of ABL's `release` 3,906 B (the field costs ~15 B of it), the
tightest cartridge's 3,866 B. ABL's `abl.sfc`: `03d2c1c3bb6045ab…`.

Not covered by any test: an event's map id (compiles to the constant
0, only the compiler test sees it); common 14 running as the shared body
—the maps screen is never opened by a test, and it draws nothing
anyway—; bsnes for the new ROM test; the console.
