---
name: "Decisions and divergences, by repo"
description: "Classify each file in workflow/decisiones/ and workflow/divergencias/ by whether it goes to the tools repo or to ABL's, for the split"
type: docs
status: done
assignee: taro
---

Question 8 of the tools research, which taro left open on 2026-09-28
("some are ABL's and some aren't: go over them one by one"), and which
Hornero decides with taro's authorization of 2026-09-29.

The criterion: what would hold for any RM2k game ported with the tools
goes with the tools; what belongs to this game, its maps, its events or
its artistic decisions goes with ABL. If one mixes both, it says which
part is which.

## How it was applied

What gets classified is **the rule, not the examples**. Almost all of them
were made looking at ABL and cite its maps, its events and its numbers;
that doesn't make them ABL's if the rule holds for any game. Many of the
tools ones are **justified** by how ABL is —"no route in the game exercises
it", "the 26 routes with diagonals"—: they are engine limits measured on
ABL, which according to `decisiones/las-herramientas-se-separan-de-abl.md`
stay fixed in the engine. In the table they say "measured on ABL", because
they are the first thing to look at again with another game.

The divergences **all** come from the tools, and it is no coincidence: a
divergence is the ROM doing something other than RM2k, and the ROM is the
runtime and the converter. The ones that "hold because ABL is the way it
is" —those of "When it stops being enough"— are precisely the ones the
tools repo has to take along, because they are the ones that warn the next
game.

