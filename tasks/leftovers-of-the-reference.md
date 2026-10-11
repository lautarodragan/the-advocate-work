---
name: "Leftovers of the reference"
description: "Comments that lean on the Python reference, and unused constants"
type: refactor
status: done
---

The Python reference went away on 2026-09-16, and on 2026-09-25 what was left
of it in `eventos.Estado` was removed. What remained, seen and left untouched
so as not to do a general sweep, in `tools/port/eventos.py`:

* the comment on `SENO_SACUDIDA`: "the ROM and the reference match exactly";
* the one on `ChangePBG`: "the reference doesn't model it either and both
  sides end up equal";
* seven constants unused in code: `ANIM_NO_CONTINUA`, `LLUVIA_DX`,
  `LLUVIA_DY`, `PAN_FIJAR`, `PAN_SOLTAR`, `SWITCH_INDIRECTO` and `SWITCH_OFF`.
  They may be there as documentation of the RM2k format: `git blame` before
  deleting them.

`grep -n -i 'referencia\|los dos lados' tools/port/*.py` gives the rest of the
candidates: separate the ones that talk about the Python reference from the
ones that talk about something else (the drawings in `tools/port/` that the
`_dibujo` tests compare against are sometimes called that too).

**And in `rom/src/`**: `grep -n -i referencia rom/src/*.s` gives some fifty
lines. taro saw one while debugging in Mesen2 on 2026-09-25, in `eventos_tick`
(`rom/src/cargar_mapa.s`, after `espera_boton`): "it would be one frame of
difference against the reference". Same criterion: if the why still holds
without the reference, it's rewritten; if it only existed because of it, it
goes.

## How it ended up (2026-09-26)

`LLUVIA_DX, LLUVIA_DY` went, the only one of the seven that only the deleted
model read; the other six are members of liblcf enums in the same tuple as
their used siblings, and they stay. The comments, in one commit per file or
per area: the `git log` of this task says which were rewritten and which
went.

What was left mentioning it on purpose, or untouched:

* the long comment on `KeyInputProc` without wait, in `eventos.py`, and its
  `NoSePuede`: the measurement it cites was against the reference, and
  rewriting it needs measuring again with `TECLA_SIN_ESPERA=1` against the
  `heroe 52` golden;
* the animations' VRAM in `snes_convert.py` stops the build instead of
  warning like the palettes do, and the only reason was the reference: the
  comment says so, and changing it is a change in behaviour;
* `titulo.render` and `ventana.pagina` have no callers and their comments
  describe the reference's comparison: the right thing is to delete them
  (the first is already in `inventory-images-to-tiles-in-python.md`);
* the "capped at 999 as in the reference" in `batalla.s`: it's unknown whether
  it's the Python one or the `escena` drawing.
