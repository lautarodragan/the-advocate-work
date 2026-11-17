---
name: "The SRAM as slow WRAM"
description: "A 256 KB SRAM, and the part the save slots do not use as working memory reached by DMA through $2180 —the map's grid and code stashed across a battle, more room while the screen is black—; first, whether the FX Pak writes its SD card on every change"
type: research
status: done
assignee: taro
agents: [Aguará]
---

taro, on 2026-11-16, asking whether part of the SRAM could be used as
slow WRAM, "to keep WRAM temporarily when we compress / decompress",
between fade out and in —entering or leaving a battle, changing maps—.
Hornero noted that DMA does reach it (A bus to WRAM through its B-bus port,
`$2180`), and three cautions: the FX Pak saves the SRAM to its SD card when
it changes; the save slots' area must never be touched; emulators save the
whole SRAM in the `.srm`. And then:

> I'd make the SRAM 256 KB, which seems to be a number the FX Pak and
> emulators accept. That can give us a lot of room for optimisations! [...]
> I _think_ the FX Pak's firmware at some point had an update precisely
> for this case (homebrews mainly, and maybe the SA-1?), but either way I'll
> test it, and that will tell us whether it affects gameplay.

Done means: what a 256 KB SRAM takes in ExHiROM (the header byte, where it
maps, what the emulators the suite uses and taro's —snes9x, bsnes, ares,
Mesen, Mednafen— and the FX Pak do with it; sources cited); a small test
ROM for taro to run on the FX Pak that writes a large SRAM region
repeatedly (as a battle would) and shows on screen what it did, so taro can
see whether the FX Pak stalls or writes the SD each time; the DMA path
measured in the harness (bytes per frame, both directions); and a
proposal: what to stash, the layout beside the save slots, what it
saves (load frames, WRAM) — measured, not implemented in the games yet.

## Log

2026-11-16, Aguará. Read from source, in `~/ref` (commits: sd2snes
`cf7e21d` = firmware 1.11.2, snes9x `890b5d44` = the installed libretro
core, bsnes `591b7e1`, bsnes-libretro `a7e88d6`, ares `4cb8d92`, Mesen2
`b9fa69d`, mesen-s `9e4fdeb`, Mednafen 1.32.1):

* **$FFD8 = $08** is 256 KB (1 KB << 8), and it is **the most ExHiROM can
  address**: the SRAM window is `$20-$3F:6000-7FFF` (and `$A0-$BF`), 32
  banks of 8 KB; the FX Pak's FPGA takes `{A20:16, A12:0}` (18 bits) for
  it (`verilog/sd2snes_base/address.v`, mapper `010`). The runtime already
  uses that window bank per slot, `$20-$23`.
* **Caps**: bsnes, ares, Mesen2 and mesen-s cap at 8 (ares wraps 9 to 2
  KB); snes9x at 9, but its libretro core reports at most 128 KB of
  SAVE_RAM to the frontend; Mednafen's `snes_faust` takes up to 9; **its
  default `snes` module masks the byte with 7, so $08 is 1 KB, "no RAM"**
  (`snes/src/cartridge/header.cpp:46`): no saves there at all. The FX Pak
  takes `1024 << n` with no cap.
* **The FX Pak does not write on every change**: it CRCs the SRAM and
  writes the whole `ramsize` to the `.srm`. Without MSU-1 (`snes_main_loop`)
  64 KB every 250 ms, and saves once the CRC has been stable for five full
  passes after a change, or every ~50 passes if it never settles. **With
  MSU-1** (`msu1_loop`, which is ABL's: its builds carry the `.msu`) it
  checks at most once a second, and **synchronously on every data seek**
  (`prepare_data` → `msu_savecheck(1)`), saving at once if changed — but
  only while no MSU audio or data is busy. The "firmware update" is 1.9.0's
  partial-SRAM CRC for **known** SuperFX/SA-1 games, a table keyed by the
  ROM's CRC (no homebrew), and 1.11.1's `autosave` / `msu1_autosave`
  toggles in `config.yml`.

The test ROM, in the ports' `abl/experiments/sram-dma/` (`just sram-dma`,
branch `aguara-sram-dma`): 8 MB ExHiROM like the game, `$FFD8 = $08`; a
round fills 96 KB of WRAM ($7E:8000-$7F:FFFF, which is exactly what a
battle takes from the map), stashes it in banks $24-$2F by DMA through
`$2180`, wipes it, brings it back and checks it; with MSU-1 it times a data
seek right after the stash and another after. Delivered to
`/shared/builds/sram-test/` with a README of what taro should look for.

