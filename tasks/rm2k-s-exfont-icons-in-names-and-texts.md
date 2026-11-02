---
name: "RM2k's ExFont icons in names and texts"
description: "A `$` and a letter in a name, a description or a message is one of RPG_RT's ExFont icons; the port draws the two characters, and Zounds uses them throughout its items and skills"
type: feature
status: doing
assignee: Hurón
agents: [Hurón]
---

taro, on 2026-11-02, in their words, translated:

> Could you make the build process remove all the special characters we
> can't process yet? Or add them to the runtime, if possible. Zounds uses
> them a lot in items (`0061: $NUltra Poción Roja`, for example — the
> `$N` I think turns into an icon, out of RPG Maker's font).

RPG_RT draws `$A`–`$Z` and `$a`–`$z` as the 52 icons of its ExFont
(easyrpg's `font.cpp` and `exe_reader.cpp`, which can read a game's own
from the `RPG_RT.exe`). Counted by Hornero with a loose `\$[A-Za-z]`
over each port's `data/` (false positives possible): Zounds about 230
—items 117, skills 57, maps 40, common events 11—, Vampires Dawn 30,
Frozen World 6, ABL 4, The Book of Three 3.

**Done**: every screen that draws a name or a text —message boxes, the
menu, items, skills, shops, battle— shows the icon where RPG_RT does, or,
where it cannot, drops the code instead of drawing `$N`; what is dropped
is written in a divergence and in each port's Known issues. Where the
icons come from (the game's exe, EasyRPG's free ExFont, its licence) is
the first thing to settle.
