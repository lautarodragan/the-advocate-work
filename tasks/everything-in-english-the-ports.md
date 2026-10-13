---
name: "Everything in English: the ports"
description: "The ports repo goes in English like the other three: directories, files, recipes, identifiers, comments, docs and commits; the history stays"
type: chore
status: done
assignee: taro
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
  `abl.sfc`'s test pages: it cannot stay byte for byte equal across that
  commit, and it is verified against a copy of `release` with the new names
  in the old order.
* The tools knew Spanish names of the ports beyond `desde_imagen`: the auto
  patches' keys and folders (`fusiones`, `colores`, `mapas/`…, written by
  `rm2k-snes/patches/src/text.rs`), the volume ceilings (`techos.toml`,
  `temas`, `aire`, `huella`…), the manual fork's folders (`mapas/`,
  `nuevos/`) and the new map's `arbol`, and what a build leaves next to the
  ROM (`conversor.log`, `sello.txt`, `memoria.cfg`, `crudos/`,
  `efectos.json`, `musica.json`, `parches/`, `parches-manual/`,
  `prueba.sfc`).

What was done, in commits that each say what they verified:

* the-advocate: the tools' names above, in English (the manual forks are
  `forks/`, because `test_dump_readers.py` forbids `join("maps")`); the
  comments and docs that cite the ports; `volume_ceilings` reads
  `PROCESSES`; the glossary's new terms.
* the ports: pure `git mv` commits for the directories and files and for the
  cases and goldens, apart from the commits that make the references follow;
  recipes (`cartridges`, `tests`, `space`, `patches`, `patches-check`,
  `ceilings`, `deliver`, `dump`, `dump-round-trip`, `culprits`, `msu-port`,
  `boot`) with their parameters, variables (`GAMES`, `CARTRIDGES`,
  `PROCESSES`), `.local-tools`, flags (`--update-msu`, `--no-msu`,
  `--read`), README.txt for what the deliveries write and
  `/shared/builds/other-games/`; the Python names that cross files —every
  harness name, fixture and test function— with a token renamer checked for
  collisions file by file; the cases and goldens translated word by word with
  one dictionary, the same one applied to the ids the tests build golden
  names from. The tests that run no ROM are `tests/tooling/`:
  `test_abl_side.py` forbids `tools/`. `RENAMES.md` at the root has old ->
  new for everything (3,440 lines: 1,684 file renames, 1,361 Python names,
  the recipes, variables, flags, the tools' names and the dictionary).
* the book, AGENTS.md, the roster and the tasks cite the new names; research
  pages, `rom/`, `tools/` and `workflow/` paths are history and stay.

Verified, with the tools of the-advocate's branch installed in
`.local-tools`: ABL's suite **1283 passed**, with every one of the 858 PNG
goldens read (atime check) and their content unchanged (same blobs);
`just boot` **9 passed**, every root golden read; the-advocate's `just test`
**27 passed**; the crate tests of patches, convert, cartridge,
rm2k-snes-audio, mapdata and project; `just patches-check` green. ROMs: the
seven games' releases, `abl.msu` and ABL's seven test cartridges byte for byte
equal to the ones built at the starting commits; `abl.sfc` is now `aa2b97c8`
and a copy of `release` with the new case names in the old order comes out
`417978e3`, the ROM of before.

Left for step 2, besides the prose: the names a single test file defines
(locals, parameters, module constants) and the experiments' internals; the
harness's own dict keys (`scene.py`: `clave`, `imagen`, `tono`…); the keys of
`music.json` and `effects.json`, which are the tools' (`temas`, `nombre`,
`huella`…); the header the mapdata emitter writes still cites
`test_encima` (its text is compared byte for byte with the Python's);
`"Thunder9@entero"` in rm2k-snes.toml, a label of ABL's own; the fonts
experiment's `--comparar`; the shell variables inside the justfiles' recipes.

To install when merging: `just install patches convert cartridge
rm2k-snes-audio`. `/shared/msu/` still has the `LEEME.txt` of before, so the
first `just deliver` asks for `--update-msu`.
