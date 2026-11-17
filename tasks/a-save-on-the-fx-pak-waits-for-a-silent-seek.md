---
name: "A save on the FX Pak waits for a silent seek"
description: "With a .msu, the FX Pak writes the .srm to its card only at a data seek or a once-a-second check made with no MSU-1 track playing, or on a reset: a game saved while a track plays and the console turned off before then loses the save"
type: bug
game: abl
status: done
assignee: taro
agents: [Aguará, Hurón]
---

Seen by Aguará on 2026-11-17, reading the FX Pak's firmware for
[`the-sram-as-slow-wram`](the-sram-as-slow-wram.md) (sd2snes `cf7e21d`,
firmware 1.11.2, `src/msu1.c`), with the-advocate at `269bb12c`. Read, not
seen on the console.

**What was read**: in `msu1_loop`, the loop the FX Pak runs a cartridge
with a `.msu` in —every ABL build—, the SRAM is checksummed and written to
the card only by `msu_savecheck`, which runs at the start of a data seek,
at a track change, or once a second, and only while no MSU-1 track plays
(`is_msu_free_to_save`); and by `save_during_msu_shortreset`, on a reset.
Turning the console off writes nothing. In ABL the once-a-second check
almost never runs either: after a data seek the firmware's data side stays
busy until a read reaches the end of the `.msu`.

So a save made in a place whose song plays from a track is on the card only
after the next silent moment that seeks the `.msu` —a map change with a
new song, a battle— or a reset. Without the `.msu` the firmware polls in
the background and writes within seconds.

**To reproduce**, on the FX Pak with the `.msu`: save in a map whose song
has a track, stay there, turn the console off, turn it on: the slot should
show the save from before. Then the same pressing reset before turning it
off.

**2026-11-17, Hornero, from taro's run of the SRAM test ROM on the FX
Pak** ([`the-sram-as-slow-wram`](the-sram-as-slow-wram.md)): after a power
cycle the ROM found the previous session's round counter (134) on the card
but its stash `LOST` —the 96 KB did not sum to that round's—: the card
held an image of the SRAM taken in the middle of a round, likely by the
periodic check while auto rounds wrote the SRAM. If so, a save slot being
written when such a check fires would reach the card half written. To
look at: whether the runtime's save slots carry a check that refuses a
torn one at load, and how many frames writing a slot takes.

## Confirmed on the console (taro, 2026-11-17)

After the SRAM test ROM showed that a seek with a track playing costs 2 ms
—the FX Pak neither checks nor writes the SRAM while MSU-1 audio plays—,
taro tried it in a game, translated:

> I just tried it: reset does save, but turning the console off directly,
> after a save, loses it. Even waiting about 6 s after saving.

So today, on the FX Pak with a `.msu` and its music playing, saving and
turning the console off loses the save.

Hornero's proposal: after the slot is written, pause the MSU-1 track (the
firmware's pause keeps the position: `dac_pause`, and play resumes with
`dac_play`), make a data seek —with no track playing `prepare_data` calls
`msu_savecheck(1)`, which writes the `.srm` before seeking, and the console
waits on the data busy bit—, then play again. At 32 KB, by the rule the
test ROM measured (~1.5 ms/KB to check, ~2.6 ms/KB to write), the pause
would be about 130 ms, in the save screen.

Done means: the save path forces the write on the FX Pak and costs nothing
without MSU-1 or on emulators; measured on the harness (the register
sequence, the time the console waits, the track resumed where it was); a
ROM test of the sequence; a build for taro to confirm on the console that
saving and turning off keeps the save; the same for every game (they share
the runtime). And whether the save slots carry a check that refuses a torn
one (see the note above).

## Log

**2026-11-17, Hurón**, from the-advocate `865163eb` and the ports
`b81744c`, branches `huron-fxpak-save` in both.

Runtime files touched: `runtime/msu1.s` (the new `msu_save_flush`, and
`MSU_AUDIO_PLAYING` moved there from `inn.s` with its sibling
`MSU_AUDIO_REPEATING`), `runtime/save_game.s` (`save_game` calls it at its
end) and `runtime/inn.s` (the constant, gone). Both save paths —the menu's
Save and the event `OpenSaveMenu`, `op_save`— go through `save_game`, which
is the only writer of a slot.

Read from the firmware (sd2snes `src/msu1.c`) and its FPGA
(`verilog/sd2snes_base/msu.v`), which decides the order:

* A `$2007` write without the play bit is a pause: `dac_pause`, the
  status's play bit cleared and `msu_audio_usage = MSU_IDLE`; play is
  `dac_play` from where the DAC stood. The FPGA itself does not clear the
  play bit on the write —only the firmware's `set_msu_status` does, in the
  same pass that marks the audio idle—, so **waiting for bit 4 of `$2000`
  to clear is waiting for the firmware to have taken the pause**.
* That wait is not optional: in one pass of `msu1_loop` a pending seek
  (`DATA_START`) is handled **before** a pending control write
  (`CTRL_START`), so a seek written right after the pause would find the
  audio still busy and `prepare_data` would skip `msu_savecheck(1)`.
* `prepare_data` marks the data side idle before asking, so whatever the
  previous seek left (busy until EOF) does not stop it; the check is
  immediate (`msu_savecheck(1)`), and `DATA_BUSY` clears only after
  `save_srm` returns.