Measured in the harness (snes9x, bsnes, mesen-s and the audit core, all
four the same within two lines): **256 KB seen in all**, 96 KB in **597-599
lines WRAM to SRAM and 598 SRAM to WRAM** = 8.3 master cycles a byte, **~43
KB a frame** each way; the stash survives a reset; banks $20-$23 untouched.
snes9x's libretro hands its frontend only the first 128 KB (the slots are
in the first 32 KB, so saves are unaffected), mesen-s 256 KB, bsnes saves
it itself. ABL's `release` with `$FFD8` patched to `$08` boots to the same
screens as without in snes9x, bsnes and mesen-s (frames 120, 300, 600): the
byte does not move the header detection, in them or in the FX Pak's
scoring (both header copies lose the same point).

Measured on ABL (snes9x, the case `battle-in-52`: map 52 has the biggest
grid, 20,000 B, plus 4,850 B behind it). The global tools are behind the
runtime today (Carpintero's panorama LZ2 is merged but not reinstalled), so
nothing builds: this ran on a copy of the `release` built at 20:05 in the
ports' main checkout, consistent with itself, with the harness's staleness
check bypassed in a scratch script. Nothing on the paths measured changed
with that merge. The return from the battle, frame by frame:

* **55 frames of audio package without MSU-1, 86 with** (the map's ARAM
  again), which the SRAM cannot shorten: the SPC700 is fed through its
  ports, from the ROM. The whole black: 80 frames, 111 with MSU-1.
* **then ~25 more black frames** of reloading: `lz2_grid` ~6 (grid and
  what lives behind it, ~25 KB), `fill_window` ~6 (the tilemap, from the
  grid), `load_map`/`load_above` ~12 (the tiles, decompressed through
  `LZ2_BUFFER` into VRAM), and the rest. The same with and without MSU-1.

With the map's WRAM (only what it uses, ~25 KB here) and its VRAM tiles and
tilemaps stashed in SRAM when the battle starts, those ~25 frames become
the DMA back: ~0.6 frame of WRAM and ~1-1.5 of VRAM (SRAM to `$2118` is an
A-bus to B-bus DMA like any other; not measured). About **22 frames, ~0.37
s, of the 80 (111) the black lasts** on map 52.

The book's research, `research/2026-11-16-the-sram-as-slow-wram.md`
(branch `aguara-sram-slow-wram` of the-advocate-docs), has all of it with
its sources and the proposal: 256 KB declared, banks $20-$23 the slots as
today, $24-$2F the map's WRAM across a battle, $30-$37 its VRAM (tiles
and tilemaps, by DMA from `$2139` and back to `$2118`), $38-$3F free (a
last-map cache, or the teleport's carried bytecode); the backdrop's seek
before the stash, so the FX Pak does not write 256 KB in front of it. It
frees no WRAM: it makes the rebuild after a battle ~22 frames shorter.

**What taro has to do**: run `/shared/builds/sram-test/` on the FX Pak as
its `README.txt` says, and send the two seek times (after a stash, and
again), with music off and on, and whether the stash survived power-off
with and without the `.msu`. That decides whether the stash can go before
the backdrop's seek or must go after it, and whether 256 KB costs every
seek too much even unchanged. And whether running Mednafen without
`-force_module snes_faust` matters: there the game would not save.

**What has to be installed when merging**: nothing. No Rust and no runtime
changed; the ports' branch `aguara-sram-dma` adds
`abl/experiments/sram-dma/` and the `sram-dma` recipe, and the book's adds
the page.

Not run: ABL's suite (nothing it builds changed) and the FX Pak. The ABL
measurements ran on a copy of a `release` built before the panorama-LZ2
merge, because the installed tools could not build the current runtime.

## Follow-up: far RAM in the SRAM (taro, 2026-11-17)

Hornero, rereading with taro: the study said the SRAM frees no WRAM, but
the CPU reaches the SRAM directly, at WRAM's speed, so far-RAM variables
could live there for good —what blocks `baked_events` in ABL—. taro's
worry is the FX Pak with the `.msu`:

> I'm still worried about the msu: whether using it to play music
> continuously, added to the periodic checksum, can introduce lag. [...]
> If I understand correctly, precisely playing music would make it persist
> and check _less_, not _more_, and when no music is playing (practically
> never), it would be at most once per second, but it would do a 256k
> write per second...

To measure: which far-RAM tenants could move and what it costs; the FX
Pak's behaviour when the SRAM changes every frame, from its firmware
(stalls? data seeks delayed, with and without a track?); and a mode of the
test ROM that writes the SRAM every frame and times data seeks, with music
on and off.

### Log

2026-11-17, Aguará. Started from the-advocate `269bb12c`, the ports
`a311082`, the book `89df6b1`; branches `aguara-sram-far` in the ports and
the book. Mulita's area (`posed.s`, the grid) only read.

**1. What could move.** The SRAM window costs 8 master cycles a byte, the
same as WRAM (fullsnes's speed table; bsnes `CPU::read`). ABL's `FARBSS`
is full (24,436 B + 128 of switches, 12 B left). Classified by how the
runtime reaches each label (a script over `abl.sfc.dbg` and `runtime/`,
heuristic): ~4.2 KB only with long addresses —movable with a segment and a
boot clear—, ~8.2 KB through 16-bit addresses with the data bank at `$7E`,
~12.1 KB also through `$2180`. `posed.s`'s ~700 B is easy: one line
(`FAR_VRAM_MAP` read under `^POSED_REG`'s bank). Cannot move: bank 0, the
direct page, the stack, anything through `$2180`, objects over 8 KB or
indexed across a window (`far_text_layer` is 8,810 B). And it asks a boot
clear (the SRAM keeps the last session, invisible to `test_cores.py`).

**2. The FX Pak** (firmware 1.11.2, `msu1.c`, `memory.c`, `sdnative.c`,
`main.v`). The console never stalls: the MCU reads the SRAM in the FPGA's
free slots. With a `.msu`, `msu_savecheck` —checksum of all that is
declared, write of all of it if changed— runs at every data seek made
with no track playing, before the seek, whose busy bit stays up; once a
second only if the data side is idle, which after a seek it is not until a
read reaches the `.msu`'s end (in ABL, almost never); at a track change,
rate-limited; and on reset. Never while a track plays; never on power off.
taro's reading is right about the music; without a track it is "a checksum
**and, if changed, a whole write** at each seek", not once a second.
Estimated from the loops (not measured): checksum 0.7-1 µs a byte, write
~1.2-1.5 µs a byte plus the card: a silent seek gains +25-35 ms today
(32 KB), and with the SRAM changed +0.13-0.2 s at 64 KB, **+0.5-0.7 s at
256 KB**, past `msu_data_seek`'s ~0.35 s cap. In ABL the silent seeks are
the sound-effect packages of a map change with a new song
(`map_song_mute` stops the track first) and the battle's backdrop.

**3. The test ROM** (ports `a3861bf`): X steps a frame test —OFF,
WRITES (16 B of `$24:6000` a frame; entering it seeks the `.msu`'s last
sector so the once-a-second check runs), SEEKS (a timed seek every 30
frames), SEEKS+WRITES— showing the seeks' last, mean and max ms and the
late frames; and a 64 KB build (`--sram-kb 64`, no rounds). `just
sram-dma` in snes9x, bsnes, mesen-s and the audit core: both see their
SRAM, the rounds and the reset as before, 10 seeks in 300 frames with 0
late frames, the bytes following the frame. The emulators seek at once:
the timing path never times a non-zero wait there. Re-delivered to
`/shared/builds/sram-test/` (`sram-test.sfc` sha1 `0d7458be…`,
`sram-test-64k.sfc` `7eb48770…`) with the README's eight numbers to send.

**4. Recommendation**: no, for `baked_events`. Far RAM changes every
frame, so the SRAM would be always changed, and every silent seek would
pay the checksum and the whole write: estimated half a second at 256 KB,
on the cartridge taro plays; 256 KB also breaks Mednafen's default module.
Behind the grid (Mulita) costs nothing of that. The SRAM suits what
changes once per battle (the stash). If the FX Pak's numbers come out far
below the estimates, a 64 KB SRAM is the one to reconsider.

The book: a new page, `research/2026-11-17-far-ram-in-the-sram.md`
(branch `aguara-sram-far`, `51b43d0`), not a section of the old one: it
answers another question at other commits, and a research is a snapshot.
Relative links checked, `mdbook build` clean.

Found and not fixed: the draft
[`a-save-on-the-fx-pak-waits-for-a-silent-seek`](a-save-on-the-fx-pak-waits-for-a-silent-seek.md)
—with a `.msu`, a save reaches the card only at a silent seek or a reset—.

**What taro has to do**: the eight numbers of
`/shared/builds/sram-test/README.txt` on the FX Pak (both cartridges,
music off and on, SEEKS and SEEKS+WRITES) and whether the LED blinks in
WRITES; plus the old test's numbers if not sent yet.

**What has to be installed when merging**: nothing. No Rust, no runtime;
the ports' branch changes only `abl/experiments/sram-dma/` and the
`sram-dma` recipe. Not run: ABL's suite (nothing it builds changed), the
FX Pak.

**2026-11-17, taro**: declared done.

## On the FX Pak (taro, 2026-11-17)

taro ran `sram-test.sfc` (256 KB) with its `.msu` on the console, music
off, auto rounds; photos of the TV in the shared folder,
`captures/2026-11-17-sram-test-fxpak/`. Read off them:

* SRAM seen 256 KB, MSU-1 yes, save slots intact; 13 to 102 rounds, all
  `PASS`, none failed.
* 96 KB by DMA: 597–599 lines, ~43 KB per frame, both ways —the same as
  the emulators—.
* A data seek **right after the stash: ~1.08 s** (max 1.084 s); the next
  one, **SRAM unchanged: 0.382 s**. Worse than the estimate (0.5–0.7 s
  changed), and the unchanged one alone is past `msu_data_seek`'s ~0.35 s
  cap: with 256 KB declared and a `.msu`, every seek made with no track
  playing would time out, stash or not.
* The frame test was at `OFF` and `WRITES` (`SEEKS` 0); 1 to 4 late frames.
  Still to run: `SEEKS` and `SEEKS+WRITES`, music on (Y), and the 64 KB ROM.
* The test ROM's background is full of garbage tiles on the console: it
  does not clear VRAM, which the emulators start at zero. Cosmetic, the
  test ROM's.

Read so far: 256 KB with a `.msu` is not usable as it stands.

Later, after the console was turned off and on (photo
`after-reboot-three-rounds.jpg`), three rounds with A: at boot **saved
rounds 134** —the counter of the previous session reached the card— but
**saved stash LOST** —a stash was there and did not verify—; the three
rounds `PASS`; after the stash 1.044 s (max 1.055 s), again 0.382 s, the
same as before. What "LOST" means against this ROM's checks (a stash
written after the card's last write? half of one?) is to be read from
`sram.s`; it fits the draft
[`a-save-on-the-fx-pak-waits-for-a-silent-seek`](a-save-on-the-fx-pak-waits-for-a-silent-seek.md):
what the SRAM holds at power-off is what the last write took, not what the
game last wrote.
