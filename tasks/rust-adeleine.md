---
name: "Rust: Adeleine"
description: "tools/port/adeleine.py (which colours are lost and how they are grouped into palettes) as its own crate in tools/snes/, next to Voodoo, with the ROMs byte-for-byte identical"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-29: start with Adeleine to Rust. Already decided
(`workflow/decisiones/las-herramientas-se-separan-de-abl.md`): Adeleine is
its own crate in `tools/snes/`, next to Voodoo and not inside it, because
Voodoo does not decide colours (AGENTS.md). It knows nothing about RPG Maker: colours,
tiles and the limit of 16 per palette. It is the step before `rm2k-render`
takes on the CharSets.

## What was done (Tucán, 2026-09-29)

Three commits:

1. **The order of try_pack** (`3a8e381f`), on its own because **it changes the ROM**.
   `try_pack` left ties between tiles of the same size in the order
   of Python's `set`, which is that of CPython's hashes. Inside
   `reduce_colors` that set is rebuilt on every merge, so in Rust it could only
   be reproduced by emulating CPython's hash tables. Now the tie is
   broken by the colours. Measured by logging every call of a
   `NO_CACHE=1 just cartuchos`: 6 of 62 `try_pack` and 5 of 11
   `reduce_colors` change. All of them are a different allocation of colours among the palettes of
   the upper layer, with not a single pixel different, except map 3: before it
   merged 2 colours (6 pixels out of 3684) and now it fits without merging.
   The upper layers of maps 1, 2, 3, 10, 32, 79 and 255 change, and
   both ROMs. **taro: look at map 3.**
2. **The crate** (`c5e22f0b`): `tools/snes/adeleine/`, with a library and the
   executable `adeleine merge|pack|reduce --request <json> --out <dir>`.
   `port/adeleine.py` stays as the Python side and calls it with
   `stage.run`. The outputs stay byte-for-byte identical to those of commit 1.
3. The prose (`cecdb6e1`).

**What stayed in Python:** `luma_distance`. The callers do not ask for a
decision, but for the closest colour of a palette, inside a `min()`,
and they call it some 40,000 times per build. It goes when `sprites.py`
and `menus.py` migrate. Also staying were `CELL`, `tile_colors` and the memoization
of `merge_least_visible`: some 1,900 merges are requested and only some 200 are
distinct. Each subprocess costs between 2 and 5 ms, and the Python took about
2 s in total.

**On merging:** `just -f tools/justfile install adeleine cartridge`.

**The suites.** `just -f tools/justfile test` passes entirely, and so do
`cargo test -p adeleine` and `-p rm2k-snes-cartridge`. `just pruebas` gives
**4 reds, and all 4 come from commit 1**: with the Python of `5dc54ff7` and
the same binaries, `dcbest` passes.

* `test_caminando[3-down-avances3]` and `test_escena[talan]`: 4 pixels
  each, on map 3. They go from (16, 56, 65) to (24, 64, 82): they are the
  pixels that are no longer merged.
* `test_los_parches_versionados_…`: `0003.toml` no longer lists the two
  merges.
* `test_el_tema_no_recorta_en_su_pico[dcbest]` clips 2 samples. Running
  `just techos` rewrites half the table: headroom, mix fingerprints of six
  themes and the header, which now comes out in English. I did not commit it: it is bigger
  than this change.

If the new order is accepted, `just parches` and
`just techos` have to be run, and the two goldens replaced. If it is not accepted, the port to
Rust cannot be byte-for-byte identical in `reduce`.
