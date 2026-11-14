---
name: "The music's loop, like RM2k"
description: "Neither of the two paths loops like RPG_RT: the MSU-1 goes back to 0 after 2-6 s of fluidsynth tail; without MSU-1 it cuts at the last note; neither skips the initial silence nor reads CC111"
type: bug
status: testing
assignee: taro
agents: [Hornero, Tijereta]
---

Measured on 2026-10-11 by Hornero, at taro's request, in their words, translated:

> we still have the music loop issue on the msu pending, and I don't
> know whether we already do it right without msu or not

With `abl.sfc` `24dd24ad…` and the tools at `6f933ff8`.

**What RPG_RT does**, according to easyrpg-player (`src/midisequencer.cpp`, `audio_decoder_midi.cpp`): on finishing —the MIDI's last event, not the last note— it goes back to the loop mark, a Control Change 111 on any channel, or to the start if there is none. The first time it skips the silence at the start and begins at the first note, unless there is a SysEx before it; on looping back, it doesn't.

**Without MSU-1** (`midi::timeline`, `stream::writes`, `music_frame` in `runtime/music.s`): the song ends with its **last note** and goes back to the start, silence included. Against RM2k: it doesn't skip the initial silence the first time, and songs with a silence between the last note and the end of the track lose it, so the bar of the loop comes out short. It doesn't read CC111.

**With MSU-1** (`tracks.rs`): the track is the whole MIDI rendered with fluidsynth and the loop point is always 0. ABL's tracks last **2 to 6 s longer than their notes**: the release and reverb tail that fluidsynth adds, which on looping remains as a gap before the song starts again. `escape_newyork` has 29 s extra, to be looked at separately. It doesn't skip the initial silence or read CC111 either.

**How much it weighs in each game** (MIDIs with more than half a quarter note of silence at the start / with more than a quarter note between the last note and the end / with CC111):

    ABL              222   52   9   0
    Dooms 2           53   22   8   3
    Frozen World      73   23   8   0
    Book of Three     67   35  12   0
    Sunset             8    7   0   0
    El Dorado          3    2   0   0
    Desert Nightmare   1    0   1   0

One of ABL's MIDIs, `dgate008.mid`, couldn't be read by the measurement script —the converter does read it—, and VD's wasn't measured.

What it would take: the length up to the end of the track, not the last note; CC111 as the loop point in both paths —in the stream, a jump back to a position instead of to the start; in the MSU-1, the loop point in samples—; skipping the initial silence the first time; and in the `.pcm`, cutting fluidsynth's tail at the loop point. Trimming that also shrinks the `.pcm` files.

## How the tail goes in the `.pcm`, with taro

taro, on 2026-10-11: cutting the tail abruptly would sound ugly. In their words, translated:

> we'd have to have a version of the start of the song that has the tail
> of the end and loop from 0 + len(tail)

That's how it is done: render the pass and, without resetting the synthesiser, the beginning of the next one —fluidsynth with the MIDI twice and `player.reset-synth=0`—, end the track at E + D and put the loop point at L + D, with E the end of the first pass, L the loop point (CC111, or 0) and D how long the tail lasts, with margin. After D seconds the previous tail has already died out, so E + D and L + D sound the same and the jump isn't heard; the tail of the first pass sounds whole, stuck onto the beginning of the second. With the initial silence skipped (length S), the loop point is `max(L + D, S)` counted from S. Without MSU-1 nothing is needed: the stream is made of notes, and the DSP's reverb carries on through the loop.

## First step: the MSU-1's basic loop, on `hzstream` (taro, 2026-11-14)

taro, on 2026-11-14, in their words, translated:

> The MSU one has an extra complexity, because we would have to bake the
> tails of effects or instruments. But, for an initial test, I'd like to
> simply try the basic loop, even if it abruptly cuts the tail of some
> notes or effects.
>
> In particular, the theme I'm using to test is hzstream — the one that
> plays when you start the game with Talan, after the intro. The
> original RPG_RT loops it with no silence between loops. I don't know
> whether it hooks exactly with the bar, but at least it feels that way.
> It doesn't feel like a bar is left abruptly cut.
>
> On the SNES with the EverDrive and MSU, instead, when the theme ends
> there's ~1 bar of silence (and it doesn't feel like an exact bar, but a
> little less or more, which makes it sound even worse).
>
> […] We can limit it to the MSU, and even limit it to hzstream if it
> helps, in a first stage.

So the first stage is the MSU-1 only: the track's loop as RPG_RT's
—the end of the MIDI's track, not fluidsynth's tail; the loop point at
CC111 or the start; the initial silence skipped the first time—, with
the tail cut abruptly if baking it is not done yet. The baked tail of
the section above is the next stage.

## The MSU-1's basic loop, by Tijereta (2026-11-14)

From the-advocate `ec3486d6`, the ports `b5d284f`, the book `95186bc`,
on branches `tijereta-msu-loop`.

**`hzstream`, measured before**: 120 bpm in 4/4, 5760 ticks at 48 per
quarter —30 bars, 60.000 s—, first note at tick 3 (0.031 s), no CC111, no
SysEx; the end-of-track of its last track is at tick 5760, a hair after
its last note-off (59.990 s). The track at `release` from 2026-10-20 is
2,734,592 frames, 62.009 s, loop point 0: the sound stops dead at 60.00 s
—the RMS of every 100 ms window after it is 0.0, its notes do not ring
on— and **2.009 s of digital silence** follow, one bar and 9 ms. That is
the gap taro hears.

