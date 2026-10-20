---
name: "Desert Nightmare's title is silent without MSU-1"
description: "The title's song, music13, only has an MSU-1 track, so without MSU-1 the title plays nothing"
type: bug
status: draft
---

Seen by Chajá on 2026-10-16, at the-advocate `3996ed61`, while making the
title the first thing heard
([`the-first-map-shows-before-the-title`](the-first-map-shows-before-the-title.md)):
Desert Nightmare's title song, `music13`, is built only as an MSU-1 track,
so a cartridge played without MSU-1 has a silent title. It was so before
that change. Why `music13` has no SPC700 version (an MP3 or WAV the
SoundFont path cannot play?) was not looked at.

## Checked (2026-10-20, Tijereta)

Why it has no SPC700 version: `Music/music13.wav` in `desert-nightmare.zip`
is a WAV —so is `musicpiano.wav`—, and the SoundFont path plays only
MIDIs. The release build of the ports `68bf55b` still gives it "0 s, 1 B
of stream". It is Zounds' case, which a MIDI next to the WAV under the
same name solved in the game's clone. Desert Nightmare is read from its
`.zip`, and `patches/manual/files/` (the-advocate `cb56d918`) replaces a
file by its name **without extension**, so a `music13.mid` there would
take the WAV's place for the MSU-1 track too: not checked whether it
can sit next to it instead. And which MIDI —a stand-in from the RTP, as
Zounds' victory, or another— is a call for taro.
