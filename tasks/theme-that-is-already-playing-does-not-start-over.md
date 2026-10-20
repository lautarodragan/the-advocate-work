---
name: "A theme that is already playing does not start over"
description: "In RM2k, PlayBGM with the theme that is already playing does not restart it; in the ROM it does: the battle victory and the walk to the factory"
type: bug
status: done
assignee: taro
---

From taro, on 2026-09-30, in their words, translated:

> I think in RPG Maker, when a play bgm runs or something transitions to
> a new theme, if the theme is the same one that is already playing, it
> doesn't start from zero, it just keeps playing

He notices it in two places:

- **The battle**: the battle theme and the "win battle" one are the same. In
  the original, probably, nothing changed on winning.
- **The cutscene of the walk to the factory**: the music restarts in one of
  the transitions.

To be confirmed in easyrpg (`Game_System::BgmPlay` and how the battle asks for
the victory theme) and, if possible, with RPG_RT under Wine, recording its
audio.

## What RM2k does

**easyrpg** (`src/game_system.cpp`, `Game_System::BgmPlay`): if the name is
the one playing and there is no fade in progress (`music_stopping`, which
`BgmFade` turns on and the next `BgmPlay` turns off), **it does not restart**:
it only adjusts the volume, tempo and balance that changed. "The same theme" is
**only the name**: with another volume or tempo it keeps going, adjusted.
`fadein` does not count. The battle goes through the same function:
`Scene_Battle` notes `before_battle_music` and asks for `BGM_Battle` on being
constructed; `Scene_Battle_Rpg2k` asks for `BGM_Victory` on winning;
`Game_Map::OnContinueFromBattle` restores the previous one. And
`Game_Map::PlayBgm`, on entering a map, too.

**The 2015 RPG_RT under Wine** says the same, measured. The MIDI does not play
in here —Wine has no MIDI synthesiser without ALSA's sequencer—, so the theme
was a WAV put in `Music/`: a frequency sweep, where the pitch tells how far
along it is. A page on the starting map asked for it like this, and the
recording (`/shared/audio/2026-09-30-tema-que-sigue/`) says:

    same PlayBGM                  keeps going
    PlayBGM with volume 50        keeps going, quieter
    PlayBGM with tempo 150        keeps going, faster (and back to volume 100)
    another theme, then this one  starts from zero
    in the middle of a FadeOutBGM starts from zero

The two sources agree on everything. What could not be done: the 2000 runtime
—the author's— needs the real `Harmony.dll`, and with MIDI.

## The game's cases

- **The victory**: the LDB's `battle_music` and `battle_end_music` are both
  `T_VGFighterMAX_Masako`, and the ROM restarted it on winning. There are 130
  `ChangeSystemBGM` in the game, which the ROM has ignored since before; with
  that the two are still the same.
- **The walk to the factory**: the door on map 8 jumps to 16 ("Running To Work
  Scene"), which brings `hzbreach` as its theme; the map starts it on loading,
  and 16's autostart begins with a `PlayBGM hzbreach`, which restarted it with
  the scene already going. The transitions inside 16 are jumps to the same map
  and do not touch the music; the final one fades, asks for `wb3mlair` and
  jumps to 17. (Map 14 also asks for `hzbreach` and jumps to 16, but no door
  leads to it.)
- **How many PlayBGMs ask for the one already playing**, statically and without
  following branches: of 168, **10** repeat the one the same page had just
  asked for without a fade in between, **5** are the first of an autostart that
  asks for its map's theme, and **8** jump→destination-autostart pairs ask for
  the same one. No battle starts with the battle theme already playing.

## What was done

`song_playing` (in `music.s`) is `BgmPlay`'s question: the theme is the one
playing —through the MSU-1 track or through the SPC700— and it is not fading.
`music_play` asks it before `music_start`, and it is used by `PlayBGM`,
`PlayMemorizedBGM` and `battle_bgm` —the entry, the victory, the return, the
Game Over—. `music_start` still always restarts: the title and the loaded game
use it. `map_song_mute` and `remembered_song` each had their own copy of the
question: now they ask the same one.

**With MSU-1** it holds the same: `song_playing` looks at `MSU_PLAYING` before
`music_off`, and the track does not restart (enforced by
`test_with_msu_the_song_asked_twice_does_not_restart_the_track`, listening).

**Without MSU-1, the battle changes the audio package on entering**, and for
that it silences what is playing: if the map were playing the battle theme, it
would restart on entering anyway. It does not happen in the game —see above—,
so `battle_audio_load` was not touched; if it is ever needed, `package_load`
already leaves the samples of the playing theme in place, and it would be
enough not to silence it when it is the same one.

## The tests

- `rpgmaker/test_song_already_playing.py`, with the case `song-requested-two-times`:
  two `PlayBGM evilrhys` in one page. Red before the fix: the stream went back
  from `$65C296` to `$65C1A6`.
- `test_battle.py::test_winning_lets_the_victory_song_go_on`: **it used
  to ask for the opposite**, that the victory start it from zero (`546fb17d`,
  2026-09-12). Red before the fix with the condition flipped: the cursor went
  back from `$6781CB` to `$67808D`.
- `abl/test_msu.py::test_with_msu_the_song_asked_twice_does_not_restart_the_track`:
  compares what plays after each `PlayBGM`. Correlation 1.00 before the fix and
  0.12 after.

## What remains

- **The volume and tempo of a `PlayBGM` are not read by the ROM**, neither
  before nor now: 69 of the 168 ask for another volume and 13 for another
  tempo. RM2k, with the same theme, adjusts them without restarting.

## To listen to

`/shared/audio/2026-09-30-tema-que-sigue/`, with its `LEEME.txt`: the victory
and the run to 16, before and after, with MSU-1 and without it, and RPG_RT's
recording.

## When merging

- Installing `cartridge` in the global one is not needed: no Rust was touched.
  Only `tools/runtime/` changed, which the global one already reads from the
  main checkout.
- There are no new or moved goldens, and `test_music_ceilings.py` passed.
- With `main` merged (`bfbabec5`) the suite gave 904 green and 2 red, both
  from `test_auditorium_routes.py`, Pecarí's: they ask for what changed in
  `map-sprites` and `maps`, and the global `rm2k-snes-maps` predates their
  merge. I did not compile them here —they are not mine—; with that
  reinstalled they should pass.

## What to listen for while playing

The victory of any battle: the theme does not start over on winning. And the
run to work, on entering 16: `hzbreach` carries straight on when the scene
starts.