**Where the 2 s come from**: fluidsynth's player does not stop at the
end-of-track but two seconds after the end-of-track or after the last
voice dies, whichever is later —measured with a one-note MIDI: note-off
at 1.0 s and end-of-track at 1.5 s render 4.80 s, the release fading out
at 2.8 s; end-of-track at 3.0 s and the note's release over at 2.3 s
render 5.00 s—. The release goes on after the end-of-track: fluidsynth
does not cut it.

**The runtime needs nothing**: `msu_start` in `runtime/msu1.s` writes
`$03` to `MSU_CONTROL`, play and repeat, and the MSU-1 goes back to the
`.pcm` header's loop point. Only the `.pcm` changes.

**What was done** (the-advocate `0e5281da`, the ports `46f68ea`, the book
`a611a83`): `rm2k-snes-msu` cuts a MIDI's render like RPG_RT, for every
game's tracks —it is the same code—. The MIDI reader collects, as easyrpg
does, the file's last event (the end-of-track), the last CC111 and the
first of note-on / CC111 / SysEx `F0`; `Midi::rm2k_loop` turns them into
seconds, and `rm2k_cut`, in `tracks.rs`, cuts the render: from the start
of the first pass to the end-of-track, loop point at the CC111 counted
from that start. A song without CC111 whose first pass skips its leading
silence carries that silence at the **end** of the track, with what
fluidsynth rendered there, and loops to 0: the same sequence as RPG_RT's.
The tail is cut at the end-of-track. Tracks from an audio file keep
looping at 0.

**`hzstream` after**: 2,646,000 frames, exactly 60.000 s —30 bars at
120 bpm—, loop point 0, and its first 60 s byte for byte the old track's.
The silence at the join, below |64|: **2.042 s before, 0.033 s after**
—3.7 ms of the last note's release and the 29 ms before the first note,
at tick 3, which RPG_RT also plays on every loop, since it goes back to
tick 0—. The bar lines up: the period is the MIDI's 5760 ticks and the
loop goes to tick 0, give or take fluidsynth's 64-frame (1.5 ms) event
quantum. Two RTP songs in ABL carry a CC111 and now loop to it:
`GameOver3` at 0.41 s of its track and `Farewell2` at 0.45 s. 36 of
ABL's 224 MIDIs skip some silence on the first pass —`RollingThunder2selection`
2.1 s, `pfdialog` 1.5 s—.

**The cache**: the track's key in `build/cache/msu/` carries the sha256
of the running `rm2k-snes-msu` (`own_version` in `tracks.rs`), so any
checkout that installs the new binary remakes its tracks without
touching the key. Not watched happening: the worktree's `build/` started
empty, so its first build made all 106 of `release`'s anyway.

**Tests**: three of `rm2k_cut` in `tracks.rs`, red against the old
whole-render behaviour, and four of the reader in `midi.rs`. In ABL,
`test_with_msu_the_track_loops_without_a_gap` in `tests/abl/test_msu.py`
plays the new case `song-hzstream` with MSU-1 in snes9x and asks that no
silence across the loop reach a quarter of a second: red with the old
track (2.04 s), green with the new one. It is the only ROM test of a
loop; the CC111 path and the skipped silence are only covered by the
crate's tests, and no ROM test listens to them.

**Audio for taro**: `/shared/audio/2026-11-14-msu-loop/`,
`hzstream-join-before.wav` and `hzstream-join-after.wav`: the last 8 s of
the track and the first 8 s after the loop point, as the MSU-1 plays
them; the join is at 8.000 s.

### What baking the tail would take (the next stage)

Measured with fluidsynth 2.6.0: rendering the MIDI twice in one call,
`fluidsynth -o player.reset-synth=0 … song.mid song.mid`, the second
copy starts exactly at the first one's end-of-track, and the first one's
release rings on over it —a one-note MIDI with the note-off at 1.0 s and
the end-of-track at 1.5 s: the second note sounds at 2.0 s, and the
release of the first fades out at 2.8 s—. So for a song **without
CC111**, which is every one of ABL's, it is little: render twice, cut at
`E + D` and put the loop point at `max(D, S) − S`, with `D` how long the
first pass's tail lasts after `E` —measurable from the same render, with
fluidsynth's two seconds as the ceiling—. It costs a render of twice the
length and `D` more seconds of track. A song **with CC111** needs the
second pass to start at the CC111 with the state the song has there,
which a playlist cannot do: a MIDI rewritten from that tick, with the
program, controller and tempo events before it folded in at its start.
For `hzstream` baking changes nothing: its notes are already silent at
the end-of-track.

**Suite**: ABL's, with `rm2k-snes-audio` from `.local-tools`: 1640
passed, 2 skipped; no golden moved. `abl.sfc` `e756e06a…`. With
`NO_CACHE=1 just cartridges --force`, the 126 `.sfc`, `.msu` and `.pcm`
of `release` and `build/tests/` came out byte for byte the same as the
cached build.

**To install when merging**: `just install rm2k-snes-audio`, from
`~/the-advocate` —it carries `rm2k-snes-msu`—. The tracks of every game
rebuild on their next `cartridges`.

**For taro to check by ear**: `hzstream` on the EverDrive, after the
opening with Talan, past the 60 s mark; and the two wavs above.
