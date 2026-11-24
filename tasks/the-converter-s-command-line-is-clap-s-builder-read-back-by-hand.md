---
name: "The converter's command line is clap's builder, read back by hand"
description: "rm2k-snes-convert declares its 23 flags with clap's builder API and copies each into Options with get_one/get_flag; the derive API, which mapdata already uses, declares and reads them in one place"
type: refactor
status: cancelled
author: calandria
agents: [cardon]
links:
  found-in: [where-mapdata-and-convert-could-be-shorter]
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/convert` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).

**Where**: `rm2k-snes/convert/src/options.rs` 26-339.

**What the code does**: `command()` builds the parser with
`Arg::new("text_padding").long("text-padding").value_parser(…)
.default_value("0").help(…)` —8 to 12 lines a flag after rustfmt—, then
`Options` declares the same 23 fields again and `parse` copies each one out
of the matches (`text_padding: *matches.get_one::<i64>("text_padding")
.unwrap()`), by its string id. A flag is written in three places.

**Every flag has a caller**: checked against the ports' `advocate.toml`,
their tests and `rm2k-snes-cartridges`; none is dead.

**The shorter form**: `#[derive(Parser)] struct Options` with a doc comment
and an `#[arg(long)]` per field, as `rm2k-snes-mapdata` does. What the
builder is doing on purpose survives it:

* the `--case` split runs `Options::command()` over each stretch, and its
  check that only `test_commands` follows a `--case` reads `ids()` and
  `value_source` as today;
* the machine flags of `environment::arguments(MACHINE)` go in with
  `Options::command().args(…)` and are read with
  `Environment::from_matches`, or become an `Args` derive in
  `rm2k-project`;
* `--test-graphic`'s pairs keep their parse, as a `value_parser`.

**Estimated saving**: about 100 lines of the 340: the copy-out in `parse`
(35) and a third of each flag's declaration.

**What it risks**: low. `--help`'s text may wrap differently; the flags,
their defaults and the errors stay.

**How to verify**: the converter's `--help` compared before and after, and
every port's `just cartridges` building the same ROMs (`cmp`), since every
cartridge's flags go through it; `--case` without `--test-commands` and a
cartridge flag after `--case` still refused.

## Log

### 2026-11-24, Cardón: cancelled

Made moot by [`one-advocate-command`](one-advocate-command.md): the converter
becomes a library that `advocate build` calls, so `Options` is built by the
caller and the builder, `parse` and the copy-out go with the command line.
Whatever command line `advocate` keeps is written then, with the derive API.
