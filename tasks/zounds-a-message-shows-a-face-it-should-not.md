---
name: "Zounds: a message shows a face it should not"
description: "Sometimes a message or a choice shows the face of an earlier message, as if an erase-face that RM2k runs was skipped; it depends on the game's state, not on the command: the save point's choice shows Uname's face after a chest's message and not other times"
type: bug
status: testing
assignee: taro
agents: [Carpintero]
---

taro, on 2026-10-19, playing Zounds (delivery of that day, the-advocate
`54ec3daf`, the ports `c2912ad`): "sometimes they show up when they should
not. It is not constant, so I think it depends on the game's state and not
on the command itself. Maybe there is a `hide face` we are not running,
sometimes, and the next message comes out wrong. It is not impossible that
it is a bug of the original game, but I suspect ours, from the patterns I
saw."

Four screenshots, in this order, in
`/shared/captures/2026-10-19-zounds-faces/` (and `~/scratch/hornero/faces/`):

* `18.png`: the save point's choice —Guardar / Salir del Juego / Ver
  Estados / Nada, from a common event— with the green-haired face.
* `19.png`: a chest's message, "Has encontrado: Poción Roja x2, Poción
  Verde x1", with the same face.
* `20.png`: the same choice, without a face (as it should be, presumably).
* `21.png`: the same choice with the face again; the hero is green there.

## Log

taro adds, the same day: it is not always with the save menu; they think
they saw it in other cases too. So the search is for the general
mechanism —face state that survives where RM2k erases it—, not only the
save point's common event.

### The cause (Carpintero, 2026-10-19)

Not the original's bug: ours. RM2k's face is `Game_System`'s, but the
foreground interpreter clears it as it starts an event and as it finishes
one —`Game_Interpreter::Push` and `OnFinishStackFrame` in easyrpg, both
with `main_flag`, at the bottom of the stack and outside a battle—, and
`Scene_Battle`'s constructor clears it as a battle starts. Parallel pages
do not clear it. The console only cleared it at reset and on a nameless
`ChangeFaceGraphic`, so a face lasted until some page cleared it by hand.

In Zounds most pages that set Uname's face never clear it: map 17's
autostart, event 1, page 1 sets it and ends; so the chest, event 5, and
the save point, event 2, whose pages name no face, drew his. A few pages
clear it at their end —the bed's, event 8, page 4—, and after one of
those the choice had no face, as in `20.png`: "it depends on the game's
state" was whether the last page to touch the face had cleared it. It is the general mechanism taro suspected, for every page of every
game that shows faces, not only the save point's.

Checked against easyrpg's source, not under Wine.

### The fix

* the-advocate, `carpintero-faces`: `face_forget` in `message_face.s`,
  called from `start_waiting` and `common_start` —a foreground page's two
  starts—, from `events_tick`'s loop when the page ends, and from
  `battle_run`. A box already up keeps the face it opened with.
* the-advocate-ports, `carpintero-faces`:
  `test_a_page_that_names_no_face_shows_none` in `tests/test_zounds.py`,
  map 17's own path: the autostart's boxes draw the face, the chest's box
  and the save point's choice draw none. Red before the fix —the chest drew
  the face on the left—, green after.
* the-advocate-docs, `carpintero-faces`: "What faces do not model" said the
  face lasts until a nameless command; it says what RM2k does now.

Left as a draft: the compiler still lays out a box before a page's first
face command for a face, in a game that shows faces —
`a-box-before-any-face-command-is-laid-out-for-a-face`—: narrower lines,
nothing lost.

### Verified, and what to install

On the branches, with `cartridge convert project` installed locally (the
runtime goes in with `cartridge`; nothing in Rust changed): `just test` in
the-advocate, 29 passed; ABL's whole suite, 1577 passed and 2 skipped;
`just boot` from the ports' root, 68 passed, Zounds' whole file included;
the test game, 45 passed and 1 skipped. Main had not moved from `54ec3daf`
and `c2912ad` when this was written. The change is runtime only, so
merging it needs no reinstall: the installed tools assemble the runtime of
the checkout they were installed from, `~/the-advocate`, as it is on disk.

What the suite does not cover: the clear when a battle starts, and the
one at the start of a foreground page when the face was set by a parallel
page or a battle page; the test only plays the page-end clear and the
start of the chest's and save point's pages. Played in snes9x only.

Captures, before (taro's) and after, in
`/shared/captures/2026-10-19-zounds-faces/` and
`/shared/captures/2026-10-19-zounds-faces-fixed/`.
