---
name: "World 4: Tasgarde, Eisen and the bridge"
description: "Milestone 4 of el-mundo-y-lo-que-sigue: the main path of the world chapter in release, toggling switches, the cut for erasing, and the end of the demo at the entrance to Tangle Forest"
type: feature
status: done
---

# What

Milestone 4 of `world-and-what-follows.md`. It starts from `3c16a17`, with
milestones 1 to 3 (`testing/mundo-1-*`, `world-2-sorbe-and-the-healing`, `world-3-the-space`),
and merges `main` with the debug map (`455f9fc`).

* **The map rule moves to `MENOR_A = 105`**, by id, as taro answered
  (question 5). The exclusion grows to sixteen —65 a folder, 75 96 97 98
  unreachable, 104 from another chapter, and the optional ones: 67 71 72 of
  Yun Town, 68 103 of Drust Camp— and the additions stay at 164, 259, 255 and,
  behind `CON_MAPA_DE_DEBUG`, 900. 70, 73 and 74, which were test maps, become
  part of the game by the rule; 255, by addition. 348 stays a test map: it's
  the world's optional shop.
* **`ControlSwitches` that toggles**: no opcode, one branch per switch with
  what already exists (`_compilar_alternar`). The game toggles only one, 286,
  twelve times, on 89 and 93.
* **`ChangeScreenTransitions` to the cut for erasing** (19, 95 ev55) and to
  "none" (20, 93 ev4), which compiles to the cut: `TRANSICION_CORTE`, and
  `fundido_desde` starts the fade at its last outgoing frame. The cut and
  "none" for showing still don't compile: nobody asks for them.
* **The end of the demo** moves from 66 ev13 (it goes back to the original:
  it leads to Tasgarde) to **66 ev19, the entrance to Tangle Forest**, and not
  to 18 as the assignment said: see below.
* **The Fortitude counter** stays as debt
  (`fortitude-counter-is-not-shown.md`, with what was measured: the
  minigame can be lost). The minigame is played to the end without it.

No opcode nor new far RAM was needed: 0x33 and $7E7A10-$7E7A2F stay free. No
new index in test tuples.

# The tunnel is on the other side of the forest

The plan considered Tangle Forest optional because no switch of the main path
depends on it (`dependencias.py`). But the map does: on the west side of the
bridge, 66 is an island that reaches the entrance to Tangle Forest (43, 57)
and nowhere else, and the tunnel to Paradise (18, at (5, 64)) is on another
one, the southwest one, which can only be reached through the forest: 310 →
311 → 313 → 312, which comes out onto 66 at (34, 56). The game says so too: on
entering, Talan says "If Vago's right, Paradise should be just a short journey
to the west, on the other side of this forest."

So the demo ends on entering the forest: the fork of 66 removes the `Teleport`
to 310 from page 1 of 19 and puts the end sign after Talan's two messages. 18
stayed as the original (its `Teleport` to 105 doesn't compile and the page
does nothing). **Tangle Forest is the next milestone of the main path**, not
the optional part; what it requires is in the plan (311's `EraseEvent`, 312's
timer conditions). Noted in `world-and-what-follows.md`, milestone 4.

# Done and checked

* **Every triggerable page of the new maps compiles**, counted with
  `mundo-plan`'s `culpables.py` against `release`'s list: 74, 85 to 95, 99 to
  102, 259 and 255. On 66 five don't compile, those of the destinations that
  aren't in: 67, 68, 105 (18, the tunnel) and two to 312.
* **`test_recorrido_capitulo_golden.py`**, new: from the entrance to Tasgarde
  to the title. The guard, the lab, Eisen's story, **95's minigame played in
  full** —three levers and the hatch, with jumps (action events that move the
  hero) and stairs (touch ones); the route ends with 4 of 99 fortitude—, the
  return to Sorbe, the bridge, Arden's plan, under the bridge with the battle
  of the seventh creak (with HP at 999; the ten creaks that have to be stepped
  on come from a BFS that minimizes them) and the end of the demo. It checks in
  RAM the parties of each stretch and what the transitions leave: the cut on
  arriving at 95, the mosaic on returning to Sorbe and the fade after Vago. Its
  screenshots aren't blessed.
* **`test_capitulo.py`**, new: goldens of the arrival at 74, 85, 95, 259 and
  255, with `celdas_mal_dibujadas` at zero.
* **`test_borrar_con_el_corte`** (cases `transicion-corte` and
  `transicion-ninguna`): the brightness at zero and the map loaded on the
  fade's first tick, against the zoom's whole ramp. **It was seen failing**
  with `fundido_desde` ignoring the cut: it reaches zero on tick 23.
* **`test_recorrido_sorbe_golden.py`** now ends when Dalia enters Tasgarde,
  alone, at the end of the car's route.
