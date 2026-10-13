---
name: "Music and troop members, without the one-byte ceiling"
description: "Vampires Dawn stops at 'Music/ has 281 songs and the track goes in a byte' and behind it at the 470 troop members in a one-byte table: make them fit"
type: feature
status: done
assignee: taro
agents: [Tijereta]
---

From the re-sweep of 2026-10-10 (research `2026-10-10-other-games-measured-again` in the book): they are the two whole-game walls Vampires Dawn has left. The music ceiling counts every file in `Music/`, used or not. Same line as `encounters-with-two-byte-indices.md`.

## Done, on 2026-10-10 (Tijereta)

Branch `tijereta-musica-y-tropas` in `the-advocate`, on 27010065.

### The music: only the named songs, and only when it doesn't fit

`Game::track_numbers` numbered all of `Music/` —281 in Vampires Dawn— and the
track goes in a byte of `song_msu`. Now, **if the whole folder doesn't fit
in the byte**, it numbers only the game's songs that something names (`PlayBGM`,
the map tree, the `System`, and now also `ChangeSystemBGM`), and
then the RTP's as before. The named ones come from the whole game and
not from the cartridge, so the number stays the same in any
cartridge, which was the reason for the design.

Why this way and not two bytes:
- It is correct: a song that nothing names never plays.
- It is cheaper: it doesn't touch the runtime or `song_msu`.
- Why plan B and not the rule: ABL brings 230 songs and names about a hundred; numbering
  only the named ones in ABL too renumbers its tracks (half a gig to
  copy to the card again) and moves `abl.sfc`. With plan B, ABL
  stays the same: `music.json`, `audio.json` and `musicdata.inc` of `release`
  come out identical to main's.
- `ChangeSystemBGM` is accepted without being done, but its songs are counted from
  now on: that way doing it doesn't renumber VD. In ABL it adds nothing (its eleven were already
  in `Music/`).

### The troops: `troop_init` in words

`troop_init` (where each troop starts in `troop_member`) becomes words
and a member's index 16 bits. `ba_member_x` builds it each time from
`BA_TROOP_K` and the position: **there is no new RAM**, and `SCN_INIT` ($6649) is left
free. The troop's place stays a byte (`BA_TROOP_K`, $FF = not carried):
up to 255 troops per cartridge. It moves `abl.sfc`, on purpose.

### And the enemies' actions, which were the next wall

With the two above, VD stopped at "the actions of the cartridge's
enemies are 344 and `enemy_acc_init` is one byte": same family, so
I widened it as well. `enemy_acc_init` is in words; `BA_S5 + 1` now stores
which enemy it is (before, where its list started) and `ba_eacc_x` builds the
index. No new RAM. `enemy_acc_n` stays a byte (bounded by
`ACTIONS_MAX`).

### Verified
- Three new tests, each one seen red before its fix:
  `a_music_folder_past_the_byte_numbers_only_the_named_songs`
  (rm2k-snes-audio), `troops_with_more_members_than_a_byte_numbers_start_in_words`
  and `enemies_with_more_actions_than_a_byte_numbers_start_in_words`
  (mapdata). The two hashes in `mapdata/tests/python.rs` moved on
  purpose: the difference is `troop_init` and `enemy_acc_init` from `.byte` to
  `.word`, nothing more.
- A Blurred Line's suite with my tools: 1159 green. `abl.sfc` goes from
  `f135f6af…` to `b0c61b1f…`, on purpose (the two tables and the runtime that
  reads them). ABL's music, the same: `music.json`, `audio.json` and
  `musicdata.inc` identical to main's.
- Vampires Dawn with the real game (the whole `Music/`, 281), starting
  on 8 and without the 82 maps Aguará excluded: the music, the troops and the
  actions get through. **What stops it now**: "the music's sounds go over one
  bank: 41118 B" (the music's sounds table, of all the songs, in
  a 32 KB bank). I didn't touch it.

### Not covered
No test executes in the ROM a battle with a member or an action with an
index greater than 255 (ABL doesn't have that many): the new 16-bit path is
executed by ABL's battles with small indices. Nor does any test build
a cartridge with `Music/` past the byte: that is covered by the crate's test and
the hand build of VD.

### Along the way, VD's boot (not done)
`BOOT_FRAMES` is a ROM constant: raising it to 46 moves the frame at
which the loop starts in ABL and with it the tests that count frames. The
cheap thing would be for each cartridge to carry its own —`max(44, the estimate)`,
emitted by the converter—, so ABL doesn't move.

When merging, reinstall: `rm2k-snes-audio mapdata` (the runtime comes in by itself,
from the checkout).
