---
name: "Plan: the picture system and the portable console"
description: "What ABL's portable console uses (ShowPicture, MovePicture, autostart and parallel common events, the controller input), how many pictures and of what size, how to draw them in mode 3 and what freezes while they are shown; to derive the tasks from there"
type: research
status: done
assignee: taro
---

From taro, on 2026-10-01: he is interested in `ShowPicture` and "the whole
portable console system" —ABL's own menu, made with common events and
pictures—, because it is useful for custom systems in many games. He said
using the MSU-1 is acceptable; with 46 free banks of 64 KB and the game's
pictures estimated at ~430 KB with LZ2, Hornero thinks they fit in the ROM
without breaking `decisiones/el-juego-se-juega-sin-msu-1.md`.

taro's idea for drawing them in mode 3, which has two layers: "in practice
most ShowPictures prevent moving while they are shown. I don't know if they
freeze other things, like event movements or animated tiles, but I wouldn't
rule out the possibility of baking the picture or map layers at runtime, or
not showing events while a picture is shown. It isn't something that always
works, but I think in many cases it does".

Our own custom menu, with mode 5 and a font, went to the wishlist:
`custom-menu-of-our-own-not-made-of-pictures.md`. This comes before: the pictures as RM2k uses
them.

## The study (Jilguero, 2026-10-01)

It is in [`docs/research/2026-10-01-el-sistema-de-imagenes.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-01-el-sistema-de-imagenes.html), measured on
`76d98bed`. What taro has to look at to decide:

* **The portable console is not needed to play**: what it writes is read by
  nobody outside it. Item 81 opens it. The old menu (commons 11 to 20 and 34)
  is dead: nobody opens it.
* **What it asks for besides the pictures**: autostart common events (not the
  parallel ones), `Label`/`JumpToLabel`, a shared `CallEvent` —pasted in
  place, the menu is 140,193 commands— and `\V[n]` in three messages.
* **Drawing**: two planes. Objects for the small stuff over the map —with the
  events hidden when the map leaves no room—, and BG1 in mode 1 for the big
  stuff with the map hidden, with no extra VRAM. They cover 20 of the 21
  situations of the scenes and the whole console, with a black frame on its
  text pages. Debts: the translucent montage of 217, the opaque smoke and
  shadow, the zoom of the four *Diff* photos as a fade.
* **Space**: ~330 KB with LZ2, 5 or 6 of the 46 banks.
* **Order**: first the scenes (phases 1 to 3 of the study), then the console
  (4 to 6), then our own menu from the wishlist.

The tasks that come out of it are in section 5 of the study, with their order;
they were not opened in `todo/` so that taro picks the plane first.

No code changed: there is nothing to install when merging. `just pruebas` was
not run —only a `.md` in `docs/research/` and this task change—. No captures
were taken with RPG_RT under Wine: the game's pictures were enough to measure.
