---
name: "Split main.s"
description: "main.s, a single file of more than thirty thousand lines, into several"
type: refactor
status: done
---

**Split `rom/src/main.s`**, which is more than thirty thousand lines in one
file —how many, `wc -l`—.

Tried small —one section moved out with `.include`, same md5—;
the boundaries already exist: section marks and `.proc`.

Three traps:
- the `.segment` crosses the `.include`,
- anonymous labels are resolved textually,
- and reordering does change the ROM even though splitting doesn't.

## Plan

Written on 2026-09-25 on top of `43bd1aa`, for one agent to critique and
another to execute. What is measured is measured that day on that commit; the line
numbers aren't copied here because they move: they are printed by
`python3 tools/ensamblado/partir_main.py --ver`.

### What was measured

* **Splitting doesn't change a byte.** With `tools/ensamblado/partir_main.py` (it is on
  this branch), the three ROMs —`release`, `test-main` and `test-special`— and their
  three `.sym` come out byte-for-byte identical. They were built with `ensamblar.py` against
  the same `mapdata.inc`/`musicdata.inc`/`memory.cfg` of each cartridge, so
  the converter is left out of the comparison on purpose: it doesn't read `main.s`.
* **The `.dbg` changes and it doesn't matter.** Its `file` rows (one per file)
  and `line` rows change; the `sym` rows, without their references to lines, are identical. It is
  already not reproducible today —it stores the absolute path and the mtime of each source— and its only
  reader is `ensamblar.simbolos()`, which takes the `.sym` out of it, which is what
  the tests read. A debugger that uses it will show the new file and line,
  which is what we want.
* **The task's three traps aren't about cutting but about reading and
  reordering.** `.include` is text to `ca65`, so nothing resets at the
  edge of a file. Tried by cutting on purpose where it hurts most:
  - between a `bcc :+` and its `:`, **inside** `.proc elegir_con_filtro`: same ROM;
  - inside a `.proc`, right after an `.a16` and before an `lda #`:
    same ROM —the register width crosses the `.include`—;
  - the plan's files that start without a `.segment` (55) inherit the
    previous one's: same ROM.

  The script still **refuses** to cut inside a block (`.proc`,
  `.macro`, `.if`…) or between an anonymous label and its use, because that is unreadable.
* **Reordering does change the ROM**, as the task said. Swapping
  `control.s` with `spc700.s` —two neighbours in bank 0— changes some two hundred
  bytes and a dozen symbols; moving `poner_switch` to `variables.s`, some
  nineteen hundred bytes and a hundred symbols. That's why this pass doesn't
  move anything.
* **A redundant `.segment` at the start of each file changes nothing**:
  added to the 55 that don't have it, ROM and `.sym` identical.
* **`ca65`'s limits**: 41 levels of nested `.include` assemble without
  complaint (the plan uses one). An `.include` done from a subdirectory is
  looked up first in the directory of the including file, not in that of
  `main.s`.
* **Three tests break with the cut**, and all three because they read `main.s` as
  text: the two in `test_sustituciones.py` and
  `test_ningun_opcode_de_la_rom_quedo_sin_declarar`. With the tooling change
  below, the fourteen in those three files
  (`test_sustituciones`, `test_protocolo`, `test_ensamblar`) pass on the
  split tree. The whole `just tests` was **not** run: there were two other
  agents using the CPU.
* **`git blame`**, measured in a clone with the cut committed, comparing
  line by line the blame of each new file against that of the `main.s` from
  before:

  | how | what it answers |
  |---|---|
  | `git blame` | everything "was the cut" |
  | `--ignore-rev <corte>` | everything "was the cut" all the same: there is no file with the same name in the parent to pass the blame to |
  | `-C`, `-C -C`, `-C -C -C` | almost everything "was the cut": it only finds the end of `main.s` |
  | `-C --minimal` | it no longer blames the cut, but misattributes half the ROM |
  | **`-C --diff-algorithm=histogram`** | **every line with the same commit the `main.s` from before gives with the same options** |

  Why the difference: with Myers, the repeated lines —`rts`,
  `.endproc`, `;`, blanks— get paired with the first ones it finds in a
  thirty-thousand-line file, and the chunks end up shorter than the minimum
  of `-C`. Histogram anchors on the unique lines. `git -c
  diff.algorithm=histogram blame -C` gives the same, but since `.git/config` is
  read-only here, taro would have to configure that on the host side.
  And `-C` with histogram sees **further back** than today's blame on `main.s`:
  it also crosses the old moves inside the file, like that of the
  shop to bank 1.

