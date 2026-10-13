---
name: "The 2000 RPG_RT runs under Wine"
description: "The book's End Game divergence says the 2000 RPG_RT crashes under Wine; on 2026-10-13 it ran ABL's title fine, so what was measured only with the 2015 one can be measured with the one the author used"
type: research
status: done
---

Seen by Tijereta on 2026-10-13, with the-advocate `28ba001f` and the docs
`42684da`, while measuring the title menu
([the-title-menu-in-a-system-window](the-title-menu-in-a-system-window.md)).

**What is seen**: `divergences/what-the-end-game-screen-does-not-model.md`
in the book says the 2000 RPG_RT "could not be looked at: under Wine it
crashes when changing the video mode". With the prefix of the Wine recipe
—its virtual desktop of 640x480— and the `Harmony.dll` that sits next to
the game, `wine RPG_RT.exe` in a copy of ABL's Wine directory showed the
title and its menu, the same window as the 2015 one with the 2000 font.

**What it opens**: the End Game screen's starting cursor —"Yes" in the 2015
RPG_RT, "No" in easyrpg— can be measured with the runtime the author used,
and so can anything else that today is decided with the 2015 one.

**How to see it**: copy ABL's Wine directory and prefix, and run
`RPG_RT.exe` instead of `RPG_RT_2015.exe` with the same environment.

## Done

taro, on 2026-10-13: the RPG_RT runs under Wine, and so does RPG Maker,
and both have been used here for a while; the sentence was stale, wrong
and confusing. Removed from the End Game divergence in the book.
