---
name: "The Game Over screen"
description: "Losing a battle or a GameOver go straight back to the title; RM2k shows the GameOver image with its music and waits for a key"
type: feature
status: done
assignee: Carpincho
---

Requested by taro, on 2026-09-28.

Today `op_game_over` (`rom/src/interprete_game_over.s`) and the defeat without
a handler (`op_battle_destination`) do `jml reset`: they go back to boot
without showing anything. RM2k goes through `Scene_Gameover`: the game's image in
`GameOver/` (the one the LDB's `System` names), the system's Game Over music,
a fade, and it waits for a key before going back to the title.

The game brings its image in `GameOver/` (see `ABL_GAME_DIR`).

2026-09-28, in `testing/`: done by Carpincho on its branch, on top of `main` at
17685f7d; `just cartridges` and `just tests` on the branch. What remains is
taro's: see "What taro has to test", below.

# What taro has to test

* **Listen to** `/shared/audio/2026-09-28-game-over/` (with its `LEEME.txt`):
  the new theme, and the nine themes that lose something without MSU-1 —the
  bass drum of seven, and one instrument of bubstix, bmlv2-sbl and
  golden_axe—. If it isn't accepted, room has to be found in the directory
  for the two programs of `GameOver3`; it isn't solved.
* **Look at** `/shared/captures/2026-09-28-game-over/`: the new golden next
  to the original.
* **Play** without MSU-1 and with MSU-1 (track 231 is new: it has to be
  copied to the card): lose a battle without a handler —the trap chest of
  Rat Tracks B1, or the boss of 26—, check that the screen appears without
  going through the map, that `GameOver3` plays, that A or START close it and
  that the title works afterwards ("Resume the Story" with the saved game).
  And the end of the demo on map 66, which is a `ReturntoTitleScreen`: it
  has to go straight to the title, without the screen.
* On the FX Pak: no new MSU-1 seek, but the screen's audio package is
  uploaded with the screen black; check that it doesn't take long.

# What the original does

Looked at in easyrpg-player (`Scene_Gameover`) and in the original with Wine,
on 2026-09-28, with a copy of the game whose boot map calls `GameOver`
(Ditto: `read`, one more command, `write`):

* **The image is the RTP's, not `ablgameover.png`.** The `System` says
  `gameover_name = "GameOver"`, and the game brings a single file in
  `GameOver/`, `ablgameover.png`, which nobody names: RM2k looks for
  `GameOver` in the game, doesn't find it, and uses the RTP's
  `GameOver.png`. That is what is seen with Wine: the grey "GAME OVER" on a
  dark background. (The request's premise was the other image.)
* **The theme is `GameOver3`, also from the RTP.** No `ChangeSystemBGM` in
  the game changes the Game Over one (only the battle one and the victory
  one).
* The map is erased with a fade (35 frames), the image comes in over 80 and
  goes out over 80; `DECISION` (Enter/Z) closes it and from there the title,
  which comes in with its own fade.
* `CommandGameOver` and `CommandReturnToTitleScreen` wait if there is a
  message open.
* Losing a battle without a handler doesn't go through the map: the battle
  is erased and the image appears. And `ProcessSceneActionDefeat` turns on
  the Game Over theme **already at the defeat message**, with or without a
  handler: the ROM doesn't do that (see the divergence).

# What was done

* `rom/src/game_over.s`, in bank 1: the screen, with its audio, its two
  fades, A or START, and `jml reset`. Three entries: `game_over_anotar`
  (`op_battle` notes the defeat destination before fighting),
  `game_over_siempre` (random encounter) and `game_over_si_perdio`
  (`pelea_arrancar`, with the battle already black: it doesn't load the map
  again). `GameOver` comes in through `game_over_desde_el_mapa`, which fades
  the map.
* **`ReturntoTitleScreen` has its own opcode**, `OP_RETURN_TO_TITLE` (0x34):
  it shared `GameOver`'s when neither of them drew anything, and it has to
  keep going straight to the title.
* **The image, compressed in LZ2** (tools/port/pantalla_completa.py): it is
  converted by `titulo.convertir` —the same path as the title one, which
  goes through neither the allocator nor Voodoo: it has its own colour
  reduction—, and a single stream carries tiles, tilemap and colours. The ROM
  decompresses it into the WRAM of $7F and uploads it with three DMAs:
  `pantalla_subir`, which reads a row of `pantallas_tabla` and doesn't know
  which screen it uploads, so the title one can use it as is.
* **The theme**, with its own audio package (`PAQUETE_GAME_OVER`, the theme
  alone, after the battle one), which the ROM uploads with the screen black.
  With MSU-1, its track. The music is now looked for in the game and then in
  the RTP, as in RM2k, and the tracks of the RTP themes that the `System`
  names are numbered after the game's (`GameOver3` is 231): no track of the
  game changes number.

# Space

`just space release`, before (17685f7d) and after:

    bancos de datos  115 de 124, 9 libres        115 de 124, 9 libres
    huecos           28.874 B                    15.367 B
    banco 0          72 B                        50 B
    banco 1          5.621 B                     5.135 B

(test-special: bank 0 from 951 to 929, bank 1 from 8,125 to 7,639.)

# The image: compressed and not light + `.msu`

Measured on 2026-09-28 with `titulo.convertir` and the `lz2` of `tools/lz2/`:

    Game Over (GameOver.png del RTP, 32 grises)   crudo    LZ2
      256x224, 8bpp, 566 tiles                   36.224  11.530
      + tilemap y colores, un solo flujo         38.336  12.843
      liviana: 128x112 4bpp 16 colores, x2        5.024   2.901

    Título (ABL20Title, hoy sin comprimir)
      256x224, 8bpp, 240 colores, 496 tiles      31.744  15.241
      256x224, 4bpp, 16 colores, 453 tiles       14.496   6.234
      liviana: 128x112 4bpp 16 colores, x2        4.512   2.483
      liviana: 128x112 8bpp, 240 colores, x2      9.152   5.190

**The quality one was chosen, compressed, in the ROM, with no light
version.** The light one would save about 10 KB against the compressed one,
and would cost a second path in the ROM —scaling up to double, seeking in
the `.msu`, waiting for the seek— that no core of the suite runs whole.
Compressed, the quality image is seen on every console.

**For the title**: compressing what is there today, without touching a
pixel, would save **16.5 KB** (31,744 → 15,241 of tiles; the tilemap and the
colours aside); a light one in the ROM with the quality one in the `.msu`,
**29 KB** (down to 2,483). The mechanism for the former is already there:
`pantalla_completa.comprimida` and `pantalla_subir`, with another row in
`pantallas_tabla`.

# The audio

**The theme fits**: `GameOver3`, with its own package and MSU-1 track (231).
The test checks that it plays with all its samples in ARAM.

**And without MSU-1 it lowers others**, so it isn't solved: it is decided by
listening. Measured with `Banco`, pair by pair (theme, program or hit), with
the arguments the converter passes to `build_varios` in `release`, against
main at 17685f7d: of 406 pairs, 392 the same, 4 go up and **10 go down** by
more than 0.5 kHz. The cause: `GameOver3` brings two programs that no theme
in the cartridge used —19 and 54— and the directory is full, so they are two
fewer copies for the rest (`snes_music.copias`).

    golpe 35 (bombo)   21,8 -> 18,2   Fire_Mustang..., Story Music,
                                      bmlv2-sbl, fm2bar_gs, jackalstg2,
                                      lufsorr, rshinld
    golpe 65           18,2 -> 14,2   bubstix
    programa 27        22,0 -> 18,9   bmlv2-sbl
    programa 50        22,0 -> 18,4   golden_axe-turtlevillage2

With MSU-1 nothing changes. The before and after wavs of the nine themes,
and `GameOver3` through the SPC700 and through its track, in
`/shared/audio/2026-09-28-game-over/` (with its `LEEME.txt`).

**The ceilings table was run again** (`just ceilings`): the fingerprint of all
the themes changed, because the sample numbers shift with the two new ones.
The headroom of eight themes changes, almost all by less than 0.1 dB; the
ones that change most: dcbest 0.325 -> 0.354 (+0.7 dB),
T_VGFighterMAX_Masako 0.335 -> 0.342, jackalstg2 0.270 -> 0.279, rshinld
0.275 -> 0.269. dcbest didn't change any sample: on main, with 0.325, its
peak sits at -1.4 dB (`techos.py --medir`), and the target is -0.5.

# Tests

* `tests/rpgmaker/test_game_over.py`: the battle without a handler, the
  random encounter and the command reach the screen —the `game-over` golden,
  the same for all three—; it doesn't go away by itself; A closes it and on
  the other side is the title (the usual `title` golden) and the game runs
  again. The control: the battle with a handler and a page without the
  command don't reach it. And `ReturntoTitleScreen` (new case
  `return-to-title`) goes to the title without going through the screen.
* `test_cores.py::test_game_over`: the screen on snes9x and on bsnes.
* `test_heal.py`: the `FullHeal` control checked that the encounter didn't
  reset; now the Game Over doesn't reset until the key, so it checks the
  screen.
