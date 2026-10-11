---
name: "A song's sounds, more than 255"
description: "Dooms 2 leaves out maps 10, 14 and 63 because of 'the song uses 291 sounds and the index is one byte' (411 in 14)"
type: feature
status: testing
assignee: taro
agents: [Hornero, Tijereta]
---

Measured by Calandria on 2026-10-11 (`exclusions-left-over-in-the-ports.md`). Same family as `music-and-troop-members-without-the-one-byte-ceiling.md`. First check how Tijereta's task on sounds in more than one bank turned out, since it touches the same thing.

## Done, on 2026-10-11 (Tijereta)

On the-advocate `main` 70d4348a, ports `main` 33fde63 and book `main` 67a671e; branch `tijereta-sonidos-de-una-cancion` in all three. `main` didn't move in the meantime.

**What was cutting it off**: `pack` (`stream.rs` in `rm2k-snes-audio`) refused to go past 256 sounds because the three note families (`OP_NOTE`, `OP_NOTE_VOL`, `OP_NOTE_PAN`) name the sound in one byte. The Dooms 2 tracks are Graig (maps 10 and 63) and Demons (14).

**The change**: a new music stream opcode, `OP_SOUND_PAGE` = **0x65** (`page: byte`), the next free one: the notes that follow name the sounds starting at page × 256. The encoder emits it only when the page changes, so a track with 256 or fewer never says it. In the runtime (`music_frame`, `runtime/music.s`) it moves `MUS_BASE` to the track's `song_sounds` plus page × 1536; `note_sound` is untouched and costs not one cycle more. `music_start_done` already resets the base when starting or restarting, which is page 0. Discarded: two-byte notes (moves ABL's music) or a per-note prefix (twenty-four opcodes or a per-note cost).

Repeats needed nothing: the page is reader state, like its cache, and an `OP_REPEAT` replaces identical bytes at the same place in the flat stream, so it reads them in the same page. At first I thought `fold` had to filter by page; the test showed it didn't.

**Red before**: `a_song_with_more_than_256_sounds_writes_what_it_has_to` (600 sounds), with the same error as Dooms 2 ("the song uses 600 sounds and the index is one byte"). Also `a_repeat_reads_its_bar_in_the_page_it_is_in`, which folds bars from pages 0 and 1 (that one couldn't be seen red: without the opcode it doesn't compile).

**ABL**: `musicdata.inc` byte for byte identical to `main`'s; `abl.sfc` goes from `f81ae57da625…` to `ea49ff07fd9d…`, only because of the new runtime code. Suite with my tools: **1176 green**. `just test` and the crates bytecode, cartridge, mapdata, events, convert and rm2k-snes-audio, green. No hash in `mapdata/tests/python.rs` nor in the fingerprint tests changed.

**Dooms 2**: without 10, 14 and 63 in `excluded`, `just cartuchos release` builds. It excludes only 1 (character select, the slots screen and the menu), and still uses ABL's System. With ABL's harness pointed at `dooms2.sfc` (`~/scratch/tijereta/sonidos/dooms2_musica.py`, disposable), the ROM writes to the DSP exactly what the Graig and Demons streams say, whole and the start of the second loop; with `sound_page` mutilated (it reads the page and doesn't move the base) it differs at frame 8138 of Graig, the first one in page 1.

**ABL's harness** (`consola.py`, `stream_del_tema`) passed 256 sounds to the decoder; now, up to the end of the bank. Nothing changes in ABL (`test_musica_escrituras.py` and `test_bateria_suena.py` green).

**Book**: `internals/audio.md` (how a note names its sound) and `ports/dooms2/README.md` (what it leaves out).

**What the suite doesn't cover**: no ABL track goes past 256 sounds, so no test in the suite executes `OP_SOUND_PAGE` in the ROM; it is covered by the crate's two tests (the decoder model) and the manual run on the Dooms 2 cartridge. Maps 10, 14 and 63 were not played in an emulator, nor was the music listened to.

On merging: `just install cartridge rm2k-snes-audio` (bytecode is a library; `rm2k-snes-assemble` writes `music_opcodes.inc` from it). The runtime comes in on its own, from the checkout.

For Cardón: the message "the song uses N sounds and the index is one byte" no longer exists; a new one remains in the same place, for more than 65536 sounds, which can't happen before the 64 KB limit of the table.
