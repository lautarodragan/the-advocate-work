---
name: "A custom menu of our own, not made of pictures"
description: "An addition RM2k doesn't have: describe a custom menu as data (text, lists, a face) instead of pictures of text on white, so that it weighs much less, aligns well and looks better; probably in mode 5 with its own font"
type: feature
status: done
---

From taro, on 2026-10-01, talking about ABL's portable console
(`NewMenuActivated`, `ManageAuraMenu`, `CustomMenu*`, `DisplayNameMenu`):
"many of these pictures are text on a white background, and, at most, a
picture of a character. We could reduce it immensely in size and at the same
time improve it in UX and aesthetics —ABL's custom menu with pictures isn't
well aligned and is aesthetically pretty ugly—". And "there I would use mode 5
and build a typeface specifically for that".

It is an addition of the port, not something from RM2k: the game describes its
menu with pictures and event logic, and this would replace it with a
description of our own. It would serve other games with menus made of
pictures, which are many. The font and mode 5 part comes from
`font-for-high-resolution-or-a-narrower-one.md` (Espinillo) and from Carancho's test
ROM; taro said that on the CRT TV stretched text looks odd, so the font
would have to be designed for that.

The picture system as RM2k uses it comes first
(`plan-the-picture-system-and-the-portable-console.md`): this comes after, on top of that.

## Closed

Closed by taro on 2026-10-12, as superseded: `console-custom-menu.md`
replaced ABL's portable console with a menu described as data
(`abl/menus/consola.toml` in the ports) instead of pictures. Mode 5 and a
font of its own were not part of it; if they come back, they are a task of
their own.