* The repeat flag in force is bit 5 of `$2000` on the FX Pak, bsnes,
  snes9x: the inn's play-once track keeps its flag when resumed.

**The disguise** (taro, through Hornero: "it will be very noticeable, but
we can disguise it"; and the fix belongs in the firmware, but the game has
to work with the one cards have, so this stays): the track **fades out in
eight frames** to volume 0 before the pause and **back to `MSU_BASE` in
eight** after the play, waiting for vblank from bank 1. Chosen over the
alternatives because a fade is what RM2k games already do, it hides a cut
of any length —the FX Pak's write is not fixed: it is the SRAM's checksum,
plus the write when it changed—, and the slot's decision sound effect,
which the SPC700 keeps playing while the CPU waits with interrupts off,
lands on top of it. Without a fade running only: with one running
(`bgm_fade` not zero) the fade owns the volume and the pause goes bare.

**Measured on the harness** (bsnes with the new MSU-1 log, map 26 with
`KSSMKEND` on its track, the menu's Save): the first step down on one
frame, volume 0 eight frames later, and in that same frame the pause
(`$2007 <- $02`), one `$2000` read with the play bit clear, the seek to 0,
one `$2000` read with data busy clear and the play (`$2007 <- $03`) at the
same track offset; eight frames up to `$D8`. **Sixteen frames, ~267 ms**,
of which the music is at 0 for one. **On the FX Pak, estimated** from the
SRAM test ROM's rule for the 32 KB every game declares: ~48 ms to
checksum plus ~83 ms to write a changed SRAM, **~130 ms of silence** between
the two fades —about eight frames—, so the dip is about 24 frames, 0.4 s.
Not measured on the console.

**Without a track playing** (the same map with `KSSMKEND`'s track
missing, so it plays on the SPC700): one seek to 0, nothing else; on the FX
Pak, the same ~130 ms with the screen still. **Without MSU-1**: nothing.

**The tests** (the ports, `abl/tests/abl/test_msu.py`), on bsnes's new
MSU-1 log —`tests/harness/emulator/bsnes-msu-log.patch`, a third patch of
the audited core of `just audit-core`, memory id `0x8001`, read by
`retro.Console.msu_accesses`—:

* `test_with_msu_a_save_pauses_seeks_and_plays_again`: two `$2007` writes,
  a pause of a playing track with its repeat flag and a play with the same
  flag; between them exactly one seek nobody reads from, made with the
  status saying stopped, after a `$2000` read with the play bit clear and
  before one with data busy clear; the same track offset at both; eight
  steps down to 0 and eight up to `MSU_BASE`.
* `test_with_msu_and_no_track_a_save_seeks_alone`: one seek to 0 nobody
  reads from, and no `$2006`/`$2007` write.

The slot screen and the menu seek the `.msu` too (the screens' LZ2): the
save's seek is told apart because nothing reads `$2001` after it, which is
why the log counts runs of `$2001` reads. **Red on main's runtime** (no
`$2007` write; zero unread seeks), green on the branch. They skip without
the audited core. **What they cannot see**: the FX Pak's own delays —bsnes
clears the play bit on the write and answers the seek at once—, so the
wait for the play bit is covered only as "a `$2000` read between pause and
seek", not as a wait that waits.

**Torn slots**: each slot carries magic, length, signature and a 16-bit
additive sum, written after the data; only `load_game` checks the sum, the
slot screen does not, and a slot that fails it starts a new game without a
word. Draft:
[`a-torn-save-slot-shows-and-loads-a-new-game`](a-torn-save-slot-shows-and-loads-a-new-game.md).

The book: `internals/the-msu-file.md` gets "After a save: a seek nobody
reads" (the-advocate-docs `huron-fxpak-save`).

**Verified** on the merged tree (the-advocate `huron-fxpak-save` at
`6d1c0729`, with main's Tijereta, Chajá and Calandria; the ports
`huron-fxpak-save` at `93efbae`), with `install-local .local-tools
cartridge project convert` and the audited bsnes rebuilt with the three
patches: ABL's `just tests` 1672 passed, 2 skipped (the save tests ran, on
the audited core); `just boot`, from the ports' root, 155 passed; the
tools' `just test` 29 passed. `just space`: the jsl costs bank 0 four
bytes, and the tightest cartridge keeps 14. The event `OpenSaveMenu` goes
through the same `save_game` as the menu's Save, and **no test saves
through it with the log**: only the menu's path is run.

**To install when merging**: the runtime only, so `just install cartridge
project` from `~/the-advocate` (main's Chajá already asked for `convert`
and `events`); and in the ports **`just audit-core`**, since the audited
bsnes has a third patch: without it the two new tests skip.

**For taro**: `/shared/builds/abl-fxpak-save/`, sfc, msu and a README
(save, wait, power off, power on, continue). The tracks are not there: the
`.msu` is byte for byte the one in `builds/abl/`, so the `.sfc` goes over
the card's copy that already has them. To confirm: the save survives power
off, and how much the dip bothers.

## Closed (2026-11-17)

> Good news: the save works perfectly on the FX Pak now :D

By taro, on the console, with the builds of the ports `428e7c3`.
