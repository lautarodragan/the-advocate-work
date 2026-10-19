---
name: "Runtime optimizations, read whole: battle and audio"
description: "Read the battle and the audio of runtime/ file by file for optimizations the book's Optimizations section does not tell"
type: docs
status: done
assignee: taro
agents: [Mulita]
---

taro, on 2026-10-18, after Hurón's pass by keywords
([`the-runtime-optimizations-the-book-does-not-tell`](the-runtime-optimizations-the-book-does-not-tell.md)):
read the code whole, so that what saves without saying so is found too.
Split in three by subsystem, one agent each: this is the battle and the audio.

## Log

2026-10-18, Mulita. From the-advocate `df9a0f9c` and the book `a083b3e`,
on the book's branch `mulita-optimizations`. The whole Optimizations
section read first, as Hurón left it, and `internals/audio.md` and
`internals/the-msu-file.md`.

### Files read, and what came out

* `music.s`, read whole: the multiply by quarter squares in mode 7
  (`mpym`); a fade rewrites only the volumes that changed
  (`voices_refresh`). The `READ` macro's inline fast path and the
  repeat's one-branch cost, left out as small.
* `spc700.s` and `DRIVER` in `rm2k-snes-audio/src/spc700.rs`, whole:
  command 3, three bytes per handshake.
* `sound_effects.s`, whole: the effects borrow two of the music's voices,
  the ones percussion fills first (`EFFECT_VOICES` in `voices.rs`), told
  only in `internals/audio.md`.
* `bgm_level.s`, `msu1.s`, whole: nothing.
* `msu_effects.s`, whole: the triplet upload with the next one read
  meanwhile (`msu_a_aram`, the same as `upload_sample`). Left out as small:
  `ex_register_bit`, a 128-byte table so `dsp_music` asks with one `and`;
  voices 0 to 5 keeping their state in the music's shadow and an index
  instead of a row.
* `audio_package.s`, whole: a package uploads only what the ARAM lacks
  (what stays stays, placed before uploading, no rebuild that cannot
  help); exit songs and `apart_themes` going up alone.
* `voices.rs`: a note goes first to the voice its channel last held, so
  it repeats neither volume nor sound.
* `battle_loop.s`, `battle.s`, `battle_run.s`, `battle_bridges.s`, whole:
  the critical hit looked up in `crit_table`, sized by distinct values
  (`ba_crit_of`; `critical_percent` and `emit.rs` in mapdata).
* `battle_scene.s`, whole, and `scene.rs`'s header in convert: the scene
  composed on the console from each backdrop and battler once; a battler
  as its mask and four planes; one loop per shift; the light backdrop
  doubled through `fallback_double`; the windows as a band per layout and
  each bar only where it changes (`battle.rs` in screens).
* `battle_tone.s`: the tint's tables composed with the flash's, built
  only when either changes, over the colours that are drawn.
* `battle_fade.s`, `battle_animation.s`, `battle_animation_frames.s`,
  whole: nothing new (the frames are already told).
* `battle_attributes.s`, `battle_items.s`, `battle_skills.s`,
  `battle_states.s`, `battle_troop.s`, `battle_victory.s`,
  `encounters.s`: their comments read whole, the code skimmed —game
  rules—. Left out as small: the HP-percentage condition compared by
  cross-multiplying (`battle_troop.s`); the skill list keeping only the
  visible page (`battle_skills.s`).

### Not bugs, but stale comments seen

* `upload_sample` (`audio_package.s`) says "batches of up to 128"; the
  code and the driver cap them at 85.
* `music_start` (`music.s`) says the sample bank "is uploaded only once at
  boot"; since the per-map packages it is not.

### What went into the book

On `mulita-optimizations`, from the book's `a083b3e`: `a2f6d49` (battle)
and `a51d95b` (audio), fourteen entries, each with its line in
`lossless.md` or `lossy.md`; no new page, so nothing in `SUMMARY.md`.
Links and anchors of the touched pages checked against `mdbook build`.

* `lossless/battle.md`: the scene composed on the console from each
  backdrop and battler once; a battler is its mask and four planes; one
  placing loop per shift; the light backdrop doubled through a table; the
  windows as a band per layout and each bar only where it changes; the
  critical hit looked up; the battle's tint and flash composed once per
  change.
* `lossless/audio.md`: a package uploads only what the ARAM lacks; samples
  go up three bytes per handshake; a note goes to the voice its channel
  last held.
* `lossless/cpu-time-in-the-frame.md`: a fade rewrites only the volumes
  that changed; in mode 7 the music multiplies by a table of squares.
* `lossy/audio.md`: the sound effects borrow two of the music's voices;
  a song played only to leave, or apart, goes up alone.

No questions for taro: what was left out was small, and it is listed
above. No drafts: no dead code or bug found, only the two stale comments.
Nothing to install: only the book changed.

**2026-10-19, taro**: declared done.
