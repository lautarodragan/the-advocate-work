---
name: "Latin-1 letters stop a box"
description: "A text box with a letter outside printable ASCII —é, ñ, ¿, ü, ß, …— leaves its whole page out: it is most of what Zounds and Vampires Dawn lose of their messages"
type: feature
status: doing
assignee: Aguará
agents: [Mulita, Aguará]
---

Seen by Mulita on 2026-10-15, measuring
[`unknown-message-escapes-are-dropped-with-a-warning`](unknown-message-escapes-are-dropped-with-a-warning.md),
with the-advocate `6fa69781` and ports `f015801`.

**What happens**: `Messages::store`, in `rm2k-snes/events/src/messages.rs`,
stops the page of any box with a letter the console's font does not have,
and the font is printable ASCII; RM2k's has Latin-1. It is on purpose
(`a_letter_the_font_does_not_have_stops_the_page`), but games in Spanish
and German lose most of their talking pages to it.

**Measured**, the map pages out only by their message commands, and of
those the ones out only by such a letter (each game's `release`,
`just culprits`, the culprit message commands classified by a throwaway
script):

* Zounds (Spanish): 919 of 965, and the other 46 by a letter and something
  else. Letters: `é á ¡ ë ¿ ó í ñ ú É ô ü î â Ó û Á ä`. The hero is called
  `Unamë`, so every box with `\n[1]` is out too.
* Vampires Dawn (German): 162 of 378 before the escapes change; 638 culprit
  boxes carry `ü ö ä ß Ü Ä Ö`.
* Desert Nightmare: 7 pages, 12 boxes (`ü ä ß ö`).
* Sunset over Imdahl: 4 pages (`ä`, `…`, `ô`).
* El Dorado: 1 page (`ä`).

**To reproduce**: build a game's `release` and run `just culprits` in its
directory; the culprit `ShowMessage`s are the ones with those letters.

**It is where Zounds' intro stops** (Aguará, 2026-10-16, the-advocate
`1a97c8ca`): once map 8 "To King's Room" stopped going black
([`zounds-the-screen-goes-black-up-the-stairs-after-the-guard`](zounds-the-screen-goes-black-up-the-stairs-after-the-guard.md)),
its autostart —event 3, Uname's talk with the two guards, which teleports
to map 9— is left out whole by its message boxes alone (`é ¿ ¡ ë`), so the
player walks on map 8 and the story does not go on.

**Taken by Aguará on 2026-10-16** (Hornero), as the next thing that blocks
Zounds: first the box shown with each such letter as its plain ASCII
neighbour and a warning, so the pages run; then the letters drawn for
real, if the font has room.
