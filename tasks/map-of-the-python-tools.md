---
name: "The map of the Python tools"
description: "Dependency graph, responsibilities and what is ABL-agnostic in the .py files of tools/, with a plan in parts to split tools and game into two repos"
type: docs
status: done
assignee: taro
---

From taro, on 2026-09-28: "I'd like to pick up the refactor of the tools made
in python again. [...] I'd like to understand the dependency graph between the
different python files, what responsibility each thing has, and what is
agnostic to ABL and what isn't. One of the next steps I want to take on is
splitting the repo in two: the tools on one side, all agnostic to any game,
and a repo dedicated to A Blurred Line. That project isn't going to be
completely trivial and we'll have to take it on in parts. This plan will help
us with that."

It is research and a plan, not code. **The result is
[`docs/research/el-mapa-de-las-herramientas-de-python.md`](https://lautarodragan.github.io/the-advocate-docs/research/el-mapa-de-las-herramientas-de-python.html)**: taro has to read
it, and above all answer the questions in its §5, which are the ones that
decide where to start.

Related: `responsibilities-of-snes-convert-py.md` and
`golden-game-and-two-repos.md`.

# Log

* 2026-09-28, Quebracho. `main` merged into the worktree (`e314ff7b`). The
  graph comes from a throwaway AST script (in the scratchpad): `import` edges
  (at module level), `lazy` (inside a function or the `if __name__`) and
  `ruta` (a literal that *is* the path of another `.py`). The first version
  counted as `ruta` any text that named a `.py` —docstrings, `help=`— and gave
  a single cycle of thirty modules: noise. With the whole literal as the path
  two real edges remain: `cartuchos` runs `snes_convert.py` as a subprocess,
  and `snes_convert` puts the hash of `rm2k`, `render_map`, `chipset` and
  `asignador` into the cache key.
* First finding against `tools/README.md`: the cycles are not the three it
  says. There is a single strong component in `port/` of six modules
  (`eventos`, `batalla`, `pantallas`, `imagen`, `titulo`, `experiencia`),
  plus `snes_convert`↔`pantalla_completa` and, at the very bottom,
  `lcf`↔`fork`. `batalla`↔`pantallas` is not direct: it goes through
  `eventos`. And the imports that violate the layers come from just two
  files: `ensamblado/cartuchos.py` (imports from `port/`, `audio/` and
  `rpgmaker/`) and `rpgmaker/fork.py` (imports from `render/`, inside
  functions).
* I split the reading for the agnostic/ABL classification into five parallel
  readings: `snes_convert`, `eventos`, the rest of `port/`, the lower layers,
  and what is not Python.
* The five readings agreed on the broad strokes: **no section of
  `snes_convert` nor of `eventos` is ABL's**. What of ABL is written in the
  code is the content of `cartuchos.py`, the audio tables of `snes_music.py`
  (269-417) and some twenty knobs. I checked against the code each hook the
  research cites by line (a grep of each constant). What ties the repo to ABL
  is the shape of the tree: eleven modules compute the root from `__file__`.
* The script in the research's appendix D is a clean version of the one I
  used. I ran it on this same commit and it gives the same table and the same
  edges as the original (empty diff, except for a header).
* `tools/README.md` said three cycles that were no longer so; I corrected it
  in its own commit, pointing to the research.

## What taro decided

On 2026-09-28, on the research's summary: see
`workflow/decisiones/las-herramientas-se-separan-de-abl.md`, which also has
the three questions that were left open (how ABL consumes the tools,
`cartuchos.py`, and which decisions and divergences go to each side). The
research was not touched: it is a snapshot.
