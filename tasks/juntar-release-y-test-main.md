---
name: "Merge release and test-main"
description: "A single cartridge that gets played and runs the suite: what it costs, measured, and the space that rules"
type: refactor
status: done
---

# What

That `release` and `test-main` be a single cartridge: the one that gets
delivered, with title and timer, which also carries all the maps and the cases
of `pruebas/casos/`, turned off in the real save. `test-special` stays as it
is.

What follows was measured on 2026-09-25 on `d118bc8`, building in a worktree a
`release` with `--grupo 10`, `--map-id 4` and `cartuchos.py`'s `MAPAS`, with
the `--grafico-de-prueba` and with all the cases, and running the whole suite
with `PRUEBAS = RELEASE`. The numbers are from that day: whoever picks this up
measures them again, doesn't copy them (the method is at the end).

# Which difference is fundamental and which is configuration

| Difference | What it is | What was measured |
|---|---|---|
| `--grupo 10` | nothing | It's the default party (`system.json`: `party: [10]`): both cartridges start with 10, and 11 is set by the `grupo-11` case. |
| Title | harness configuration | With the title passed through "Begin the Story" before choosing the case, **zero goldens move**. What it requires is that `tanda.partida` pass `titulo=EMPEZAR` on the cartridge with a title, and that `reiniciar()` come back through "Resume the Story" (without that 13 "viaja en la partida" tests fail, which choose "Begin" on reset and start from scratch). And the two of `test_game_over.py` that expect the start after the GameOver: with a title the ROM goes back **to the title**, which is what RM2k does, so the test has to get past it. |
| Timer | configuration, plus **a real bug** | 14 goldens move with the timer on every map (the comment in `snes_convert.py` said fifteen, in 9f). 9 are small requantizations —from 2 to 166 pixels: `gemelo-20`, `gemelo-ruta-20`, `gemelo-fija-20`, `tram-200`, `tram-viaje-10`, `autos9-2`, `npc-diagonal-10`, `tram-26`, `puerta-8-9-120`—, because the digits' colors go into the palette allocation. The other **5 are a bug**: `sacudir-60`, `cerrar-400`, `cerrar-right-400`, `autocierre-63` and `autocierre-3-185`, map 7's door untinted on a tinted screen. See below. |
| Start map (6 against 4) | fundamental, but cheap | The cases live in event 0 of the start map. The 24 of `test-main` that don't start with a `Teleport` ran on 6, and in the merged one they run on 4: 27 goldens move, from 15 to 89%. **With a `Teleport` to 6, (50,50) —the cell where the hero landed—, in front of each one, all 27 go back to zero**: the harness already counts from the arrival. They are `anclada`, `animacion`, `animacion-dibujo`, `atravesar-sin-paso`, `grupo-11`, `pan*`, `rama-grupo*`, `ruta*`, `sacudir-fuerte`, `sacudir-lluvia`, `salto`, `switch-171`, `tropa-talan-aura`, `ventana-6`, `vuelta-ventana`. Map 4's cutscene doesn't interfere: none of the ~150 cases with a `Teleport` moved. |
| Test graphics | configuration | They go on the maps where a case runs, and that includes maps the walkthrough walks: even so **no golden of `release` moved** —walkthrough, title, scenes, stack, MSU-1, cores—. |
| Cases in the ROM that gets played | fundamental, small | See the next section. |
| Extra maps (52, 70, 73, 74, 119, 121, 133, 255, 261, 269, 348) | fundamental: space and patches | 282 KB in the cartridge, and `test_parches` requires everything that goes into the playable one to be versioned. |

## The cases in the ROM that gets played

Page 0 **asks for nothing** and always runs, on the start map, at the start;
page k asks for `VARIABLE_DE_CASO >= k`, and the game doesn't touch 1000. So
case 0 doesn't guarantee they don't run: **it's the one that runs**. Today it's
`grupo-11`, which puts Kersh in and breaks the opening. To turn them off it's
enough for `PRIMERO` to be `nada`, which already exists: the save then runs a
page that only turns on switch 1023 and turns itself off, and the others never
run. Measured: with `PRIMERO = "nada"` the tests that play all pass on the
merged one.