* **When merging `main`** (the debug map) `AGREGADOS` clashed: it ended up as
  `(164, 259, 255)` plus 900 behind the flag. `just techos` again on the
  merged tree, because of the chapter's five new themes.
* **The SPC700 directory fills up** with the chapter's themes: the second
  batch of `snes_music.copias` stops for lack of entries.
  `test_los_efectos_comparten_lugares_y_a_las_copias_les_sobran_entradas`
  asked for that not to happen; now it's
  `test_los_efectos_comparten_lugares_del_directorio` and asks that the
  sound effects take fewer entries than the usual ones. It's a limit on how
  much the music can be improved, and it'll come back with each theme.
* **`just cartuchos` and `just pruebas` green** on the merged tree.

# Space

`just espacio release` on the merged tree (with the debug map): 115 of 124
data banks, 9 free; bank 0 137 B; bank 1 7,722 B; BSS 138 and ZEROPAGE 4;
texts 142,138 of 262,144 B. Before the merge, without the debug map, it was
114 banks, which is what milestone 3 measured for this path.

# The earlier music, without MSU-1

Measured pair by pair with `Banco`, as in `audio-after-lashe-city.md`
(the arguments of `build_varios` captured from each tree and the allocation
rebuilt; a drop = more than 0.5 kHz), against `main` 455f9fc1: **43 (theme,
instrument) pairs of 15 themes that were already there go down, and 51 go
up.** The worst, drum hits and some instrument from ~22 to ~14.4 kHz
(Lunar_Pyramid, wb3shop, escape_newyork, Deflector1, bubstix…). The whole list
is in the recordings' `LEEME.txt`.

It isn't the full directory: the cause is the five new themes, which share
samples with the earlier ones and change which copies `snes_music.copias`
makes (removing them from the capture, 0 go down; with only jackalstg2, 36;
with only Story Music, 26). Without letting the second batch copy for the new
themes there's room left in the directory and 42 go down anyway. Tried without
recovering them: `TEMAS_APARTE` doesn't apply (each new theme already goes
alone in its package); a shorter or longer first batch (`SE_DE_SIEMPRE` from
70 to 130: the best is 29, and it changes the batch taro approved);
`COPIA_HASTA` 0.85 and 0.95; without jackalstg2's inheritance or 259's
package. **Nothing was changed**: per taro's rule, the fifteen themes are
recorded before and after, without MSU-1, in the audio directory of 2026-09-27
for world 4, with a `LEEME.txt` that says what to listen for. Recovering them
would require touching how `copias` chooses, which is its own task.

# Debt

* **The panoramas aren't drawn**: the bridge (259), under it (255), 95, 94 and
  99 have one and show black behind the map, like every panorama in the port
  (`panorama-of-map-2.md`).
* **The Fortitude counter isn't visible**: `fortitude-counter-is-not-shown.md`.
* Erasing with "none" is a black frame and not the fade from the old map to
  the new one: `divergencias/las-transiciones-del-teletransporte.md`.
* A save made at the minigame's save point comes back with the fade instead of
  the cut (the transition doesn't travel in the save): it's only noticeable in
  the jump to the start when fortitude runs out. See `TRANSICION_BORRAR` in
  `rom/src/ram_lejana.s`.
* The debug map has no door to Tasgarde or to the bridge.

# What `just pruebas` doesn't cover

* Saldra's branch and AG7's on the bridge: Arden's plan is 54's page; with
  Saldra (56) or AG7 (150) those of 13-14 and 15-16 of 259 run, which no test
  plays.
* The other choices: "Not yet" on the bridge (it goes back to 66 and turns on
  851, with another page afterwards) and the path underneath with other creaks
  (there are battles at 13, 20, 26…: the test only plays the 7th).
* Losing 95's minigame (parallel 56) and starting it over.
* The save points of 74 and 95.

# What taro has to test

* **Listen to the before and after wavs** of the fifteen themes whose music
  drops without MSU-1 (see "The earlier music"), and say whether it's
  accepted.

* From Dalia's trip: Tasgarde, the guard, the lab, Eisen and the switch, and
  Eisen's whole story (86 to 94): that the messages and the cutscenes look
  right, and the jump from 93 to 95 (a black frame instead of the original's
  crossfade).
* **95's minigame, without seeing the fortitude**: it can be lost, and with
  the direct route 4 of 99 are left over. Is it clear what to do? And what
  happens on losing?
* The exit from the minigame (the cut), the throne simulation (the mosaic) and
  the return to Sorbe with Talan.
* The bridge: the guards' talk, Arden's plan, and **under the bridge**: the
  creaks, the battles (can they be won with the party of a played save?) and
  the exit on the other side. The bridge's background is black (panorama).
* The entrance to the forest: Talan's two messages, the end sign and the
  return to the title.
