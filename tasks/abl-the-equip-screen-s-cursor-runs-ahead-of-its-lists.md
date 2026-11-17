---
name: "ABL: the equip screen's cursor runs ahead of its lists"
description: "Choosing a body part, the selection bar moves at once and the item list replaces the parts' list frames later (~4 + ~5), and going back takes ~16; the description above lags the cursor up to 5 frames; Mesen's lag counter sees none of it"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

taro, on 2026-11-17, playing ABL's build on Mesen with Hornero's
frame-numbered screenshot script (the report and the captures are in the
shared folder, `bug-reports-etc/bug2-abl-lag/`, copied to
`captures/2026-11-17-equip-lag/`), translated:

> When selecting a body part to equip an item, the selection indicator
> takes about ~4 frames to move to the first position, and then another
> ~5 frames pass before the list is erased and replaced by the list of
> items (or an empty list). That means that for ~4 frames it gives the
> impression that another body part was selected. The same happens going
> back, from the list of items to the list of body parts, except that it's
> many more frames, about ~16.
>
> Ideal: reduce that lag. Acceptable: that the selection bar has the same
> lag as everything else.
>
> Possible optimisation: if VRAM allows, don't overwrite the list of body
> parts with the list of items, so it doesn't need rebuilding when going
> back.
>
> Note: Mesen's lag counter doesn't count these frames as lag frames.

And on launching this: measure the transitions of the text too, which the
captures do not show and which taro thinks are the larger ones.

What the captures show (Hornero): moving among the body parts, the
description above lags the cursor by 1 frame when the part is empty
(6295→6296, 6366→6367) and by 5 when it has an item whose text is
composed (6327→6332). Mesen counts no lag because the main loop reads the
pad every frame: the screen is built over several frames on purpose, to
fit the vblank.

Done means: every transition measured frame by frame in the harness
(choose a part → item list; back → parts list; moving among parts → the
description; moving in the item list), with what takes each frame; the
lag reduced where it can be —taro's VRAM idea measured—, and at least the
bar never showing a part as chosen while the old list is still up; ROM
tests that hold the new frame counts; goldens that move looked at.

## Log
