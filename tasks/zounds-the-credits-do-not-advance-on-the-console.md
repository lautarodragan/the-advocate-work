---
name: "Zounds: the credits do not advance on the console"
description: "On a real SNES, Zounds' build with MSU-1 boots and stays on the first screen, the credits with music on map 106; the boot test, without tracks and in emulators, gets past it to map 7"
type: bug
status: testing
assignee: taro
agents: [Aguará]
---

taro, on 2026-10-16, on the console with the delivered build (ports
`ed3e0ee`, the-advocate `30ab0ca6`, with its MSU-1 tracks): "Zounds boots
perfectly on the SNES. It stays on the first screen, a credits screen with
music. It still needs to advance to the next one, but the opening menu and
all seem to work perfectly." The boot test (`just boot -k zounds`, no tracks,
snes9x and bsnes) reaches control on map 7 since Aguará's
`zounds-the-intro-on-map-106-waits-for-a-key-nobody-reads`.

## Work (Aguará, 2026-10-16)

Worktrees under `~/scratch/aguara/zounds4/`, branches `aguara-zounds-credits`
from the-advocate `30ab0ca6`, the ports `f8aca68` and the docs `3f105f2`.
The delivered `zounds.sfc` is byte for byte the `release` of the main ports
checkout, so its `.sym` serves to read the ROM's state.

### What the ROM does there

Map 1's event 1 (autostart, switch 330) turns switch 315 on, teleports to
106 and plays `Zounds_MyGameIs`, a `.wav` song: MSU-1 track 50. On 106,
event 1 page 0 waits 50 and turns 192 on; page 1 (autostart, 192) polls
variable 4 for 5 or 6. Common event 3 (parallel, no switch, entry 0 of
`compar_table`) runs every frame: eleven `ControlVars`, then `if switch
315: KeyInputProc(var 4, wait, dirs + decision + cancel)`, compiled as
`OP_KEY slot 3 $9F` (the starting half: var 4 := 0, `pad_prev := pad`) and
`OP_KEY slot 3 $8F` (the waiting half, which rewinds to itself until an
edge). The main loop runs the commons in `map_events` and the autostart
page in `events_tick`, same frame, so the one frame var 4 holds the key is
enough.

What follows from the edge: a press **during** the 5 s is caught by the
common, var 4 holds 5 for a frame while page 1 does not exist yet, and the
next frame the starting half zeroes it: the press is eaten, as in RPG_RT
(`CommandKeyInputProc` resets the variable and the trigger keys). A button
**held since before** the common reached the key never gives an edge
either. Start and Select are not RM2k keys; a direction gives 1 to 4, which
page 1 does not look at. So what advances is an A or B press that begins
after the credits have been up for 5 s.

### What was tried, and advances every time

A probe (`~/scratch/aguara/zounds4/probe/probe.py`) runs the delivered
`.sfc` with its `.msu` and tracks next to it through `emulator/retro.py`,
passes the title and plays a scripted input, reading `map_current`, var 4,
switches 315/192/193, `auto_n`, common 3's `compar_state`, `pad`,
`pad_prev`, `pad_a`, `pad_a_prev`, `MSU_PLAYING` and `ticks` every frame:

* snes9x, MSU-1 on: A held 30 frames at 8 s, A tapped 2 frames at 8 s,
  B held at 8 s —all reach map 107 at tick 495—; Start held: nothing, as
  in RM2k; A held from 1 s to 9 s: nothing, no edge; idle 30 s: the loop
  runs, common 3 waits at cursor 98.
* bsnes (WRAM garbage, high entropy), MSU-1 on: A held at 8 s, four runs:
  all reach 107.
* mesen-s, MSU-1 on: A held at 8 s: 107.
* Mednafen `snes_faust` —the only one with the MSU-1 busy bits, so the
  only one that runs `msu_wait` for real—, under Xvfb with xdotool, A for
  0.5 s at ~10 s: the next screen within a second, then the garden map
  (`probe/shots/hold/`).
* `msu_start`'s `fails` path, which no emulator takes with every track
  there: track 50 removed (bit 3, missing) on snes9x, and every track
  removed with the `.msu` kept, on bsnes: the song falls back to the
  SPC700 and A at 8 s still reaches 107.

### What is only on the console, and cannot be run here

* `dsp_pair` and `apu_token` wait for the SPC700's echo **without a cap**:
  `music_start_level` with a track does `msu_start` —the track starts
  playing on the MSU-1's own hardware— and then nine `dsp_pair`s under
  `sei`. A SPC700 that does not answer there is a CPU stopped with the
  credits on screen and the music playing, which is what taro saw. Nothing
  found that would leave the SPC700 like that on the FX Pak and not in the
  emulators; the same path plays ABL's tracks on the console.
* The reset never writes `$4016` (the joypad latch) nor `$4201`: it is the
  FX Pak's menu that leaves them, and `ppu_reset` was written for that.
  With the latch left high the auto-read returns B's state in every bit;
  the title's first option would still be picked by any button, and on 106
  B would still advance.
* The FX Pak's `msu_wait` timing (a track off the SD card) against the
  `MSU_WAIT` cap, and its data port on `se_msu_upload`: both run before the
  credits are visible or fall back, as tested above.

Not reproduced, so nothing was changed in the tools or the ports: no fix
and no test yet.

### The diagnostic build, for the console

`/shared/builds/zounds-diagnostic/`: the same game from the same commits
with one parallel event added to map 106 in the dump —event 2 "Readout",
made by `~/scratch/aguara/zounds4/probe/make_diagnostic.py`, the retouched
map kept next to it as `Map0106-diagnostic.json`; not committed—, with
the delivered tracks copied in (its `.msu` is byte for byte the delivered
one). While the credits are up it says what the ROM sees:

* a soft white flash every two seconds —variable 200 counts frames—: the
  main loop is alive. Without it the CPU is stopped, and the music says
  nothing because the MSU-1 plays the track on its own;
* the screen shakes while A, B or a direction is held —`KeyInputProc`
  without wait into variable 199—: the pad is read;
* a green flash of 0.6 s when variable 4 reaches 5 or 6: common event 3
  saw the key's edge, which is what page 1 of event 1 waits for.

Checked on snes9x with MSU-1: the white flash and the green one show on
the picture, the shake runs while A is held, and the press still leaves
for map 107 (`probe/shots/diag/`). Its `README.txt` says what to look at
and what to write down, with what was pressed and when.

What each answer would mean: no white flash, the CPU is stopped on 106
—the SPC700 echo waits are the first suspect—; white but no shake, the
pad is not reaching the ROM; shake but no green on a press after 5 s, the
edge logic of `op_key`; green and no fade, page 1 or the teleport.