### The partition

One file per contiguous stretch, in today's order. `main.s` keeps its
prologue (`.p816`, `.smart`), the `.include`s in order, and the stretch of the
generated files written as is: the two `.inc`s from `tools/protocol/`, `musicdata.inc`
and `mapdata.inc`, and the two constants that depend on the converter
(`VENTANA_LINEAS_TEXTO`, `TEXTO_BUF_BYTES`). That way `main.s` shows **where
the cartridge's data comes in**, which is the only thing that isn't a subsystem.

The anchor is what the script looks for: the cut falls on the section mark, or at
the start of the comment preceding the `.proc`.

| file | segment | anchor | what's there |
|---|---|---|---|
| `registros.s` | — | `INIDISP =` | ports, PPU, DMA and HDMA |
| `ram_lejana.s` | — | mark "la RAM del banco 1" | the far RAM map, skills, window, strips, flashes |
| *(stays in `main.s`)* | — | `.include "event_opcodes.inc"` | the generated files and two constants |
| `pagina_cero.s` | ZEROPAGE | `.segment "ZEROPAGE"` | the whole zero page |
| `arranque.s` | CODE | `.proc reset` | `reset`, NMI, vblank, PPU zeroing, `ppu_init` and the little piece of TABLAS |
| `cargar_mapa.s` | CODE | `.proc cargar_mapa_sin_eventos` | map dump, `eventos_tick`, fades |
| `paginas_de_eventos.s` | CODE | `.proc leer_pagina` | which page runs, parallels, slots, conditions, waits |
| `interprete.s` | CODE | `.proc correr_codigo` | the bytecode loop and `pelea_arrancar` |
| `variables.s` | CODE | `.proc var_apuntar` | variables, random, choice |
| `tinte.s` | CODE | `.proc tabla_canal` | tint, saturation, palette upload |
| `grupo.s` | CODE | `.proc en_el_grupo` | the party and the hero's graphic |
| `ruta_del_heroe.s` | CODE | `.proc paso_de_ruta` | the hero's forced route, `hay_rutas`, `poner_switch` |
| `cargar_graficos.s` | CODE | `.proc dma_origen` | `load_map`, sprites, OAM, hot poses, upper layer, NPCs |
| `rutas_de_eventos.s` | CODE | `.proc ruta_para_evento` | the events' forced routes |
| `tecla_de_accion.s` | CODE | `.proc evento_en_celda` | the action key and touch |
| `destello_de_personaje.s` | CODE | `.proc flash_empezar` | `FlashSprite` |
| `eventos_caminando.s` | CODE | `.proc animar_ruta_ev` | the events drawn walking |
| `partida.s` | CODE | mark "guardar y cargar la partida" | the SRAM |
| `titulo.s` | CODE | mark "la pantalla de título" | |
| `ranuras.s` | CODE | mark "la pantalla de ranuras" | slots and their text per actor |
| `menu.s` | CODE | mark "el menú de pausa" | menu, `ChangeSpriteAssociation`, actor selection |
| `pantallas_de_texto.s` | CODE | mark "las pantallas de texto" | `pant_*` |
| `batalla_puentes.s` | CODE | mark "la batalla" | the `ba_t_*` bridges in bank 0 and the battle's audio |
| `lluvia.s` | CODE | mark "la lluvia" | |
| `msu1.s` | CODE | mark "el MSU-1" | |
| `paquete_de_audio.s` | CODE | mark "el paquete de audio de cada mapa" | ARAM, samples, tracks |
| `efectos_de_sonido.s` | CODE | mark "los efectos de sonido" | with the two `SE_*_VOZ` macros |
| `items.s` | CODE | mark "la pantalla de ítems" | and `volver_al_mapa`/`volver_de_batalla` |
| `quietos_que_animan.s` | CODE | mark "los eventos quietos que animan igual" | and `sonido_de_codigo`, `sonido_tocar`, `destello_de_codigo` |
| `imagen.s` | CODE | mark "el cartel del ShowPicture" | |
| `animacion_de_batalla.s` | CODE | mark "la animación de batalla" | the animation and its drawing |
| `giro_hacia_el_heroe.s` | CODE | mark "el giro hacia el héroe" | |
| `npcs.s` | CODE | `.proc subir_pose_npc` | NPC poses and order |
| `celdas.s` | CODE | `.proc celda_vecina_existe` | `puede_celda` and its neighbours |
| `destello_de_pantalla.s` | CODE | mark "el destello de pantalla" | |
| `camara.s` | CODE | mark "la cámara corrida sin el héroe" | pan, shake, `follow_camera` |
| `ventana_del_mapa.s` | CODE | mark "la ventana móvil del mapa" | the tilemap streaming |
| `mensajes.s` | CODE | mark "la ventana de mensaje" | window and text compositor |
| `vblank.s` | CODE | mark "lo que va sí o sí dentro del vblank" | `flush_video` and the strips |
| `animacion_del_chipset.s` | CODE | mark "la animación del ChipSet" | |
| `heroe.s` | CODE | `PASS_DOWN =` | walking, passability, walk animation |
| `cronometro.s` | CODE | mark "el cronómetro" | |
| `oam.s` | CODE | mark "armado de OAM" | `build_oam`, jumps, `place_*`, `emit_object` |
| `control.s` | CODE | mark "lectura del control" | `read_pad` |
| `spc700.s` | CODE | mark "carga al SPC700" | the upload through the IPL |
| `ram_baja.s` | BSS | `.segment "BSS"` | the whole BSS |
| `musica.s` | CODE | `.proc irq_musica` | the stream player |
| `banco1.s` | FAR | `.segment "FAR"` | bank 1's header and what came down from bank 0 |
| `nivel.s` | FAR | mark "el nivel y el máximo en el menú" | |
| `medicina.s` | FAR | mark "una medicina desde el menú" | |
| `equipo_desde_eventos.s` | FAR | mark "el equipo y las habilidades desde un evento" | and `menu_hp_escribir` |
| `batalla.s` | FAR | `.proc ba_azar` | arithmetic, setting up the battle, hit, turn, screen |
| `batalla_items.s` | FAR | mark "usar un ítem en la pelea" | |
| `batalla_habilidades.s` | FAR | mark "ejecutar una habilidad" | executing and listing skills |
| `batalla_lazo.s` | FAR | mark "el lazo de la pelea" | and the experience |
| `batalla_tropa.s` | FAR | mark "las páginas de evento de la tropa" | |
| `batalla_escena.s` | FAR | mark "la escena de la pelea" | |
| `batalla_correr.s` | FAR | `.proc batalla_correr` | the whole battle, with its frame loop |
| `banco_de_la_pantalla.s` | FAR | mark "el banco de la pantalla, también fuera del banco 0" | uploads the font, the tilemap and the palettes of all the text screens |
| `encuentros.s` | FAR | mark "los encuentros al azar, fuera del banco 0" | |
| `pantalla_de_equipo.s` | FAR | mark "el equipo y la tienda, fuera del banco 0" | |
| `tienda.s` | FAR | mark "la tienda" | |
| `cabecera.s` | FAR, HEADER, VECTORS | `.align $8000` | the close of bank 1, header and vectors |

