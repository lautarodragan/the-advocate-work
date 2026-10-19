---
name: "The Book of Three: the story's battles play the default battle theme"
description: "Each scripted fight sets its own battle and victory music with ChangeSystemBGM, which the port does not do: they all play the database's battle theme"
type: bug
status: testing
assignee: taro
agents: [Carpintero]
---

Seen by Mulita on 2026-10-15, comparing the port with the original's event
data, with the-advocate `fa9d1a14` (and `362d3765` for
`degradations.json`) and the ports `0ca371b`, in The Book of Three.

**What is heard**: before almost every story fight the game changes the
system's battle music —and the battle-end music— with `ChangeSystemBGM`,
and sets it back after. In the port the battle always plays the
database's theme, "intothefireedit". Measured in the port's RAM on map 16:
the original asks for "talisn" there, the port plays "intothefireedit".

**Where**: 40 commands on maps 16, 21, 22, 26, 31, 32, 44, 46, 64, 78, 88
and 89, in `degradations.json` as `system-bgm-not-changed`.
`ChangeSystemBGM` is a declared debt since the survey —"the missing
commands" research, 2026-10-05—; there was no task for this game, where
every story fight relies on it.

**How to see it**: the ports' case `milestone-cauldron` and the song in
RAM (`games.Session.song`) during the first battle.

## Defined (2026-10-16, Carpintero)

Still open: `compile.rs` drops `ChangeSystemBGM` with
`system-bgm-not-changed` at the-advocate `f4709d0b`. It is a missing
command, heard in every story fight. **Done**: `ChangeSystemBGM` for the
battle and the victory slots at least —a slot the battle reads instead of
the database's theme, kept in the save—, the songs it names carried by
the audio packages, the degradation gone for those slots, and the
ports' `milestone-cauldron` asserting "talisn" in the first battle.
**First step**: count, over the nine dumps, which slots the command
changes (battle, victory, inn, vehicles, game over), to decide which go in
the first version.

## Doing (2026-10-19, Carpintero)

Branches `carpintero-music` in the-advocate (from `9592b88b`) and the
ports (from `c420032`), shared with the two other music tasks —
`a-maps-own-music-ignores-its-volume-and-tempo.md` and
`playbgm-fade-in-is-dropped.md`—, since all three are how a song starts.

**The count, over the nine dumps** (maps, common events and troops):
`ChangeSystemBGM` changes the battle's song 487 times —ABL 65, The Book of
Three 20, Dooms 2 7, Vampires Dawn 380, Zounds 15— and the victory's 89
—ABL 65, The Book of Three 20, Dooms 2 4—; the Game Over's once (Dooms 2)
and a vehicle's once (Zounds); **the inn's never**. So the first version
is slots 0 and 1, and the rest stays `system-bgm-not-changed`. ABL and
The Book of Three set both to the same song almost always, so the victory
goes on with the battle's song.

**How**: `OP_SYSTEM_BGM` (0x39: slot, song, the six bytes of a level)
writes `SYS_SONGS` in far RAM, which a new game fills with the database's
—with the database's level, `BA_SONG_GAINS` and the like from the
converter— and which travels in the save. The battle reads it on entering
and on winning. The song goes into the battle's audio package as a
**separate** song, like a troop page's: uploaded first with the battle's
sound effects and without the database's songs —`battle_extra_l` in
`audio_package.s`—, so it does not lower the battle song's rate.

Found on the way: `song_ensure`, the upload of a song that is not in ARAM,
always rebuilt `map_current`'s package, also in a battle. A troop page's
`PlayBGM` —ABL's radio— left the battle without its sound effects. It now
rebuilds the package loaded last (`PKG_LOADED`), the battle's in a battle.

### For whoever starts a song from the runtime (Tijereta's inn jingle)

The interface, written at the top of `runtime/bgm_level.s` too:

