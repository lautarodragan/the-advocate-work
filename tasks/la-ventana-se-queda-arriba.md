---
name: "The message window stays at the top"
description: "While playing, the window started staying at the top all the time —and the timer at the bottom— with Lashe City NPCs who in the original talk at the bottom"
type: bug
status: done
assignee: Calancate
---

From taro, on 2026-10-04, with the build `2026-10-04-5b29ba9-f6a44973`: "at
some point it started staying permanently at the top, and the timer, at the
bottom. I think it should have gone back to the bottom at some point". The Bum
next to Talan's house, the worried worker, the hover tram officer, several
NPCs on the left side of Lashe City, the Neon Vipers: all at the top.

It comes from `la-ventana-arriba-al-medio-y-sin-fondo.md` (Quirquincho). A
candidate, unconfirmed: common 15, `CustomMenuSideQuests`, ends with
`MessageOptions [0,0,0,0]` —top— and the console's other menus with
`[0,2,0,0]`.

## It is not a bug: the original does the same (Calancate)

taro confirmed it playing the original: "I'm testing the original and it
seems it really is like that". What leaves it at the top, read in ABL's dump
at `5b29ba9` and in easyrpg-player:

* **The Neon Vipers scene is the first to put it at the top**: map 14
  (`NV Get Talan to Work`), event 2 `SceneDriver`, autostart. Its command 120
  is `MessageOptions [0,0,0,1]`, for "LAZER TEETH LOOKOUT", and 124 leaves it
  at `[0,0,0,0]` —top, fixed— right before moving to map 16, the run to work,
  which has no `MessageOptions` at all. That is why that run's timer is at the
  bottom.
* **And in Lashe City almost everything leaves it at the top again**. On maps
  8 and 9, the signs do `[1,0,0,0]` and then `[0,0,0,0]`. The Bum opens his
  page 1 with `[0,0,0,0]`. The events that move it to the bottom for a while
  (EV0013, the kids, EV0004 on 9) end up going back to `[0,0,0,0]`. For the
  author, the top is the normal place in that area. The only one that leaves
  it at the bottom is page 2 of the `DetourOfficer` on map 8, with
  `[0,2,1,0]`. The NPCs without `MessageOptions`, like the Tram Officer or the
  UpsetWorker, talk wherever it was left.
* **Common 15 is not needed**: it ends in `[0,0,0,0]`, but the window was
  already at the top without opening the console.

Against easyrpg-player:

* **The option persists the same way**. `CommandMessageOptions` stores it in
  `Game_System` (`message_position` and `message_prevent_overlap`), which is
  part of the save and is not reset on changing maps. liblcf defaults to
  bottom and moving aside. Ours is `FAR_MSG_OPTIONS`, in the save, which
  `msg_place` only reads: the moved position goes to `MSG_PLACE` and is not
  saved. The compiler translates `p[2] != 0` to `MSG_DODGE`, which is the
  inverse of `SetMessagePositionFixed(p[2] == 0)`, as it should.
* **The timer goes to the bottom too**. `Sprite_Timer` moves it down when the
  window has `GetY() < 20`, whether it shows or not: "RPG_RT doesn't check
  for the global setting … just checks for the Y position of the message
  window, regardless if it is active or visible". `timer.s` looks at
  `MSG_PLACE`, the last window, and does the same.

Neither code nor goldens changed. Neither Wine nor any ROM was run: the dump
and easyrpg-player's source were enough, plus what taro played.