What's left, and isn't free:

* **The ROM taro plays carries the test pages and the test maps**, unreachable
  but inside: 3.75 MB against 3.01 MB of `release` today.
* **The cases' variables go into the index** —`datos.ranuras_de_variable`
  explains it—, so the layout of the game's saved data depends on which cases
  there are. A new case that names a new variable shifts the slots of the ones
  that come after it.
* The saved game carries switch 1023 on.

## The bug the timer uncovers

`tinte.s`, at the end of `tenir`, uploads the timer's palette untinted again,
and the comment says why: "the digits have a palette all to themselves". It
was true when it was written (`5be4ade`, 2026-09-04); since `034d721`
(2026-09-07) the digits **share** a palette with a character that has room, so
that character stays untinted. In the suite it shows on map 7's door. **It
happens today in `release`**, which carries the timer on every map: on any
tinted map where a character shares the digits' palette. It goes before
regenerating the remaining 9 goldens.

# Outside the suite

* `just entregar` and `just video` read `rom/build/release/` and don't break:
  the merged one comes out in the same place and with the same name.
  `test_msu` passes.
* `test_parches` fails: the eleven test maps go into the playable one without
  a versioned patch. Either they get versioned —`just parches` would copy them
  to `parches/`—, or `parches.revisar` learns which maps are test ones. It's a
  decision.
* **The build directory's patches aren't cleaned**: when building `release`
  again without the test maps, `rom/build/release/parches/auto/mapas/` still
  had `0052.toml` and the others, and `test_parches` failed because of that.
  Any cartridge that loses a map will have it; best to fix it along with this.
* `test_protocolo` and `test_ensamblar` are parametrized by cartridge: two
  cases fewer.
* Things that name `test-main`: `cartuchos.py` (5), `pruebas/README.md` (3),
  `justfile` (2), `test_guardar_save_point.py` (1, with `en="test-main"`),
  `la-carrera-en-release.md` (2). `conftest.py` asserts that `release` carries
  no cases. And `donde_esta` depends on the dictionary's order: with
  `test-special` first, `parado-tapado` —which is in both— ran on the small
  one and moved its golden.

# Space

| | `release` | `test-main` | merged |
|---|---|---|---|
| Bank 0 free (of 32,704) | 2,320 | 1,950 | 1,946 |
| `BSS` free (of 7,808) | 108 | 108 | 108 |
| `ZEROPAGE` free (of 256) | 3 | 3 | 3 |
| `FAR` free (of 32,768) | 11,179 | 5,489 | 5,489 |
| Cartridge used | 72% (98 banks) | 87.7% (120) | 89.6% (124) |

`test-special`: bank 0 2,644, 27.5% of the cartridge.

**What rules isn't bank 0: it's the cartridge.** `test-main` is already at
87.7%, and `el-cartucho-se-queda-en-4-mb.md` says it gets revisited at 85-90%.
Merging barely changes it (+1.9 points: the title and the timer), because
`test-main` already carries all of `release`'s maps; what changes is that this
89.6% becomes **the ROM that gets delivered**, instead of today's 72%.

## What takes up each region

**Bank 0**: 29,467 B are `CODE` —90%— and the converter emits only ~1,300 B of
`TABLAS` there. **It doesn't grow per map**: the difference between `release`
and `test-main`, with eleven extra maps, is 370 B, and it's all items (6 B
each: `item_id`, `item_precio`, `item_tipo`, `item_uso`), themes (4 B:
`tema_lo/hi/bk/msu`), faces (1 B) and 6 B of `ranura_bloque_*`. The per-map
tables live in their banks. If room is needed, what has to move is code; the
heaviest: `paginas_de_eventos.s` 2,295, `oam.s` 1,261, `rutas_de_eventos.s`
1,235, `menu.s` 1,188, `paquete_de_audio.s` 1,157, `tinte.s` 1,131, `items.s`
1,044. The natural candidates are screens that don't run with the map, as
was already done with the shop and the equipment in `FAR`: `menu.s`,
`items.s`, `ranuras.s` (884), `titulo.s` (422), `pantallas_de_texto.s` (264),
about 3.8 KB.

