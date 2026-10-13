---
name: "All the battle backgrounds in the MSU-1"
description: "Every background of the game in the .msu in high quality; in the ROM only those that fit, and the rest share a low-quality replacement"
type: feature
status: done
---

From taro, on 2026-09-27, on seeing that the battles in the world (66) came out black
because the cartridge does not carry its five terrains:

- **All the game's battle backgrounds go to the `.msu`**, in high quality,
  whether or not they are on the cartridge's maps. With that the part of the `.msu` dedicated
  to backgrounds stays fixed: the exact sector it takes up is known, and it does not move when
  a map goes in.
- **In the ROM, each battle whose background does not fit uses the same
  replacement background**, one of those already there, in low quality. Not black: black
  is confusing.
- **With MSU-1, each battle shows its correct background**, even if it is not in the
  ROM.

See `internals/the-msu-file.md` and `msu-1-the-backgrounds-through-the-data-port.md`
for how they are read today. It needs measuring how much all the game's backgrounds weigh
in the `.msu` and deciding the order (by background id, so that each one's sector
does not depend on which maps go in).

# Where RM2k gets a battle's background from

From easyrpg-player, not from memory: `CommandEnemyEncounter` (parameter
`[2]`: 0 "the place's", 1 the one the command names, 2 a terrain, from RM2k3),
`Game_Map::SetupBattle` (it goes up the tree while the node says "the
parent's"; only type 2 carries a name) and `Spriteset_Battle` (without a name, the
background of the terrain of the hero's cell). So **reaching the root without a
type 2 is also "the terrain's"**, and the port treated it as "no background".

Measured over the game on 2026-09-27 (throwaway script):

* `EnemyEncounter`: 51; 49 name a background (14 distinct names) and 2 ask for
  the place's, on 105 and on 141. **No `ChangeBattleBG`** in the whole
  game (maps, common events, troops).
* Tree: 58 nodes with their own background (24 names), 24 with the terrain's, the
  rest inherit.
* Terrains: 30, 21 with a background (19 names).
* **The union is 45 backgrounds, and they all exist**: 32 in the game and 13 in the RTP
  (`Cave1`, `Castle`, `Swamp` and those of the generic terrains). Until today
  `escena._abrir` did not look in the RTP; now it does, only for the backgrounds.
* The world's terrains, by cell of 66: forest5 (16), river5 (21), mroad2
  (15), plains5 (20), desert1 (19), plains6 (25) and Galaxy (1). They are not the
  five the plan said: forest6 is 17, which 66 does not step on. At the arrival
  (71, 29) it is plains6. 158 and 210 are also terrain-based.

# What was done

* **A background's number** is its place in the list of the 45 sorted by
  case-insensitive name (`escena.fondos_del_juego`). It does not depend on the
  cartridge. A byte is enough with margin: `$FE` is "the place's" and `$FF` the plain one.
* **The `.msu`, version 2**: the header and the index padded up to `$10000`,
  and from there background k at `$10000 + k × $8200` (tiles; colours `$8000`
  further on; the rest padded up to the 512 sector). The sound effects after the
  last slot. Documented in `internals/the-msu-file.md`.
* **In the ROM**: `escena_tropa_fondo` and `escena_mapa_fondo` carry the game's
  numbers; `fondo_terreno` (per terrain) and `fondo_respaldo` (per number,
  which of the ROM's is drawn without MSU-1). `esc_terreno` reads the terrain under the
  hero like `op_terrain`. `ESC_FONDO` is the game's number and the new
  `ESC_RESPALDO` ($7E664B, in the scene's stretch) the ROM's.
* **The replacement is `ABLBackdropSJ08`**, the Rat Tracks one: a cave of
  grey rock, the only one of the three that does not say where you are (the droid's is
  a ship with Earth on a monitor; the Back Alleys', a street with
  signs). `release` already carries it, so it costs nothing.

# The figures

* `.msu` of `release`: 3,347,116 B, with the 45 backgrounds and 212 sound effects. The
  backgrounds region is 45 × 33,280 = 1,497,600 B from `$10000`. Before, with 3
  backgrounds, the backgrounds were some 99 KB.
* Each background the ROM carries is 16,416 B (tiles and colours) plus 8 of
  pointers.
* **Three in the ROM (what remains) against only the replacement**, measured
  building `release` both ways: 75.6 % against 74.8 %, that is 32,848 B
  (two fallbacks). Bank 0, BSS and ZEROPAGE, identical in both.
* **Recommendation: keep the three.** taro's criterion is that without
  MSU-1 something reasonable shows: with the three, the battles that already worked —the
  droid, Sector 27 and 30, the Rat Tracks— keep their background; with only the
  replacement, the droid fights in a cave. 32 KB is one bank, and the day
  space gets tight it is one line: `escena.FONDOS = (REEMPLAZO,)`.

# What does not scale in today's format

* **Background numbers are 8 bits**: 45 of 254 possible. Plenty.
* **`msu_fondo_pos` grows 8 B per background** (360 B) but goes in a
  generated bank, not in 0. The new tables too (31 + 45 B).
* **The `.msu`'s index has a ceiling** at `$10000`: 8,190 entries. With 90 for
  backgrounds some 8,100 are left for sound effects; `armar` refuses if it goes over.
* **`se_msu_altura`, the sound effects' height table**, is the one that does not
  scale: the world plan measures it at 33.8 KB with the whole chapter, and
  `escribir_msu` refuses to go past one bank. It is not part of this task: it is per
  package × sound and grows with the audio, not with the backgrounds.

# Tests

* `test_msu_una_pelea_del_mundo_lee_su_terreno_o_el_reemplazo` (new, in
  snes9x and bsnes): a battle at the arrival on 66. Without `.msu`, `ESC_FONDO` is the
  number of plains6 computed from the game (tile → ChipSet terrain → terrain
  background) and the clean background in WRAM is the light replacement, not
  zeros: golden `msu-world-rom`. With `.msu`, `ESC_MSU` at 1 and the clean one is
  quality plains6: golden `msu-world-msu`.
* `test_msu_the_rom_knows_where_each_backdrop_is`: in addition, each background in its
  fixed place, `MSU_FONDOS_N == FONDOS_JUEGO == 45`, and the backgrounds region
  byte-for-byte identical in the `.msu` of both cartridges.
* `test_battle_scene_drawing`: the fallback's colours are read with
  `ESC_RESPALDO`.
* `test_scene_a_place_battle_uses_the_maps_backdrop` (new): the case
  `battle-113` fights with "the place's" background on 60, which names
  `SJBackdropABL01`; `ESC_FONDO` is that one and the clean one is the replacement.
* **Verified** with `just cartridges` and `just tests` on this branch before
  the merge: all green, and **no old golden changed**. The only
  new ones are `msu-world-rom` and `msu-world-msu`.
* What **no test runs**: the terrain under the hero with a
  `TileSubstitution` set (the lookup of `esc_terreno` is copied from
  `celda_sustituida`, which the suite does exercise through `op_terrain`), and a map
  with a single terrain that asks for the terrain's (the `TERRENO_PLANO` branch).

# What changes on purpose

Without MSU-1, the battles that used to come out black because their background was not in
the ROM now come out on the replacement: the world, 158 and 210 (terrain), and
in `release` also those of the maps that name a background the ROM does not
carry, like Sector 27's Warehouse (`SJBackdropABL01`). And two things the
port did differently from RM2k and now does not: an `EnemyEncounter` with "the
place's" background (105 and 141 in the game, and the case `battle-113`) came out without a background, and a
map that goes up to the root without naming a background was treated as without one; both
are "the terrain's" in easyrpg. No golden of the suite looks at those
battles.

# Space

Measured by relinking the `.o` of `release` with `ld65`'s map:

    release   75,6 %   bank 0 261 B    bank 1 ~8.090 B    BSS 138   ZEROPAGE 4

Bank 0 did not change: all the new code is in bank 1 (some 95 B, in
`escena_subir` and `esc_terreno`) and the tables go in generated banks.

# What taro has to look at

* **Without MSU-1 (Mednafen)**: walk through the world from the arrival and fight.
  The background has to be the grey cave of the Rat Tracks, in 16 colours, and
  **not black**. The usual battles —the droid, Sector 27 and 30, the Rat
  Tracks— have to look as before.
* **With MSU-1 (the `abl.msu` next to it, in an emulator that supports it or on the FX
  Pak)**: the same battle in the world has to show **the terrain being
  stepped on**: grassland at the arrival (plains6), forest (forest5), mountain (mroad2),
  desert (desert1), depending on the cell. The usual battles, with the quality
  background.
* **Decide** whether the three backgrounds stay in the ROM (the recommendation) or whether
  all of them move to replacement plus MSU-1, which saves 32 KB and puts the droid in the
  cave without MSU-1.
  Decided the same day, the other way round: all of `release`'s in the ROM, at
  128x64. See `all-of-release-backgrounds-in-the-rom.md`.
* The `.msu` went from a few hundred KB to some 3.3 MB (the 45 backgrounds are 1.4
  MB): copy it whole next to `abl.sfc`.