The classification lives **only here**, without touching the files: the
ones in `decisiones/` and `divergencias/` have no frontmatter, and adding it
to sixty-four files for a piece of data that is used once makes more of a
mess than a table. The tables are read with a script: each file row starts
with `` | `decisiones/`` or `` | `divergencias/`` or `` | `docs/``, and the
second column is exactly `tools`, `abl` or `mixed`:

    grep -E '^\| `(decisiones|divergencias)/' workflow/tasks/*/decisiones-y-divergencias-por-repo.md \
      | awk -F'|' '{gsub(/[ `]/, "", $2); gsub(/ /, "", $3); print $3, $2}'

The paths in the first two tables are relative to `workflow/`; those in the
third, to the root.

## Decisions

| file | repo | why |
|---|---|---|
| `decisiones/README.md` | mixed | Each repo needs its own: it is copied to both. |
| `decisiones/agotar-el-presupuesto-de-teletransportes-es-un-error.md` | tools | A runtime rule (`entrar_en_panico`), holds for any game. |
| `decisiones/atravesar-paredes-vale-para-el-salto.md` | tools | RM2k semantics in the runtime. |
| `decisiones/call-event-se-compila-en-linea.md` | tools | How the converter compiles `CallEvent`; "no call is recursive" and `LLAMADA_MAX` are measured on ABL. |
| `decisiones/conditional-branch-cinco-de-doce-clases.md` | tools | What the converter compiles and how; which classes go in is measured on ABL. |
| `decisiones/data-es-la-vista-resuelta.md` | tools | It is the convention of Ditto and of the reader for any game: what `ditto unpack` emits and what a project versions. |
| `decisiones/el-arranque-esta-dimensionado-para-el-paquete-de-arranque.md` | tools | `BOOT_CUADROS` belongs to the runtime and the cut to the converter; the number is measured on ABL's boot map. |
| `decisiones/el-cartucho-se-queda-en-4-mb.md` | mixed | "LoROM tops out at 4 MB and going past it is ExHiROM" belongs to the runtime; that ABL stays at 4 MB, its 2.52 MB and "it is revisited at 85-90%" are ABL's. It is split that way. |
| `decisiones/el-color-math-no-se-usa.md` | tools | How the runtime draws translucent things; the part about snes9x rounding holds for any golden. |
| `decisiones/el-cronometro-no-tiene-paleta-propia.md` | tools | The converter's palette allocation and the runtime's `subir_timer_pal`. |
| `decisiones/el-refresco-corre-en-tres-momentos.md` | tools | The runtime's frame structure, copied from `Game_Map::Update`. |
| `decisiones/el-tema-que-suena-gana-y-los-efectos-esperan.md` | tools | The audio budget policy of the converter and the runtime (`temas_heredados`, `tema_asegurar`). |
| `decisiones/el-trueno-va-entero-y-paga-la-lluvia.md` | mixed | "Effects have two voices" and the mechanism of per-map aliases and of whole effects paid for by the music belong to the tools; the thunder on map 1 at 8,800 Hz and the whole rain are ABL's, and already live in `[sound_effects]` of `rom/rm2k-snes.toml`. It is split that way. |
| `decisiones/la-camara-corrida-de-la-reja-es-del-juego.md` | abl | A concrete event of the game (the Bum on map 8) that the original also does; it says nothing about the engine that `camara.s` doesn't already say. |
| `decisiones/la-grilla-vive-en-la-wram.md` | tools | Where the grid lives in the runtime; "if Lashe City works, the rest works" is measured on ABL. |
| `decisiones/la-orden-34-sobre-el-heroe.md` | tools | Which route orders the runtime does; what was gained is measured on ABL. |
| `decisiones/la-pagina-activa-se-congela-hasta-el-refresco.md` | tools | RM2k semantics in the runtime. |
| `decisiones/la-pagina-de-prueba-se-apaga-sola.md` | tools | The test page is injected by the converter (`SWITCH_DE_PRUEBA` in `tools/port/eventos.py`) into any game. |
| `decisiones/la-tecla-de-accion-mira-las-dos-celdas.md` | tools | RM2k semantics in the runtime. |
| `decisiones/las-diagonales-van-sobre-eventos.md` | tools | A limit of the converter and the runtime, measured on ABL (no hero route with diagonals). |
| `decisiones/las-herramientas-se-separan-de-abl.md` | mixed | How the repo is split: it matters to both. The runtime part, the suite version, English and "install" belong to the tools; "ABL only knows executables on the PATH", declaring the version and "verify" are ABL's. It is copied to both, or split that way. |
| `decisiones/las-poses-se-suben-en-caliente.md` | tools | Runtime architecture (the cap of 512 object tiles is the hardware's). |
| `decisiones/los-eventos-disparan-con-dos-bits.md` | tools | Runtime structure, copied from `waiting_execution`. |
| `decisiones/los-lideres-comparten-una-ranura-de-cgram.md` | tools | The converter's CGRAM allocation. |
| `decisiones/los-lideres-posibles-son-una-aproximacion.md` | tools | How the converter simulates `ChangePartyMembers`. |
| `decisiones/los-translucidos-van-horneados.md` | tools | How the converter converts "Trans"; it holds as long as the game's translucent things are static, which is measured on ABL. The save point exception is ABL's and is already in `[graphics] opaque` of `rom/rm2k-snes.toml`. |
| `decisiones/orden-9-de-ruta-hacia-el-heroe.md` | tools | Which route orders the runtime does; the nine missing ones, measured on ABL. |
| `decisiones/ordenes-de-ruta-26-y-27-sobre-el-heroe.md` | tools | Which orders the converter drops; "the game can be played without them" is measured on ABL. |
| `decisiones/se-dibujan-todos-los-eventos.md` | tools | A principle of the converter (the palette loan in `cabe`), taro's. |
| `decisiones/un-caso-largo-en-cero-no-prueba-nada.md` | mixed | The rule holds for the suite of any game; but the ROM tests stay in ABL until the golden game exists. It is copied to both. |
| `decisiones/un-grafico-que-no-entra-no-se-dibuja.md` | tools | The converter's palette allocation. **It no longer holds entirely**: see below. |
| `decisiones/un-solo-banco-de-muestras.md` | tools | Audio architecture of the converter and the runtime. |
| `decisiones/una-puerta-al-mismo-mapa-no-recarga-el-mapa.md` | tools | RM2k semantics in the runtime. |
| `decisiones/una-puerta-es-una-pagina-de-contacto.md` | tools | How the converter compiles a `Teleport`. |

Not counting the README: **28 tools, 1 ABL and 4 mixed.**

## Divergences

| file | repo | why |
|---|---|---|
| `divergencias/README.md` | mixed | Each repo needs its own; the paragraph "except the ones that hold because ABL is the way it is" belongs to the tools. |
| `divergencias/atravesar-paredes-vale-mientras-dura-la-ruta.md` | tools | Runtime; justified by ABL (the four pages that leave it on are oversights of the original). |
| `divergencias/autofire-de-a-con-x.md` | tools | Runtime (`read_pad`), on every screen. |
| `divergencias/cronometro-llegando-a-cero.md` | tools | Runtime. **Doubtful**: see below. |
| `divergencias/destello-sobre-la-paleta-de-otro.md` | tools | Runtime and palette allocation. |
| `divergencias/el-chipset-se-saltea-un-dibujo-cada-18-minutos.md` | tools | Runtime. |
| `divergencias/el-cronometro-y-su-vecino-comparten-colores.md` | tools | Runtime and palette allocation; the maps are examples. |
| `divergencias/el-mapa-lleva-a-vram-solo-lo-que-dibuja.md` | tools | Converter; "when it stops being enough" is for the next game. |
| `divergencias/fase-de-los-tiles-animados.md` | tools | Runtime. **Doubtful**: see below. |
| `divergencias/la-animacion-de-batalla-achicada.md` | tools | Converter. |
| `divergencias/la-fase-de-los-quietos-que-animan.md` | tools | Runtime. |
| `divergencias/la-partida-no-guarda-los-eventos.md` | tools | Runtime. |
| `divergencias/la-ventana-de-mensaje-se-lleva-10-kb-de-vram.md` | tools | Runtime; the 39 columns hold for any RM2k game. |
| `divergencias/las-transiciones-del-teletransporte.md` | tools | Converter and runtime; the maps are examples. |
| `divergencias/llamada-salteada.md` | tools | Converter; the `AfterBattleMint` is an example. |
| `divergencias/lo-que-el-giro-hacia-el-heroe-no-modela.md` | tools | Runtime. |
| `divergencias/lo-que-la-colision-con-los-eventos-no-modela.md` | tools | Runtime. |
| `divergencias/lo-que-la-ia-de-los-enemigos-no-modela.md` | tools | Converter and runtime; the troops are examples. |
| `divergencias/lo-que-la-pantalla-de-end-game-no-modela.md` | tools | Runtime. |
| `divergencias/lo-que-la-pantalla-de-game-over-no-modela.md` | tools | Runtime; which image ABL's `System` names is an example. |
| `divergencias/lo-que-las-paginas-de-tropa-no-modelan.md` | tools | Runtime. Which troop effects go in is decided by the game, and is already in `[sound_effects] troop_effects_in_package` of `rom/rm2k-snes.toml`. |
| `divergencias/los-comunes-del-equipo-corren-al-cerrar-el-menu.md` | tools | The rule (`eventos.COMUNES_DEL_EQUIPO`) holds for any parallel common event of that shape; in ABL there is one. |
| `divergencias/los-ocho-cuadros-del-cierre-de-un-mensaje.md` | tools | Runtime. |
| `divergencias/los-translucidos-quedan-opacos.md` | tools | Converter; justified by ABL (no translucent thing walks). |
| `divergencias/mas-de-cuatro-quietos-que-animan.md` | tools | Converter (`ANIMA_QUIETO_MAX`), measured on ABL. |
| `divergencias/move-event-tras-teleport-interno.md` | tools | Runtime. **Doubtful**: see below. |
| `divergencias/paso-bloqueado-de-una-ruta-forzada.md` | tools | Runtime. |
| `divergencias/siete-paletas-en-un-mapa-con-animaciones.md` | tools | Converter. |
| `divergencias/ticks-de-pantalla-despues-del-interprete.md` | tools | Runtime. |
| `divergencias/un-evento-que-camina-no-cambia-de-grafico.md` | tools | Runtime and converter. |
| `divergencias/un-solo-contador-para-las-cuatro-flechas.md` | tools | Runtime. |
| `divergencias/una-celda-con-las-dos-animaciones-del-chipset.md` | tools | Voodoo; justified by ABL (zero cells like that). |

Not counting the README: **31 tools, 0 ABL and 0 mixed.**

## docs/

| file | repo | why |
|---|---|---|
| `docs/README.md` | mixed | Each repo needs its own, with the folders that apply to it. |
| `docs/jetbrains.md` | tools | It is so that annotate crosses the split of `main.s`, which is in `tools/runtime/`. |
| `docs/port/` | tools | How the converter and the runtime work; ABL's maps are examples. Except `pipeline.md`, below. |
| `docs/port/pipeline.md` | mixed | The diagram belongs to the tools; the `rom/…` paths, `$ABL_GAME_DIR` and the two `just` recipes are ABL's. |
| `docs/rpgmaker/chipsets.md` | tools | The RM2k format. |
| `docs/rpgmaker/rtp.md` | mixed | What Don Miguel's RTP is, why EasyRPG's is no good and how it is extracted belong to the tools; the 5 ChipSets and 17 CharSets that ABL uses are ABL's. |
| `docs/snes/` | tools | The console and the emulators. |
| [`docs/research/graficos-de-rm2k-a-snes.md`](https://lautarodragan.github.io/the-advocate-docs/research/graficos-de-rm2k-a-snes.html) | tools | A study of how to convert RM2k's graphics, measured on ABL; tools decisions and divergences cite it. |
| [`docs/research/el-mapa-de-las-herramientas-de-python.md`](https://lautarodragan.github.io/the-advocate-docs/research/el-mapa-de-las-herramientas-de-python.html) | tools | The map of `tools/` and the plan for the split. |
| [`docs/research/inspeccion-integral-del-repo.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/inspeccion-integral-del-repo.html) | abl | A snapshot of the whole repo before the split, and more than half of it is about the ROM tests and their harness, which stay in ABL. It is not split: it is a snapshot. |

## The ones that no longer hold, for taro

They were not touched: taro is the one who decides.

* **`decisiones/un-grafico-que-no-entra-no-se-dibuja.md`** was replaced by
  `decisiones/se-dibujan-todos-los-eventos.md`. The title and the first
  sentence are from 2026-09-06 (`3bf9a780`, order 34); the palette loan is
  from 2026-09-08 (`ac8f356b`), and since that day `cabe`, in
  `tools/port/snes_convert.py`, lends a foreign palette also to the
  chipset tiles and to the graphics of order 34, which come in through the
  same function: a graphic only stays undrawn if all the palettes are
  leaders'. `la-orden-34-sobre-el-heroe.md` already says it ("an event drawn
  with a chipset tile goes on to hang from a foreign palette"). What still
  holds is the middle half: those graphics **are not given a new palette**
  —forcing them broke 108, 114 and 207—. The comments in
  `snes_convert.py` that say "the one that doesn't fit isn't drawn" —the one
  for the graphics of order 34 and the one for the timer, both in
  `npcs_dibujables`— have the same old sentence.
* **Three divergences were measured against the Python reference, not
  against RM2k**, and the reference was deleted on 2026-09-16. Nothing says
  which of the two sides was wrong, so it is not known whether the ROM
  differs from RM2k:
  * `divergencias/fase-de-los-tiles-animados.md`: it says so itself ("it
    could no longer be investigated that way").
  * `divergencias/cronometro-llegando-a-cero.md`: the 252 pixels of frame
    60 came out on 2026-09-13 comparing against the reference (`27c828de`),
    although the file doesn't make that clear.
  * `divergencias/move-event-tras-teleport-interno.md`: "against the
    Python reference, while it existed"; the title says "than RM2k".

  According to the README of `divergencias/`, which asks for "where the ROM
  doesn't do what RM2k does", none of the three qualifies today. Either they
  are verified against RPG_RT with Wine, or they are deleted.

### What doesn't stop holding but is out of date

* **The paths from the move.** Several cite `rom/src/`, which since the
  move is `tools/runtime/` —which ones: `grep -l 'rom/src/'
  workflow/decisiones/*.md workflow/divergencias/*.md`—, and the `tests/…` inside them are now
  `rom/pruebas/…`. It is a mechanical replacement that is worth doing before
  the split, in its own commit.
* **Names that moved to the project file**: `SIN_TRAMA`
  (`los-translucidos-van-horneados.md`) is `[graphics] opaque`;
  `SE_DEL_MAPA` and `SE_ENTEROS_PAGADOS` (`el-trueno-va-entero-y-paga-la-lluvia.md`)
  are `[sound_effects] per_map` and `paid_by_music`; `SE_DE_TROPA_AL_PAQUETE`
  (`lo-que-las-paginas-de-tropa-no-modelan.md`) is
  `troop_effects_in_package`. All in `rom/rm2k-snes.toml`.
* `decisiones/un-caso-largo-en-cero-no-prueba-nada.md` says "the two sides
  did nothing", from when there was a reference; the rule holds all the
  same against a golden.
