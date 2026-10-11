---
name: "The texts fit in the window"
description: "Rebuilding the messages' line breaks for the SNES's width, as a patch"
status: done
---

# What

That the game's messages fit whole in the SNES window, instead of being cut.
Today `Mensajes.agregar` (`tools/port/eventos.py`) **truncates** each line to
`ventana.COLUMNAS` and each box to `ventana.LINEAS`: the reason for the 39
characters is in `tools/port/ventana.py`, and it is the tile bank, not the
window's width. RM2k has no auto-wrap: the author put each break by hand,
thinking of a 320 px screen.

It is an artistic decision —it changes what is read— so it goes as a
**patch**, in the line of `parches-de-decisiones-artisticas.md`.

# Status

**Done on 2026-09-24**, in `4c82f2a` and `6ea392e`. taro played it until after
the Director and the texts are fine: "we don't need to do anything more
complex". How it ended up:

* **The refit is a step of the pipeline, separate from the patches.** taro
  asked that it not compete with `parches/` nor with the forks of `juego/`:
  they are two different processes. The reader has a hook,
  `lcf.REAJUSTAR_TEXTOS`, which the converter sets —like
  `DECORAR_TRANSLUCIDO`—, and it runs after the forks on whatever is left. A
  box that already fits is not touched, so a text corrected by hand in a fork
  always wins.
* **The TOML below was not done**, and it is not needed as long as no case
  shows up: if one comes out wrong, it is treated as a bug of that case.
* **The message block counts in steps of two bytes** (`MENSAJES_PASO`):
  splitting boxes pushed it past the 64 KB the operand of `OP_MESSAGE`
  reaches.
* The battle texts have another width and continue in
  `los-textos-de-la-pelea-no-entran.md`.

What is below is how it was arrived at, on 2026-09-24:

* **First a function, and the infrastructure only if needed.**
  `tools/port/textos.py` is pure: it receives a box and returns one or more.
  It is in `main` with its tests, but the converter does not call it yet.
* **The TOML that maps text is decided**, and the mapping has to be
  deterministic. It is gettext's model: the key is the exact original, the
  translation can be more than one box, and a context disambiguates the day
  the same box has to come out differently in two places. With the function
  alone that day does not come: the same box always gives the same thing.
* **A split box repeats the speaker's line**, because the game does it that
  way: of the 564 consecutive boxes by the same character, all repeat the
  name.
* The idea of Ditto extracting the texts with ids, with a byte-for-byte round
  trip, is useful for real translations. Today it is not needed.

**The experiment is in the `textos-experimento` branch**: forks in
`juego/mapas/` of the maps 1 to 16 that change, without 11. It is temporary and
does not go to `main`, because a fork covers `data/`. The ROM and a before and
after of each box are in `pruebas-manuales/2026-09-24-0aeb917-textos/`.

# What complicates it, and how it is solved

**The speaker's line.** Almost all the boxes that do not fit start with one:
the name in capitals —`KERSH`, `MANTA`— or `?????` when it is not yet known who
it is. That line is not touched, and the body has three lines instead of four.
Detecting it with "all in capitals, short, without a final period" was enough
on maps 1 to 16, but it is a heuristic: the patch says which one it is, so a
wrongly detected case is fixed by hand.

**The breaks the author wanted.** Two rules:

1. **A box that fits is not touched.** That way all the breaks of all the boxes
   that already worked are kept, which are the majority.
2. In a box that does not fit, **an original break is a good place to cut, but
   not a mandatory one.** Treating them as mandatory left orphans —"it still
   / is."— and made more boxes not fit.

**What does not fit even refitted.** The body goes over three lines. There are
two ways out and it is a decision per case: splitting it into two boxes, which
adds one key press for the player, or editing the text by hand. The patch has
to be able to say both things.

# Where the patch lives

**The JSON files in `data/` are not edited.** They are derived: `just datos`
empties them and writes them again from the `.lmu`, so an edit there is lost on
the next regeneration, and besides the `git diff` of `data/` would stop saying
"the game did not change".

