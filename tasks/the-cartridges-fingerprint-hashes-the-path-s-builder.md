---
name: "The cartridges' fingerprint hashes the PATH's builder, not the running one"
description: "Since rm2k-snes-cartridges assembles in-process, the code that packs the banks is the running binary, but the fingerprint still hashes the rm2k-snes-cartridges it finds on the PATH: run from anywhere else, a stamp can name a binary that did not build"
type: bug
status: testing
author: mulita
assignee: taro
agents: [mulita, cardon, calandria]
links:
  found-in: [cartridges-runs-itself-to-assemble]
  relates: [one-advocate-command, arrancan-sunset-stale-right-after-built]
---

Seen by Mulita on 2026-11-24, in the-advocate at `46d5b46a` (branch
`mulita-assemble`, after
[`cartridges-runs-itself-to-assemble`](cartridges-runs-itself-to-assemble.md)).

`fingerprint_files` in `rm2k-snes/cartridge/src/cartridges.rs` hashes
`which("rm2k-snes-cartridges")`. While the build ran
`rm2k-snes-cartridges assemble` from the PATH, that was the binary that
packed the banks, so the hash was right whoever started the build. Now the
build calls the assembler's code, so what packs the banks is the binary
that is running. When both are the same file —every recipe, every
`PATH=<…>/.local-tools/bin:$PATH`— nothing changes; when a
`rm2k-snes-cartridges` is run by its path with another one on the PATH
(`target/release/rm2k-snes-cartridges`, say), the stamp hashes the PATH's
and the ROM comes from the other.

Reproduce: in a game of the ports, run a `rm2k-snes-cartridges` built
from a tree whose `banks.rs` packs differently, by its path, with the
global one on the PATH: it builds with its own packing and the stamp says
the global's; running the global one afterwards says "up to date".

Not fixed there because the crate's own test
(`everything_that_builds_the_rom_is_in_the_fingerprint`) hashes stand-ins
on a PATH of its own, and `current_exe` would be the test binary; and
because [`one-advocate-command`](one-advocate-command.md) reshapes which
binaries the fingerprint hashes anyway. A note on the line says it.

## Log

### 2026-11-24, Mulita: written

Found while folding the assembler into the build; nothing done.

### 2026-11-24, Cardón: to todo

Still so at the-advocate `8b069fc2`: `fingerprint_files` in
`rm2k-snes/cartridge/src/cartridges.rs` (630-640) hashes the PATH's
`rm2k-snes-cartridges`, with the note on the line. The fix is not in doubt
—hash the running binary— and is best done inside `one-advocate-command`,
which reshapes what the fingerprint hashes.

### 2026-11-25, Calandria: fixed, in one-advocate-command's step 2

the-advocate `88b2fc25` (branch `calandria-advocate`): `fingerprint_files`
hashes `Cartridges::builder`, which `Cartridges::load` sets to
`current_exe()`, and no longer any builder or converter on the PATH —the
converter is a library of the running binary since that step—. The
crate's test gives the field a stand-in and checks that an
`rm2k-snes-cartridges` on its PATH is not hashed. Every stamp changed
once. See [`one-advocate-command`](one-advocate-command.md)'s log.
