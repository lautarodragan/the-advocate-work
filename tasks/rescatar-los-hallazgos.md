---
name: "Rescue the findings"
description: "Read the tasks in testing/ and move to tasks/draft/ the findings that were left loose —unfixed errors, uncovered paths, 'the next thing, measured'—, and to each port's 'Known issues' what is seen while playing"
type: docs
status: testing
agents: [Calandria]
assignee: taro
---

taro, on 2026-10-11, created the `draft` status (see this repo's README and
"Un hallazgo que no se arregla" in `AGENTS.md`). The findings from before
stayed in the agents' tasks; this one rescues them. The example of the
format is `los-eventos-encima-del-heroe-sobre-los-techos-pintados.md`,
and the one for "Known issues", Sunset's page in the book.

## How it was done (Calandria, 2026-10-11)

The 60 tasks in `testing/` were read. Each finding was checked against today
—the-advocate `fc6f7456` (the global tools), ports `a85b7e3`,
book `f6e8d57`— with `git log`, the later tasks and the code. For
those of the other games, the release of Frozen World, Desert
Nightmare, Dooms 2, Book of Three, El Dorado and Vampires Dawn was built in a
worktree of the ports of its own (without commits), and where a map was
excluded it was returned to see today's stop (Dooms 2 map 1, Frozen
maps 1 and 2, VD without the `system` knob). The one-off scripts, in
`~/scratch/calandria/tmp/`.

## New drafts (17)

* `los-comunes-paralelos-no-corren` — from `el-tablero-contra-rm2k`.
* `el-lider-y-los-renombrados-en-los-mensajes` — from `el-nombre-del-heroe-en-los-mensajes`.
* `lo-que-se-funde-en-las-pantallas-no-va-a-los-parches` — from `la-ventana-con-mas-colores` and `la-ventana-en-el-banco-de-tiles`.
* `las-ranuras-y-el-menu-de-dooms2-no-entran` — from `las-exclusiones-que-sobran`, `la-ventana-en-el-banco-de-tiles` and point 4 of `degradar-en-vez-de-fallar`.
* `el-heroe-que-destella-comparte-paleta` — from `las-exclusiones-que-sobran` (Frozen 1).
* `los-flujos-de-un-mapa-que-no-entran-en-la-wram` — from `las-exclusiones-que-sobran` (Frozen 2) and `vampires-dawn-arma-desde-su-toml` (VD 1).
* `los-mapas-de-vampires-dawn-que-no-entran-en-la-vram` — from `vampires-dawn-arma-desde-su-toml`, `una-cuantizacion-por-personaje` and `fusionar-tiles-parecidos`.
* `vampires-dawn-con-su-system` — from `la-ventana-en-el-banco-de-tiles`: **it already builds with `VDBlutsys`**, measured today.
* `las-paredes-invisibles-que-se-pierden` — from `los-eventos-que-no-entran-en-la-ram`.
* `las-imagenes-sobre-el-mapa-fuera-de-sunset` — from `eraseevent-de-verdad` (Desert's WC).
* `el-titulo-que-no-entra-en-la-vram` — from `degradar-en-vez-de-fallar` (Desert, Frozen, VD).
* `las-variables-que-pasan-de-256` — from `degradar-en-vez-de-fallar` (VD).
* `los-bordes-de-techo-que-no-entran` — from `sunset-en-modo-1-con-color-math` and `los-otros-juegos-arman-y-arrancan`.
* `la-camara-que-vuelve-sobre-una-fila-a-medio-subir` — from `sunset-en-modo-1-con-color-math`.
* `textos-que-quedaron-viejos` — from `el-libro-docs-y-ports` and `el-justfile-mas-chico`.
* `una-pelea-con-el-grupo-vacio` and `borrar-un-evento-sin-prueba-de-lo-que-se-ve` — coverage, from `el-grupo-vacio-al-empezar` and `eraseevent-de-verdad`.

And a line in two tasks in `todo/`: `eraseScreen-y-showscreen` (it no longer
leaves pages out, it is debt; what is seen in Desert and El Dorado) and
`changesystemgraphics` (also VD and Desert, which plays entirely with the
intro's System). The example draft now names the edges one.

## Known issues

In the book, branch `calandria-known-issues`: the section at the very top of
the eight port pages (in ABL, the presentation text moved to "The
port"). Each line names its draft or its task in `todo/`.

## Discarded: already fixed or covered

* Sunset black at 30 s (`ignorar-changesystemgraphics`) and the opaque
  orange window (`sunset-el-mapa-22-en-negro`): they were fixed by the
  pictures inside the map and mode 1; the capture `modo1-22-01600` in
  `/shared/capturas/2026-10-11-sunset-modo-1/` shows the scene with the
  window without background.
* Desert's intro that ended in black because of the excluded map 2
  (`eraseevent-de-verdad`): Desert no longer excludes anything.
* Sunset takes hours (`sunset-tarda-horas-en-armar`, `otros-juegos-el-rebarrido`):
  it builds in 33 s (`los-otros-juegos-arman-y-arrancan`).
* The stripes in VD's intro (`boot-frames-por-cartucho`):
  `la-intro-de-vampires-dawn-rota`.
* Dooms 2's maps 40 to 93 (`las-caras-y-los-escapes-de-espera`):
  `las-muestras-que-sobran`.
* The own System of Book of Three, Frozen, Desert and Dooms 2:
  `la-ventana-en-el-banco-de-tiles`.
* The game's resources outside the fingerprint (`el-volcado-fuera-de-la-huella`):
  `la-huella-con-el-juego-y-force`.
* `ChangeFaceGraphic` outside `ACCEPTED_UNDONE` (`el-tablero-contra-rm2k`):
  `changefacegraphic-en-las-deudas`.
* The red of `the_layers_are_the_ones_the_python_made` and the screens
  test that changed: `los-colores-de-la-ventana-en-el-pedido-de-wally`
  and `00710e92`.
* VD's walls of music, troops, poses, boot and the
  errors without a map: their tasks in `testing/`.
* The hero's diagonals and turns in routes (`cuatro-atajos-para-los-otros-juegos`):
  `ruta-los-movimientos-que-faltan.md`.
* `EraseScreen`/`ShowScreen`, `ChangeSystemGraphics`, the faces, the
  colours and the waits: their tasks in `todo/` (with the line above).

## Not rescued, by judgement

* `SUB_MAX` could be exceeded again (`cuatro-atajos-para-los-otros-juegos`):
  it wasn't seen being exceeded.
* ABL's routes that get cut at speed 3
  (`la-ruta-del-mirador-deja-trabada-la-direccion`): they do what RM2k does, and
  the model was without the tints' waits.
* The copies in `build/cache/zip/` that aren't deleted
  (`la-huella-con-el-juego-y-force`), the 168 pose banks that remain
  (`una-cuantizacion-por-personaje`: VD fits now) and the painted maps with
  mandatory MSU-1 (`sunset-en-modo-1-con-color-math`): nothing is broken.
* Desert's "light-blue garbage" panorama from 2026-10-05
  (`otros-juegos-el-relevamiento`): the panoramas were redone afterwards and
  nobody saw it again; not checked.
* The "it wasn't played" and "the suite doesn't cover" that don't name a concrete case.

## Seen in passing, without a draft

Today's Desert release says that on 157 maps it doesn't draw the pictures
`TextboxInnen` and `TextboxRahmen` —its messages' own frame—; it doesn't
come from any task in `testing/`, and Desert's page already says that
"136 maps don't draw some of their pictures". It is left for whoever looks at
Desert.

## When merging

Nothing to install. Merge the book's `calandria-known-issues`.
