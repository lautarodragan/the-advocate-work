---
name: "The music's loop, like RM2k"
description: "Neither of the two paths loops like RPG_RT: the MSU-1 goes back to 0 after 2-6 s of fluidsynth tail; without MSU-1 it cuts at the last note; neither skips the initial silence nor reads CC111"
type: bug
status: doing
assignee: Tijereta
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
