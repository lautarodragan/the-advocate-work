---
name: "Book: an Optimizations section"
description: "A section of the book for the port's optimizations, Lossy and Lossless, plus what was tried and left out; checked against the code, and the decisions that are really optimizations moved there"
type: docs
status: done
assignee: taro
agents: [Cardón]
---

taro, on 2026-10-15: add an **Optimizations** section to the book with two
sub-pages, **Lossy** and **Lossless**.

1. First, list every optimization we know we have (the documented ones),
   and publish that (a commit and a push of its own, so it is visible
   early).
2. Then look into the code —the runtime's assembly and the tools— for an
   optimization that was lost and is not documented, or one the
   documentation mentions that no longer exists (or never did).
3. During or after, remove pages or sections that are really about an
   optimization but live elsewhere today, e.g. under decisions:
   `decisions/a-window-with-a-gradient-is-fused-until-it-fits` should be
   documented as an optimization, not as a decision. "It isn't worth
   keeping a record of the decision if the decision is final."
4. An optimization that existed and was later removed goes to a third
   section, "Tried and left out" or similar.

## Log

- 2026-10-15, Cardón: stage 1 on branch `cardon-optimizations` of
  the-advocate-docs (from `33e9cfe`): `src/optimizations/` with README,
  `lossless.md`, `lossy.md` and `tried-and-left-out.md`, built only from
  what the book documents, paths checked against the-advocate at
  `99140946`. Found for stage 2: `internals/cgram.md` names
  `convert_layers()`, which no longer exists (it is `convert_with` in
  Wally's `background/layers.rs`); several pages still cite old Python
  paths (`tools/port/…`, `docs/port/…`). `fitting.md` overlaps Lossy and
  should move under `optimizations/` in stage 3. w65 and Voodoo's
  `--merge` are not in the book, so they are not in "Tried and left out".
- 2026-10-15, Cardón: stages 2 and 3 on branch `cardon-optimizations-2`
  of the-advocate-docs (from `9b028a0`), with the same branch in
  the-advocate (comments only, `just test` green) and in the ports (one
  test's comment and message). Stage 2 (`fd4a5a9`): the code read against
  the pages, at the-advocate `99140946`; undocumented optimizations
  added —identical blocks and pointer tables stored once (the leader
  tables, `npc_poses`), repeated boxes and troop pages once, battle
  animation frames shared, battlers in LZ2, encounters and experience
  precomputed, hot NPC code unrolled in bank 1, tint tables copied, DSP
  writes skipped by a cache, the panorama maps that flatten or go to
  mode 1—; nothing documented turned out not to exist, only names
  (`convert_layers()`, old Python paths, renamed constants), fixed on the
  pages touched. Stage 3 (`8390fdd`): the decisions that only saved moved
  in —five as sub-pages, seven folded into entries—, plus the divergence
  "The map takes to VRAM only what it draws" and `fitting.md`, which
  became the intro of Lossy; 15 redirects, the old Spanish ones
  retargeted, citations fixed in the book, in the-advocate's comments, in
  the ports' test and in the one open task that cited one. Done and
  testing tasks keep their old citations, as history: the redirects
  resolve them. Nothing to install when merging.
