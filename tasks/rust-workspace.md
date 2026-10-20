---
name: "The Rust workspace"
description: "The nine crates of tools/ in a Cargo workspace: one Cargo.lock and one target/, without changing what any binary does"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-29, in their words, translated:

> go ahead, set up the workspace

Discussed before:
the crates are still separate projects —`cargo install --path` installs each
one on its own, and each one is published alone—; the workspace only makes the
shared dependencies compile once and there be a single `Cargo.lock`.

What Hornero already decided: the build profiles go at the top, because the
workspace ignores each crate's. `ditto` and `protocol` optimised for size
(`opt-level = "z"`, `panic = "abort"`): the `opt-level` is kept per package,
and `panic = "abort"` is lost, because it cannot be set per package. It
changes the size of those two binaries, not what they do.

## Added on 2026-09-29, from taro

Two more things, in the same task:

1. **The crates are grouped into folders by layer**, inside the same workspace
   and with `git mv`: `tools/snes/` —SNES format, without knowing about RPG
   Maker: `voodoo`, `lz2`, `gunter` and `protocol`, which is generic but
   generates constants for the 65816 assembler—; `tools/rm2k/` —RPG Maker,
   without knowing about the SNES: `ditto` and `rm2k-render`—; and
   `tools/rm2k-snes/` —what joins the two: `project`, `cartridge`,
   `rm2k-snes-audio`, and the converter crates that are coming—. The names of
   crates and binaries do not change; the workspace's `Cargo.toml` stays in
   `tools/`. The Python packages of `tools/` do not move.
2. **A test that enforces the direction of the layers**, reading
   `cargo metadata`: `snes/` and `rm2k/` do not depend on `rm2k-snes/`, and
   `snes/` and `rm2k/` do not depend on each other.

3. **`rm2k-render` stops reading `rm2k-snes.toml`.** It goes to `rm2k/`, but
   `layers --map N` looked for the project file upwards and read
   `[paths] data` to find the dump: knowing about the layer above by copying
   its format instead of depending on a crate, which the layers test via
   `cargo metadata` does not see. Now it receives `--data <dir>`, Ditto's dump
   directory, and the layers test also checks that nothing in `snes/` or
   `rm2k/` names `rm2k-snes.toml`.

Commits: the workspace; the move, only `git mv` and paths; the test; the
`rm2k-render` part; the prose separately.

## What was done

### The workspace

- `tools/Cargo.toml`, virtual, with the nine crates and `ditto/xtask`: Ditto
  had its own workspace for the schema generator, and a workspace cannot nest
  another, so `xtask` became a member of the one above. `cargo xtask` still
  works standing in `ditto/`, because the alias is in
  `ditto/.cargo/config.toml` and cargo reads it from the directory where it is
  run.
- `resolver = "2"`: a virtual manifest has no edition to take it from and would
  fall back to 1; "2" is what each member, in edition 2021, used on its own.
- Profiles at the top, `opt-level = "z"` per package for `ditto` and
  `protocol`; `panic = "abort"` is lost. Measured: `ditto` goes from 2.21 to
  3.01 MB and `protocol` from 0.77 to 1.07 MB.
- One `Cargo.lock`: built **by joining the nine** —the registry packages of
  all of them, deduplicated— so that cargo starts from versions that were
  already in use, and then, where two crates had different versions, bumped to
  the newest with `cargo update --precise`. No version is new: they were all
  in some lock. The ones that were unified, with who had the old one:
  - `clap` and `clap_builder` 4.6.6 → 4.6.7, `clap_derive` 4.6.4 → 4.6.7,
    `clap_lex` 1.1.0 → 1.1.1: `protocol`.
  - `syn` 3.0.5 → 3.0.6 and `unicode-ident` 1.0.24 → 1.0.26: `ditto`,
    `gunter`, `protocol` and `voodoo`.
  - `cfg-if` 1.0.4 → 1.0.5 and `zlib-rs` 0.6.7 → 0.6.8: `voodoo`.
- **`cargo install --locked --path <crate>` uses the workspace's lock**:
  checked by lowering `clap` to 4.6.6 in the workspace's lock and installing
  `protocol`, which compiled `clap v4.6.6`. And it uses the workspace's
  `target/`.
