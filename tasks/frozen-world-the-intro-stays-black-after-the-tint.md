---
name: "Frozen World: the intro stays black after the tint"
description: "At the end of map 6, after EV0005's TintScreen to black, the box \"They were dark days.\" never opens and the screen stays black with the music on; intermittent, on Mesen and bsnes, since the window's vblank writes started waiting for room"
type: bug
status: done
assignee: taro
author: taro
agents: [Aguará]
---

taro, on 2026-11-16, playing The Frozen World's build of the-advocate
`c9860b49` and the ports `7bbddaa`:

> The screen stays black during the intro. Before, it was playable. [...]
> The music keeps going, even though the screen stays black.

> I just tried it in bsnes. It breaks almost consistently at the end of
> Town (map 6). I think it gets to run EV0005's
> `Tint Screen: (R0,G0,B0,S100), 0.0s`. The `Show Message: They were dark
> days.` I don't get to see. But I just tried it 3 times, and 3 times it
> worked fine. I can't find the pattern.

On Mednafen 1.32.1 and Mesen 2.2.1 too. In Mesen's tilemap viewer every
layer is black.

## What Hornero read

Not reproduced in the harness: the same ROM (sha256 `dc91d95a…`), from
the title with A every 16 ticks, reaches the beach (map 11) with control
on snes9x with and without MSU-1, bsnes, and bsnes with the accurate PPU
(the audit core).

**taro's Mesen savestate**, at the black screen, is in the shared folder
(`captures/2026-11-16-fw-black/tfw-map6-black.mss`). It is a zlib stream
of `name\0 + u32 size + data` fields (`memoryManager.workRam`,
`ppu.cgram`, `ppu.vram`…); a reader is in `~/scratch/hornero/fw-black/mss/`
(`rd.py`, with the release `.sym`). What it holds:

* map 6; `msg_state` 1 (composing), `msg_upload` 1 (a line waits for
  VRAM), `msg_open` 0, `msg_line` 2, `msg_lines` 0;
* `MSG_PLACE` 5: **a window without its background** (`MSG_BARE`);
* INIDISP brightness 15, no forced blank, main screen BG1, BG2, OBJ;
  CGRAM black but entries 1-7, 210-223 and 241-247: the tint is done
  (`tint_pending` 0);
* the CPU waiting in the main loop.

**The suspect**: `upload_line` in `runtime/vblank.s`, since `7f2a0ae2`
(2026-11-15, the fix of
[`a-transparent-message-keeps-the-layer-above`](a-transparent-message-keeps-the-layer-above.md)),
starts a bare window's line only up to `LINE_LATEST_BARE` = 238 (measured
on ABL's memory in snes9x), so between 225 and 238; otherwise it waits for
the next vblank with `msg_upload` set, and the window does not open until
the line is up. If what goes before it in the vblank reaches 238 on every
frame of this map, it waits forever. That fits: intermittent, on the
accurate emulators, and new in the build taro played.

Done means: reproduced (the vblank line `upload_line` sees on map 6, on an
accurate core), the cause proven, a line that cannot wait forever, a ROM
test that fails without the fix, ABL's console fix kept.

## Log

**Aguará, 2026-11-16.** From the-advocate `c9860b49` and the ports
`c5c0711`, branches `aguara-fw-black`. EV0005 of map 6 (autostart) ends
with a `ShowBattleAnimation` 77 on event 14 without waiting, a
`TintScreen` to black in 0.0 s, a wait of 12, a `MessageOptions` with
the window transparent at the bottom, and the box. Measuring with a
temporary probe in `flush_video`: the line the PPU is on after each of its
steps, and the one `upload_line` reads.

**Reproduced in the harness**, deterministically: from the title, A every
16 ticks only while there is no control (`probe.py` in
`~/scratch/aguara/fw-black/`), map 6's last box hangs on tick ~1280 and
stays so. On `release` with c9860b49's runtime, **ten of the sixteen
phases** of those presses hang in snes9x (A on ticks 2, 3, 6-9, 12-15
modulo 16), and the ones tried in bsnes the same (8 and 2 hang, 0 not);
the probe cartridge, whose marks cost the vblank a little, hangs on phase
0 too, in snes9x and in bsnes with the accurate PPU (the audit core,
`bsnes_ppu_fast` off). `until_control`'s phase, 0, does not hang on
`release`: that is why `test_frozen_world.py` and Hornero's run stayed
green.

