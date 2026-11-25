---
name: "SuperFamiconv as an oracle for palette packing"
description: "A differential test for Adeleine: hand the same tiles to SuperFamiconv without quantizing and flag every picture it packs in fewer palettes than try_pack, or fits where try_pack says no"
type: test
game: advocate
status: testing
assignee: taro
agents: [Hurón]
author: hornero
links:
  found: [try-pack-picks-the-smallest-group]
  relates: [overload-and-remove-for-try-pack]
---

# What

A test in `snes/adeleine/` that converts a set of pictures with both
Adeleine's `try_pack` and SuperFamiconv
(<https://github.com/Optiroc/SuperFamiconv>, MIT, Rust since v0.12), and
**fails when SuperFamiconv needs fewer palettes than `try_pack`**, or fits
a picture `try_pack` answers `None` for. Not a dependency of the toolchain:
an external referee, the way bsnes is for snes9x in `test_cores.py`.

# Why

Packing is the one place where SuperFamiconv and Adeleine answer the same
question with no taste involved: with quantization off (no `-Q`), both only
choose how to group colours that all survive, and the one with fewer
palettes is simply better. Today nothing would tell us if `try_pack` got
worse, or how far it is from another good packer: the goldens see pixels,
and a packing that needs one palette more than it should only shows up as a
merge somewhere else.

It also measures [`overload-and-remove-for-try-pack`](overload-and-remove-for-try-pack.md)
from outside, and keeps measuring it after it lands.

# How

* **Lossless only**: `superfamiconv palette -M snes` with no `-Q`, so
  neither side invents or merges a colour; with `-N` and `-C 16` set to what
  the call gives `try_pack`. Comparing `reduce_colors` against `-Q` is not
  this task: SuperFamiconv's quantizer averages colours and dithers, which
  Adeleine never does, so there is no fair winner.
* **Colour zero has to agree.** SuperFamiconv picks it by the longest run
  of pixels unless `--color-zero` says otherwise; the test passes the one
  the caller reserves, or the counts differ for a reason that is not
  packing.
* **The pictures are built inside the test**, like Adeleine's other tests
  —random tiles with shared colours, at sizes where packing gets tight—, so
  it needs no game and names none. A run over a port's real layers is a
  measurement for the other task, not part of this test.
* **Without `superfamiconv` on the PATH it is skipped with a message**, as
  Goombario's tests are without `ca65`. Installing it is `cargo install`
  from a pinned commit; who compiles what in the container is in
  "Where this runs" in `AGENTS.md`.
* A case where SuperFamiconv wins is a bug in Adeleine or a known limit:
  the second kind goes in the test with its reason, like Goombario's
  `pull-branch` exceptions, so the list stays honest.

## Log

### 2026-11-22, Hornero: taken by Hurón

taro, translated:

> Can we start this one?

What Hornero checked first, through GitHub's public API: SuperFamiconv
is Rust and MIT on `main` (pushed 2026-11-16); the only Rust tag is
`v0.12.0-beta4`, the ones before it are the C++ tool. Its dependencies
are `clap`, `png`, `quantette` and `serde_json`.

### 2026-11-22, Hurón: SuperFamiconv cloned, checked and built

Cloned into `~/ref/superfamiconv` and pinned at the tag
**`v0.12.0-beta4`** (`ee30a652`, 2026-09-17), not `main` (`54f10893`,
2026-11-16): the tag's `palette` subcommand already has everything the
test needs —`-M snes`, `-N`, `-C`, `-Z`/`--color-zero`, and lossless
packing when `-Q` is absent—, and the three commits after it touch the
quantizer, the map's JSON and a library API; in `src/binpack/` they only
move the seeded PRNG to another module.

How it packs, read in its source (`src/palette.rs`,
`add_colors_from_tiles`, and `src/binpack/mod.rs`): each tile's colour set
reduced to 15 bits, colour zero removed, duplicates and subsets dropped;
then first-fit decreasing and overload-and-remove, unseeded and with 32
seeds, keeping the result with fewest palettes and then fewest colours.
The packer never sees `-N`: it only refuses afterwards ("Colors do not fit
in available palettes") if more palettes came out. Same for `try_pack`,
whose groups do not depend on `limit` until it runs out, so "fits in N"
and "how many it needs" are one question for both.

#### What was checked before building

* **No `build.rs`** in SuperFamiconv itself, and no committed binaries
  (`git ls-files`: sources, PNG test images, scripts, the PngSuite licence).
  Its own sources (8k lines) have no `unsafe`, no `std::net`, no
  `process::Command`, no `include_bytes!`.
* **`Cargo.lock`: 79 packages, 57 in the release build** (`cargo tree -e
  normal,build`; the rest are dev-dependencies: `assert_cmd`,
  `predicates`, `regex`…). Five proc-macros: `clap_derive`,
  `serde_derive`, `bytemuck_derive`, `palette_derive`, `ref-cast-impl`.
  Build scripts in `crc32fast`, `libc`, `libm`, `num-traits`,
  `proc-macro2`, `quote`, `radium`, `ref-cast`, `serde`, `serde_core`,
  `serde_json`, `zmij`: each was grepped for `Command`, `std::net`,
  `TcpStream`, `fs::write` and `File::create`. The only processes they
  start are `rustc --version` probes (and in `libc`, `freebsd-version`
  and `emcc`, behind their targets); the only files they write are
  `private.rs` in their `OUT_DIR` (`serde`, `serde_core`, `ref-cast`).
* **The network only for the fetch**: `cargo fetch --locked`, then `cargo
  build --release --locked --offline` (27 s), into its own `target/`.
* **The binary's 64 dynamic imports** (`nm -D --undefined-only`) are libc
  and the unwinder: no `socket`, `connect`, `exec*`, `fork`, `system`,
  `popen` or `dlopen`. Linked as `/usr/local/bin/superfamiconv`, a new
  name that no tool or suite uses.

What was **not** checked: the tag is not signed, nobody read the 57
crates' sources beyond their build scripts, and the fetch and build ran
as root with network for the fetch.

### 2026-11-22, Hurón: the test, and what it measured

`snes/adeleine/tests/superfamiconv.rs` in the-advocate, branch
`huron-sfc-oracle`, commit `47653361`. `png` is a new dev-dependency, but
it was already in the lock for Voodoo.

#### Its shape

* **Pictures from seeds** (splitmix64). Each has 6 to 12 themes of 6 to 14
  colours at 15 bits, and each theme shares up to four colours with the one
  before, as shades do. There are 48 to 160 tiles. Each tile draws 1 to 15
  colours from one theme, and one tile in six borrows a colour from another
  theme. Half the tiles have colour zero pixels. Random sets from one pool
  would rarely share anything, and shared colours are what packing is
  about.
* Each picture is written as an **RGB PNG**, with five-bit channels widened
  to eight as `c << 3 | c >> 2`. It is given to `superfamiconv palette -M
  snes -C 16 -N 8 -Z <colour zero> -j`, with no `-Q`. `try_pack` gets the
  same tiles without colour zero, with 8 palettes and 15 colours.
* **The referee's answer is checked before it is believed**
  (`check_referee`): every palette starts with colour zero and has at most
  16 distinct colours, the palettes together hold exactly the picture's
  colours at 15 bits, and every tile draws with one palette. A second test
  sends one picture through with 31 colours spread over the channel values
  and gets the same 31 back. Both were green on every seed tried, which
  answers the fairness question: without `-Q` SuperFamiconv keeps every
  colour, and it sees the same 15-bit colours Adeleine does.
* **Red** when SuperFamiconv fits in fewer palettes than `try_pack`, or fits
  where `try_pack` says `None`. The seeds where SuperFamiconv already wins
  are in `KNOWN`, grouped by reason. A listed seed that no longer wins is
  red too. The test runs 120 seeds, in about 2.5 s in debug, and
  `ADELEINE_ORACLE_SEEDS` runs more.
* **Skipped with a message** when `superfamiconv` is not on the PATH,
  checked with `PATH=/usr/bin:/bin`. CI (`.github/workflows/ci.yml`, `just
  rust-test`) does not install it, so the test is skipped there. It was not
  added to CI.
* `distribution`, `#[ignore]`d, prints both packers' counts with `-N 64`.

#### What it measured

It was red on its first run: 42 of the 120 seeds at eight palettes. Over
500 seeds with no limit (`ADELEINE_ORACLE_SEEDS=500 cargo test --test
superfamiconv distribution -- --ignored --nocapture`), the counts were:

| SuperFamiconv against `try_pack` | pictures |
|---|---|
| one palette more | 6 |
| the same | 133 |
| one palette fewer | 169 |
| two fewer | 121 |
| three fewer | 53 |
| four fewer | 16 |
| five or six fewer | 2 |

The worst case was `try_pack` needing 13 and SuperFamiconv 7.

**Most of the gap is not the algorithm.** `try_pack`'s comment, and the
Python's since `330708ae`, says each tile goes "into the group that grows
the least". The code takes the group whose union ends smallest. A
throwaway copy that minimises growth needs fewer palettes than `try_pack`
in 362 of the 500 pictures. Against SuperFamiconv it ties in 364, loses in
90 and wins in 46. This is a draft,
[`try-pack-picks-the-smallest-group`](try-pack-picks-the-smallest-group.md),
with the smallest reproducer: 10 tiles, 36 colours, 4 palettes against 3.
The 90 remaining are the overload-and-remove gain, with their own
reproducer in
[`overload-and-remove-for-try-pack`](overload-and-remove-for-try-pack.md)'s
log: 9 tiles, 30 colours, 4 against 3.

`KNOWN` holds the 42 seeds in those two groups, split with the same copy:
32 point to the draft and 10 point to overload-and-remove. `try_pack` was
not touched, which is what the assignment asked for.

#### What was run

    just crate-test adeleine        # in the worktree: all green, oracle included
    cargo clippy -p adeleine --all-targets -- -D warnings
    cargo fmt -p adeleine
    just test                       # 29 passed
    PATH=/usr/bin:/bin cargo test -p adeleine --test superfamiconv   # skipped

The book does not describe Adeleine's tests, either in `tools.md` or in
`testing.md`, so nothing was added there. The adeleine README's "Tests"
section has a paragraph about the referee.

#### When merging

There is no Rust to reinstall, because only a test was added.
`superfamiconv` is already in `/usr/local/bin`, linked to
`~/ref/superfamiconv/target/release/superfamiconv` and built from
`v0.12.0-beta4`. If the container is recreated, rebuild it in
`~/ref/superfamiconv`: clone the repository, check out `v0.12.0-beta4`,
run `cargo fetch --locked`, then run `cargo build --release --locked
--offline`.

### 2026-11-22, Hurón: no capture

A test only: Adeleine against SuperFamiconv over generated pictures, with
nothing in any game changing. How to check it: `just crate-test adeleine`
in the-advocate, with `superfamiconv` on the PATH, runs the referee; with
it off the PATH (`PATH=/usr/bin:/bin`) the same test says it is skipped.
What it found and changed on screen is
[`try-pack-picks-the-smallest-group`](try-pack-picks-the-smallest-group.md),
which carries the capture.
