---
name: "The items screen's bar runs ahead of its text"
description: "Moving the cursor on the items screen, the bar is on the new item two frames before the description and the list say so; the equipment screen had the same and was fixed"
type: bug
status: draft
agents: [Calandria]
---

Seen by Calandria on 2026-11-17, in A Blurred Line, with the-advocate at
`7178ceee` (branch `calandria-equip-lag`) and the ports at `8042dc8`.

What was seen: on the items screen of the test page `items-screen` —a
potion, a weapon, the console—, down from the first item: the frame of the
press and the next are neither the screen before nor the one after
(`screens.items`), 367 pixels from the after one: the bar already on the
second row with the first item's description; the after screen whole from
the third frame. The bar moves in the vblank right after the press
—`items_bar`, "the bar moves now, inside this vblank"— and the text arrives
when the text layer has typeset it.

It is what [the equipment screen did](abl-the-equip-screen-s-cursor-runs-ahead-of-its-lists.md),
fixed there by `tl_settled`: the bar follows the cursor in the vblank the
text's tilemap goes up in. Not looked at: the skills screen
(`sk_bar_want`, set as the cursor moves) and the shop (`ti_windows`, every
frame), which draw their bars the same way.

How to reproduce: the frame-by-frame helper of ABL's
`test_menu_equipment_frames_drawing.py`, on the items screen, with
`screens.items(INVENTORY, 0, 0)` before and `screens.items(INVENTORY, 1,
0)` after.
