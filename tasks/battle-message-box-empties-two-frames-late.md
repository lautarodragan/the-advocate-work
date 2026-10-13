---
name: "A battle message box empties two frames late"
description: "When A closes a troop page's message, the battle's message window still shows its text for two frames; RM2k empties it at once. Seen next to a FlashScreen, which starts on the first of those frames"
type: bug
status: draft
---

Seen by Chajá on 2026-10-12, with the-advocate `5238c200` and the ports
`3952062` (`monster-conditions-and-flashscreen-in-battle.md`), in ABL.

**What is seen**: in a troop page that shows a message and then does
something on screen —`Inscribe`'s wall of bark, a message and then a
`FlashScreen`—, pressing A closes the box, the page goes on in that same
frame, and the flash shows on the next one; but the message's text is
still in the window for two frames, under the flash. In the original under
Wine the window is already empty on the first frame of the flash. The
golden `battle-inscribe-flash-1` of
`tests/rpgmaker/test_battle_flash_golden.py` holds it that way.

**How to see it**: the `battle-inscribe` case, frame by frame from the A
that closes "TALAN inscribes a glyph of power": the lower band of the
screen still has the text on the first two frames after the A —the flash
already shows on the second— and is empty from the third. It
looked like the text layer's own pace —it clears a row per budget—, not
measured.
