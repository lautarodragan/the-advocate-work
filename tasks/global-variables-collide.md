---
name: "Global variables collide"
description: "Two branches that add a variable at the end of pagina_cero.s, ram_baja.s or ram_lejana.s always collide"
type: refactor
status: done
agents: [Carpintero]
assignee: taro
---

The `main.s` split spread the code out by subsystem, but memory is still
declared in three global files: `rom/src/pagina_cero.s`, `ram_baja.s` and
`ram_lejana.s`. Two branches that each add a variable add it at the end of
the same file, and they collide there even if they work on subsystems that
have nothing to do with each other. Seen by the split's critic, on 2026-09-25.

To investigate before deciding:

* whether each subsystem can declare its variables in its own file with
  `.segment "BSS"` / `"ZEROPAGE"` and go back to its own —the order in RAM
  changes, and that changes the ROM and the `.sym` files: measure which tests
  notice—;
* which variables have to stay together or in a fixed order (those cleared
  as a block, those saved in the save file —`partida_tabla`—, those the
  symbol table exports to the tests by name);
* whether something cheaper is enough, like leaving padding lines per
  subsystem or an alphabetical order that spreads the additions.

And far RAM has a trap of its own, which `AGENTS.md` names in
"Sub-agentes": its addresses are chosen "the next free one", so two
branches can choose the same one without git seeing it. Whatever is decided
here should close that too.

## What was decided (Carpintero, 2026-10-11)

**RAM is no longer chosen by hand, and a new variable goes in its
subsystem's file.** The three files keep what they have; what changes is
where the next one goes.

* **Far RAM gets a linker segment, `FARBSS`**, in a `FARRAM` area of the
  `.cfg` that `rm2k-snes-assemble` writes —`FAR_POOL_START` and
  `FAR_POOL_SIZE` in `rm2k-snes/cartridge/src/banks.rs`—. A new variable is
  `.pushseg` / `.segment "FARBSS"` / `name: .res n` / `.popseg` in the file
  of its subsystem. The linker places it: two cannot overlap, and when the
  area is full the link fails. The segment is declared `far` at the top of
  `far_ram.s`, so its labels carry bank `$7E`: a plain read is a long
  access; code with the data bank at `$7E` and `save_table` lines take
  `.loword(name)`; a use before the declaration (in `main.s` order) fails
  the link with a range error and goes with `f:`.
* **The area is $7E66C0–$7E67FF**, the unused end of the battle scene's
  reservation; `battle_scene.s` asserts its state ends before it. Far RAM
  is otherwise packed: $7E2000–$7E7FFF is a hand-written map with only
  small gaps, the upper half of `$7E` is the grid and `$7F` is time-shared
  by the battle and the loads. `just espacio` prints what the area has left
  ("far RAM"). It grows by taking over another stretch of the hand-written
  map and moving whatever lived there into `FARBSS`.
* **The hand-written map stays where it is**, to not move the ROM: the
  infrastructure commit leaves all six ABL ROMs byte for byte equal.
  `MAP_SONG` moved into `FARBSS` in its own commit, so the suite runs the
  new path (16 bytes change per ROM, no golden moves, the save is
  untouched).
* **The far-RAM trap is closed by a test**: ABL's
  `test_reservas_de_la_wram.py` fails if any symbol that is not a
  `FARBSS` label lands in the area, as a long or a 16-bit value. Shown red
  with a `HAND_PICKED = $7E66C0`. `test_espacio.py` checks the new "far"
  measure against a linked `.res`.
* **BSS and ZEROPAGE** were already linker-placed: the rule is only that a
  new one goes in its subsystem's file with `.pushseg`/`.segment "BSS"`,
  said at the top of `low_ram.s` and `zero_page.s`. Moving the existing
  ones was not done: it moves the ROM, some lines are saved or cleared as
  blocks (`party, 6` in `save_table`), and it gains nothing against
  collisions, which come from additions.
* Padding lines or an alphabetical order were discarded: they spread the
  textual collisions but leave the far-RAM addresses chosen by hand.

Found on the way and fixed: `FAR_GROWTH` asserted against `CARRY_MAP`
while the panorama took $7E7E00 a day later; a game with more than 21
experience slots would overlap the panorama silently. The assert now looks
at `PANO_ON`.

What the suite does not cover: the hand-written map overlapping itself
(only the `.assert`s that already exist guard it), and a branch that writes
a far address by hand **outside** the `FARBSS` area: the test only looks
inside it.

When merging: reinstall `cartridge` (`just install cartridge`). It writes
the `.cfg` with `FARRAM`/`FARBSS`, and `rm2k-snes-space` and
`--memory-map` report the area; without it the runtime does not link,
because `far_ram.s` imports `__FARRAM_START__`, and ABL's new tests fail
for lack of `far_pool`. Branches: `carpintero-variables` in the-advocate,
the-advocate-ports and the-advocate-docs.

**A branch that added a far variable the old way** (`FOO = $7Exxxx` chosen
by hand) fits by replacing that line, in its subsystem's file, with
`.pushseg` / `.segment "FARBSS"` / `FOO: .res <bytes>` / `.popseg`. Then:
uses after the declaration stay as they are if they were long (`f:FOO`, or
plain with the long constant); uses with the data bank at `$7E` and lines
of `save_table` become `.loword(FOO)`; a use in a file included earlier
than the declaration needs `f:`. Fields written as `FOO + n` keep working.
If the address was 16-bit (`FOO = $xxxx`, used with the data bank at
`$7E`), it can keep its name as `FOO = .loword(foo)` over a lowercase
`foo:` label, as long as no `.if` or `.res` needs it at assembly time. A
bank-0 variable added at the end of `low_ram.s` or `zero_page.s` can stay
there —two appended lines are a plain conflict— or move to its subsystem's
file inside `.pushseg` / `.segment "BSS"` / `.popseg`.