**`FAR`**: 10,729 B are converter tables —`mensajes_tropa` 5,065,
`tropa_codigo` 4,541, `tpag_*` 1,000— and **they grow with the troops** the
maps ask for; the rest is the code of the battle, the shop, the equipment and
the level. In the merged one 5,489 are left: Lashe City's battles will eat
from there.

**`BSS` and `ZEROPAGE`**: they don't depend on the maps, they depend on the
code, and they're at the limit: 3 bytes of zero page. The big things in `BSS`
are `texto_buf` 1,968, `npc_buf` 1,664 (`NPC_MAX × NPC_STRIDE`), `oam`,
`cgram_sombra` and `pal_buf` 512 each, `ev_pos_buf` 480; the place to move them
to is `ram_lejana`.

**The cartridge** (merged, 3.76 MB used): `tema_stream` 789 KB (21%),
`anim_batalla` 561 KB (15%), `map_tiles` 470 KB (12.5%), `sprite_poses` 375 KB
(10%), `sprite_tiles` 295 KB, `map_celdas` 285 KB, `muestra` 269 KB, `fondo`
98 KB, `battler` 77 KB, `mensajes` 66 KB. There are also 312 KB scattered
inside half-filled banks, which only serve for small pieces.

**How much a map weighs**: adding up what carries the map's suffix (tiles,
cells, blocks, sprites, poses, events, NPCs), the game's 29 average 39.5 KB
—from 16 to 69 KB—, without counting the music or the new battle animations
they bring. In the merged one ~436 KB are left: **about ten average maps**,
and fewer if they bring themes (~25 KB each) or animations. The eleven test
maps weigh 282 KB together; knowing which test needs each one is the other
lever.

# Time

| | three cartridges (today) | two (merged + `test-special`) |
|---|---|---|
| `cartuchos`, cold cache | 177 s (137.7 + 12.7 + 27.0) | 149 s (136.8 + 12.4) |
| `cartuchos`, warm cache, everything rebuilt | 114 s (76.4 + 12.4 + 24.9) | 97 s (83.9 + 12.9) |
| pytest of `just pruebas` | 61 s, 623 cases | 57 s, 621 |

The MSU-1 tracks add 71 s cold to either. Touching `rom/src/` rebuilds all of
them, so the typical round saves about 17 s.

# Recommendation

**Merging is worth it, in the "`release` is the merged one" form**: a
cartridge with title and timer, `--map-id 4`, all the maps, the cases with
`PRIMERO = "nada"`, and the harness getting past the title on its own. What it
costs, measured:

1. fixing the tint of the timer's shared palette (a bug today, merging or
   not);
2. a `Teleport` to 6 in front of 24 cases —zero goldens—;
3. in the harness, the automatic title and the reset through "Resume" —about
   ten lines—, and the two GameOver tests getting past the title;
4. regenerating on purpose the 9 goldens the timer requantizes;
5. deciding what `test_parches` does with the test maps, and cleaning the
   build's stale patches;
6. renaming what says `test-main`.

**Before Lashe City**, because the cost in goldens is small —14, and 5 of those
are a bug that has to be fixed anyway— and it grows with each map added on
top of two different configurations. But **space comes before both**:
`test-main` is already at 87.7% and each new map goes into every cartridge, so
Lashe City runs into the 4 MB with or without merging. Merging only makes the
collision show in the ROM that gets delivered. The order that comes out of the
numbers is: the tint bug, the space (where the weight is: music, animations,
tiles; and which test maps can be removed), merging, Lashe City.

**The intermediate variant** —`test-main` with the same configuration as
`release` but staying separate— costs almost the same: the timer (14 goldens)
and the title (harness, GameOver), without the `Teleport` if it keeps starting
on 6. It leaves the delivered ROM clean (72% and with no test pages) and keeps
the three cartridges. It makes sense **only if it's decided that the ROM that
gets played can't carry the test maps and pages**; if that doesn't matter, it
saves nothing worth two cartridges.

# How it was measured

