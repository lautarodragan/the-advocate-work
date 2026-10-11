---
name: "The bank guard"
description: "A test that walks the .dbg and flags every absolute jsr/jmp that lands in another bank and every absolute ROM read outside bank 0: the rule in main.s that the assembler doesn't check"
type: feature
status: done
assignee: taro
---

Pepitero proposed it (`bank-1-filled-up.md`), without doing it: the
throwaway script with which he verified the moves to `FAR2` gave 0 before and
after each one, and the rule for where the code goes (header of
`tools/runtime/main.s`) "nada de esto lo revisa el ensamblador". A `jsr` to
a routine in another bank jumps to the wrong place without any error.

## What was done (2026-10-02, Ratona, on `5a93a5ca`)

`rom/pruebas/herramientas/test_saltos_entre_bancos.py`, over the three
cartridges. Harness Python, with no separate disassembler: **`ld65`'s `.dbg`
already carries what's needed.** Each `sym` says on which lines it's named
(`ref=`), and each `line` which bytes came out of it (`span=`, with `ooffs` in
the `seg` to go to the file). So the operand isn't read from the source with
a regular expression, like Pepitero's script: the opcode is read in the ROM,
which says the mode, and where the instruction goes is compared with where the
symbol is. The only thing about the 65816 that had to be written is the mode table of the
256 opcodes. The source is read only for the message.

What it checks, for each instruction that names a label (or an `=` that lands
in the ROM or on a register):

* absolute `jsr`/`jmp`: that the destination is in the instruction's bank;
* `jsr`/`jmp (tabla, x)`: that the table is in the program bank, **and that
  each entry lands on a label of that bank** —that's what the
  `opcode_handlers` comment says—. The table goes from its label to the
  next;
* `jmp (abs)` and `jml [abs]`: that the pointer is in bank 0;
* the long ones (`f:`, `jsl`, `jml`): that the bank written is the symbol's,
  with the `$00`/`$80` and `$01`/`$81` mirrors resolved;
* the absolute data ones —reads **and** writes—: that the data bank
  that code runs with, plus the address, is the symbol's place. The
  mirrors are resolved: low WRAM looks the same from `$7E` and from
  bank 0, and the registers aren't visible from `$7E`.

**The data bank isn't tracked: it's declared.** `BANCO_DE_DATOS` in the test:
`$7E` for the eight `battle*.s` that run in battle and for
`encounters.s` —both say so in their header—, and 0 for everything
else. **The only exception** is one routine: `scene_cgram_restore` lives in
`battle_scene.s` but it's called by `back_from_battle`, from bank 0, with the
data bank at 0 —its comment says so—, and it writes `CGADD` and the DMA with
absolute addresses. With the per-file table, the test flagged it (seven
lines, all registers). Another test in the same file checks that everything
named in `BANCO_DE_DATOS` exists, so that a rename doesn't silently leave it without
effect.

What it **doesn't** see, and its docstring says so: what changes the data bank
midway (the `ba_t_*` bridges, the interpreter with the bytecode's), what
is addressed through a pointer, and that what's entered with `jsl` is left
with `rtl`.

**`FAR2` with `+ FAST` doesn't need checking**: I tested it by changing the `jsl
f:battle_run` of `op_battle` to `+ FAST`, and `ld65` refuses to link —"Range
error"—, because `$C0 + $80` doesn't fit in 24 bits. It's stated in `main.s`.

### The red I saw

With four breakages at once, each one in the three cartridges (`release`,
`test-special`, `test-encounter-every-step`), and the test flagged them all:

    battle_loop.s:417  jsl f:exp_add -> jsr exp_add
      "en `ba_exp_allocate` ($C01ECC): `jsr exp_add`. `exp_add` está en el
      banco $01, y un jsr no cambia de banco: salta a $C0:8805. Entre bancos
      va jsl, con un rtl o una entrada `_l`."
    battle.s:313       lda f:actor_txt, x -> lda actor_txt, x  (con $7E)
      "`actor_txt` está en $00F3CD, y con el banco de datos en $7E esto va a
      $7EF3CD: lo que no está en ese banco va con `f:`."
    shop.s:74          lda f:item_id, x -> lda item_id, x
      "`item_id` está en $C3FFE4, y con el banco de datos en $00 esto va a
      $00FFE4 …"
    interpreter.s:80   op_reserved_39 = op_done -> = exp_add
      "`jmp (opcode_handlers, x)`. Las entradas de `opcode_handlers` se
      saltan en el banco $00, y éstas no caen en una etiqueta de ahí: $8805
      (`exp_add` en $018805)."

Afterwards, with the final version, the first two again. Everything reverted.

Commit: `d2cec449`. `main` didn't move in the meantime (`5a93a5ca`): there was
nothing to merge.

**A mistake of my own that the test now guards against**: the first version didn't strip
the `\n` from the last field of each line of the `.dbg`, which is `type=lab`,
so it recognised no label and gave zero while checking almost nothing. That's
why the test requires having looked at at least one instruction of each class
(jump, table, long, data).

## The numbers

On today's `main` it gives **zero** in the three cartridges. `just pruebas`: 1005
(1001 + the four new ones: three cartridges and the `BANCO_DE_DATOS` one). `just -f
tools/justfile test`: 39. `abl.sfc` of
`release`: `35c76500…`, the same as Pepitero's. The comment in `main.s` doesn't
move the ROM: `NO_CACHE=1 just cartuchos` before and after, the three `.sfc` and
the three `.msu` identical byte for byte.

## On merging

There's nothing to install: the test is harness Python, and `main.s` changes
only a comment. (To see the red I installed `cartridge` in the worktree's local
`bin/`, because the global assembler builds with the main checkout's
runtime; that doesn't travel.)