**Why this one.** The criterion is the task's: that a human finds something
by the file name, and that two branches of different subsystems don't touch
the same one. Almost all the cuts fall on the `; --- … ---` marks that already
exist, which are the boundaries the code itself declares; the ones that fall on
a `.proc` are where a mark lumps together things that are unrelated —"la
saturación del tinte" ends with the party, the hero's route and `load_map`;
"el giro hacia el héroe" ends with the NPC poses and `puede_celda`—. Two
marks don't work as anchors because they are repeated ("el héroe", "el PPU", "el
compositor de texto"): hence `PASS_DOWN =` and `.proc reset`. The granularity
is fine on purpose: joining two neighbours is deleting an anchor, separating them later
is more expensive. With the history of the last week (live lines per commit, with
`git blame` on `43bd1aa`), what gets touched the most is `interprete.s` by far,
then `ram_lejana.s`, `cargar_mapa.s` and `arranque.s`: the cut doesn't solve
the clash in `interprete.s` —see the second stage—.

**Flat, without subdirectories.** They work —tried—, but an `.include`
inside a subdirectory is resolved against that subdirectory, and the order
is still given by `main.s`'s list: folders per subsystem would suggest an
independence that isn't there. The prefixes (`batalla_*`) group the same in `ls`.

**The `.s` extension.** `rom/src/` today has an implicit rule: `.inc` is
generated (the two from `tools/protocol/`, and `mapdata.inc`/`musicdata.inc` in
`rom/build/`). `.s` for what's handwritten keeps it. The check in
`ensamblar.py` is **by name** (`GENERADOS`), not by extension, so the
new files don't trigger it with either; what that rule protects
—a file in `rom/src/` shadowing one from `-I`— stays the same, because
none is named like a generated one. What the `.s` extension may suggest is
that each one is assembled on its own, as in a `ca65` project with several
objects: no, they are all text of a single `main.s`, and the comment
in `main.s` says so in the prose commit.

