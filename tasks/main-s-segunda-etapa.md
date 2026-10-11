---
name: "The second stage of splitting main.s"
description: "Moves, interprete.s split (B) and the table dispatch (C): done"
type: refactor
status: done
---

The cut of 2026-09-25 (`391930c`, see `done/partir-main.s.md`) split
`rom/src/main.s` into contiguous stretches **without reordering**, because splitting does not
change the ROM and moving does. So routines were left in a file that is not
theirs. That is already done (see "The moves"). Then came `interprete.s`:
taro chose **B, and C afterwards** among the partitions of "interprete.s". B is
done (see "B, done"), and so is C (see "C, done", at the end).

## The moves

Done on 2026-09-25, on `d99694d` and with `main` merged in the middle
(`4147242`). One per commit and without touching the moved text:

| commit | what | from → to |
|---|---|---|
| `d63130b` | `poner_switch` | `ruta_del_heroe.s` → `variables.s`, after `var_escribir` |
| `14c71e5` | `volver_al_mapa`, `volver_de_batalla` | `items.s` → `cargar_mapa.s`, after `cargar_mapa` |
| `4811091` | `poses_npc_olvidar` | `items.s` → `npcs.s`, after `subir_pose_npc` |
| `be42124` | `sonido_de_codigo`, `sonido_tocar` | `quietos_que_animan.s` → `efectos_de_sonido.s`, at the end |
| `14eb259` | `destello_de_codigo` | `quietos_que_animan.s` → **`destello_de_pantalla.s`**, after `destello_tick` |
| `0164143` | `pan_cuadros` | `destello_de_pantalla.s` → `camara.s`, after `pan_tick` |
| `6e49fc5` | `exp_sumar`, `aprender_del_nivel` | `batalla_lazo.s` → `nivel.s`, at the end |
| `1874a93` | `menu_hp_escribir` | `equipo_desde_eventos.s` → `nivel.s`, after `texto_maximo` |
| `c2df013` | `actor_nivel_de` | `banco1.s` → `nivel.s`, before `nivel_param` |
| `70f1716` | `hp_inicial_poner` | `banco1.s` → `nivel.s`, before `curar` |
| `5f395e0` | `ba_mensaje` | `batalla_habilidades.s` → `batalla.s`, below its comment |
| `3efad4e` | the comment of `titulo_subir_menu` | `titulo.s` → `banco1.s`, next to the routine |

What changed from the list before, measured on `43bd1aa`:

* `destello_de_codigo` was going to `destello_de_personaje.s`, but it sets
  `destello_rgb`/`destello_nivel`/`destello_resta`, which is the **screen**
  flash.
* `menu_hp_escribir` did have a home in bank 1: `nivel.s` is what the
  menu writes about each actor and does not leave the cartridge.
* Two that were not on the list: `pan_cuadros` (GetPanWait, at the end of the
  flash stretch) and `ba_mensaje`, which was the owner of the "orphaned comment
  before using an item in battle": they were born together in `9527063` and `72109da`
  put the items between the two.

**What was not moved, and why**: `titulo_subir_menu` (its home, `titulo.s`, is
in bank 0: moving it back up changes the `jsl` of its three callers; only
its comment was brought next to it). For the same reason `hp_inicial_poner` stays far from
`equipo_inicial_poner` (`variables.s`, bank 0) and `menu_hp_escribir` from
`menu.s`. The ends of `ram_baja.s` and `ventana_del_mapa.s` end in a
comment, but they talk about their own file: they are not orphans.

**How each one was verified.** `just cartuchos` and `just pruebas` green
(with `test_cores.py` inside) after each commit, without any golden
changed or any test touched. The ROM changes in each one (the first, 2352
bytes of `abl.sfc`). That no routine ended up assembled with another width was
checked by a throwaway script that builds `ca65 -l` of the tree before and of the one
after, against the same generated files of the three cartridges, and compares routine
by routine the listed bytes —with `rr` where the linker relocates— and the text:
in all eleven, 0 different blocks out of 2015/2257/1378. Tested the other way round: changing
the `.a8` of `hay_rutas` to `.a16` flags it. The comment's commit came out
with the three ROMs byte-for-byte identical.

