---
name: "The bytecodes, declared in Rust"
description: "The two bytecodes in a crate in tools/rm2k-snes/ with a macro, the .inc written by rm2k-snes-assemble when building, and out go protocol, its TOML files and the four generated files"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-10-02. It goes **after** `las-pruebas-sin-opcodes.md`,
so that no Python test needs the numbers.

- A crate in `tools/rm2k-snes/` (for example `rm2k-snes-bytecode`) declares
  the two bytecodes with a `macro_rules!` that gives the constants and a
  walkable table; `protocol`'s validations (contiguous numbers, names that
  don't repeat across the two, sizes) become tests or `const`
  asserts of the crate.
- `rm2k-snes-assemble` writes `event_opcodes.inc` and `music_opcodes.inc`
  —with the dispatch table— in the cartridge's directory, when building.
- Out go `tools/snes/protocol/`, its TOML files, the four generated and
  committed files, `test_protocol.py` and the `just protocol` recipe.
- Verification: the ROMs identical byte for byte, and the generated `.inc` identical
  line by line to the one committed today.

The bytecode is this runtime's format, not RM2k's: adding a feature is
adding opcodes (`decisiones/rm2k-plus.md`).

## How it turned out (Benteveíto, 2026-10-02)

**The crate is `tools/rm2k-snes/bytecode/`**, package `rm2k-snes-bytecode`:
the directory name follows its neighbours (`events`, `battle`), and the
package's the layer prefix. It's a library: it isn't installed, it goes into
`rm2k-snes-events`, `rm2k-snes-audio`, `rm2k-snes-convert` and
`rm2k-snes-cartridge`.

* `src/events.rs` and `src/music.rs` are the two declarations, each one an
  invocation of `bytecode!`:

      /// `CallEvent` inside a shared common event body: ...
      OP_CALL = 0x3F (body: byte);
      OP_CHOICE = 0x14 (length: count byte, on_cancel: byte)
          repeated options (window: word, destination: word);
      OP_PAN = 0x11 (operation: byte, dx: signed word, ...);

  The macro gives a `pub const OP_X: u8` per opcode, with the doc comment above,
  and `BYTECODE`, the walkable table (name, number, typed arguments,
  `signed` and `count`, and the repeated group). The sizes come from there
  (`fixed_size`, `size_at`): there's no longer an `OPCODE_SIZE` or `VARIABLE_SIZE`.
* The TOML files were transcribed with a script, not by hand: the header of each
  one became the module's `//!` —rewritten where it talked about the TOML,
  `README.md` or the generator—, and each opcode's comment became `///`. In
  the music ones the comments were per family (one every eight opcodes): they're
  repeated in all eight, so that each constant says what it is.
* Checked against what there was: the two `.inc` files identical line by line
  except lines 3 to 5 of the header, and each opcode's sizes
  identical to those of the generated `opcodes.rs` —with a throwaway test
  that included both—.

**The validations are `const` asserts**, with the message built in a
`const fn` because `panic!` in a constant doesn't format: a repeated number
("OP_RETURN and OP_CALL both take 0x3F"), a gap in the event dispatch
("nothing takes 0x40, 0x41"), a name in both bytecodes ("OP_END is in
the event bytecode and in the music one"), a repeated group without `count` or
a `count` without a group, and an empty bytecode **don't compile**. A type that doesn't
exist (`dword`) doesn't either: it's a token the macro doesn't expect. Two opcodes
with the same name are two `const`s with the same name. The first four
I saw fail by breaking `events.rs` on purpose. The crate's tests are
those messages —calling the same `const fn`s at runtime—, the
shape of the `.inc` and `tests/runtime.rs`, which replaces the half of
`test_protocol.py` that looked at the runtime: every `#OP_X` is declared and
no `OP_X =` is written by hand (seen failing with both).

**The assembler**: `rm2k-snes-assemble` writes `event_opcodes.inc` and
`music_opcodes.inc` in the cartridge's directory (`-I`) before looking for
the generated ones, so they're generated like the rest: the bank packing
walks them —they have no segments, they come out the same— and a stale copy next
to `main.s` is rejected like `mapdata.inc`'s. `main.s` didn't change.

**The `.inc` header changed** —it says `rm2k-snes-assemble` writes it
on each build—, with the same five lines, so the lines of the rest
don't move. The `.dbg` changes: the `.inc` file moves from
`tools/runtime/` to `rom/build/<cartucho>/`, with another size. And `just
entregar` no longer carries the opcodes in the `tools/runtime/` it copies: Mesen2
sees them like the other generated `.inc` files.

**An ABL test depended on the `.inc` being in the runtime**:
`test_saltos_entre_bancos.py` knew that the line of `interpreter.s` that
expands `EVENT_HANDLERS` is data because it gathered the expansion's `.addr`s
only from `tools/runtime/`. It went red in the three cartridges; now it
gathers the data from any file, in its own commit.

## The commits

1. `3954ce6c` the crate, the uses, the assembler and the four generated files
   deleted —the crate replaces them, and the `.inc` files in the runtime would cover up
   the cartridge's—;
2. `e2baa5ef` only deletions: `tools/snes/protocol/`, `test_protocol.py`,
   `conftest.py` —its only fixture was used by that test—, the recipes, the
   workspace member and profile;
3. `f6a9b6cc` the prose, guided by the diff of 2;
4. `e81834de` the fix to `test_saltos_entre_bancos.py`.

## Verification

* `NO_CACHE=1 just cartuchos` after each of the first three:
  the three ROMs identical to the baseline (`abl.sfc` `35c765009320d436…`). Against
  the baseline, `rom/build/` has the same files plus the six new `.inc`
  files, identical to the ones that were committed except lines 3 to 5; the
  three `.dbg` files change in the two lines for those `.inc` files (path and size:
  compared against the main checkout's `.dbg`, which had the same
  ROM, they're the only ones). 2 leaves everything identical to 1; 3 changes the
  `.dbg` files again, because the comments in `main.s` and `interpreter.s` shift
  line numbers.
* `just pruebas`: **993**, same as before, with the fix of 4.
* `just -f tools/justfile test`: **32** (it was 36: the four from
  `test_protocol.py` went away).
* `cargo test -p` of `rm2k-snes-bytecode` (19 and the runtime one),
  `rm2k-snes-cartridge`, `rm2k-snes-events`, `rm2k-snes-convert` and,
  with `--release`, `rm2k-snes-audio`.

## What to install on merging

    just -f tools/justfile install cartridge rm2k-snes-audio events convert
    cargo uninstall --root /usr/local protocol

`bytecode` is a library: it goes into those four. `convert` is needed
even though what it does doesn't change, because it took the constants from the
`events` module that no longer exists. The global `protocol` is left orphaned: nothing
calls it, and `just which` no longer lists it.
