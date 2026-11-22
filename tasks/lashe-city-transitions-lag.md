---
name: "Lashe City's transitions lag"
description: "Going from one sector of Lashe City to another, or into and out of a house, costs many frames of lag; measure where they go —the audio package, the map's tiles, events, graphics— before choosing what to fix"
type: bug
status: testing
author: taro
assignee: taro
agents: [Hornero, Chajá]
game: abl
---

> In ABL, in Lashe City, going from one sector to another, or entering and
> leaving a house, costs many frames of lag. If the sound package is part
> of the cause, it should be able to improve a lot, because they usually
> have the same effects, but the relation between teleports is not a closed
> cycle, so a naive static analysis would not find it.
>
> On the other hand, Lashe City is huge, so the loading time may be in the
> map's tiles themselves, events, graphics...

taro, 2026-11-22, before trying the build with
[`frozen-world-every-turn-re-uploads-the-battle-screens-audio`](frozen-world-every-turn-re-uploads-the-battle-screens-audio.md),
which already moved every game's effects out of the teleport's fade.

## Log

### 2026-11-22, Hornero: taken for Chajá, to measure first

### 2026-11-22, Chajá: the method

Lashe City is maps 8 ("Lashe City - 34,35") and 9 ("33,36"), 75x75 each,
with 10 (Interiors: the pawnshop and the houses), 11 (Lazer Teeth HQ,
100x100), 12 (Trash Dump), 7 (Talan's Pad) and 13 (Hover-Tram) around
them; the sectors with the car, later, are 37, 38, 47 and 48, joined by
map 36 (the car's choice). The doors are touch pages with a `Teleport`,
most with nothing else; the song changes are `PlayBGM`s on the door's own
page: 9's EV0003 plays `hzstream` going to 8, and 8's EV0054 plays `cd4`
with switch 35 on.

A throwaway script (`measure.py` in scratch) boots `release` on the case
`in-5`, puts the hero next to each door with the harness's jump —not
measured— waits for control and 240 more ticks, and **walks onto the
door**: the window counts the hardware frames of every tick from the step
until 30 ticks of control on the new map; "extra" is frames minus ticks.
Then 300 more ticks, to see what the effects cost when they go up after
the fade. Each door twice, after a warm-up door that starts Lashe's song;
the tables give the second lap. On Mesen2's core with its line profiler
(`abl/tests/harness/mesen2.py`), so the frames and where they go come from
the same run; the profile is flat —each watched routine owns the lines
until the next watched one starts—, so a routine's bucket also holds what
its caller does after it returns.

The same doors on two builds of the ports' `cb9f4f5`, which differ only in
the ROM (`.msu`, tracks, `audio.json` and `mapdata.inc` byte for byte
equal):

* **main**: the global tools, the-advocate `ec672f4c`; `abl.sfc`
  `174d4fd8…b5d5a0`.
* **before**: the runtime before the
  `frozen-world-every-turn-re-uploads-the-battle-screens-audio` merge,
  the-advocate `63f07a16` (its first parent), with `project` and
  `cartridge` installed into a `.local-tools` of a worktree at that commit
  —those two carry the runtime's path—; `abl.sfc` `fcff9c9c…2ba3f67`.

Without MSU-1 the core gets the ROM alone; with it, the ROM's directory
with `abl.msu` and the 106 tracks.

### 2026-11-22, Chajá: where the frames go

#### The doors, before and after

Extra frames of each door —frames minus ticks from the step until 30
ticks of control on the new map—, second lap; in brackets the ticks that
lasted more than two frames. The warm-up and the first lap give the same
to a frame or two.

| door | before, no `.msu` | main, no `.msu` | before, `.msu` | main, `.msu` |
|---|---|---|---|---|
| 8>9, sector to sector (EV0009) | 36 (21, 17) | 23 (17, 8) | 98 (48, 23, 16, 11, 5) | 15 (16) |
| 9>8, sector to sector (EV0003, `PlayBGM hzstream`, already playing) | 24 (19, 6) | 19 (19) | 101 (56, 46) | 19 (19) |
| 8>10, street to house (EV0033) | 11 (10) | 11 (11) | 45 (23, 14, 10) | 10 (10) |
| 10>8, house to street (EV0018) | 43 (25, 19) | 19 (19) | 102 (56, 47) | 18 (18) |
| 8>10, street to the pawnshop (EV0055) | 11 (11) | 11 (11) | 44 (23, 14, 10) | 10 (10) |
| 9>11, street to the Lazer Teeth HQ (EV0009) | 49 (35, 16) | 15 (16) | 98 (77, 14, 10) | 14 (15) |
| 11>9, HQ to street (EV0004) | 44 (28, 18) | 32 (18, 16) | 98 (47, 37, 17) | 16 (17) |
| 8>9 with `PlayBGM cd4`, a song change (EV0054, switch 35) | 34 (19, 17) | 21 (17, 6) | 97 (38, 24, 23, 16) | 15 (16) |
| 9>8 with `PlayBGM hzstream`, back | 24 (19, 6) | 19 (19) | 101 (101) | 19 (19) |
| 10>38, house to Sector 34 with the car (switch 231) | 17 (18) | 17 (18) | 29 (29) | 17 (18) |
| 38>10, back | 10 (10) | 10 (10) | 45 (45) | 10 (10) |

Not measured: 12>8, the Trash Dump's fence (EV0001 at (1,47)): the hero
walking left from (2,47) never starts its page, and I did not look for the
side it is reached from.

**What taro felt is mostly gone in the build they have not played**: with
the `.msu` —the way taro plays— a Lashe door cost ~100 extra frames, two
ticks of ~50 frames each, and now 10 to 19 in one tick. Those 100 frames
were the `.msu`'s effects: `se_msu_prepare` forgets every effect on each
load, and each package's `.msu` versions (~60 KB, see below) went up whole
in the fade's last black tick and in the load. Without the `.msu`, 24-49
became 11-32.

#### What is left, by the profiler

The load's tick, on today's main, in frames (routines that took 40 lines
or more of it; a bucket holds what its caller does after it returns):

| door | load tick | background + ChipSet animation (LZ2) | grid (LZ2) | sprites (LZ2) | package placing | `code_carry_after` | event pages | the rest |
|---|---|---|---|---|---|---|---|---|
| 8>9 | 16.9 | 7.5 | 3.3 | 2.6 | 1.3 | 0.6 | 0.6 | 1.0 |
| 9>8, 10>8 | 18.9 | 8.4 | 4.0 | 2.7 | 1.2 | 0.7 | 0.9 | 1.0 |
| 8>10 | 10.9 | 4.1 | 1.6 | 1.8 | 0.8 | 0.6 | 0.2 | 1.8 |
| 9>11 | 15.9 | 3.6 | 4.4 | 2.1 | 2.2 | 0.7 | 0.6 | 2.3 |
| 11>9 | 17.9 | 7.5 | 3.3 | 2.6 | 1.4 | 1.6 | 0.4 | 1.1 |
| 10>38 | 17.9 | 10.3 | 3.5 | 1.6 | 1.0 | — | 0.4 | 1.1 |

With the `.msu` the same, a few tenths lower in placing. Map 8's backdrop
is 418 8-bit tiles, 26,752 B raw and 13,707 B of LZ2; 9's 23,104 B; 38's
31,488 B. **Three quarters of what is left is LZ2** —backdrop, grid and
sprites, 13 to 15 frames on the sectors—, and it does not depend on the
audio at all.

And without the `.msu`, a second long tick on some doors: the fade's last
black tick (`package_settle`) uploading **the other songs of the
destination's package** —the ones its pages could start, not the one
playing—: 7.5 frames entering 9 (cd4's and C3classi's samples, 23 KB),
5.4 with the song change, 15.4 entering 9 from the HQ (11's `rshinld`
pushed hzstream's neighbours out). Before my change the same tick also
carried the effects: 21, 25, 35 frames.

#### The audio packages of Lashe share almost nothing

From `audio.json` and the ROM's `sample_table` (`packages.py` in
scratch), the destination's effects and how many of them the origin's
package already has (same effect; with the `.msu`, same version):

| pair | destination's effects | shared, cartridge | shared, `.msu` |
|---|---|---|---|
| 8>9 | 5, 10.2 KB (`.msu`: 59.2 KB) | 0 | 0 |
| 9>8 | 8, 21.5 KB (58.7 KB) | 0 | 0 |
| 8>10 / 10>8 | 2, 4.9 KB / 8, 21.5 KB | 0 | 0 |
| 9>11 | 10, 27.3 KB (60.9 KB) | 1, `Jump1`, 0.8 KB | 0 |
| 11>9 | 5, 10.2 KB | 1, 0.8 KB | 0 |
| 7>8 | 8, 21.5 KB | 1, `Open2`, 2.0 KB | 0 |
| 8>12 / 12>8 | 1, 2.5 KB / 8, 21.5 KB | 0 | 0 |
| 36>38, 36>47, 36>48 (with the car) | 1-3, 2.2-5.7 KB | 0 | 0 |

Map 8 plays `Blow2 Open2 Cursor2 Fall2 Bite Blow4 Blow6 Holy5`, 9 plays
`Failure2 Jump1 Success2 Teleport1 Recovery5`, 10 `Success2 Close1`: the
neighbours' pages simply ask for different sounds. And measured on the
console —the samples whose ARAM address is the same before and after each
door, `places_in_aram(uploaded=True)`—: without the `.msu` the runtime
**already keeps** what stays —hzstream's 9 samples and cd4's 8, 27.8 KB—
and uploads only the rest. So "upload only the difference" is already
what it does for songs and for effects without the `.msu`; with the
`.msu` it forgets the effects, but no Lashe pair shares a version, so
keeping them would save nothing here. The songs: 8's package is `cd4`
alone, 9's `hzstream cd4 C3classi`, 11's `rshinld`; what goes up is
C3classi (and hzstream's after the HQ), the songs that are not playing.

#### The tile banks do not repeat either

Backdrop tiles equal byte for byte between two maps (64-byte 8-bit tiles,
`raw.py` in scratch): 8 and 9 share 58 of 418/361; every other pair, one
or two. Each map has its own palette, so keeping VRAM across a door would
not save anything.

### 2026-11-22, Chajá: the effects after the fade, door by door

taro's worry, through Hornero: that leaving the effects for after the fade
moves the lag into playable frames, and that one stall inside the fade may
suit a map like Lashe better. Measured with the same doors, second round
of `measure.py`: after each door, 300 more ticks walking back and forth
from the arrival cell (right 16 ticks, left 16), noting each tick's frames,
how many effects are still marked 3 in `FAR_WANTS`, and every
`sound_play` and `effect_now_l` the profiler saw. The door tables of the
first round repeat to a frame or two.

#### (a) How long the waiting effects take, and whether play gets slower

"Waiting" is the effects still not up when the fade ends; "all up" the
ticks after it until none waits.

| door | no `.msu`: waiting / all up after | `.msu`: waiting / all up after |
|---|---|---|
| 8>9 | 5 / 23 ticks | 4 / 121 |
| 9>8 | 1 / 8 | 6 / 157 |
| 8>10, both doors | 0 | 1 / 9-10 |
| 10>8 | 5 / 56 | 6 / 161 |
| 9>11, into the HQ | 7 / 249 | 3 / **more than 330** (2 still waiting) |
| 11>9 | 4 / 21 | 4 / 129 |
| 10>38, 38>10 | 0 | 0, 1 / 9 |

**No gameplay tick got longer**: tick by tick after the fade, main and the
old runtime last the same, every one a frame except a 2-frame tick right
after arriving on 8 that both have. The idle pump only uses what is left
before line 180 (`PUMP_LINE`), and it never lengthened a tick here. What
it costs instead is time: two to three seconds on the sectors with the
`.msu`, and **in the Lazer Teeth HQ more than five and a half**: its ticks
rarely end before line 180 (it is the map of
`build-oam-costs-a-third-of-the-frame-on-busy-maps`), so the pump moved
one effect at tick 133 and none after, in 330 ticks. The two left are
likely its biggest `.msu` versions, `Glass` (21.6 KB) and `Dark1` (20.2 KB).

#### (b) Effects played while they wait

**None, on any door**: in 330 ticks of walking after each one,
`sound_play` was not called once —Lashe's maps have no parallel or
autostart page that sounds on arrival, and the steps make no sound—. So
on these doors no effect was heard late. What one would cost if a page
played it while it waits, from the rates measured here (~1 KB a frame
for the cartridge's samples through the SPC700 and for the `.msu`'s,
`sample_block` and `se_msu_chunk` lines over the bytes that went up): a
freeze of about a frame per KB, heard that much late —0.5 to 8 frames
for the cartridge's versions in Lashe (the HQ's `Dark1` is the 10 KB one),
2 to 21 for the `.msu`'s, `Glass` and `Dark1` the worst—. That is an
estimate from rates, not a measured play; the measured one is the
draft's, `Close1` (9.3 KB) heard ~13 frames late. The HQ is where it can
happen: its puzzle plays `Item1`, `Blow2`, `Glass` and `Dark1` from action
pages, and they may still wait five seconds after entering.

#### (c) Everything inside the fade, for comparison

That is the old runtime, the "before" columns of the table above: per door
it added, over today's, **+13 to +34 frames without the `.msu`** (8>9 36
against 23, 10>8 43 against 19, 9>11 49 against 15) and **+28 to +85 with
it** (the sectors 98-102 against 15-19, the HQ 98 against 14), in one or
two black ticks of 20 to 100 frames. Even uploaded in pieces at the rate
measured, Lashe's `.msu` packages (~60 KB each) would take some 50 frames
beyond what the fade has room for.

#### The hybrid is mostly what main already does

The fade's frozen ticks already pump the whole package, effects included,
in what each tick has room for (`package_pump_l`, Cardón's); only the
music is forced up on the last black tick, and only the effects the fade
did not reach are left waiting. That is why 8>10 leaves none, 9>8 leaves
one of eight without the `.msu`, and 8>9 leaves all five —map 9's other
songs (23 KB) take the room first—. So "upload inside the fade whatever
it has room for" is today's behaviour; what it has room for is some 3 to 10 KB of
`.msu` effects (one or two of each package) and ~20 KB through the
cartridge per fade, read from
the waiting counts above.

What would go further, sketched and not built:

* **The cartridge's version first, the `.msu`'s later.** Inside the fade,
  each `.msu`-replaced effect goes up in its 6 kHz cartridge version
  (Lashe's packages: 2.5 to 27 KB, most within the fade's ~20 KB); after
  the fade, the `.msu` version replaces it in idle time. An effect played
  early sounds at the cartridge's quality instead of freezing up to ~21
  frames. Cost: a second upload per effect and room planning in ARAM for
  both sizes; the `.msu` versions are fitted to fill the ARAM the music
  leaves, so the smaller one fits in its place.
* **The destination's first effects first**: none in Lashe —nothing plays
  on arrival—, so it would change nothing here; the converter would have
  to tell which effects a map's autostart and parallel pages play in their
  first ticks.
* **A floor for busy maps**: one block per tick even when the tick ends
  past line 180, as long as it ends before the vblank. It would drain the
  HQ in seconds instead of never, at the cost of the pump finishing a few
  lines before vblank on ticks that are already full.

None of this matters for the lag taro felt: on today's main the
transitions with the `.msu` are 10 to 19 frames, and that is the load.

### 2026-11-22, Chajá: where Lashe's frames go, ranked

On today's main (the-advocate `ec672f4c`), a Lashe door costs **10 to 19
extra frames with the `.msu`** and 10 to 32 without it, against 44 to
102 and 10 to 49 before the
`frozen-world-every-turn-re-uploads-the-battle-screens-audio` merge. What
is left, largest first, with what each candidate fix would save per door
and what it costs:

1. **LZ2 in the load's tick: 7 to 15 frames**, every door, with or without
   the `.msu` —background + ChipSet animation 4 to 10 (map 38's 31 KB of
   8-bit tiles the most), grid with its blocks, bytecode and pages 1.5 to
   4.4, sprites 1.5 to 2.7—. The decompressor runs at some 3.5 to 4 KB of
   output a frame here. Draft
   [`a-map-load-still-decompresses-inside-its-tick`](a-map-load-still-decompresses-inside-its-tick.md).
   * *Store the big maps' streams raw and DMA them*: saves ~12 of the 13
     to 15 frames on the sectors (26.7 KB of backdrop DMA to VRAM is ~0.6
     frames). Costs ROM: backdrop, grid and sprites raw are 28 to 30 KB
     more per sector map than their LZ2 (8: 29.4 KB, 9: 28.2 KB, 38: 27.9
     KB), 206 KB for Lashe's nine maps, and `just space` leaves 18 halves
     of 32 KB (576 KB) in `release` today; every map raw would be ~1 MB
     for the backdrops alone, which does not fit. And a raw path in the
     runtime (ROM to VRAM, ROM to WRAM through `WMDATA`) and a per-map
     choice in the converter.
   * *A decompressor that can stop and go on in the black ticks*: the same
     frames when the black ticks are free, which with the `.msu` they are
     (no music to upload); without it the music competes for them. Cost as
     Cardón wrote it: some 400 bytes in a far bank, its state in far RAM,
     and the load buffer's users in a fixed order across ticks.
   * *A faster decompressor*: not measured.
2. **Without the `.msu` only: the songs the map is not playing, 5 to 16
   frames** on the fade's last black tick —map 9's `cd4` and `C3classi`
   entering it (7.5), and hzstream's neighbours again coming back from the
   HQ (15.4)—. They could wait like the effects and go up whole when a
   `PlayBGM` asks for them (`song_now` already finishes what waits),
   at ~1 frame per KB then: a hitch on the `PlayBGM` instead of on the
   door. New draft
   [`the-fades-last-black-tick-uploads-songs-the-map-is-not-playing`](the-fades-last-black-tick-uploads-songs-the-map-is-not-playing.md).
3. **Placing the package, 0.7 to 2.2 frames** (`package_load_done` before
   anything goes up; 2.2 into the HQ, ten effects). Not looked into.
4. **`code_carry_after`, 0.6 to 1.6 frames**: the most leaving the HQ,
   whose bytecode is 7 KB. Draft
   [`a-door-decompresses-the-whole-bytecode-of-the-map-it-leaves`](a-door-decompresses-the-whole-bytecode-of-the-map-it-leaves.md).
5. **The event pages and the first run, 0.2 to 1**; the window and the
   tint already go in the black ticks (1 to 1.9 frames there, unseen).

And **the audio package is no longer in the transition with the `.msu`**,
and taro's hypothesis does not hold for Lashe: neighbouring maps share no
effect (one, at most, on three pairs), and what they do share —the song
playing, cd4's samples— the runtime already keeps without uploading it
again. "Upload only the difference" would save nothing here. What the
effects cost now is time after the fade (two to three seconds with the
`.msu`, more than five in the HQ), with no gameplay tick longer and no
effect played in that window on these doors; see the draft
[`an-effect-played-while-it-still-waits-is-heard-late`](an-effect-played-while-it-still-waits-is-heard-late.md)
for what a play in that window costs.

Nothing was changed: no fix here is trivial. The cheapest is 2, and it
trades the door's hitch for one on a `PlayBGM`, which is taro's call.

#### What was run

* ABL's `release` built twice in a ports worktree at `cb9f4f5`: with the
  global tools (main) and with `.local-tools` (`project`, `cartridge`)
  from a the-advocate worktree at `63f07a16` (before). Copies in
  `~/scratch/chaja/lashe-lag/rom-main/` and `rom-before/`, the tracks
  hard-linked.
* `measure.py` four times per round (two builds, with and without the
  `.msu`), two rounds, on Mesen2's core; `summary.py` and `post.py` read
  them. `packages.py` (the packages' overlap), `raw.py` and `lz2
  compress` over `build/release/raw/` (the streams' sizes), `just space
  release`.
* No suite: nothing in the tools or the ports changed.
* The book, branch `chaja-lashe-lag` (`09945ae`): a line in ABL's "Known
  issues" for the black that Lashe's doors still hold. Nothing to install
  when merging; the ports and the-advocate have no branch of mine.