**`git blame -C --diff-algorithm=histogram`** follows them: in seven of the eleven
it gives for each moved line the same commit it gave at the origin. In the other
four it gets a few generic lines wrong that the diff pairs with the
destination's neighbours: 2 of 89 (`volver_*`), 4 of 56 (`pan_cuadros`: `sep`,
`.a8`, `rts`, `.endproc`), 6 of 187 (the end of `aprender_del_nivel`, identical
to that of `curar_actor`, which was the end of `nivel.s`) and 10 of 28
(`actor_nivel_de`, the `rep`/`.a16`/`and #$00FF` identical to those of
`nivel_param`).

## interprete.s

A single `.proc correr_codigo` with the 46 handlers inside —measured on
2026-09-25, like everything below—. This is what was measured and the proposal
from before choosing; what was done is in "B, done".

### How much each part is touched

`git log` without merges over the `main.s` from before the cut (`391930c^`, since
2026-09-03, 214 commits) plus `interprete.s` afterwards, distributing each line
of each hunk among the handlers according to the version on each side. The
cut and the four commits of `.git-blame-ignore-revs` are taken out (the rename of
`ec94369` touched 70 handlers), and the old names are counted with the
new ones (`op_si` is `op_if`). What remains: **76 commits touch `correr_codigo`**.

| family | handlers | commits | lines changed | size today |
|---|---|---|---|---|
| flow | dispatch, if, if_var, if_actor, goto, delay, key | 41 | 935 | 599 lines, 782 bytes |
| scenes | shop, battle, save, game_over, access, teleport | 23 | 376 | 238, 274 |
| screen | tint, flash, flash_screen, shake, pan, weather, picture×3, animation, tile_sub, terrain | 16 | 482 | 455, 679 |
| audio | bgm, fade_bgm, sound | 14 | 286 | 80, 68 |
| party | gold, item, party, actor_sprite, heal, equipment, skill | 12 | 235 | 203, 265 |
| variables | switch, var, timer | 12 | 340 | 308, 364 |
| movement | route, route_event, place, place_var, swap, wait/stop_routes | 12 | 296 | 261, 342 |
| messages | message, choice | 9 | 91 | 79, 87 |

What matters is inside "flow": **the dispatch alone —the
chain of `cmp`/`bne`/`jmp`— is touched by 34 of the 76.** No handler goes
beyond 9 (`op_message`), and almost all have 2 to 4, counting the one that created them.
Each new opcode adds its comparison to the dispatch and its body at the end of the
`.proc`: those are the two places where two branches collide, and no partition
by family separates them. Since 2026-09-18 only 15 commits touched
`correr_codigo`: the pace has already slowed down.

### What was tried (in the scratchpad, uncommitted)

**Each handler can be its own `.proc`, and it comes out byte for byte identical.**
Only the scopes are closed: `.endproc` before each handler's comment
and `.proc op_x` instead of `op_x:`. The references that cross from one handler to
another are 42 and nothing more: the 40 `jmp otro` back to the loop (they become `jmp
correr_codigo::otro`, the same absolute `jmp`), the `bra lugar_plantar` of
`op_place_var` to `op_place` (`op_place::lugar_plantar`), and the `bne
op_route_event` of `op_route`, which is already global. Built against the generated files of
`release`, `tests/main` and `tests/special`: **the three ROMs identical**. And
also identical with an explicit `.a8`/`.i16` at the start of each handler,
that is, none is assembled with a width inherited from the text above.
The only thing that changes is the `.sym`: `correr_codigo::abrir` becomes
`op_shop::abrir`; no test or tool reads the locals of
`correr_codigo` (grep of `correr_codigo::` and `op_*::` in `pruebas/` and
`tools/`).

### The possible partitions

**A. `.include` inside the `.proc`, by family** —what the cut's plan
proposed—. Byte for byte identical. It gains: the diff is only moving text. It loses:
eight files that start in the middle of a scope, with `jmp otro` to a label
in another file and without a `.proc` that says where you are; `blame` and the
reader have to know that the file does not exist on its own.

**B. One `.proc` per handler, and the files by family**, in the same
order as today. Byte for byte identical (tested above). It gains what A gains without its
defect: each file starts with a `.proc` and its widths, and a handler is
a unit that is found with `grep '\.proc op_'`. It costs 42 mechanical
lines besides the cut. It does not solve the dispatch, which stays in
`interprete.s` as the point where two new opcodes collide. It is verified
like the cut: the three ROMs identical and `just pruebas`.

