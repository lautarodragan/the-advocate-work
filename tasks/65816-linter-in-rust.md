---
name: "A 65816 linter, in Rust"
description: "Checks for common traps that assemble fine but are wrong: pl* before a conditional branch, jsl/rtl against jsr/rts, the unbalanced stack, and register width as a study; a tool in tools/ that knows nothing about ABL, with the game's exceptions in rom/"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-02: "are there equivalents to linters, formatters or other
static analysis tools for assembler? In particular, maybe some check for common
traps —things that compile fine but are surely wrong— would add value". For the 65816 there's nothing worth adopting,
so it gets made: "and let it be made in Rust".

The precedent is Ratona's bank guard
(`la-guarda-de-los-bancos.md`), which reads the `.dbg` and flags branches
to another bank. Trap 1 is the one in `AGENTS.md`, "The trap that bit
most often".

## What was done (2026-10-02, Carpintero, on `a6ba9693`)

**Goombario**, `tools/snes/goombario/`, on the PATH as `goombario`. The
name is from Goombario, the Paper Mario companion whose power is "Tattle":
telling what he knows about everyone. A linter is that. taro can change it.

It reads **the ROM, the `.dbg` and the source**, just like Ratona's bank
guard: it doesn't disassemble by guessing, each line of the `.dbg` says where
its bytes went and the instruction is read from the ROM there. The source is read for the
declared widths —`.a8`/`.a16`, and `rep`/`sep` under `.smart`—, following
the `.include`s from `main.s` and reproducing the body of each macro where
it's used. **The immediates verify that reading**: the size with which `ca65`
assembled each one has to be the width read from the source, and on
today's runtime zero of them don't match.

Four checks; the README says how each one looks and what it doesn't see:

1. **`pull-branch`**: from each `pl*`, along every path until
   each flag it set is set again, a conditional branch that
   looks at it. N and Z for `pla`/`plx`/`ply`/`plb`/`pld`; all four for `plp`.
2. **`call-return`**: it walks each routine from its entry —each target of
   `jsr`, `jsl` and `jsr (tabla, x)`, and the vectors— along every branch and
   jump, even into other routines, and flags each `rts`/`rtl`/`rti` that
   doesn't match how some caller entered it.
3. **`stack`**: in the same walk, the bytes pushed since the entry,
   with the width of each `pha`/`phx`. What isn't followed —a loop that
   pushes, `tcs`/`txs`, a jump through a pointer— isn't an error: `--unfollowed`
   lists it. On the release there are four places: two loops that push
   (`big_palette_build`, `pic_tick`) and the two `jsl`s to the LZ2's trampoline in
   RAM.
4. **`width`**: see below.

On ABL's side: `rom/pruebas/herramientas/test_linter.py`, over the three
cartridges, and `rom/excepciones-del-linter.txt`.

### What it found in the runtime

**Three width declarations that weren't what runs** (check 4), in their
commit: `op_var` after `jsr random_next`, `medicine_use` after
each `jsr per_hundred` —both return with A16, and the code knows it— and
`ba_t_sound`, which is entered with A16 (that's how the seven `jsl`s of the
battle call it) and inherited the `.a8` from the previous bridge. **They don't change a byte**: there
was no immediate between the old declaration and the next one. They were the
trap in `main.s`'s header waiting for the first one to be added.
`git blame` lands on the translation commits; the intent is stated by the
comments at each place ("the dividend, sixteen bits", "returns with
A16", "A16 the index"). Since they don't change the ROM, the test that shows them
is the linter's: before the fix it gave those 16 lines.

**Exceptions**: twelve `pull-branch` where the branch looks on purpose at what
was pulled —`pla` and `beq` is also the short way of asking whether it's
zero—, and the shared exit of `slots_screen` (`close`), which pulls the
return address to get to what its caller pushed, as its
comment says. Each one with its reason in the file.

**No `jsl` against `rts` nor unbalanced stack** for real.

### The red I saw

Four breakages at once, one per check, and the test flagged them in the three
cartridges:

    event_routes.s:686  without the `cmp #0` after the `plx` (the historical bug)
      "pull-branch: in `ev_route_frame`, `bne no_blocked`: `bne` looks at Z,
      and the last instruction to set it is the `plx` at event_routes.s:680"
    battle_bridges.s:96  the `rtl` of `ba_t_ppu` changed to `rts`
      "call-return: `ba_t_ppu` is entered with jsl (at menu_experience.s:113),
      and this path out of it is an `rts`, which pulls 2 bytes …"
    medicine.s:245  an extra `phx` on entering `k_in_x`
      "stack: `rts` leaves `k_in_x` with 2 bytes still pushed, by `phx` at
      medicine.s:245"
    audio_package.s:170  without the `sep #$20` before `.a8` and `lda #3`
      "width: `lda` was assembled for a 8-bit A, and on the path from
      `upload_sample` A is 16 bits wide here: the CPU reads it with a
      different length"

The first time two false ones came out as well: the `.align` of `header.s` and a
`.dword` of `mapdata.inc` read as code, because `ca65` doesn't give them a
type. It was fixed in its own commit (the line's directive decides) and the
second time only the four came out. All reverted.

### Width: it came out as a check

Measured on the release, with `--stats`:

* **immediates** (`lda #`, `ldx #`…): 4010 decided, 0 wrong; 210 undecided;
* **the other instructions that depend on width** (loads, stores,
  arithmetic, pushes, transfers): 13676 decided, 0 wrong; 460
  undecided.
  Before the fixes it gave 8 wrong, all from the three declarations;
* **calls** against the width the callee declares at its entry, for
  the registers it uses before setting them: 2606 decided, 0 undecided.
  Before, 8 wrong: the seven of `ba_t_sound` and the one inside.

Undecided is what comes after an `xce`, a `plp` without its `php`
or a call that returns with different widths depending on the path. Zero
false positives after the macro business —their inner `.a8`s, and the
`.repeat`s inside a macro, which the `.dbg` doesn't mark as macro—, so
it goes as a check and not as a study.

## The numbers

`just pruebas`: 1008 (1005 + the three cartridges of `test_linter.py`).
`just -f tools/justfile test`: 39. `cargo test -p goombario`: 5 + 8.
`abl.sfc` of `release`: `35c76500…`, the base's: `NO_CACHE=1 just
cartuchos` before and after the declarations, and `just cartuchos` at the end,
with the three `.sfc` and the three `.msu` byte for byte the same. No golden
moved. `main` didn't move in the meantime (`a6ba9693`): there was nothing to
merge.

## What remains

* The `pull-branch` check can't tell the branch that looks at what was pulled
  on purpose from the one that meant to look at what came before: the exception says that.
* A loop that pushes leaves the stack of its whole routine unchecked (two today).
* A routine that returns with N/Z from a `pl*` and a caller that branches on that
  after the `jsr` isn't looked at: check 1 doesn't cross calls.

## When merging

**Install `goombario` globally**: `just -f tools/justfile install
goombario`, from the main checkout. Without that `test_linter.py` doesn't
find the executable. Nothing else: `cartridge` was installed in the local `bin/`
only to build with the worktree's runtime, and didn't change.