1. The level in `BGM_ASK` (4 bytes: left gain, right gain in 128ths, the
   tempo's step in 256ths, little endian) and the fade-in's step in
   `BGM_ASK_FADE` (word, 65536ths per frame; zero none). The tools write
   all six bytes with `Level::bytes()` (rm2k-snes-bytecode's `level.rs`);
   `bgm_level_whole` fills them with the song as written.
2. The song in A, `jsr music_play` (bank 0): a song that already plays only
   changes level, otherwise it starts at that level, fading in if asked.
   `music_start` restarts it even if it plays. From another bank,
   `ba_t_bgm`/`battle_bgm` do the same with the data bank at 0.
3. What plays, to put it back afterwards: `song_current` (or nothing, if
   `music_off` is set and `MSU_PLAYING` is not), and its level `BGM_NOW`
   —4 bytes, copy them to `BGM_ASK` to restart it at that level, as
   `bgm_level_battle_in`/`_out` do with `BGM_BEFORE_BATTLE`—.

`ChangeSystemBGM` does not change the inn's song in any of the nine games,
so the inn's is the database's `inn_music`; its level is not emitted yet.

## Done (2026-10-19, Carpintero)

`ChangeSystemBGM` of the battle and the victory is `OP_SYSTEM_BGM` (0x39,
the number handed out; 0x3A stays reserved). A new game starts with the
database's two songs at the database's level, and they travel in the save:
**`SAVE_BYTES` grows by 18** —two system songs of seven bytes and the
four of `BGM_NOW`, see the map task—, before `music_off`; saves from
before do not load. The battle plays them on entering and on winning,
and each song a `ChangeSystemBGM` names goes up first in the battle's
package as a separate song, with the battle's sound effects.

**The test, not `talisn`**: the cauldron milestone's first battle is on
map 26, whose `ChangeSystemBGM`s right before it give both slots `dowds`
at 80; `talisn` is map 16's. The ports' `test_book_of_three_music.py`
asserts `dowds` at 82/128 there; ABL's `test_battle.py` gives the droid's
battle `KW-robot` at 80 and asserts the song, its level, its samples and
the battle's sound effects in the ARAM, and the victory keeping it.

**What it cost**, measured in the sample bank (`audio.json`,
`bank.voices[].rate` per key, against main's): The Book of Three, nothing.
**ABL, thirteen of its 236 sample keys go down to ~9.5 kHz** (from 12–22),
limited by `pelea>T_AVGFighter_KyaraSelect`: the battle's package leaves
32,432 B for music, and that song's 28 samples take 31,428. Without MSU-1
only. Draft: `a-battle-song-with-many-instruments-squeezes-shared-samples`,
with its line in ABL's Known issues. ABL's ceilings table was measured
again (`just ceilings`), since `KW-robot` is a song of `release` now.

**Not covered by any test**: a victory song other than the battle's after
a `ChangeSystemBGM` —it is uploaded when the battle is won, with the
picture still; draft
`a-victory-song-other-than-a-changed-battle-songs-uploads-at-victory`—;
`ChangeSystemBGM` to "(OFF)", which leaves the battle silent; the system
songs' path with MSU-1, where a song with a track uploads nothing
(`battle_extra_l` asks `song_per_msu`); and a save made after a
`ChangeSystemBGM`, loaded —the bytes are in `save_table`, which
`test_save.py` walks, but no test changes the song before saving—.
Dooms 2's Game Over slot is still a loss: draft
`change-system-bgm-of-the-game-over-is-ignored`.

**When merging**: reinstall `cartridge`, `rm2k-snes-audio`, `events`,
`mapdata` and `convert` —the bytecode's `OP_BGM` grows two bytes and
`OP_SYSTEM_BGM` is new, so every binary that walks or writes pages—.
Tijereta's inn emits `OP_BGM` (`tijereta-inns`): it has to write the two
bytes of fade-in, at zero —`Level::bytes()` does it—; if not, the
conversion stops, since pages are walked by the declared sizes.

**Verified**, with the branch's tools (`.local-tools` with `cartridge`,
`rm2k-snes-audio`, `events`, `mapdata` and `convert`): `just test` (29),
`just lint`, the crate tests of bytecode, events, mapdata, convert,
cartridge and rm2k-snes-audio; ABL's `just cartridges` and `just tests`,
1569 passed and 2 skipped, **no golden moved**, `abl.sfc`
`c79657f4c1504a7f`; `just boot` from the ports root, 76 passed, no golden
moved. Bank 0 (`just space` in ABL): `release` 146 B left,
`test-change-system` 91 B, the tightest; main had 98 and 52, since
`op_bgm`'s and `op_fade_bgm`'s bodies and the MSU-1 fade's multiply went
to FAR3.