**C. B plus a table dispatch**: a `cmp` against the number of opcodes, `bcs` and `jmp (tabla,
x)` with one `.addr` per opcode in the order of its number. **It changes the ROM.** The
numbers, from the 65816's cycle table and not measured: today's chain costs
`5k + 7` cycles for the opcode at position k, that is from 7 (`OP_MESSAGE`) to 227
(`OP_GAME_OVER`, the 45th), and the table some 23 for all; in bank 0 bytes,
the chain is 45 × 7 = 315 and the table 46 × 2 = 92 plus some 15 of code,
**some 200 bytes free in the tightest bank**. And if the table is emitted by
`tools/protocol/` from `events.toml` —a handler name by
convention—, adding an opcode stops touching the dispatch: the number keeps being
chosen in a single place. It loses: it clobbers X in the dispatch, which today does not touch it
(it needs checking that no handler reads X before writing it), it forces
the numbers to be contiguous or the gaps to be filled, and giving
`tools/protocol/` a new output is a decision of that project.

Splitting by **frequency of change** has nothing to go on: no handler stands
apart from the rest, except the dispatch, which is what C deals with.

### The recommendation

**B, now**, as a mechanical commit alone and verified like the cut —the three
ROMs identical—, with one file per family of the table. **C afterwards and separately**,
if taro wants the two hundred bytes or to get the dispatch out of the way: it changes the
ROM, and it is the one that really removes the point where branches collide.

## B, done

On 2026-09-25, in four commits: each handler to its own `.proc` in the
same file; the cut into files (only the output of a throwaway script
modelled on `partir_main.py`); the `.segment` and the widths at the start of
each new file; and the prose. The first three with the three ROMs byte for
byte identical to those from before and `just pruebas` green; see the messages.

Two corrections to what was measured above. The references that cross from one
handler to another are **46, not 42**: the 45 `jmp otro` —all of the
interpreter's— and the `bra lugar_plantar`. The `bne op_route_event` does not cross:
`op_route_event` is a label of `op_route`, not a handler. And the
handlers are 46 because `op_battle_destination` —which `op_battle` jumps to
with `jmp`— stays in its own `.proc`, but the dispatch compares **45**
opcodes: those of `events.toml` minus `OP_DONE`.

**One file per family did not happen**, because the families are interleaved
in the ROM's order and putting them together is moving code: the scenes fall in five
stretches and screen in four. What remained is one file per contiguous stretch with a
theme, `interprete_*.s`, and when a theme continues in another file the header
says so. The list is that of `main.s`; the why of each grouping is in the
message of the cut's commit.

`blame -C --diff-algorithm=histogram` crosses the cut: over the 2399
lines, each one gives the same commit as in the `interprete.s` from before except
the final blank line of twelve files, which blames the cut of `main.s`. None
blames the cut of `interprete.s`.

## C, before doing it

**A table dispatch**: `jmp (tabla, x)` with one `.addr` per opcode, instead
of the chain of `cmp`/`bne`/`jmp`. It changes the ROM. It is what really
removes the point where two branches that each add an opcode collide —with B,
the chain in `interprete.s` is still the only place they all touch—.

