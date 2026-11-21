---
name: "A picture's common part stays after it is erased"
description: "When several drawings of one place share a picture number, their common part is drawn into the map and stays there after the game's ErasePicture; in Desert Nightmare, the treasure's plate (map 115) and probably the shrine's (161)"
type: bug
status: todo
game: desert-nightmare
---

Found on 2026-11-20 with Aguará's `aguara-dn-intro-menu` (the start menu
shows its choice): when every show of a picture number on a map is one
of several opaque drawings of the same place, the converter draws what
they have in common into the map, and each `ShowPicture` shows only its
own part as a small picture that goes with the map. Desert Nightmare's
start menu (map 1, `Introauswahl_1..3`) is the case it was made for.

The rule also takes maps 115 (`Tresor_Bild1..6`) and 161
(`Schrein_Zahl0..9`), and there the common part —the plate— stays drawn
after the game's `ErasePicture`, as it already did before the rule,
when the most-shown picture was drawn into the map whole. Neither map was
looked at on screen.

taro, the same day, translated, when this was described as where the
optimisation stops being lossless:

> This is a bug, then.

So it is not a limit to document but something to fix: the common part
has to go away when the number is erased, and come back when it is
shown again. Whoever takes it measures what it costs first —the common
part as its own layer of the map that can be dropped, or as small
pictures too, or redrawing the cells it covered from the map without
it— and looks at 115 and 161 against Wine or EasyRPG before and after.

## Note (2026-11-20, Aguará)

Since the-advocate `d1972f68` (branch `aguara-dn-intro-menu`) the rule no
longer takes 115 and 161: it splits only numbers every show of which
comes from an autostart or parallel page, and the locks' pictures come
from pages the action key starts. Both were looked at on screen against
RPG_RT under Wine (`/shared/captures/2026-11-20-dn-intro-and-file-screen/locks/`):
they are drawn in as before the rule, one symbol frozen in the room, the
draft `desert-nightmare-the-locks-pictures-are-drawn-into-their-rooms`.
Today no number of any port is split and erased, so this bug has no case
on screen; map 1 never erases its menu. **So no captures here**, of 115
nor of 161: at `e4bbee1e` neither shows this bug —what they show, a
symbol frozen in the room and a lock that never opens, is in that draft,
with the ROM and RPG_RT side by side—.
