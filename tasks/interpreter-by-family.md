---
name: "The interpreter by family"
description: "The opcode handlers grouped by family, and eventos_tick out of cargar_mapa.s: done"
type: refactor
status: done
---

Dispatch has been by table since 2026-09-25 (part C of
`second-stage-of-splitting-main-s.md`), so it can be done now. Watch out: the test
`test_table_entry_k_jumps_to_the_handler_of_opcode_k` requires each
handler to stay in `correr_codigo`'s bank.

Since part B each opcode handler is its own `.proc`, spread across
`rom/src/interprete_*.s` by contiguous stretch with a theme, not by family:
the families are interleaved in the ROM's order (the scenes fall in five
stretches) and grouping them meant moving code. With dispatch by table, where
each handler lives stops mattering, so grouping each family into its file is
moving whole `.proc`s **within the same segment**, same as the eleven moves
of the second stage.

It's verified the same way as those: `just tests` without any golden
changed, and the `ca65` listing compared routine by routine so that no
handler ends up with a different width (the script for that comparison was in
the second stage's scratchpad: redo it if it got lost). One family per
commit, without touching the moved text, so that `git blame -C
--diff-algorithm=histogram` follows it.

Decided with taro on 2026-09-25: the interpreter yes, and **not** reordering
all of `rom/src/` —bank 0 is tight, there's timing-sensitive code, it clashes
with every open branch, and for debugging in an emulator the `.dbg`'s symbols
are enough—.

**Along the way, another move of the same kind**, seen while debugging in
Mesen2: `eventos_tick` —with `espera_boton` inside, what runs the pages every
frame— lives in `rom/src/cargar_mapa.s`, together with `entrar_en_panico`,
`empezar_fundido` and `fundido_tick`. They stayed there because the cut cut
by stretches and that one started with `cargar_mapa`. See whether they have a
better file (same segment) and move them with the same checks.

## Done

On 2026-09-26, on `b581d4e` and with `main` merged twice along the way
(`7d7528a`, before touching the other agents' files, and at the end). One
move per commit, each `.proc` whole with its comment and without touching the
text:

| commit | what | from → to |
|---|---|---|
| `f043c13` | `op_choice` | permissions/jumps/switches → `interprete_mensaje.s`, at the end |
| `bfd27c8` | `op_if_var`, `op_goto` | variables and permissions → `interprete_condiciones.s` (`op_if_var` after `op_if`) |
| `d4aa17a` | `op_switch` | permissions → `interprete_variables.s`, at the end |
| `d8ebb29` | `pelea_arrancar` | teleport → `interprete_tienda_y_pelea.s`, at the end |
| `4b441c9` | the teleport file, renamed | `interprete_teletransporte_y_pelea.s` → `interprete_teletransporte.s` |
| `e7cac13` | `eventos_de_mapa`, `eventos_tick` | `cargar_mapa.s` → `paginas_de_eventos.s`, before the parallels |
| `52a788a` | `tinte_de_evento` | `cargar_mapa.s` → `tinte.s`, after `aplicar_tinte` |
| `40873aa` | `entrar_en_panico` | `cargar_mapa.s` → `arranque.s`, after `contar_perdidos` |
| `a0510b4` | `op_wait_routes`, `op_stop_routes` | `interprete_esperar_rutas.s` (goes away) → `interprete_movimiento.s` |
| `33a29df` | `op_sound` | sound effects → `interprete_musica.s`, at the end |
| `7bdb733` | `op_access` | permissions (goes away) → `interprete_guardar.s`, at the end |
| `2ef02b8` | the headers | only comments |

It ends up like this —the list and the order in the ROM are `main.s`'s—:

| file | handlers |
|---|---|
| `interprete_mensaje.s` | message, choice |
| `interprete_condiciones.s` | if, if_var, if_actor, goto |
| `interprete_oro_e_items.s` | gold, item |
| `interprete_tienda_y_pelea.s` | shop, battle, battle_destination, and `pelea_arrancar` |
| `interprete_efectos.s` | picture, picture_move, picture_erase, animation, weather |
| `interprete_movimiento.s` | route, place, place_var, swap, wait_routes, stop_routes |
| `interprete_destellos.s` | shake, flash_screen, flash |
| `interprete_cronometro.s` | timer |
| `interprete_musica.s` | bgm, fade_bgm, sound |
| `interprete_guardar.s` | save, access |
| `interprete_variables.s` | var, switch |
| `interprete_grupo.s` | party, actor_sprite, heal, equipment, skill |
| `interprete_game_over.s` | game_over |
| `interprete_mapa.s` | tile_sub, terrain |
| `interprete_teclas_y_esperas.s` | key, delay |
| `interprete_camara_y_tinte.s` | pan, tint |
| `interprete_teletransporte.s` | teleport |

What was decided along the way:

* **The files that already had a family name kept theirs**, even though the
  second stage's "Cuánto se toca cada parte" table groups more (gold with the
  party, the timer with the variables, the scenes in one). Keeping them
  separate costs nothing and renaming clashes with every open branch; only the
  one that lied (`..._y_pelea`) was renamed.
* **`op_access` goes with saving**: the permissions are game state, and the
  first one is the save one. **`op_goto` with the conditions**: it's the jump
  the converter puts in the `else`.
* **`empezar_fundido` and `fundido_tick` stay in `cargar_mapa.s`**: they're
  the teleport's fade, and `fundido_tick` calls `cargar_lo_pedido`, which is
  after them in the same file with `mapa_tema_callar` and `mover_heroe_a`.
  `eventos_de_mapa`, which the task didn't name, went with `eventos_tick`
  because it's its other half, and `tinte_de_evento`, which it didn't name
  either, because without them it was left alone between the return from the
  battle and the fade.

**How it was verified.** Each commit with `just cartridges` and `just tests`
green (707 until the first merge of `main`, 719 after), with no golden changed
and no test touched. That no handler ended up assembled with a different
width, with the second stage's script —`ca65 -l` of the tree from before and
of the one from after against the same generated files of release and
tests/special, routine by routine—: on each move, 0 blocks with differing
bytes, and the same between `main` and the end of the branch (2955 and 1589
blocks). The only text difference is the `.include` list. Tested the other
way round: an `.a16` at the start of `op_choice` gets flagged. The rename and
the headers came out with both ROMs byte for byte identical to those of the
previous commit. `test_cores.py` twice at the end, green.

**`git blame -C --diff-algorithm=histogram`** follows the thirteen moved
routines: of 683 lines, 648 give the same commit as in the origin. Of the 35
that don't, 30 go to the cuts of `main.s` (`391930c`) and of `interprete.s`
(`a1547b9`), which have the same text in another file —`jmp
correr_codigo::otro`, `.endproc`, `rts`, `phb`/`phk`/`plb`—, and 5 to the move
itself, paired with the destination's neighbors: `si_var_sigue:` and two
`iny` of `op_if_var`, an `rts` and `sin_espera:` of `eventos_tick`.
