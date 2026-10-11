---
name: "Translate the tools into English, phase 1: the runtime"
description: "Comments, docstrings, messages and prose into English, without touching code names: tools/runtime/, the comments of the hand-written .s and .inc files"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-29: "translate the tools into English". It's the rule in
AGENTS.md for the separate projects, which now reaches all of `tools/`
(see `workflow/decisiones/las-herramientas-se-separan-de-abl.md`).

**Phase 1**, split among four agents by area: comments, docstrings,
error messages, `help=` and prose. **Code names aren't touched** —
modules, functions, variables, runtime symbols, flags—: that's phase
2, one area at a time, because a name changes in everything that
imports it. The terms come from `tools/GLOSSARY.md`.

Scope of this part: tools/runtime/, the comments of the hand-written .s and .inc files.

## How it was done

On 2026-09-29, Palmar. There are 93 hand-written `.s` files and some 44,000 lines; the
two `.inc` files next to them (`event_opcodes.inc`, `music_opcodes.inc`) come from
`tools/protocol/` and **already had their header in English**: they weren't touched.

It was split into nine groups of about ten files, one per helper, each one
in its own worktree; each group is a commit. What gets translated: everything after the
`;`, and the message of the `.assert ..., error, "…"`, which is text that
`ca65` prints when the build fails and not data. What doesn't: nothing to the left of the
`;`, nor the `.byte`/`.asciiz` strings, nor the identifiers the
comments cite.

Two safety nets per group:

* a comparer that strips comments and `.assert` messages —respecting
  `"…"` and `'x'`— and requires the rest to be line by line what's in `HEAD`;
* `SIN_CACHE=1 just cartuchos` and the sha256 of the `.sfc`, `.msu` and `.pcm` in
  `rom/build/`, which have to come out the same as before starting.

## What was left

The 93 `.s` files, in nine group commits and one that aligns the groups with
each other: some 10,700 comment lines rewritten. The `.sfc`, `.msu` and
`.pcm` in `rom/build/` came out with the same sha256 after each commit,
and on the tree merged with `main` both suites pass.

**What was left in Spanish on purpose**, inside the comments:

* the identifiers, paths and Python names being cited: they're phase 2;
* section titles of files that aren't the runtime's, cited
  in quotes so they can be searched for: "Cuánto tarda"
  (`docs/port/msu-datos.md`), "Qué fondos hay" and "El respaldo liviano"
  (`tools/port/escena.py`), "el formato por nota" (`tools/audio/snes_music.py`),
  "lo que depende del actor" (`titulo.py`), and the section title of
  `tasks/audio-bgm.md` that `paquete_de_audio.s` cites. **If the
  phase 1 of those files translates the title, the citation is left dangling**: each one
  has to be grepped;
* a phrase of taro's quoted verbatim in `nivel.s`, with the translation next to it;
* the only piece of data: the `.byte "S-MSU1"` in `msu1.s`.

What can't be seen with the two safety nets is the quality of the prose: the
comparer only says the code didn't change.
