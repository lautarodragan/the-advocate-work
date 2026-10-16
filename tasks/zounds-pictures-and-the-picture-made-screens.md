---
name: "Zounds: the picture-made screens keep more than two pictures at once"
description: "Zounds builds its menu (map 136), its skill screen (map 190), a race's score board (map 75) and its intro (map 106 'Imágenes') out of ShowPicture; the console keeps two, the ROM does not run the picture pages, and the boot stalls on the intro with the hero stuck"
type: bug
status: draft
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39` and the ports `8a9ab73`.

**Measured**: 266 `ShowPicture` (56 picture files, 31 picture numbers, up
to 50), all with RM2k's 16 parameters —no RM2k3 1.12 features—. The
converter warns on three maps that pictures do not go in because "the
console keeps 2 at a time": 75 "Super Race" (three numbers over: the
digits of a score), 136 "Menu" (`Zounds_Menu_Faces_Kazar`, `Zounds_HP-
Image - N`) and 190 "Skill Screen" (`Zounds_SkillScreen_Skills`,
`Zounds_Face_*`). `ChangeMainMenuAccess` is used 30 times: the game
closes RM2k's menu and opens its own, made of pictures on map 136.

**The boot**: the measuring cartridge passes the title and the harness
says the player has control on map 106 "Imágenes" —no page running—, but
the hero does not move to any side; the map is the picture intro and its
pages use `ShowPicture`, which the ROM does not do (`ACCEPTED_UNDONE`).
Captures of both cores in `/shared/captures/2026-10-15-zounds/`.

**What to decide**: whether Zounds' screens are rebuilt the way ABL's
custom menu was (the book's "The custom menu"), or the picture system
grows past two —the book's "The picture system and the portable
console"—; and how the intro gets past without them.

**Noted on 2026-10-16 (Hurón)**: the boot stalling on map 106 had another
cause too, followed in
[`zounds-the-intro-on-map-106-waits-for-a-key-nobody-reads`](zounds-the-intro-on-map-106-waits-for-a-key-nobody-reads.md)
(in testing). What stays a draft here is the choice above for the
picture-made screens.
