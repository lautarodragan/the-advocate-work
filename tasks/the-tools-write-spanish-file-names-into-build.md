---
name: "The tools write Spanish file names into a port's build/"
description: "memory.cfg, music.json, effects.json, crudos/, patches/uses.json and stamp.txt come out of the already-English projects with Spanish names, and the ports' harness opens them by name"
type: refactor
status: draft
---

Seen by Hurón on 2026-10-12, at the-advocate 57abdca3, while listing the
Spanish identifiers left in the-advocate
([the-advocates-spanish-identifiers-into-english.md](the-advocates-spanish-identifiers-into-english.md)).

`the-advocate` goes in English entirely, and "what those tools generate
goes in English too" (`AGENTS.md`). Yet the English projects name in
Spanish files they write into a port's `build/<cartridge>/`:

* `memory.cfg` — `MEMORY_MAP` in `rm2k-snes/cartridge/src/assemble.rs`;
* `music.json` and `effects.json` — `rm2k-snes/rm2k-snes-audio/src/main.rs`,
  also read back by `ceilings.rs` and `tracks.rs`;
* `crudos/` — `rm2k-snes/convert/src/emit.rs`;
* `patches/uses.json` — `rm2k-snes/convert/src/convert.rs`;
* `stamp.txt` — the cartridges' stamp (see
  `rm2k-snes/cartridge/tests/cartridges.rs`);
* and the comment `rm2k-snes-audio` writes at the top of `musicdata.inc`
  says ``lda tabla, x`` (`src/emit.rs`).

To see them: `ls build/release` in `abl/` of the ports after `just
cartuchos`. They are not symbols, so they were left out of the identifiers
task. ABL's harness and tests open several of them by name —`grep -rln
'music.json\|effects.json\|memory.cfg\|crudos\|uses.json\|stamp.txt'
pruebas justfile` in `abl/` gives about a dozen files—, and changing the
binaries that write MSU-1 data changes the cache key.