### What depends on there being a single file

* **`cartuchos.huella()`** hashes `rom/src/main.s` only. Once split, editing
  `tienda.s` would leave the cartridge "up to date" and the tests would run against an
  old ROM **without warning**. It changes to all of `rom/src/` recursively —not to what
  `main.s` includes: a new file is added and included in the same
  change—. Along the way it covers `event_opcodes.inc` and `music_opcodes.inc`, which today
  are only covered indirectly by the `.py` files generated together with them.
* **The tests that read the source**: `test_sustituciones.py` (`SUB_MAX`,
  `sub_clave`, `sub_valor`) and `test_protocolo.py` (the `#OP_*` used, and that
  none is declared by hand). They switch to reading
  `ensamblar.texto_de_la_fuente(MAIN)`. Watch out for the temptation of reading
  `rom/src/*`: it would include `event_opcodes.inc`, and the test of "no `OP_`
  declared by hand in the ROM" would go red because of the generated ones. That's why the
  new function follows the `.include`s that end in `.s` and nothing else.
* **`ensamblar.py`** doesn't need to change to build: `main.s` is still the
  entry point. It adds the two functions:

      INCLUDE = re.compile(r'^\s*\.include\s+"([^"]+)"', re.M)

      def fuentes(principal):
          """`principal` y los `.s` que incluye, en el orden de `ca65`."""
          directorio = os.path.dirname(os.path.abspath(principal))
          rutas = [principal]
          with open(principal, encoding="utf-8") as archivo:
              texto = archivo.read()
          for nombre in INCLUDE.findall(texto):
              if nombre.endswith(".s"):
                  rutas += fuentes(os.path.join(directorio, nombre))
          return rutas

  and `texto_de_la_fuente(principal)`, which glues them together. In `huella()`:

      partes = (sorted(r for r in glob.glob(os.path.join(ROOT, "rom", "src", "**"),
                                            recursive=True) if os.path.isfile(r))
                + ensamblar.binarios() + …)

  Tried on the split tree. It's also worth having **a test** that everything
  `fuentes()` returns is in the fingerprint —moving the list of parts out to
  a function—, because otherwise, the fingerprint covering the new files is a
  path no test executes.
* **Optional**: the `GENERADOS` check could become "no file
  in the `-I` directory also exists in `rom/src/`", which doesn't depend on a
  list. It isn't needed for the cut.