**What the vblank holds** while the line waits, every frame the same
(snes9x; accurate bsnes one line later): `push_oam` ends on 232, the tint
and the ChipSet's step nothing, **`vram_drain` 233 → 241**, the strips and
the panorama 244, and `upload_line` reads **244-245**, past
`LINE_LATEST_BARE` (238). `vq_n` is 7 after every frame, `vq_done` 1: a
waiting line sets the poses' budget to one, and the seven characters that
animate there (the flames' events, without shared slots, `SHARE_N` 0)
queue faster than one a frame, so the queue never empties, and its one
pose with the slot's zeroing is ~8 lines in every vblank. The line's wait
is what keeps the queue full: it does not end on its own. Before
`7f2a0ae2` the line could start up to 246 and fitted.

**taro's two savestates** (`mss/rd2.py` in my scratch reads both): the
stuck one has `vq_n` 7 with the same kind of entries, `msg_upload` 1;
the one before the last box, `vq_n` 0. Whether it hangs depends on the
frame the box is closed on: if the next box's first line has to wait
while poses are queued, the cap of one keeps the queue full from there
on. Why it varies from the same savestate with the same input: a guess,
not measured —`msu_wait` (`runtime/msu1.s`) spins on the MSU-1's
`AUDIO_BUSY` when a track starts, which takes as long as the host takes;
snes9x and bsnes never set it, so the harness is deterministic—.

**The orange palette** Hornero asked about (CGRAM `$D2`-`$DF` lit under
the black tint): it is the battle animation's, `ANIMB_CGADD`, above
`SPRITE_CGRAM`, which the tint does not reach. Not a divergence: in
easyrpg a battle animation on the map is drawn above the screen's tone
(`Priority_BattleAnimation` over `Priority_Screen`, and `BattleAnimation`
takes only its cells' tone). And nothing shows it: the animation (77 on
event 14) ended before the box, its objects are no longer in OAM.

**Why it varies for taro.** The hang needs a line of the box to wait
while the queue holds poses; from then on it holds itself. So it depends
on where the seven animated characters' pose changes fall against the
frames the box's lines go up: in the harness, on the phase of the A
presses, ten of sixteen. taro's later tries agree: with the port's
auto-fire held, paced by the ROM's own frames, the box closes on the same
phase every time and hangs ~99%; a single A press ~50%. And taro's
consecutive pair (`tfw-pair2-save3-fine`, almost never hangs, and
`tfw-pair2-save4-bug`, almost always; by `msg_ptr` against the ROM's text, save 3 on "Please! Show mercy on my
children!" and save 4 on "Very well.", three boxes before the black
one): among
what paces the characters, the animated stills' schedule
(`animated_stills.s`) is what differs in kind —`still_next - still_t` 1
against 5, `still_gap` 1 against 5, `vq_n` 1 against 3—. The flames stand
still and animate in place, so they are the poses that keep the queue
full; the phase of their schedule against the frames the box's lines go
up decides it. Not proven beyond that reading. The stuck savestate without
MSU-1 holds the same: `vq_n` 7, a line waiting. From taro's savestate before the last box
the flames' phase is fixed, which fits "almost always" there and "usually
not" from a new game. What makes the same savestate with the same input
differ is not found: its MSU-1 fields (`msu1.*`) are the same in both
savestates but the stream's offset, and `audioBusy` and `dataBusy` are 0;
`msu_wait` spins only when a track starts. taro had MSU-1 on in the three
emulators, but it hangs without it too (taro, from the savestate with the
`.msu` renamed; and the harness runs without tracks), and Mesen's RAM at
power on —random, zeros, ones— made no pattern. Not chased further: the
fix does not depend on it, and the test is deterministic without it.

## The fix (Aguará, 2026-11-16)

the-advocate `b23d446e`, branch `aguara-fw-black`. A line that missed a
vblank (`msg_waited`, set by `upload_line` when late, cleared when it goes
up and when a new line is ready) gets the next vblank's room:

* `flush_video` gives the poses no budget (`vq_cap` 0) and skips the
  ChipSet's step (`anim_pend` stays and goes up a frame later) before it;
* a bare window's line takes the framed window's `LINE_LATEST` (246)
  instead of `LINE_LATEST_BARE` (238). What it writes after the 1920
  bytes asks the clock and waits on its own since `7f2a0ae2`; the earlier
  line only kept the box's pace.

Both are needed, measured with the probe over the sixteen phases: on the
vblank after a wait `upload_line` read lines 237 to 242, most past 238
—the poses gone, what is left is the strips, the tint and the rest—. No
line waited two vblanks in a row. Frames without a waiting line pay a
`bra` and, in a bare window, the `msg_waited` check.

**The test**: `tests/test_frozen_world_dark_days.py` in the ports, A every
16 ticks on ticks 8 modulo 16 while there is no control, snes9x and bsnes:
the intro has to reach map 4 from map 6. Red on c9860b49's runtime, both
cores (stays on map 6 with `msg_state` 1, `msg_upload` 1, `msg_open` 0
—taro's savestate—); green with the fix.

**Verified** (the-advocate `b23d446e`, the ports `7350777`, tools of the
branch installed locally: `project`, `cartridge`, `convert`,
`rm2k-snes-audio`):

* the sixteen phases on Frozen World's `release` in snes9x reach map 9;
  phase 8 in bsnes with the accurate PPU too, with **0** display accesses
  on the audit core over the whole intro;
* ABL's `just tests`: 1658 passed, 2 skipped, no golden moved; and
  `test_display_accesses.py`, `test_vblank_budget.py` and
  `test_message_layer_above.py` again apart with the audit core: 8 passed.
  On the memory, with the probe: `flush_video` past the vblank on the same
  5 frames as before, the worst window write on line 257, as before;
* the ports' `just boot`, 153 passed, the new test among them;
* `just test` in the-advocate, 29 passed. `just test-game`: 3 red in
  `test_leader_name.py` (the renamed actor's menu and slot), the same with
  c9860b49's runtime and with the global tools alone: not this change.
  Draft:
  [`the-test-games-leader-name-goldens-are-red-on-main`](the-test-games-leader-name-goldens-are-red-on-main.md).

**What the suite does not cover**: Mesen, Mednafen and the console, where
taro saw it; a line that, with no poses before it and the framed limit,
still does not fit (what is left before it: the tint, the flash, the
pictures' palettes, the strips, the panorama, a painted map's slots,
with their fixed budgets) —not seen in the sweep, but nothing forbids it
on a map that scrolls a panorama and tints at once—; a framed window's
line that waits, which gets the poses' yielding too and is covered only
by ABL's suite staying green.

**To merge**: the-advocate `aguara-fw-black` (`b23d446e`, runtime only)
and the ports `aguara-fw-black` (`7350777`, the test), both on today's
main, which did not move. Nothing to install: the runtime is the
checkout's. The build to play comes from merged main.

**2026-11-16, taro**: declared done.
