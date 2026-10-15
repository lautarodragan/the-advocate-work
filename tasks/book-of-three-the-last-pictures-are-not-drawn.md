---
name: "The Book of Three: the closing pictures are not drawn"
description: "The pictures the game shows over its last two maps (69 and 72) do not fit any VRAM layout and are left out: those moments of the ending are a plain or black screen"
type: bug
status: draft
---

Seen by Mulita on 2026-10-15, comparing the port with the original under
Wine, with the-advocate `fa9d1a14` (and `362d3765` for
`degradations.json`) and the ports `0ca371b`, in The Book of Three.

**What is seen**: on map 69 the original shows a full-screen picture
(`credits3`) and on map 72 five in a row (`quote1` to `quote4`, `theend`),
each moved in and out; in the port the screen stays as it is under them
—black for most of map 72's—, and the page waits as long as the original.
The game then returns to the title as in the original.

**What the build says**: the converter warns —"the pictures … aren't drawn
here: with their 1280 tiles the map fits no VRAM layout" (384 for map
69)— and `degradations.json` has them as `pictures-not-drawn`,
`picture-not-shown` and `picture-move-not-done`. Nothing in the tasks
covered them.

**How to see it**: the ports' `tests/test_book_of_three_milestones.py`,
`test_the_end`, plays up to them; it does not photograph map 72's last
scene because it is black.