* **`main.s:NNNN`** appears only once in the whole tree: `AGENTS.md`, "La
  trampa que más veces mordió", which cites `main.s:7997` and **was already stale**:
  slot 0's `cmp #0` is in `cuadro_de_ruta_ev`. It is cited by symbol.
* **"`symbol` in main.s"** appears in some forty files outside
  `rom/src/` (`grep -rln 'main\.s' --exclude-dir=.git --exclude-dir=build .`).
  The ones that describe the structure do change: `README.md` (the audio's file
  tree), `docs/port/pipeline.md`, `docs/port/events.md`, the
  `justfile`'s comments about `ensamblar`, the docstring of
  `ensamblar.py` ("al lado de `main.s`" becomes "en `rom/src/`") and two
  paragraphs of `AGENTS.md` —`huella()` in "Mientras corren las pruebas…" and
  the generated `.inc` trap—. The rest cite a **symbol**, which is the
  anchor that doesn't go stale: see question 9.
* **Inside `rom/src/`**: the comments that locate something by position
  ("see down there", "at the end of the file") and whose target ended up in another
  file. `partir_main.py --colgadas` gives the list of those that cite a
  symbol; it is a working list with false positives ("the cell
  above"), and it doesn't see the ones that cite nothing: it has to be completed with
  `grep -n 'archivo\|allá abajo\|más arriba' rom/src/*.s`, looking above all at
  the first and last paragraphs of each file. The sure case is
  `batalla_puentes.s`: "ver `batalla_correr`, al final del archivo".
* **The comment at the top of `main.s`** says "PoC de audio: reproduce un
  tema en loop, sin dibujar nada": it dates from when this was the audio test.
  It is the natural place to explain that the order of the `.include`s is the
  order in the ROM, and that each file inherits the segment and widths of the
  previous one.

### Commits, in order

1. **This one**, already on the branch: `tools/ensamblado/partir_main.py` and the plan. The
   script does nothing until it is run.
2. **Tooling**: `fuentes()`/`texto_de_la_fuente()`, `huella()` over
   `rom/src/`, the two tests and the new fingerprint test. On the
   whole `main.s`, `fuentes()` returns `[main.s]`, so this commit is
   verified on its own: `just tests` green. It changes the fingerprint, so all
   the cartridges get rebuilt; the ROMs have to come out identical because no
   source was touched.
3. **The cut**: `python3 tools/ensamblado/partir_main.py`, `git add -A
   rom/src`, and nothing else in that commit —not one line of prose—. Its being only
   the script's output is what makes it reviewable: the reviewer
   reproduces it instead of reading sixty thousand lines of diff (see below). It is
   also what serves `blame -C` best: a commit that only moves.
4. **Optional, mechanical**: an explicit `.segment` at the start of each
   file that doesn't have one (see question 5). Same ROM, measured.
5. **Prose**: everything in the previous section. It is guided by the diff of 3, and
   nothing verifies it but reading it. **And it deletes `partir_main.py`** (the critic's
   correction D): an old branch takes it from
   `git show <corte>^:tools/ensamblado/partir_main.py`, which is the exact
   version that produced the cut.

The script can be run again if `main` moved between planning and
executing: it looks for anchors and not line numbers. If an anchor disappeared or
got duplicated, it refuses, and the `TRAMOS` table is adjusted. Before committing,
`--ver` shows the first line of each file, and it's worth looking at them: a
cut that starts in the middle of a comment is an anchor that went wrong.

### How it is verified

For commit 3, the three things, and the message says which ones were run:

1. **Reproducible**: from a clean tree at the cut's parent,
   `python3 tools/ensamblado/partir_main.py && git add -A rom/src && git diff --cached --stat <corte>`
   shows nothing. (Without the `git add`, `git diff` doesn't see the new untracked
   files and gives a false red: the critic's correction A.) It is the verification that the commit is the script's output
   and nothing else, and the one anyone can do without reading the diff.
2. **Byte for byte**: before the cut, `just cartridges` and copy
   `rom/build/release/abl.sfc`, `rom/build/tests/{main,special}/prueba.sfc` and
   their `.sym` to a scratchpad directory; after, `just cartridges` again
   and `cmp` of the six. **Check that they really were rebuilt** —that
   `cartuchos` prints the three `ensamblar` lines or that the
   `stamp.txt` files change—: if they aren't rebuilt, the old ones are compared with themselves and it's always
   identical. Without the converter, faster and just as conclusive: build
   with `ensamblar.py` the before and after trees against the same
   generated files of `rom/build/*/`, which is what was done for this plan.
3. **`just tests`** green, and the suite: with the identical ROM no
   golden can change, so any red is from tooling or
   inherited.

The `.dbg`s aren't compared, for the reasons above.

### `git blame`

**It doesn't go into `.git-blame-ignore-revs`.** It meets `AGENTS.md`'s criterion
—no effect, demonstrated—, but measured it doesn't help: the new files keep
saying "was the cut", because ignoring a commit passes the blame to the same
file in the parent and here it doesn't exist; and it makes `main.s` worse, because each
new `.include` shows up attributed to some random old commit. And since the
repo's config already has `blame.ignoreRevsFile`, the damage would be by default.

What does go, in the prose commit, to "`git blame` y los cambios mecánicos"
in `AGENTS.md`: that for `rom/src/` it is **`git blame -C
--diff-algorithm=histogram <archivo>`**, with what was measured. `git log --follow` doesn't
cross the cut —no new file is half of `main.s`— and `git log -S`
keeps working the same, because it searches by content in all files.

### The open branches

A direct merge of an old branch with the cut gives a conflict in the whole of `main.s`:
git sees a thirty-thousand-line file replaced by a hundred-line one.
The recipe, tried in a clone with a branch that changed one line of the
shop and added a `.proc` between two stretches:

    CORTE=<el commit del corte>
    git merge "$CORTE^"
    git merge-base --is-ancestor "$CORTE^" HEAD || { echo "falta main hasta el corte"; exit 1; }
    git diff --quiet "$CORTE^" "$CORTE" -- . ':!rom/src' || { echo "el corte no es sólo el script"; exit 1; }
    git show "$CORTE^:tools/ensamblado/partir_main.py" > <scratchpad>/partir_main.py
    python3 <scratchpad>/partir_main.py --dir rom/src && git add -A rom/src && git commit -m "Partir main.s, reaplicado sobre la rama"
    git merge -s ours "$CORTE"
    git diff --name-status "$CORTE" HEAD -- rom/src   # ni una A ni una D
    git merge main                                     # lo que vino después, normal

It is the version with the critic's mechanical guards (correction B). The script
is taken from `$CORTE^` because in `main` it gets deleted in the prose commit, and it is the
exact version that produced the cut. The `--dir rom/src` is needed because,
run from the scratchpad, the script computes the repo root from
where it is.

The guards are what make the `-s ours` safe, which silently discards everything
the other side brings and the branch doesn't:

* `merge-base --is-ancestor`: if the branch doesn't contain everything before the
  cut, `-s ours` throws it away.
* `git diff --quiet … ':!rom/src'`: the cut has to be **only** the script's
  output. If it brought anything else —prose, the fingerprint, a
  `.segment`—, `-s ours` would delete it in every old branch. That's why the cut
  commit carries nothing else.
* `--name-status … rom/src` without `A` or `D`: the branch split into the same
  files as the cut. An `A` or a `D` means the anchors fell
  differently. The `M`s are the branch's own.

In the plan's trial, the result was exactly the branch's two changes,
in `tienda.s` and in `control.s`.

**If the branch changed the text of an anchor** —a section mark the
script looks for—, the script refuses (it happened in the first trial, which edited
precisely the shop's mark). **`TRAMOS` is not touched**, which would make the branch
split differently from `main`: that change is reverted on the branch, the cut is made, and
it is reapplied in the new file.

It's best to make the cut with as few open branches as possible, and
to warn the ones there are. On 2026-09-25 two agents are running that don't touch
`main.s`, but the MSU-1 one may touch `tools/ensamblado/cartuchos.py`, which
commit 2 also touches near `huella()`.

### Second stage, separately

Moving changes the ROM: each move is verified with `just tests` and the
suite **with no golden changed** —the behaviour doesn't change, only the
addresses—, and the `.sym` changes in the shifted symbols. Things can only be
moved **within the same segment**: moving something from bank 0 to 1 changes how
it is called (`jsr` versus `jsl`, the data bank) and is a code change,
not a move. What the cut leaves in a file that isn't its own:

* `poner_switch` in `ruta_del_heroe.s` → `variables.s` (measured: changes the ROM);
* `volver_al_mapa`, `volver_de_batalla` and `poses_npc_olvidar` at the end of `items.s`;
* `sonido_de_codigo`, `sonido_tocar` and `destello_de_codigo` at the end of
  `quietos_que_animan.s` → `efectos_de_sonido.s` and `destello_de_personaje.s`;
* `menu_hp_escribir` in `equipo_desde_eventos.s` (FAR; `menu.s` is bank 0:
  they can't be joined without changing the call);
* `exp_sumar` and `aprender_del_nivel` in `batalla_lazo.s` → `nivel.s` (both FAR);
* `titulo_subir_menu`, `hp_inicial_poner` and `actor_nivel_de` in `banco1.s`;
* orphan comments stuck above a mark, which belong to the previous stretch
  or to nothing: before "la pantalla de ranuras" (about
  `titulo_subir_menu`, which moved) and before "usar un ítem en la pelea".

And the one that would be worth most and isn't a move: **`interprete.s` is a single
`.proc correr_codigo`** with all the opcode handlers inside, and it is the
file the most commits touch. Splitting it means cutting **inside** the `.proc`
—an `.include` of one file per opcode family—, which is byte-for-byte
identical (tried: the test cut between `bcc :+` and its `:` fell inside a
`.proc`), but leaves files that start in the middle of a scope, with local
labels from another file. It is a separate readability decision.

### Questions for the critic

1. **The granularity.** Sixty-two files, some of forty lines
   (`control.s`, `items_banco1.s`). The coarse alternative comes from deleting
   anchors in `TRAMOS`; the measurement doesn't change.
2. **The names.** Above all the pairs that can be confused:
   `destello_de_personaje.s`/`destello_de_pantalla.s`, `items.s`/`items_banco1.s`,
   `equipo.s`/`equipo_desde_eventos.s`, `batalla.s`/`batalla_puentes.s`, and the
   ones named after their dominant content and not all of it (`grupo.s`, `npcs.s`,
   `celdas.s`, `banco1.s`).
3. **The stretch that stays in `main.s`.** The generated files and two constants; the
   alternative is a `generados.s` and `main.s` being only the list.
4. **`.s` versus `.inc`**, above.
5. **The explicit `.segment` per file** (commit 4). For: whoever opens
   `nivel.s` knows it is in bank 1 without looking at `main.s`. Against: it suggests
   the file is independent, and it isn't —the `.a8`/`.i16` widths and the
   order still come from the previous one—, and it is one more line in each file that
   an old branch has to get through.
6. **The recipe with `-s ours`**, which is the sharpest part of the plan.
7. **Keeping the script committed in `tools/`** until there are no old
   branches, instead of in the scratchpad: the fingerprint covers `tools/*/*.py`, so
   its commit rebuilds the cartridges.
8. **Not using `.git-blame-ignore-revs`**, against what the task suggests.
9. **"`symbol` in main.s" outside `rom/src/`**: leave it, change it to
   "`symbol` in `rom/src/`" or name the file. Naming the file is the
   most useful today and the first thing to go stale with the second stage; the symbol
   alone is found with `grep -n '^símbolo:\|\.proc símbolo' rom/src/*.s`.

### What the critic settled

Critiqued on 2026-09-25 on top of `c71666e`, which measured the above again
(ROMs and `.sym` identical through `ensamblar.py` and through `just cartridges`; `just
pruebas` green on the split tree with the tooling change, and
exactly 3 reds without it; without the `huella()` change, editing `tienda.s` doesn't
change the fingerprint; `blame -C --diff-algorithm=histogram` gives 0 different lines).
Its changes, which are mandatory:

* **A.** The reproducibility check carries `git add -A rom/src` and
  `--cached`: already corrected above.
* **B.** The open-branches recipe carries mechanical guards: already
  corrected above. From that follows that **the cut commit is the
  script's output and nothing else**.
* **C.** The tooling commit carries a test that everything
  `fuentes()` returns is in the fingerprint, and it is shown to fail with the
  `huella()` from before.
* **D.** The script is deleted in the prose commit, not "later on".
* **Names**: `items_banco1.s` → `banco_de_la_pantalla.s` and `equipo.s` →
  `pantalla_de_equipo.s` (already in the table and in `TRAMOS`). The rest stays.
* **Commit 4** —explicit `.segment` per file— goes in.

## Log

**2026-09-25, execution.** On top of `cd4adf8`.

1. Plan and script: the cherry-pick of `5377d8b` with the names and the
   corrections A, B and D. `partir_main.py --ver` finds all the anchors.
2. Tooling: the plan's patch, and the list of files of `huella()`
   moved out to `cartuchos.archivos_de_la_huella(fuente)` so it can be tested.
   C's test, `test_everything_that_builds_the_rom_is_in_the_fingerprint`, looks at the
   real tree and at one built by hand with a `main.s` that includes a
   `tienda.s`; the second is the one that catches it today, when `main.s` still doesn't
   include any `.s`. With the `huella()` from before —only `main.s`— in a
   copy, it goes red: `Left contains one more item: '…/tienda.s'`.
3. The cut is **`391930c`**, and it is the script's output alone: from its
   parent, script + `git add -A rom/src` + `git diff --cached --stat
   391930c` gives empty; `git diff --quiet 391930c^ 391930c -- . ':!rom/src'`
   too. `just cartridges` rebuilt the three cartridges (the seal changed) and
   `abl.sfc`, the two `prueba.sfc` and their three `.sym` came out identical to
   commit 2's. `just tests`: 611 passed, same as in 2.
4. Explicit `.segment` in the 55 that didn't have it. Left without it are
   `registros.s` and `ram_lejana.s`, which emit nothing (constants and
   `.assert`). Same verifications, same results.
5. Prose, guided by the cut's diff: the header of `main.s` (the
   SPC700 paragraph that was there moved down to `spc700.s`), the six citations by
   position that the cut left pointing to another file, the citations of
   `main.s` in the rest of the repo —those naming a symbol now name
   its file; those talking about the whole ROM, `rom/src/`; the
   historical ones ("the `main.s` from before") and those talking about the assembly's
   entry point stay—, and `AGENTS.md`: how it is split, the fingerprint, the
   `.inc` trap and `blame` with histogram. And the script is deleted.

Of the 16 lines of `--colgadas`, only `tinte.s` was real (the others
say "above"/"below" a cell, a stack or a palette); the grep for
"archivo|allá abajo|más abajo" added five: `batalla_puentes.s`,
`menu.s`, `ventana_del_mapa.s` and two in `arranque.s`.

**For a branch from before the cut**: the recipe in "The open branches",
with `CORTE=391930c`. The script is no longer in the tree: it comes from
`git show 391930c^:tools/ensamblado/partir_main.py`, and is run with
`--dir rom/src`. The `--ver` and `--colgadas` the plan cites belong to that
script.

What was **not** done, on purpose: the second stage (moving routines to their
file, splitting `interprete.s`), which changes the ROM and goes separately.
`componer_mensaje`, which `tools/port/snes_convert.py` cited and which no longer
existed before the cut, is still cited.

**The recipe, tried with the real cut** (before handing in, because
`main` hadn't moved and there was no real use): a temporary branch from
`cd4adf8` that changed one line of the shop in `main.s`; the four
guards passed, `--name-status` gave only `M rom/src/tienda.s`, and the
following merge with the whole branch —with the `.segment` and the prose, which
touch the first line of `tienda.s`— went in without conflicts and left
exactly that line. The branch was deleted.