The space comes from `ld65`'s `.sym`/`.dbg`: the segment sizes, and what each
label takes up by adding the `span`s that have a source line. `FAR`'s free
space is the padding of the `.align` that closes `cabecera.s`. Bank 0 agrees
with AGENTS.md's `.res` method. The times are from a worktree with
`rom/build/` empty (cold) or with the cache full and the cartridges deleted
(warm), with another agent using CPU at the same time.

# What was done (2026-09-25, in progress)

taro decided to merge in the recommended form: `release` becomes the merged
one and `test-main` ceases to exist. `test-special` stays.

Before starting, on `cfb100e` (with the tint already fixed and the lightweight
fallback in): `just cartuchos` cold 266 s —`test-main` 154, `test-special` 13,
`release` 28 and the MSU-1 tracks 71—, and `just pruebas` 632 cases green.

1. The `Teleport` to 6 in front of the 24 cases that ran on the start map:
   separate commit, 632 green, no golden moved.
2. The converter empties `rom/build/<cartucho>/parches/` before writing (closes
   `el-conversor-no-limpia-los-parches-viejos.md`).
3. `donde_esta` no longer depends on `CARTUCHOS`'s order.
4. `parches.revisar` knows what's a test thing: the maps come from
   `cartuchos.MAPAS_DE_PRUEBA`, and for the animations and the battlers —91
   and twelve battlers exist only because of the test maps or a case, which
   the measurement hadn't seen— the converter leaves an unversioned
   `usos.json` with who asks for each one.
5. The merge: `release` carries all the maps and all the cases, with
   `PRIMERO = "nada"`; `test-main` no longer exists. The harness gets past the
   title on its own (`Cartucho.titulo`), `reiniciar()` comes back through
   "Resume" and the two GameOver tests get past the title. The "no title"
   control of `test_guardar_save_point` was lost: there's no ROM without a
   title left that reaches 8.

Measured at the merge:

* **36 goldens of 9 tests** move, all because of the timer (side by side in
  `/shared/goldens/2026-09-25-juntar-cartuchos/`). The five of map 7's door no
  longer do, thanks to `c3910f4`. The new thing is what the earlier `release`
  already drew: map 9 comes out identical pixel by pixel in both ROMs.
* **Saves made with the earlier `release` don't work in the merged one.**
  `PARTIDA_BYTES` goes from 1850 to 1868: one more variable (the case one,
  which goes last, so the game's ones don't shift) and four more `EXP_K`
  entries (the test maps' troops). Everything after the variables shifts two
  bytes. With the SRAM snes9x leaves behind the save (bytes `$60`) the checksum
  doesn't add up and the save **doesn't load**; with zeros behind it the
  checksum adds up anyway and it **loads corrupted**: inventory, HP, SP,
  equipment, graphics and skills shifted. And the format will keep changing
  every time a case names a new variable or brings a new troop, because now
  the cases are part of the ROM that gets played.

Then, on the branch with `main` merged (`4d33549`):

* `just pruebas`: 640 green. Without `main` it was 633: the 632 from before,
  plus three new tests (stale patches, `donde_esta`, `de_prueba`) and minus the
  two cases of `test_protocolo` and `test_ensamblar` that were parametrized by
  `test-main`. `test_cores.py` green three times.
* `just cartuchos` cold: 235 s —`release` 150, the tracks and `test-special`
  85—, against 266 before. The `gunter` on the PATH changed in the middle of
  `test-special`, so that stretch isn't clean.
* Space, adding up the `.dbg`'s segments: `release` goes from 70.9% to 86.5%
  of the cartridge (last bank $76); `test-main` was at 86.6%. The study gave
  89.6% for the merged one with another method and before the lightweight
  fallback.

# What's left for taro

* Look at the 36 goldens in `/shared/goldens/2026-09-25-juntar-cartuchos/`
  before the merge.
* Play the ROM: it starts as before (the walkthrough, the title and the scenes
  pass), but now it carries the test pages and maps inside.
* **Earlier saves don't work**: see above. If it matters, what's missing is
  for the save to carry its size or a version and for the ROM to reject the
  ones that aren't its own; today, with zeros behind it, it loads a corrupted
  one.
