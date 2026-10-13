---
name: "Everything in English: the ports"
description: "The ports repo goes in English like the other three: directories, files, recipes, identifiers, comments, docs and commits; the history stays"
type: chore
status: doing
assignee: Chajá
agents: [Chajá]
---

taro, on 2026-10-12: "I also want the ports repo in English. Basically,
EVERYTHING in English, but without modifying the git history."

Two steps, as AGENTS.md asks for a big cleanup ("What is verifiable and
what is a matter of judgement do not share a commit"):

1. **The mechanical renames, alone**: directories (`tests/`, `harness/`,
   `casos/`, `patches/`, `experiments/`…), files (`machine.just`,
   `deliver.py`, `LEEME.txt`…), recipes (`cartuchos`, `pruebas`,
   `entregar`, `arrancan`, `espacio`…), Python modules, classes, functions
   and test names, golden file names, and the Spanish keys the tools read
   from a game (`from_image` in the converter's chipset recipes). Verified
   by the suite green with the same count, `arrancan` green, and every ROM
   byte for byte equal. `AGENTS.md`, `.claude/` and the book follow the new
   names in the same step. A table of the renames, so that old citations
   can be found.
2. **The prose**, guided by the diff of the first: comments, docstrings,
   READMEs, messages the harness prints, `LEEME.txt` that recipes write.
   Can be split by directory among agents.

It waits for Mulita's skills screen and the book's file names to merge, so
nobody renames under someone's feet.

## Log

### 2026-10-12, Chajá: step 1, the mechanical renames

Branches `chaja-english` in the-advocate (from `65885882`), the ports
(`0bf10fd`) and the book (`49c0421`).

Found before starting:

* **`release` carries every case, sorted by name** (`all_cases` in
  `rm2k-snes/cartridge/src/cartridges.rs`), so renaming the cases reorders
  `abl.sfc`'s test pages: `abl.sfc` cannot stay byte for byte equal across
  that one commit. It is verified instead against a reference built from
  the old tree with only the case files renamed.
* The tools know Spanish names of the ports beyond `from_image`: the
  auto patches' keys and folders (`patches/auto/maps`, `fusiones`,
  `colores`…, written by `rm2k-snes/patches/src/text.rs`), the volume
  ceilings (`musica/ceilings.toml`, `temas`, `huella`…), the manual fork's
  folders (`mapas/`, `nuevos/`, `chipsets/`), the `@entero` suffix of
  `[sound_effects.whole]`, and the build's `patches/uses.json` and
  `patches-manual/`.
