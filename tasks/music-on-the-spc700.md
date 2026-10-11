---
name: "Music on the SPC700"
description: "A sequencer on the SPC700 instead of the 65816"
type: refactor
status: wishlist
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

Today the 65816 plays the music from an IRQ —see "La música no espera al lazo"
in `docs/port/events.md`— and it works, but it costs **up to twenty lines per
frame** and imposes the interrupt's rules.
