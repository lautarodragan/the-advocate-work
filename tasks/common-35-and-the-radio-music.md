---
name: "Common 35 and the radio's music"
description: "What Yarará left open in the battle systems: ResetAfterBattles, so that the summon gives Lerle back, and the three Play Radio themes in battle"
type: feature
status: done
assignee: taro
---

From taro, on 2026-09-30, answering about `troop-events.md`
(Yarará):

- **Common 35 (`ResetAfterBattles`).** Without it, the summon stays in the
  party instead of Lerle after the battle. Its commands already compile; what
  blocks it is that the variables that only a common names have no slot in the
  save, and adding them shifts everyone else's. taro: breaking save
  compatibility is **never a problem**.
- **The music of `Play Radio` (809).** Its `PlayBGM` is accepted today and not
  done. taro: with quality as low as needed in the ROM and as high as possible
  in the `.msu`; if separating them is harder than lowering the quality of the
  battle theme or others, it is lowered and that's that.

See `decisions/first-the-whole-game-then-the-quality.md`.

It starts from `main` at the commit that launches the task. There: `NO_CACHE=1
just cartridges` gives `abl.sfc` `e20182d1bd905de7…`; `just tests` 893,
`just -f tools/justfile test` 46.

# Common 35 (Aguará, 2026-09-30)

**How it runs in RM2k**, confirmed in the LDB and in the maps: there is nothing
special after the battle. 162 of the 300 troops bring a turn-0 page that turns
on 498 when the battle opens (in EasyRPG, `CheckTurns` with 0 and 0 is turn 0:
it runs before the first orders). And 74 maps —82 pages— bring the autostart
`AfterBattleMint`, with 498 as its condition, which only does `CallEvent` to
common 35; on returning to the map, the autostart runs and the common turns off
498 at the end. In `release` 16 of those maps are there, among them 60 of the
case `battle-summon`.

**What it does**, besides giving Lerle back: it heals the 18 summons (36 to
53), removes whichever is in and adds Lerle (26); it turns off Talan's switches
and rebuilds his HP and SP from variables 134 to 138; it removes Emily's (25)
accessory and the four tapes (385 to 388); and it rebuilds AG7's (18) skills
from its parts.

**The fix**: the variable sweep (`variables`, in `indices.rs` of
`rm2k-snes-events`) also looks at the commons. The game's went from 132 to 169
and the highest, from 201 to 204. It shifts the slots: the saves of the
cartridges from before do not load correctly in this one, and that is
approved.

**The test**: `test_after_the_battle_lerle_rejoins_the_party`, in
`test_troop_systems.py`. **Red before the fix**, measured: 498 stayed on
after the battle. `test_la_invocacion_cambia_...`, which looked at the party
right after the battle closed, now turns 498 off before closing, because
otherwise the common has already run when it looks.

**The cost**: the common compiles in place of each `CallEvent`, so it goes
copied into each map with encounters. `just space` in `release`: data banks
from 116 to 117 used (7 free), gaps from 8,799 to 7,678 B. Bank 0 and bank 1
did not move (13 B and 5,054 B). It is a debt: a shared body would pay it only
once.

**No golden moved**: the suite gave 893 green and the slots one red, which is
the one that counts the variables (updated).

# The radio (Aguará, 2026-09-30)

**What it plays**: the page of 809 starts a theme according to the tape —806
`dd2shad2`, 807 `patchb`, 808 Ryan Bury's— before looking at the variable, so
it plays on all three paths.

**What was tried first, and discarded**: letting the three themes into the
battle package with the battle one. The battle one went down from ~11.5 to
**~4.5 kHz** in its samples (NYLON48A, STLGT57B, DSTGT48…), and the whole bank
was rearranged.

