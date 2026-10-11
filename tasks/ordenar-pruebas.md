---
name: "Tidy up pruebas/"
description: "The tests' bugs, the helpers to arnes/, the organization and a prose pass, in four jobs"
type: refactor
status: done
---

**What a review of `pruebas/` found on 2026-09-25, against `43bd1aa`.** Decided
with taro: it's done **after the MSU-1 change is merged** —which touches
`tools/emulador/retro.py` and the harness—, and in three separate jobs, in this
order. The line numbers are from that commit: verify before touching. **All
four are done.**

## 1. The bugs — done on 2026-09-25

What each one was and what was done. The goldens that changed are side by side
in `/shared/goldens/2026-09-25-pruebas-bugs/`, with their `LEEME.txt`.

- **`ev41` was badly set up, not the ROM.** EV0041 is on the lower layer, and
  those are talked to **from their cell** (`CheckEventTriggerHere`); from the
  front only those on the hero's layer (`CheckEventTriggerThere` asks for
  `Layers_same`, in easyrpg-player). The case put it at (52,24) facing
  (52,23): measured with a temporary case, from the front the page never runs,
  same as in RM2k, and its screenshots are byte for byte the old goldens. Now
  it starts at (52,23), the page runs and the route ends at (55,18), which is
  its `MoveEvent`'s count. Ticks 30/60/108/200: message, going up, jump,
  arrival (120 came out the same as 200 and was removed).
- **`varios-18-down` wasn't the ROM either**: map 19's `RunDirectorScene` is
  an autorun without conditions, and it compiles since its messages compile
  (`6cfce1e`); in RM2k the hero doesn't walk while it runs. `down` now uses
  `grupo-11-en-19-sin-escena`, with switch 90 which leaves the map after the
  scene, and walks the plan's five cells. `none` stays the same.
- **`plan-73`, `plan-17` and `plan-8` going down are correct**: the plan says
  zero cells and it's true —a wall on 17 and 8, the Receptionist at (15,7) of
  73—; that the snapshot is the standing one is what proves the collision.
- **The walks now look at RAM**: `test_heroe` and `test_varios` require the
  hero to have walked the plan's cells (`tanda.celdas_del_plan`,
  `Partida.heroe`). Except when it changes map —8 to the right steps on the
  door to 16, which the reference didn't model—.
- **`ruta-vel` / `ruta-vel-lenta`**: besides the golden, `BAJO_EN_EL_TICK`
  asks for the hero's cell and speed on the ticks that are byte for byte
  `6-none`. They weren't moved to another map: it would have changed thirteen
  goldens.
- **The identical-screenshots check**: `conftest._capturas_distintas` fails
  if all of a test's goldens are the same screen. The ones that were so on
  purpose are in `MISMA_PANTALLA` with their why.
- **`test_los_largos_de_opcode_cuadran_en_todo_el_juego`**:
  `paginas_del_juego` fills every index the converter fills, not only the
  variables one. The game's `skipif` moved to that test, which is the one that
  reads it.
- **`test_paginas`** restores `VARIABLE_SLOT` even if the assertion fails.
- **`test_parches` looks at `release`**, and requires it to be built. The
  section of `UNTESTED.md` that said it didn't went away.
- **`ABL_GAME_DIR`** in `test_timer_paleta` and `test_destello_paleta`, via
  `render_map.GAME_DIR`.

The suspects:

- **`Partida.reiniciar` didn't restore `llegada` nor `hardware`: confirmed.**
  A `correr(10)` after a reset ran 81 ticks in `guardar-198`. The three resets
  now go through `_resetear`, which sets them to zero.
- **"Viaja en la partida" depended on WRAM: half confirmed.** snes9x's reset
  leaves WRAM as it was and the ROM doesn't clear it entirely, so a value the
  load didn't restore stayed there. `_resetear` overwrites it with `$55`
  first. With that the tests that reset stay green: today none was passing
  because of that.
