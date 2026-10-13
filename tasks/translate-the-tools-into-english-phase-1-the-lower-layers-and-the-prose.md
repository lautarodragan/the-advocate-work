---
name: "Translate the tools into English, phase 1: the lower layers and the prose"
description: "Comments, docstrings, messages and prose into English, without touching code names: tools/audio, rpgmaker, render, comun, ensamblado, emulador, pruebas, justfile, README.md and each folder's README"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-29: "translate the tools into English". It's the rule in
AGENTS.md for the separate projects, which now reaches all of `tools/`
(see `decisions/the-tools-split-from-abl.md`).

**Phase 1**, split among four agents by area: comments, docstrings,
error messages, `help=` and prose. **Code names aren't touched** —
modules, functions, variables, runtime symbols, flags—: that's phase
2, one area at a time, because a name changes in everything that
imports it. The terms come from `tools/GLOSSARY.md`.

Scope of this part: tools/audio, rpgmaker, render, comun, ensamblado, emulador, pruebas, justfile, README.md and each folder's README.

## Progress

- Baseline: `SIN_CACHE=1 just cartridges` on `66152183`, 47 `.sfc`/`.msu`/`.pcm`
  hashed; the `.inc` files saved to diff comments.
- `tools/README.md` and `tools/justfile`: translated.
- `tools/rpgmaker/README.md` and `tools/pruebas/README.md`: translated. The
  heading "Qué prueba cubre qué" is data that `test_index.py` reads, so
  it changes together with it.
- The `.py` files, split into five batches by folder.
- The five groups of `.py` done, each in its own commit. `SIN_CACHE=1 just
  cartuchos`: the 47 `.sfc`/`.msu`/`.pcm` identical to the baseline; of the `.inc` files
  only `musicdata.inc` changes (release and special), only in comments.
- `ensamblado/deliver.py` isn't translated: it's `abl-entregar`, which according to the
  justfile stays with the game and in Spanish. taro decides.
- Left in Spanish because they're data: the `; Temas:` line in `musicdata.inc`
  and its "sin música" (read by `techos.py` and `rom/pruebas/arnes/consola.py`),
  `b"mapa %dx%d"` (cache key), the keys of the fork's recipe, of
  `collect_npcs`, of `espacio.medir`, of `ceilings.toml` and `music.json`, the
  CharSet suffixes and `RESERVADO` in the `.cfg`.
- Mentions of the environment that were already there and were only translated (outside
  phase 1): `/extras/...` in `retro.py`, `ensamblar.py`, `msu.py` and
  `chipset_del_fork.py`.
- Merged `main` (`106484ea`, only a doc). On the merged tree:
  `just -f tools/justfile pruebas` 132 and 2 skipped; `just tests` 874.

For taro: look at the diff per folder; what no test verifies is the
quality of the English. And decide whether `deliver.py` goes into the translation.
