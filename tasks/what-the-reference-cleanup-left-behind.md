---
name: "What the reference cleanup left behind"
description: "Four things that the cleanup of the reference's leftovers left out on purpose, because they weren't comments"
type: refactor
status: done
---

**Done**, 2026-10-12, with nothing to do: the four had stopped applying
when the tools moved to Rust (checked on the-advocate `25d93f0a`).

1. `KeyInputProc` without waiting is compiled for real —the `KEY_INPUT_PROC`
   arm of `rm2k-snes/events/src/compile.rs`, "the car's steering wheel"—;
   neither the `NoSePuede` nor the 55% are left.
2. A battle animation that doesn't fit is shrunk until it fits
   (`rm2k-snes/convert/src/animations.rs`), and a map whose animation box
   doesn't fit goes without it
   (`have-vampires-dawn-map-1-build-without-its-animation-box.md`).
3. `titulo.render` and `ventana.pagina` were Python, and no Python is left.
4. The 999 cap in `runtime/battle.s` (`ba_capped`) cites RM2k's window, not
   the reference.

The cleanup of 2026-09-26 (`leftovers-of-the-reference.md`)
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
   `inventory-images-to-tiles-in-python.md`). `git blame` and `git grep`
   first.
4. **"Topado en 999 como en la referencia"** (`rom/src/batalla.s`): it isn't known
   whether it speaks of the Python reference or of `escena`'s drawing. Find out with
   `git log -S` and rewrite against RM2k (does RM2k cap damage at 999?).