- **`test_piedras` and the fork: ruled out.** `lcf.Map` on `GAME_DIR` reads
  the `data/` dump with the fork on top (34 events, the original has 84).
- **The walkthrough snapshots by sequence number: confirmed and covered.** A
  snapshot without a golden still doesn't fail, on purpose; but if its
  milestone has a golden with another number, it fails saying the numbering
  shifted.
- **The seven black goldens: ruled out.** The four `puerta-*-40` and
  `manta-2800` are halfway through a fade (`fundido` = 1), `cartel-880` is the
  image already erased over map 4, which is black, and `saturar-120` is the
  tint to black that the case asks for.

What was left uncovered: the seven snapshots of the `vipers` walkthrough don't
have goldens, so they always pass until taro blesses them; and he has to look
at the new goldens of `ev41` and `varios-18-down`.

## 2. The helpers to `arnes/` — done on 2026-09-25

One commit per topic, each with `just pruebas` green; the detail and what was
measured is in each message. What remained and where to look for it:

- **No test imports from another.** The harness grew: `menu.py` (opening and
  pressing the menu, `GRUPO`, `ORO`), `batalla.py` (`Pelea`, the droid, losing
  without fighting, `sabe`), `datos.py` (what's read from the original game:
  the base, the System, `maximos`, `pagina_de`, `DEMO` and the cartridge's
  variable and skill indices), `dibujo.py` (`comparar_pantalla` against
  `titulo.render_*`) and `piedras.py`. `LINKAGE` is in `tanda.py`,
  `UN_ANO_DESPUES` in `recorrido.py`, `EMPEZAR` and `SEGUIR` in `consola.py`.
  The only exception is `video.py`, which imports `test_recorrido` to run its
  playthroughs, on purpose.
- **`arnes/lcf.py` is called `datos.py`**: a bare `import lcf` has to fail
  —`tools/README.md`, "Cómo se importa"— and an `lcf` in the harness would
  make it work with another module.
- **There's no session fixture for the base and the skin**: they're
  `datos.base()` and `datos.skin()`, cached, because almost all the reads were
  inside helper functions that can't ask for fixtures.
- **The variable slots were counted in five ways** and they weren't the same
  count; the converter's stays. Before unifying, what each test asks for was
  compared number by number: they gave the same.
- **`Pelea.modo()` answers the name** of the mode (`"ORDEN"`, `"FIN"`), from
  the symbol table. The `b"ABLS"` mark stays written, once (`consola.MAGIA`):
  the ROM doesn't have it as a symbol.
- **`tocar` still has three clocks** —`Partida.tocar` in ticks, `menu.tocar`
  and `Pelea.tocar` in frames with different spacing—: unifying them changes
  when each press lands. `menu.tocar`'s docstring says so.
- **New `Partida` methods** for what was copied around: `evento`,
  `oro`/`poner_oro`, `equipo`, `hay_partida`/`magia`,
  `celdas_mal_dibujadas`.
- **Three cases that ran the same as another were deleted** —`batalla-segunda`,
  `tabla` and `ventana-7-y-269`, with their goldens and the last one's JSON
  case—: the goldens were byte for byte those of the case that remains.
- `test_teleport.py` now lives at the end of `test_protocolo.py`; the
  screenshots of `test_cores` go to `pruebas/snapshots/cores/`.

## 3. The prose pass — done on 2026-09-25

One commit per area —`arnes/`, `rpgmaker/`, `abl/`, `herramientas/`,
`UNTESTED.md` and the goldens' `LEEME.md`, and what's outside `pruebas/`—,
each with `just pruebas` green; what was removed, what was fixed and what was
left on purpose is in each message. Before that, the index:

- **`pruebas/README.md` has an index by system** of all the `test_*.py`, the
  naming convention and what to do when each kind goes red.
  `herramientas/test_indice.py` guards it: it fails if a test file isn't named
  there, or if the README names one that doesn't exist. What it can't guard is
  that each one's description is true.