What I propose is a **texts file that the converter applies in memory**, after
reading `data/` and before compiling:

    parches/textos/<mapa>.toml     one per map, like parches/mapas/
    parches/textos/comunes.toml    the common events
    parches/textos/tropas.toml     the battle pages: another width

Each entry is a box: **the original text as the key** and the one that replaces
it —one or more boxes—. That the key is the content and not a position (map,
event, page, command index) is what avoids copying the events:

* nothing of the event needs to be copied, only the text;
* it survives the order of the events or of the commands changing;
* a box the game repeats in several places is fixed once;
* an entry whose original no longer appears in the game is a stale patch, and
  the check fails saying so, like `just parches-check`.

An entry could look like this:

    [[cuadro]]
    original = ["MANTA", "I already told you. He didn't go this way."]
    nuevo = [["MANTA", "I already told you.", "He didn't go this way."]]
    a_mano = false

It is applied **by replacing the `ShowMessage` and its `ShowMessage_2`** with
the new boxes, before `agrupar`. That way splitting a box in two is two more
`ShowMessage`s, and the ROM does not notice. The tail of escapes —`\|`, `\^`—
goes at the end of the last box.

**Two steps, like the other patches:** a recipe proposes the refit of
everything that does not fit and writes the entries; what is edited by hand
carries `a_mano = true` and the recipe does not overwrite it again. The suite's
check fails if a box does not fit and has no entry. With that the truncation of
`Mensajes.agregar` stops being the normal path and becomes an error.

# The experiment, only on the text

Counting the boxes per page, with repeats, on 2026-09-24:

| | Boxes with a line longer than 39 | Start with the speaker | Still do not fit after refitting |
|---|---|---|---|
| Maps 1 to 16 (introduction and Lashe City) | 157 | 155 | 4 |
| The rest of the game | 1,353 | 1,297 | ~310 |

The way of cutting weighed a lot on how many are left not fitting. With the
same boxes of maps 1 to 16:

* if the original breaks are treated as mandatory, 9 do not fit;
* if the whole body is rebuilt, 4 do not fit, but all the author's breaks are
  lost;
* with the algorithm below, 4 do not fit.

The algorithm chooses the cuts by minimising a cost, like a TeX paragraph:

* cutting after the end of a sentence is free;
* cutting after a comma costs a little, and anywhere else more;
* where the original cut, the cut comes out cheaper;
* a short line and an orphan word at the end are penalised.

Examples from maps 1 and 2:

    KERSH                                          KERSH
    Time is running out. There's no turning back.  Time is running out.
                                                   There's no turning back.

    CORE                                           CORE
    No sweat, Boss! You want a door removed,       No sweat, Boss!
    I'm your MAN!!                                 You want a door removed, I'm your MAN!!

    In the beginning, life was simple.             In the beginning, life was simple.
    Perhaps, for the computers, it still is.       Perhaps, for the computers,
    Imagination is not easily represented          it still is. Imagination is not easily
    with ones and zeroes.                          represented with ones and zeroes.

The third shows the limit: the original had one sentence per line, and the
refit turns it into running prose. **The weights are taste**: with other values
the same box comes out another way and others end up worse. That is the reason
for the output to be a file that is read and edited, and not something the
converter decides on its own in each build.

# Plan

1. **The format and the application**, without refitting anything: the
   converter reads `parches/textos/`, replaces the boxes and the check detects
   stale patches. With the directory empty the ROM has to come out byte for
   byte identical.
2. **The recipe that proposes**, run over maps 1 to 16. taro reads the diff,
   corrects by hand what he does not like and plays it. It is the real
   experiment.
3. **The rest of the game**, in batches. The roughly 310 boxes that do not fit
   ask for a decision each.
4. **The options of `ShowChoice` and the battle texts**, with their own width.
   It is what `los-textos-de-la-pelea-no-entran.md` asks for, and the same
   mechanism solves it.

# Open questions

* For the boxes that do not fit: split in two, or edit the text?
* One file per map, or a single one for the whole game? Per map reads better in
  the diff, but a box repeated in several maps ends up in only one, or in all.
* The three `\V` —the value of a variable— have no known width until run time.
  Today they do not compile; when they compile, the refit has to assume a
  width for them.
