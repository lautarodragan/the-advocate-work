---
name: "Music on the SPC700"
description: "A sequencer on the SPC700 instead of the 65816"
type: refactor
status: wishlist
author: hornero
---

# What

Have the SPC700 play the music instead of the 65816: a small sequencer that
reads **today's same stream** from a ring buffer in ARAM, at its own pace, and
that the 65816 only keeps full. Sound effects would move there too.

# Status

Noted, not started. Agreed with taro on 2026-09-11 as the next step.
It is **not** a sequencer on the SPC700 like those of commercial games, and
the converter doesn't change.

It gets tackled when the loop's headroom is needed, or if on the console the
audio shows something the emulator doesn't.

# Why

Today the 65816 plays the music from an IRQ —see `internals/events.md` in
the book— and it works, but it costs **up to twenty lines per frame** and
imposes the interrupt's rules. With MSU-1 the SPC700 plays no music and
this matters less; without it, it still does, and the game has to play
whole without MSU-1. Kept in the wishlist by taro on 2026-10-12.

## Log

### 2026-11-17, Hornero: reviewed

Still not started: the 65816 sequences the music (`irq_music`,
`music_tick` in `runtime/music.s`; the stream in
`rm2k-snes/bytecode/src/music.rs`). One number above is wrong: the cost is
not "up to twenty lines per frame" —`quality-of-the-music.md`
(2026-09-26) measured the worst frame at 89 lines, about 1.0 + 1.34 lines
per write + 1.27 per voice event—. A sequencer on the SPC700 would need
an ARAM ring buffer reserved in each package's budget.

### 2026-11-22, Chajá: still applies

Checked at the-advocate `0ae40e0a`: nothing moved since Hornero's review.
`runtime/music.s` and `runtime/spc700.s` were last touched on 2026-10-19
(`804895df`); `irq_music` still expands the stream into DSP writes on the
65816, and the SPC700 still runs the minimal driver that waits for
(register, value) pairs —`DRIVER` in
`rm2k-snes/rm2k-snes-audio/src/spc700.rs`, as the header of `spc700.s`
says: "all the music is still driven by the 65816"—. Not started, and no
task since asked for the loop's headroom it would free. Stays in
wishlist.