- **Prose that contradicted the code**, besides what the review listed
  (`PASO_TOPE`, the 8 KB that are 32, "there's a single voice", the three
  things that were two): `Partida.tocar` and `sostener` said `correr` only
  knows about A; `test_textos` said the converter doesn't call the function
  its last case checks it calls; `test_un_ano_antes` said there's no menu;
  `test_condicional`, that the branch that runs can't be tested with a game
  page because of a switch order that `Partida.prender` already solved.
- **They stay**, even though they tell history, the whys that protect a line:
  the four the review named and others by the same criterion —the `inc a` of
  the escape permission, `vueltas` and not `mapa_actual` after the Game Over,
  `nmi_boot` and the fourth slot, the SRAM that passed vacuously—, and the
  numbers an assertion pins on purpose (`test_cuantos_mapas`, the 123 slots of
  `test_paginas`).

What was left undone:

- `AGENTS.md` still cites the glob `pruebas/*/test_tanda*.py` in "Repartirles
  los números de antemano"; today it's `pruebas/*/test_*_golden.py`. This
  pass's sub-agent didn't touch it because it's the agent's instructions file.
- `workflow/tasks/done/` and the logs of what was run in `wishlist/` keep the
  old names, on purpose: they're history.

## 4. Organization — done on 2026-09-25

Four proposals taro approved, each in its commit and with `just pruebas`
green; what was measured is in each message. Done **before** 3, so the prose
has to take this into account too.

- **The save's HP and SP**: `Partida.hp` / `poner_hp` / `sp` / `poner_sp`, on
  `FAR_HP` and `FAR_SP`. The battle's are something else —the `BA_UNO` slot
  per combatant position— and stay in `Pelea.hp_del_combatiente` /
  `sp_del_combatiente`. `palabra_de`, `hp_guardado`, `sp_guardado`, `hp_de`
  and the two test `poner_hp`s went away.
- **`apertura`'s 370** was byte for byte `cinematica`'s, from the same run: it
  went away from `apertura`, with its golden. The why of which one, in the
  commit.
- **Map 11** is read in `piedras.mapa11()` / `eventos_del_11()`, from
  `GAME_DIR`: compared field by field, it's the same thing the two read.
- **The names**: `test_<sistema>[_<detalle>][_golden|_dibujo].py`. The suffix
  says what the screen is compared against —the goldens of `pruebas/golden/`,
  or what `tools/port/` draws—; without a suffix, the test looks at state or
  doesn't run a ROM. Why a suffix and not a prefix or a folder, in the renames
  commit. `test_tanda_pantallas` was split into `test_batalla_golden`,
  `test_menu_golden`, `test_guardar_golden` and `test_titulo_golden`, and its
  `test_espera` moved to `test_comandos_golden`.

For 3:

- **The prose citations of the old names weren't touched**: the renames commit
  is only that plus `video.py`'s import. They're searched for with the old
  names —`test_tanda`, `test_tanda_*`, `test_menu`, `test_items_pantalla`,
  `test_equipo`, `test_curar_menu`, `test_hp_de_batalla`, `test_tienda`,
  `test_titulo`, `test_experiencia`, `test_escena`, `test_recorrido`,
  `test_recorrido_vipers`— as a whole word; the glob `pruebas/*/test_tanda*.py`
  appears in `AGENTS.md`, the `justfile` and several headers, and today it's
  `pruebas/*/test_*_golden.py`.
- `pruebas/README.md` has no test index; the inventory by type and by system
  that 4 built is useful for making it.
- `herramientas/test_pila.py` runs the ROM, and the README says `herramientas/`
  are the ones that don't. It wasn't moved: it's a folder decision, not a
  naming one.
- Two golden counts went stale because of the 370: "the seventeen" of the
  tombstone at the end of `test_titulo_golden.py`, and "the six of
  `apertura`" in `test_escenas_golden.py::test_cinematica`, which are now
  five.
