---
name: "The book: the board against RM2k, in English"
description: "The artifact \"El motor contra RPG Maker 2000\" into the book as HTML as is, translated into English, and linked from a page"
type: docs
status: testing
assignee: taro
agents: [Aguará]
---

From taro, on 2026-10-10: the board that Aguará inventoried and Hornero published
on 2026-10-06 (`el-tablero-contra-rm2k.md`) moves into the book "copying
its .html as is, and linking it from the book, instead of converting it
all to markdown. I would translate it to English, though." It is the fifth of the
parallel tasks of moving the documentation into the book.

## What was done

In `snes-rm2k-docs`, branch `aguara-board` of the clone `~/scratch/aguara/docs`
(base 149452a), two commits:

* `4e24aac`: `src/engine-vs-rm2k/index.html`, the published HTML translated
  —mdBook copies it as is and it ends up at `engine-vs-rm2k/index.html`—, and
  `src/engine-vs-rm2k.md`, the book page that explains what it measures and
  links to it. It still says it is a snapshot of 2026-10-06, commit
  3d0c787c of snes-rm2k.
* `a4f7c6e`: the entry in `SUMMARY.md`, after `fitting.md`, separate
  so that Hornero merges it with the others'.

What was translated is everything visible: title, header, footer, the labels of
`ST` (done, partial, patch, degrades, missing, n/a) and in the JSON
`nombre` and `nota`. The RM2k command names stay the same (the
script that built it checks it for tabs 1 to 3). **The status
keys stay in Spanish** (`hecho`, `parcial`…): they are CSS classes and
are not seen, and a comment in the CSS says so.

`donde` went from text to list: the divergences and decisions are links to
`../divergences/<slug>.html` and `../decisions/<slug>.html` (slug in
Spanish, 46 links); the rest stays as text with the repo in front
—`snes-rm2k: tools/…`, `snes-rm2k: docs/…`, `snes-rm2k-work: tasks/…`,
`snes-rm2k-ports: …` for what said `ABL:`—. No note named the
environment.

What is left for the merge, Hornero's:

* the 8 decisions cited all look like the engine's, so they go to
  `../decisions/`; if any ends up in `ports/abl/decisions/`, the link
  changes;
* the paths `snes-rm2k: docs/research/…` and `docs/port/…` stay as
  text of the snapshot, even though those files move to the book;
* `snes-rm2k-ports: menus/consola.toml` is the path of 2026-10-06; today
  ABL is in `abl/`.

## How it was verified

* `mdbook build --dest-dir` (v0.5.4) without warnings, and the served
  `index.html` is byte for byte the one in `src/`.
* The JSON of the `data` block of the served HTML parses with `json.loads`: 271
  items.
* In a headless Chromium (Playwright), without console or
  page errors, in light and dark: same numbers as the original in the same
  browser —73%, 194 of 266, 97/93/4/13/59/5—, 31 rows that open into 271
  items, the legend's filter works (removing "done" leaves 174), and the
  captures at 1000 and 400 width look like the original.