**What stayed**: the event compiler does the `PlayBGM` of a troop page and notes
its themes as `troop_songs`; `rm2k-snes-audio`'s plan (`cartridge::plan`) puts
them **apart** in the battle package, same as a map's `apart_themes`: their
`PlayBGM` uploads them alone with the package's sound effects. That way the
battle theme does not make room for them, and separating them from the quality
of the `.msu` cost nothing: **with the MSU-1 the three have their track** (38,
142 and 161), because the numbering comes from `Music/` and the converter
rendered them on its own.

**The quality debt**, measured by comparing `release`'s `converter.log` before
and after (throwaway script, per sample and per theme): three more themes
leave fewer entries of the sample directory for copies, and samples that other
themes had in their own copy move to the worst package's. The battle theme: its
lowest sample goes from 11.5 to **10.0 kHz** (MMBAS40, 13.3 → 10.0), although
others go up a little (NYLON48A 11.5 → 12.2). The three of the radio end up
between **6.8 and ~10.5 kHz**. And 34 more themes go down, in some sample; the
worst:

    Astpgmarch                11 samples; OBOE_69A 13.6 → 6.8 kHz
    lufsorr, iknow, prepara   OBOE_69A 20.4 → 6.8 kHz
    hzstream                  OCARI72A 16.1 → 8.0 kHz
    rshinld, Lunar_Pyramid    STRNG71B 22.1 → 10.6 kHz
    cd2, Story Music, vswar   drum hits 22.0 → 10.6 kHz
    3D-Galax, wb3mlair        MMBAS40 16.7 → 10.0 kHz
    TF3_1_awe, escape_newyork hits 14.3 → 10.6 kHz

It gets adjusted when the whole game can be played
(`decisions/first-the-whole-game-then-the-quality.md`). To listen:
`/shared/audio/2026-09-30-radio/`, the three themes and the battle one through
the SPC700.

**The test**: `test_the_radio_plays_the_tapes_song`, in
`test_troop_systems.py`, one per tape: `song_current` is the theme, the
music is not silenced and its samples are in the ARAM, like
`test_map_song.py`. **Red without the fix**, measured with `main`'s
compiler: the cartridge did not carry the themes.

**Bank 0**: the three themes cost it 4 B each —`song_lo`, `song_hi`,
`song_bk` and `song_msu`— and left it with **1 B** in `release`. Those four
tables moved to RODATA and are read with `f:` (separate commit).

# How it ended up (on `main` at dc5810b7, with Tatú)

Commits: e0100423 (common 35), d6f3342d (the theme tables out of bank 0),
92c3f95f (the radio) and the merge of `main`.

`NO_CACHE=1 just cartridges` and `just cartridges` with cache give the 1035 files
of `rom/build/` identical. `abl.sfc` `30ae28d9cff39cd3…`.

`just space`, `release`: data banks **120 of 124, 4 free** (116 before the
common and the radio: one is the common copied into each map with encounters,
almost three are the streams of the three themes); gaps 21,391 B; **bank 0
182 B** (14 in `main`); bank 1 4,697 B.

**The suites**: `just tests` gives **897 green and 1 red**,
`test_music_ceilings.py`: the three radio themes are missing from its table.
**`just ceilings` was not run.** `just -f tools/justfile test`: 46.
`cargo test -p rm2k-snes-events -p rm2k-snes-audio` green. `test_cores.py`
green. **No golden moved.**

**When merging, install** `just -f tools/justfile install events
rm2k-snes-audio`. The runtime changed (`music.s`, `msu1.s`), which asks for
nothing. No `.py` was renamed or added.

**Numbers used**: none —no opcodes, no far RAM, no test tuples, no new
cases—.

# What taro has to test

- **A summon by Lerle**: after the battle, Lerle comes back to the party and
  the summon leaves, healed. On returning to the map the whole common 35 runs:
  it also removes Emily's tapes and accessory, and rebuilds Talan's HP and SP;
  no test looks at that.
- **Emily's `Play Radio`**, with each tape: its theme plays in the battle, and
  with the MSU-1 in full. And by ear: the battle theme and the ones in the list
  above, through the SPC700.
