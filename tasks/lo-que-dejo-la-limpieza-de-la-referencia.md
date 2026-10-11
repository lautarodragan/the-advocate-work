---
name: "What the reference cleanup left behind"
description: "Four things that the cleanup of the reference's leftovers left out on purpose, because they weren't comments"
type: refactor
status: todo
---

The cleanup of 2026-09-26 (`restos-de-la-referencia-en-eventos-py.md`)
removed the comments that relied on the Python reference and left
out, on purpose, these four things: each one asks for something more than
rewriting a comment.

1. **`KeyInputProc` without waiting** (`tools/port/eventos.py`, the long
   comment and the `NoSePuede` message): it cites a measurement (55%) made against
   the reference. It has to be measured again with `TECLA_SIN_ESPERA=1` against the
   ROM and RM2k before rewriting it, or decide whether the command without waiting is
   accepted (see also the race, which asks for it: `RaceController2`).
2. **Animations that don't fit in VRAM abort the build**
   (`tools/port/snes_convert.py`), instead of warning and going on as with the
   palettes. The only reason was the reference. Decide whether it becomes a warning (and what
   is drawn then) or whether aborting is still right, and leave the why.
3. **`titulo.render` and `ventana.pagina` have no callers** and describe the
   old comparison: delete them (`titulo.render` is already named in
   `inventario-de-imagenes-en-python.md`). `git blame` and `git grep`
   first.
4. **"Topado en 999 como en la referencia"** (`rom/src/batalla.s`): it isn't known
   whether it speaks of the Python reference or of `escena`'s drawing. Find out with
   `git log -S` and rewrite against RM2k (does RM2k cap damage at 999?).
