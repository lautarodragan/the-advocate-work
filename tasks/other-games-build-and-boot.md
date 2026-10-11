---
name: "The other games build and boot"
description: "A recipe that builds the seven games from their toml and boots them up to the first map, in snes9x and bsnes; and some goldens of Sunset's painted maps, the only engine path that no test runs"
type: feature
status: testing
agents: [Cardón]
assignee: taro
---

taro, on 2026-10-11, approved the proposal: tests of the other games,
but few.

1. **That each game builds from its `rm2k-snes.toml` and boots.** Today a
   change in the tools can break Vampires Dawn or Book of Three
   and nobody finds out until the next survey. Red if it does not build or if
   it does not reach the first map; along the way, the same cartridge in snes9x and bsnes
   (uninitialized memory in code that ABL does not run). It does not go in
   ABL's `just pruebas` —VD alone takes ~2 min to build—: it is a separate
   recipe, for before delivering or after a big change.
2. **Goldens of Sunset's painted maps** (`[graphics]
   painted_maps`, `Way::Painted`): the plaza (2) and the bar (28), still and
   walking. ABL has no painted maps.

What **not**: goldens of screens or walkthroughs of each game (they bake in
birth errors and multiply what has to be looked at), nor tests of
mechanisms with a game as the stage (that belongs to the crates or to the test
game, phase 2).

## Cardón's log

Base: the-advocate `fc6f7456` (global tools, untouched), ports
`1353abc`. Branch `cardon-otros-juegos` in `~/scratch/cardon/ports`; book
`cardon-otros-juegos-arrancan` in `~/scratch/cardon/docs2`. Exploration
scripts in `~/scratch/cardon/explorar/`.

### Where it lives and how it is run

A new `justfile` at the root of the ports, which imports `maquina.just`, with
`just arrancan` (whatever is passed goes to pytest: `just arrancan -k sunset`).
The tests, in `pruebas/` at the root: `juegos.py` (the harness),
`test_arrancan.py`, `test_pintados.py` and `golden/`. From ABL's harness only
`emulator/retro.py` is used (via `pythonpath` in `pruebas/pytest.ini`): the
rest imports `lugares.py`, which pins ABL's project and asks for its
`GAME_DIR`. The cut to 15 bits moved to `retro.fifteen_bits`, and
`tanda.quince_bits` calls it. Each game is built with its own
`just cartuchos`, **without the outside `GAME_DIR`** (if it came inherited,
it would build with another game's resources). It does not go in ABL's `just pruebas`.

### How it decides "it reached the first map" (measured 2026-10-11)

* Title: A is pressed every 16 frames until `ticks` stops being zero
  (the main loop started). ABL's single press —30 frames of air and
  an A— was lost in Dooms 2 and El Dorado. Without a title (`TITLE_TILES` at
  zero) nothing is pressed.
* Afterwards, **by ticks and not by frames**: A on one tick out of 16
  while there is a page (`ev_active`), fade, message or menu. By frames,
  El Dorado arrived 5 frames earlier in bsnes; by ticks both cores
  arrive on the same tick with the same screen.
* Control = 30 ticks in a row without `ev_active`, `fade`, `msg_open` or
  `menu_open`. There it requires: the measured map (`PRIMER_MAPA`), a screen with more
  than one color, and that the hero walks some way (24 ticks per side).
* Hung: a tick that does not arrive in 3000 frames (the longest load measured,
  ~200 frames in El Dorado).
* The two cores: same (tick, map, hero, side) and identical captures at 15
  bits on arriving and after walking.
* MSU-1 only for VD (`[rom] msu = "required"`); the others without, which is
  what is played.

Result, per game (control at tick, map):

    book-of-three        3054   2
    desert-nightmare    10138  16   (map 1's own menu: "With Intro")
    dooms2               1934  15
    el-dorado            1108   2
    frozen-world         2682   9
    sunset-over-imdahl   8442  10
    vampires-dawn         490   4   ("Skip Intro ?" by the first option)

The seven build and arrive, identical in snes9x and bsnes. Building from scratch,
serially: BoT 13 s, DN 55 s, Dooms2 13 s, El Dorado 5 s, Frozen 20 s,
Sunset 33 s, VD 132 s. `PRIMER_MAPA` is what the port reaches, **it is not
compared against RM2k**.

### Sunset's goldens

Plaza (2) and bar (28), still on the cells of Mulita's captures
—(28,10) and (4,11)— and walking three cells to each side with the shot at
the middle of the third step: plaza from (25,17), with the camera moving in
all four; bar from (10,9), where the camera has almost nowhere to go.
It gets there by playing the intro and with the door jump (`ir_al_mapa` like
ABL's): it is the `release`. It requires `PAINT_ON` = 1, the "painted" record
in the `.inc`, that the hero walks 48 px to each side and, in the plaza, that
the camera moves. snes9x and bsnes against the same golden, at 15 bits: they come out
equal. Side by side in
`/shared/capturas/2026-10-11-los-otros-juegos-arman-y-arrancan/`.

**Findings** (not fixed, they belong to the engine):

* In a painted map the events "above the hero" are drawn **over the
  roofs**: the objects go up one step in mode 1 (`oam.s`), and "above"
  ends up at priority 3, over high BG1. In RM2k the pictures (the
  roofs) go above everything (easyrpg: `Priority_PictureNew` >
  `Priority_EventsFlying`). It shows with the DummyGuard (13,23) of map 2,
  walking from (15,20). Not compared against the original with Wine.
* A normal-layer guard (event 8, (36,13) of map 2) with its legs
  over the edge of the orange roof. Probably an edge of those that do not
  fit in the 127 (Mulita's debt); I did not check it.

The walks are chosen so that neither of the two ends up in a
golden.

### Red checked (by hand, and reverted)

* `start_map = 999` in Dooms 2's toml: "dooms2 no arma", with the output.
* `TOPE = 300`: "300 ticks tocando A y el jugador no tuvo el control".
* El Dorado waiting for map 3: "tiene el control en el mapa 2 y no en el 3".
* One pixel of a golden touched: "difiere de su golden en 1 de 57344".
* What was **not** checked in red: that the two cores differ (it would need
  a ROM that reads uninitialized memory); the comparison is the same as
  `test_cores.py`'s.

### What it does not cover

* Whether the maps look right (on purpose), except the two painted ones.
* What happens after the first map, battles, menus, saving.
* The other options of the intros' questions ("No Intro", etc.).
* That `PRIMER_MAPA` is RM2k's.

### To merge

Branches: ports `cardon-otros-juegos` (`b94b479` the harness and the recipe,
`a85b7e3` the goldens; `origin/main` 1353abc already inside), book
`cardon-otros-juegos-arrancan` (`29a5114`, a section in `testing.md` and
a line in `contributing/README.md`). Nothing to install: it does not touch the
tools.

On the branch, with the global tools (`fc6f7456`): `just arrancan`
**8 passed**, rc 0, 106 s with the cartridges already built (Dooms 2 was
rebuilt); from scratch it adds ~270 s of building. ABL's suite **1203
passed**, rc 0, and `abl.sfc` `27d989db75901791…`, the same as main.
