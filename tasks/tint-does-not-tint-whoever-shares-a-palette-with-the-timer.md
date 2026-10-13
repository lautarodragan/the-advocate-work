---
name: "The tint does not tint whoever shares a palette with the timer"
description: "tinte.s uploaded the digits' whole palette untinted, which since 09-07 a character shares; now it uploads only the digits' entries"
type: bug
status: done
assignee: taro
---

Found while measuring whether `release` and `test-main` can be merged (see
`merge-release-and-test-main.md`), on 2026-09-25. **It happened in
`release`.** Fixed in the commit that moves this task to `testing/`.

# What was happening

`rom/src/tinte.s` re-uploaded **the whole palette** of the digits untinted,
because "the digits have a palette all to themselves" (`5be4ade`,
2026-09-04). Since `034d721` (2026-09-07) they share that palette with a
character, and that character was left untinted. And not only with the
timer running: the upload checked whether the map **carried** the glyphs,
not whether they were visible, and `release` carries them on all its maps.

The five goldens of map 7's door that the measurement uncovered
—`shake-60`, `close-400`, `close-right-400`, `auto-close-63` and
`auto-close-3-185`— show it if `test-main` is built without `--sin-timer`:
**the door of Talan's house** (an event drawn with tiles 111 and 117 of
`BLchp1`) stays grey on the screen tinted blue. 512 pixels in each one with
the code from before, 0 with the current one. **There are no goldens to
re-freeze because of this.**

# What was found out before touching anything

**RM2k does not tint the timer.** In easyrpg the tone of `TintScreen` is
applied by `Spriteset_Map` to its tilemap, its characters and the panorama,
and `Sprite_Timer` is not part of it (`Priority_Timer` 140 against
`Priority_Screen` 90). So skipping the digits was right; what was wrong was
skipping the whole palette.

**The digits use two colours**, black and pure red (`colores_del_timer`),
and the character they share with sometimes has one of the two or both.
With those there is no fix without spending entries: they are **the same
CGRAM entry**.

**Who shares**, in `release` —measured by running the converter with
`digitos_del_timer` wrapped by a throwaway script—:

| Maps | Who | Shares with the digits |
|---|---|---|
| 1, 3, 6, 14, 16, 30 | events drawn with a ChipSet tile | nothing |
| 7 | the door of Talan's house (`BLchp1` 111 and 117) | nothing |
| 9 | `Future1:7` | nothing |
| 13 | `Future3:5` | nothing |
| 2 | three tiles of `ChipSet3` | the black |
| 10 | `People4:4` | the black |
| 11 | `Object2:6` | both |
| 17 | `Men1:5` | both |
| 21 | two tiles of `caveD` and `Object2:5` | both |
| 8, 20, 23, 26, 28, 32 | the save point | both |
| 4, 5, 12, 18, 19, 29, 33, 34, 36 | nobody: the palette is the digits' | — |

**Where the timer is used in the game** (`TimerOperation` in `data/`): it
is not just one. There are **three visible countdowns** —Talan's alarm
clock (map 7, 600 s), the quarry (map 150, 300 s) and the burning forest
(311 to 312, 120 s)—, and on maps 9 and 11 the tram officer sets it from a
variable and stops it in the same event, so there it is not seen. **Two of
the three coincide with a tint**: the alarm clock starts shortly after a
`TintScreen` with saturation at 40 that neither map 7 nor map 8 undoes —the
countdown runs over the desaturated screen until map 16 stops it—, and the
forest one starts with the screen at (120, 50, 50). So the case is not only
the suite's: in Lashe City the save point was whole and untinted while
everything else was desaturated.

# The fix

Without a new palette and without touching the distribution:

* `subir_timer_pal` uploads from ROM **only the digits' entries**, which the
  converter emits as `timer_mascara` —one word per map, separate from
  `mapa_tabla` because the record is at its 128 bytes—.
* And only **while the timer is visible**. On turning on or off with a tint
  in place, `timer_repintar` asks to re-upload the shadow, because those
  entries change owner.

What remains is in `divergences/the-timer-and-its-neighbor-share-colors.md`.

# What to look at while playing

The Lashe City save point (map 8) with the alarm clock running: before, it
showed with all its colours over the desaturated screen; now it desaturates
with the rest, **except its pure red**, which stays red while the timer is
visible. And the door of Talan's house in any tinted scene of map 7.
