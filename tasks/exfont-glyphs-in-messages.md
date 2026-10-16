---
name: "ExFont glyphs in messages"
description: "RM2k draws `$` plus a letter as an icon from the System's ExFont; the converter prints it as text. Seen in Vampires Dawn: a sign reads \"$s Graveyard\""
type: bug
status: wishlist
---

Seen by Cardón on 2026-10-12, in the captures of
`changesystemgraphics.md` (the-advocate `8231f7c7`), and not looked into:
a sign in Vampires Dawn, reached with the harness's teleport, reads
**"$s Graveyard"**.

In RM2k, `$` followed by a letter (`$A`-`$Z`, `$a`-`$z`) in a message is
not text: it is one of the 52 icons of the ExFont, the 12x12 symbols the
engine carries —a sword, a heart, a note…—. EasyRPG draws it as a glyph
(`window_message.cpp`, the `$` escape, and `Text::Draw` with
`is_exfont`, in `~/ref/easyrpg-player`). Our text pipeline doesn't know it
and prints the two characters.

Not measured: how many messages use it, in which games, and which glyphs.
`grep` over each game's `data/` is the first step. What doing it asks for
is a glyph per icon used in the font —`rm2k-snes/text/`— and the
converter recognising the escape; if few are used, only those.

## Defined (2026-10-16, Carpintero)

Cosmetic: two characters in a message; nothing stops. **Done**: `$` plus
a letter in a message is drawn as its ExFont icon, for the icons the
games use, with a golden of a message that carries one. **First step**:
the grep over each game's `data/` for `$[A-Za-z]` in messages, which says
how many icons the font needs; if it is many, it becomes `todo`.
