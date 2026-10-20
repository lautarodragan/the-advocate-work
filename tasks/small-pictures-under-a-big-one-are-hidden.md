---
name: "Small pictures over a big one are hidden, and two big ones are one"
description: "Zounds' skill screen (map 190) puts its selectors and a face over a full-screen picture and a tall skill list: the background layer holds one big picture and hides the map and the small ones"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

Seen by Tijereta on 2026-10-16, with the-advocate `9407d385` plus the
branch `tijereta-more-pictures`, while measuring
[`zounds-pictures-and-the-picture-made-screens`](zounds-pictures-and-the-picture-made-screens.md).
Read from the converter's log, not played.

**What it is**: Zounds' map 190, the skill screen, shows
`Zounds_SystemBox_Pic` (320x240) under everything, `Zounds_SkillScreen_Skills`
(167x227, placed by variables, which scroll it) and over them two
selectors of 170x41 and a 48x48 face. The box and the list are too big for
the objects and go to the background layer, which holds one at a time and,
while it is up, hides the map and every small picture
(`divergences/what-large-pictures-do-not-model.md` in the book). The four
small ones go in since the branch above —"the pictures 'Zounds_SysSelector,
Zounds_SysSelector_Bright, Zounds_Face_Unamë, Zounds_Face_Kazar', 49
objects in 192 tiles, 4 palettes"— but are not seen over the box.

How to see it: build Zounds' `release`; the converter's log says "map 190:
the picture 'Zounds_SkillScreen_Skills' is 133x211 on the console: bigger
than the plane of objects". The book's research "More pictures at once",
option 4, weighs what it would cost.
