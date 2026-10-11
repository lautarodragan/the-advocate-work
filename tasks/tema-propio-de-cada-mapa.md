---
name: "Each map's theme"
description: "On entering a map, the theme it carries in its properties plays"
status: done
---

**Make entering a map play its own theme.**

RM2k stores a theme per map in `maps.json` (`music_type`: 0 inherits from the parent, 1 is
decided by an event, 2 is the one the map carries). The converter today reads it **only for the
starting map** —`temas_de_la_rom` in `snes_convert.py`—; in the rest the music
changes only with a `PlayBGM`.

73 maps of the game use it. In `abl`: 16 (`hzbreach`), 21 and 26
(`KSSMKEND`, the Rat Tracks, where taro found it). `lcf.map_music` already resolves the
inheritance.

Done means: entering the Rat Tracks switches to `KSSMKEND`, with a test that checks it.
