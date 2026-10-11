---
name: "Shrink the README"
description: "A much shorter README.md: out with the narrative and the duplicated, the rest to docs/ and decisiones/"
type: docs
status: done
assignee: taro
---

taro started it by hand on 2026-09-25 and on 2026-09-26 handed it to an
agent, with his criteria: out with what is narrative (the commit log has it),
to `docs/` or `decisiones/` whatever can go there, and nothing that a more
focused README already explains. What stays: what the project is, how to get
started, the architecture whys with no line of code to live in, and "Lo que
falta".

The stale or false paragraphs that different agents noted during those days,
and that this pass fixes or removes:

* `README.md` links to an "El MSU-1" section (`#el-msu-1`, in the index at
  the top) that doesn't exist, and the docstring of `tools/audio/msu.py`
  cites it.
* The `--inicio` flag was removed on 2026-09-25: the line of `README.md` that
  mentions it ("sigue existiendo para las recetas") goes away.
* The "Cómo se suelta una nota" paragraph (~lines 851-853) says that "el valor por familia está en `sdsp.py`": since 2026-09-25 the envelopes come from the SoundFont and the families are gone.
* "Cómo está armado", in the audio (~lines 777-785): "en la consola sólo un
  intérprete de un stream de escrituras" hasn't been the case since
  2026-09-26 —the stream is per note and the 65816 expands it into writes:
  see "el formato por nota" in `tools/audio/snes_music.py`—. The part about
  the SPC700 driver, which expects (register, value) pairs, still holds: the
  driver didn't change.
* The two paragraphs at the end of "las muestras de percusión" (~lines
  890-898): "La percusión se lleva además una segunda voz del DSP" and "Con
  el reparto de voces por cobertura, que es el mismo código de
  `md_music.py`" stopped being true on 2026-09-26: the eight voices belong to
  all channels and are allocated note by note (`assign` and `_victima` in
  `tools/audio/snes_music.py`); the drums go to voices 6 and 7 first but
  don't have them fixed, and `share_voices`/`coverage` are gone. How much
  note-time is lost is printed by the converter per theme.
  Also since 2026-09-26: the order in which the notes of a single frame pick
  a voice is `_orden_del_cuadro` (hits first, one per family; the melodic
  ones by level divided by their place in the chord).
* "Lo que sí queda de ellas son los números de `sdsp.py`" (~lines 962-966):
  the per-voice ceiling is no longer a single one since 2026-09-26.
  `sdsp.AIRE` is the maximum, and the theme that would clip with it goes with
  its own, measured by `just techos` and versioned in
  `parches/auto/musica/techos.toml` (see `leer_techos` in
  `tools/audio/snes_music.py`).
* "Varios temas en el cartucho" (~lines 130-200) went entirely stale on
  2026-09-26, with the per-package budget (step 6 of
  `tasks/la-calidad-de-la-musica.md`): there's no longer trimming of
  contributors —all themes contribute all their samples—, `build_bank`, the
  allocation of leftovers, the percussion "with whatever is left" and
  `--banco-entero` are gone, and "Por qué el límite sigue estando" is exactly
  what was changed: now each sample has the budget of its worst package. The
  why that remains is in `workflow/decisiones/un-solo-banco-de-muestras.md`
  and in `Banco` (`tools/audio/snes_music.py`). The link to
  `workflow/presupuesto-de-muestras-por-paquete.md` now points to
  `workflow/tasks/done/`.
* "Lo que sí cuesta caro es el arranque" (~line 217): the boot no longer
  uploads the bank through the IPL; it uploads the driver and the directory,
  and the boot map's package through command 3. `BOOT_CUADROS` went down from
  112 to 40 on 2026-09-26 and is no longer sized on the ceiling: see
  `workflow/decisiones/el-arranque-esta-dimensionado-para-el-paquete-de-arranque.md`.

## How it ended up

The eight points above are resolved: the anchor and the citation in
`msu.py`, in the new index and in the citations commit; `--inicio` went away
with "Cómo se verifica", which was entirely in the tests' docstrings; the
rest, in the commit of the audio's stale paragraphs. Each commit of the pass
says in its message where each section it removed went.

What taro should read, because it's judgement and nothing verifies it:

* the whole README, which is short now;
* the two new decisions, `decisiones/las-poses-se-suben-en-caliente.md` and
  `decisiones/el-color-math-no-se-usa.md`;
* the divergence that comes back,
  `divergencias/atravesar-paredes-vale-mientras-dura-la-ruta.md`, which had
  been lost in the rewrite of 2026-09-20 and which `celda_bloqueada` was
  still citing.

What was left untouched on purpose, because it's no longer the README:

* two comments in `tools/port/eventos.py` cite sections that don't exist
  ("Lo que falta", for `PlayBGM`, and "la tabla de orden", for `PlaySound`),
  but the whole paragraph is stale —it says the ROM uploads a single bank—
  and fixing it is judgement, not a citation;
* the `README.md` line in the map at the top of `AGENTS.md` says "el port a
  SNES entero con sus trampas", and `decisiones/README.md` says that "el
  porqué largo de varias está además en `README.md`": both describe the
  earlier README.

## The second pass

taro asked on 2026-09-26 to remove "Por qué la Super Nintendo" and every
comparison with the Mega Drive, move what had been left as doubtful, leave
"Referencias" as a list with links, and that no documentation except
`AGENTS.md` name the environment (container, `/extras`, `/shared`, `box`).
Where each thing went:

* the audio, to `docs/port/audio.md`;
* the hardware traps, to the header of `rom/src/main.s`;
* the baked translucent ones, to
  `decisiones/los-translucidos-van-horneados.md`;
* the environment rule, to `AGENTS.md`.

What still names the environment, on purpose, because taro left out the
tasks and the code: the tasks in `tasks/` and `ESTADO.md`, and comments and
defaults of `justfile`, `tools/` (`render_map.py`, `msu.py`,
`snes_samples.py`, `entregar.py`, `ensamblar.py`, `retro.py`, `batalla.py`,
`experiencia.py`, `fuente.py`, `fork.py`, `cache_disco.py`),
`rom/src/msu1.s` and four tests.

**taro approved it on 2026-09-26.**