- `CARGO_MANIFEST_DIR` is still the package's directory: the `.dbg` files the
  new binaries build name the sources relative to the worktree's root, same as
  before.
- A single `target/`, in `tools/target/`; each crate's `.gitignore`, which only
  said `target/`, was deleted.
- `tools/justfile`: the test recipes still stand in each crate (`cargo test`
  in a member tests only that one), and there is a new one, `rust-test`, which
  tests the whole workspace in debug.

### The layers

- The move was a commit of only `git mv` and the paths that stopped being
  valid: the members, `rm2k-snes-audio`'s dependency on `gunter`, the recipes'
  `cd`s, the paths of `protocol`, `test_protocol.py` and ditto's `.idea/`.
  `_install` looks for each project by its name in the folders of
  `rust_layers`, so `install lz2` is still `install lz2`.
- `project`'s `suite::tools()` counted one directory up from the crate and now
  counts two. It is the only `CARGO_MANIFEST_DIR` that reaches `tools/`; the
  other uses of `env!` are `CARGO_BIN_EXE_*` and `CARGO_TARGET_TMPDIR`, which
  do not depend on where the crate is. Since one more move would break it
  without a compile error, it carries a test: that from there `runtime/main.s`
  is reached.
- `tools/tests/test_layers.py` reads `cargo metadata --no-deps`. Tested that it
  fails with `rm2k-project = { workspace = true }` in `gunter` —inherited from
  the workspace, to see that `cargo metadata` gives it the path anyway— and
  `lz2` as a dev-dependency of `ditto`; and the grep of `rm2k-snes.toml`, with
  `rm2k-render`'s `source.rs` from before.
- `rm2k-render layers --map N` asks for `--data <dir>`; nobody used `--map`
  —the converter uses `--request`, `render/render_map.py`—. With the crate's
  `toml`, `toml` 0.9, `toml_datetime` 0.7 and `winnow` 0.7 leave the lock.

### Verification

- `cargo build --release` and `cargo test` of the workspace: 251 tests, the
  same ones the nine gave separately in `main`, plus the `suite::tools()` one,
  252; 3 ignored in both cases.
- `NO_CACHE=1 just cartridges` with the nine installed in the local `bin/`: the
  999 files of `rom/build/` —`.sfc`, `.msu`, `.pcm`, `.inc`, `.sym` and the
  rest— identical to those that come out here with `main`'s binaries. The two
  `.dbg` differ, and only in two measured things: `main`'s binaries were
  installed from another tree and name the `.inc` with an absolute path, and
  the comments the prose changed in `tools/runtime/*.s` change the size the
  `.dbg` notes for each source.
- `just -f tools/justfile test`, `rust-test` and `protocol --check`.

### Times

Compiling and installing from clean the eight crates with a binary, with
`_install`'s loop, on this machine and with the registry already downloaded:

- before, nine projects with a `target/` each: 188 s;
- after, the workspace: 172 s.

Little, because what costs is the `lto` with a single code unit, which is done
per binary anyway; what is saved is recompiling the dependencies: 80 crates are
compiled instead of 206. And not all are shared, because `cargo install
--path` compiles one package at a time and the features are unified per
package: `clap` with and without `derive`, `toml` and `serde_json` with and
without `preserve_order`. Recompiling after touching a crate is what goes down
the most: the dependencies are already in `tools/target/`.

With that, on the branch before merging `main` (what `main` brought was only
prose in `workflow/`): `just tests`, 874 green.

## When merging, in the main checkout

- `just -f tools/justfile install`, everything: the profiles of `ditto` and
  `protocol` change, the lock of all of them, and `rm2k-render` changes its
  interface; and `cartridge`'s binaries look for the runtime through the
  crate's path, which moved.
- Delete each crate's old `target/`, which are left untracked and nobody uses
  any more: `tools/*/target`. The new one is `tools/target/`.
- Check that nothing is left loose in `tools/` with a crate's name: an empty
  directory or an untracked `.idea/` are not moved by the merge.
