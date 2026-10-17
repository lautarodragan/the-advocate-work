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