What is known, from the earlier proposal (numbers from the 65816's cycle table,
not measured): the chain costs `5k + 7` cycles for the opcode at
position k, from 7 (`OP_MESSAGE`) to 227 (`OP_GAME_OVER`, the 45th), and the table
some 23 for all; in bank 0 bytes, the chain is 45 × 7 = 315 and the
table 46 × 2 = 92 plus some 15 of code, **some 200 bytes free in the tightest
bank**. If the table is emitted by `tools/protocol/` from `events.toml`
—the handler of `OP_X` is called `op_x`, by convention—, adding an opcode
stops touching the dispatch. Giving `tools/protocol/` that new output is a
decision of that project (which is in English and knows nothing about this game: the
handler's name would have to come from a rule, not from a field).

What was learned doing B that changes or refines C:

* **The numbers are already contiguous**: `events.toml` goes from `0x00` to `0x2D` without
  gaps, and the 45 that are not `OP_DONE` have their `op_x` with that exact
  name. The table does not have to fill anything; `OP_DONE` (and any extra
  number, with a `cmp` against the count and a `bcs`) goes to today's `stz ev_activo`
  / `rts`.
* **No handler reads X before writing it**, in text order and
  without following jumps or `jsr` (a throwaway script over the 45). Today's
  dispatch does not touch X, so clobbering it would be new, but none
  expects it.
* **`tax` with 8-bit A and 16-bit indices copies the 16 bits of C**, which means
  the high byte of A has to be zero beforehand: with the opcode read in
  8 bits, B carries whatever the previous handler left. A
  `rep #$20` / `and #$00FF` / `asl` / `tax` / `sep #$20`, or equivalent, is needed.
* **`jmp (tabla, x)` reads the table from the program bank**, not from the data bank,
  and that matters here: the interpreter runs with the data bank set to that of the
  bytecode (see the comment of `op_shop`). A table read with `lda
  tabla, x` would read another bank.
* **They all enter with `.a8`/`.i16`** and Y at the first operand, and none
  depends on the width the previous one leaves in the text (the prototype with
  explicit widths showed it): the order of the handlers in the ROM does not
  matter to the dispatch.
* `op_battle_destination` is not an opcode: it does not go in the table.

## C, done

On 2026-09-25, on `73fc639`, in four commits plus the prose:

| commit | what |
|---|---|
| `a0b0358` | `protocol --jump-table`: `EVENT_OPCODE_COUNT` and the macro `EVENT_HANDLERS`, one `.addr op_x` per opcode in the order of the number |
| `40661ce` | the recipe `protocolo` and `test_los_generados_estan_al_dia` ask for it; the ROM does not change (the three byte-for-byte identical) |
| `79d765e` | the dispatch: `cmp #EVENT_OPCODE_COUNT` / `bcs op_done` / `asl` / `xba` / `lda #0` / `xba` / `tax` / `jmp (manejadores_de_opcode, x)` |
| `97614f8` | `test_la_entrada_k_de_la_tabla_salta_al_manejador_del_opcode_k` |

What was decided along the way:

* **The name comes from a rule**: the handler of `OP_X` is `op_x`. That is why
  `OP_DONE` got its own `.proc op_done` (the `stz ev_activo` / `rts` from the
  end of the chain), instead of being an exception.
* **It is a flag and a macro**, not something the generator always does: it requires
  contiguous numbers, and `music.toml` ends at 0xFF. The `.inc` stays in
  `rom/src/` because it is the same for all the cartridges and shadows nobody;
  the rule for generated files is about the per-cartridge ones.
* **An out-of-range opcode cuts the page**, as the chain did. It should
  never arrive —the converter emits it with the same numbers—, but it
  arrives if a handler miscounts its operands, and without a cap it would index
  outside the table. No test executes that path.
* **B is cleared with `xba` / `lda #0` / `xba`**, not with `rep` / `and` /
  `sep`: one cycle and three bytes less.

**X, A and the flags.** Each handler now enters with X = opcode × 2, A =
opcode × 2 with B at zero, C=0 and Z=0 (before: X whatever the previous one left, A the
opcode with garbage B, C=1 and Z=1). Four throwaway scripts that follow
branches, `jmp`, `jsr` and `jsl` —stopping at the return to `correr_codigo::otro`—
find no path that reads X, A, C or Z/N before setting them, neither
from the 45 handlers nor from the `jsr correr_codigo` of the three
callers (and theirs) on return. What they cross of `phx`/`plx` with X
unwritten is save-and-restore, or the return-address trick of
`cerrar` in `ranuras.s`.

**Measured**: bank 0 has 210 more bytes free in the three cartridges
(`.res N, $00` in `TABLAS` against the `.o` of each): release 2139 → 2349,
tests/main 1769 → 1979, tests/special 2463 → 2673. **Calculated, not measured**:
22 cycles from `cmp` to `jmp` for any opcode, against `5k + 7` for the
chain; three get more expensive (`OP_MESSAGE` 7 → 22, `OP_SWITCH` 12, `OP_ROUTE`
17). Weighted by how many times each opcode appears in the game's compiled
pages —static, not by how many times it runs—, from 87 to 22 cycles per
instruction.

Verified with `just cartuchos` and `just pruebas` three times on the
dispatch, green, without any golden changed or any test touched, and
`test_cores.py` three more times separately.
