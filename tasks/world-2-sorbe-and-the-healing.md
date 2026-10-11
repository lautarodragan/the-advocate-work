---
name: "World 2: Sorbe and the healing"
description: "Milestone 2 of el-mundo-y-lo-que-sigue: the layout with a 256-tile above layer, ChangeEncounterSteps, maps 69 and 76 to 84 in release, the sign on 81 and the end of the demo at Tasgarde's entrance"
type: feature
status: done
---

# What

Milestone 2 of `world-and-what-follows.md`, which has everything measured
beforehand. It starts from `3aac634`, with milestone 1 (`world-1-map-66-fits.md`).

* **The sixth layout**, `LAYOUT_VENTANA_ENCIMA`: BG2's base at `$5000`,
  the above layer in 256 tiles, 384 background and 384 sprite, for 69
  (329 background, 157 above, 283 sprite). The window starts at index
  256 of BG2 and not at 128, so the cartridge carries a second map of its
  cells, `ventana_celdas_256` (640 B), and `estampar_ventana` chooses by the
  distance between the window and BG2's base. `vram_layout` now also looks
  at the above layer.
* **`ChangeEncounterSteps`**: OP_ENCOUNTER_STEPS (0x32) carries the `1 / pasos`
  and the seven thresholds of the rows, computed in the converter. The map's
  thresholds are now copied to RAM on entering (`ENC_UMB`, $7E79C0), so
  that the command changes the chance and the rows together, like
  `Encuentros.poner_pasos`. On a map without encounters it does nothing; loading
  another map goes back to that map's.
* **69 and 76 to 84 in `release`**, through `AGREGADOS`: between 66 and 84 are
  Yun Town and Drust Camp, which don't go in yet, and 74, which was already there as
  a test map.
* **The sign "Meanwhile, in Lashe City"** on 81: a fork that replaces the
  `ShowPicture` of `MeanwhileLashe` with a `ShowMessage` with the same text and
  removes the `MovePicture`s, the wait and the `ErasePicture`. The text comes from
  reading the game's image.
* **The end of the demo** moves from 66 ev10 (Sorbe) to 66 ev13 (Tasgarde):
  ev10 went back to being the original's.

# Done and checked

* **No map that was already in changes layout**: with the converter from the
  first commit, the `mapdata.inc` of `release` and of `test-special` come out
  the same as `3aac634`'s except for the new block of `ventana_celdas_256`
  (diff of the two `.inc`s, which carry each map's record: layout,
  `BG12NBA`, the window's addresses).
* **69 goes into the new layout** and the window comes out right: golden
  `sorbe-69-mensaje` (`test_sorbe.py`). **It was seen failing with the bug in place**:
  forcing `estampar_ventana` to always use the 128 map, that golden
  differs in 26 % of the pixels.
* **All triggerable pages of the new maps compile** (with
  `culpables.py` from `mundo-plan`): 69, 76 to 84. On 66 seven don't compile,
  those whose destinations aren't in (67, 68, 105, 259, 310, 312).
* **`test_pasos_de_encuentro.py`**, new: 10 steps on 66 (chance and
  thresholds), zero on 66, 10 on 5 (without encounters: it writes nothing), and
  the return to 66's 65 on reloading it. `test_batalla_golden.py::
  test_encuentro` covers that the step on which `test-special`'s encounter
  comes up didn't move when reading the thresholds from RAM.
* **`test_recorrido_sorbe_golden.py`**, new: from the world (the "no" branch to
  Wick, 162, which is the ankle one) to Sorbe, the old woman and the guard, the
  mountain and the fight with Vago, the healing, the story and the sign, the
  office, the factory, outside, the transport, and Dalia's trip up to the
  end of the demo and the title. **The fight with Vago is won with the party's HP
  set to 999** from the harness: Talan at level 1 and Arden at 3, which
  is what a new game gives, lose. Its captures aren't blessed.
* **`test_sorbe.py`**, new: goldens of the arrival at 69, 76 and 81, with
  `celdas_mal_dibujadas` at zero, and the one of the message on 69.
* **Dalia's trip ends by itself at the end of the demo**, without walking: the
  car's route ends right on Tasgarde's entrance, and RPG_RT, on taking
  the last step of a route, cancels it and looks at the event under the hero
  (`Game_Character::UpdateMovement` and `Game_Player::UpdateMovement` of
  easyrpg); the event waits for the trip's page to finish. The
  ROM does the same.
* **The race** now ends on entering Sorbe Village (69).
* **On merging `main`** (the backgrounds in the MSU-1)
  `test_msu_una_pelea_del_mundo_lee_su_terreno_o_el_reemplazo` went red: it reaches 66
  with `DummyHero` and that now starts Dalia's trip. It turns on 278 and passes
  with its goldens intact. And `just techos` for the two new themes.
* **`just cartuchos` and `just pruebas` green** on the merged tree.

# Space

Measured with the method in `AGENTS.md` on what `just cartuchos` left, on the
merged tree with the backgrounds in the MSU-1:

    release        81,8 %   bank 0 189 B    bank 1 ~7,9 KB    BSS 138   ZEROPAGE 4
                   last data bank $71: twelve left, from $72 to $7D
                   texts: 117.016 B of 131.072, 14.056 to spare
    test-special   19,2 %   bank 0 1.033 B  bank 1 ~9,8 KB    BSS 138   ZEROPAGE 4

Against milestone 1 (75.6 %, bank 0 261 B, bank 1 8,185 B): bank 0 lost
72 bytes in `release` —the tables of the ten maps, plus `estampar_ventana` and
`op_encounter_steps`— and gained 40 in `test-special`, which adds no maps. The
text block that the plan considered full with the whole chapter has room to spare with
these maps.

# Debt

* **The battle on the world and Vago's come out without a background.** That belongs to
  `all-the-battle-backgrounds-in-the-msu-1.md`, which goes in parallel.
* **The sign comes out in the usual window**, at the bottom: the original's `MessageOptions`
  (transparent and in the middle) isn't done by the ROM, same as in the
  rest of the game.
* Wick's branch (164, the ankle healed by his surgeon) isn't played by
  any test: in Sorbe, Vago waits at the door of his house (69 ev18) and
  leads straight to 81.
* Yun Town, Drust Camp and Tangle Forest are still out: their entrances on the world
  do nothing.

# What taro has to test

* Finish the race and the farewell (with the "no" to Wick, which is the ankle),
  walk to Sorbe and go in.
* In Sorbe: talk to the old woman at the well, and the guard on the road to the mountain
  lets you through. That the trees and roofs that cover the hero (the above layer,
  in the new layout) look right, and the messages too.
* The mountain: the random encounters, and Vago at the top. **With the party of a
  played game** —the test wins it with HP at 999—: can he be beaten?
* The healing, the story and the sign "Meanwhile, in Lashe City" on the
  black screen; the office; Dalia in the factory and the exit at the bottom; the
  transport.
* The car trip across the world: no battles, and on reaching Tasgarde the sign
  of the end comes out by itself and goes back to the title.
* Sorbe's shop (79), inn (78), spa (77) and mayor (80): no test
  looks at them.
