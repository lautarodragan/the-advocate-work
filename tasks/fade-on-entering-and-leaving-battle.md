---
name: "The fade on entering and leaving battle"
description: "RM2k's transition when a battle starts and ends, which also covers the loading of the audio package"
type: feature
status: done
---

Today the battle enters and leaves without a transition. In RM2k there is
one (the one in the system database, "Battle Start" and "Battle End"; see
`las-otras-transiciones-de-rm2k.md` for those that are not the fade).

Besides looking like the original, taro pointed out on 2026-09-26 that **it
covers the loading time**: with the samples distributed per map package
(step 6 of `la-calidad-de-la-musica.md`), uploading the battle package goes
from ~0.7 s to ~1.3 s frozen on entering, and as much again on leaving.
With a fade, that load falls inside the black screen, as already happens on
map changes.

Look at which transition ABL's database asks for, whether the fade that
already exists for maps is enough, and measure that the load falls entirely
inside.

# What the database asks for

`battle_start_fadeout = 16`, `battle_start_fadein = 17`, `battle_end_fadeout =
17`, `battle_end_fadein = 16`. In easyrpg's `Game_System::GetTransition` 16
is `ZoomIn`/`ZoomOut` and 17 `MosaicOut`/`MosaicIn`, 41 frames each.
Besides, on entering, `Scene_Map::TransitionOut` always prepends two white
flashes of ten frames (`PrependFlashes(31, 31, 31, 31, 10, 2)`).

# What was done

All in `rom/src/fundido_de_pelea.s`, and blocking like the battle: it costs
no tick.

* the flashes, with colour math: the fixed colour added to the whole
  screen;
* the zoom **as a fade** —taro's decision for what the console does not
  do—, with the teleport's ramp;
* the mosaic with the PPU's mosaic, **and fading at the same time**: RM2k
  does not darken in the mosaic, but the load has to fall in black. So each
  side goes dark, loads, and the other lights up.

The battle goldens did not move: no capture falls inside the transition.
What shifted were the numbers of `test_batalla_golden.py` —68 frames, what
the transition adds before the battle takes control—, the one of
`test_cores.py`, and `Pelea.cerrar`, which now waits for the map to run
again.

`test_fundido_de_pelea.py` enforces that every frame in which the package
advances is black, on entering and on leaving. Without the change it gives
83 of 83 frames visible on both sides (map 2's droid, `release`).

# Measured, map 2's droid in `release`, without MSU-1

| | before | after |
|---|---|---|
| entering: from the battle requested to control | 90 frames, 83 with the map frozen | 158: flashes 20, fade 23, load 83 in black, scene 9 in black, mosaic 23 |
| leaving: from the final A to the map running | 104, 83 with the battle frozen | 150: mosaic 23, load 83 in black, map 22 in black, fade 22 |

The load takes the same; what is added are the ramps. With MSU-1 —with not
uploading the samples of themes that have a track already merged— the
entering load drops to 20 frames and the leaving one to 49, both in black:
entering lasts 94 frames and leaving 116.

# To look at while playing

* that the flashes look alike: they are colour addition, not alpha, and the
  sprites of palettes 0 to 3 —the hero— flash less, which is the
  hardware's;
* the battle's mosaic, which in RM2k reaches blocks of 41 pixels and here
  16, the PPU's cap;
* it was already there before: when the droid battle starts the last
  message ("Get ready everyone!") shows again during the flashes and the
  fade. It is the same on `main` without this change —before it was seen
  frozen—, it does not come from here.

**taro looked at the captures on 2026-09-26 and finds them fine.** It still
has to be played.
