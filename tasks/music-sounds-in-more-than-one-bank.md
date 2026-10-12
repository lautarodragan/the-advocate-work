---
name: "The music's sounds, in more than one bank"
description: "Vampires Dawn stops at 'rm2k-snes-audio: the music's sounds go over one bank: 41118 B': the sounds table of all the songs can't go past a 32 KB bank"
type: feature
status: done
assignee: taro
agents: [Tijereta]
---

Measured by Tijereta on 2026-10-10, when closing `music-and-troop-members-without-the-one-byte-ceiling.md`: with the whole `Music/` (281 songs), starting on 8 and without the 82 maps Aguará excluded, VD gets past the music, the troops and the actions and stops here (`emit.rs` of `rm2k-snes-audio`). It is the next wall of the whole game.

## Done, on 2026-10-11 (Tijereta)

On the-advocate `main` 5094ef11 and ports `main` 038ea64, branch `tijereta-sonidos` in the-advocate. The ports weren't touched.

**The ceiling's "bank" was LoROM's.** `if body.len() > 0x8000` is from 2026-09-29 (29c710cf), two days before the cartridge moved to ExHiROM. Today the packing (`pack`, in `rm2k-snes-cartridge`) leaves a `.block` of up to 64 KB whole inside a bank, and `note_sound` reads `music_sounds + k` with 16-bit X —the song's base plus six per sound—, so with the whole table in one bank any index stays inside. The smallest change that works is to raise the ceiling to 0x10000: neither the runtime nor the table change, and ABL's comes out byte for byte the same.

Splitting the table across several banks —one bank byte per song, and reading it some other way, because `note_sound` uses Y for the voice's register and an `lda [dp], y` would overwrite it: either a pointer in the zero page and saving Y, or changing the DBR to copy the six bytes to far RAM— is left for when a game goes past 64 KB. VD uses 41118 B with its 281 songs.

* New test, `the_music_s_sounds_take_a_whole_bank_and_no_more` in `tests/python.rs` of `rm2k-snes-audio`: it stretches the test game's songs up to 38736 B and then until going past 64 KB. **Red before the change**, with the same error as VD (`the music's sounds go over one bank: 38736 B`); green after. The hash of the test game's `musicdata.inc` didn't move.
* `abl.sfc` = `5852b72358b685be…`, same as on `main`, and A Blurred Line's suite with my tools: 1174 green.

**What stops VD now**: with Aguará's 82 exclusions and starting on 8 (`~/scratch/tijereta/musica/vd.py`), it gets past the music and stops at the packing: `the data does not fit: a piece of 512 bytes needs a new bank, and the 127 banks the cartridge has for data are taken`. The `.block`s add up to 11.69 MB against 7.94 MB of the 127 banks —without counting the 82 `.crossbank` samples—: 4.27 MB are `pose_N`, 2.21 MB `map_tiles_N`, 0.54 `map_cells_N`, 0.51 `pano_tiles_N`, 0.42 `big_tiles_N`, 0.39 `pages_N`; the music, 0.71 MB, and its sounds 0.04. It is another wall, and a big one: not touched here.

**What the suite doesn't cover**: a sounds table of more than 32 KB in a ROM that runs. ABL has a small one, and VD doesn't link yet; that `note_sound` reads it correctly across a whole bank comes from the reasoning above, not from a run.

When merging: `just install rm2k-snes-audio`.
