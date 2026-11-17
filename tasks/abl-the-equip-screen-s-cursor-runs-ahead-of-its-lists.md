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

### 2026-11-17, Calandria: the measurements before

From the-advocate 865163eb and the-advocate-ports 8042dc8, branches
`calandria-equip-lag` in both. Measured with a throwaway test in the
harness —case `equipment-inventory`, Talan with the club ×2, the spear
and the shield in the inventory—: the button held one frame (f0) and
then every frame captured, each band of the screen —the description,
the parameters, the bottom window— compared at 15 bits against
`screens.equipment` before and after, the bar's row found by its red,
and the text layer's state read from RAM. **snes9x and bsnes give the
same frames, one by one.** The number is the first frame that shows it,
counted from the press:

| transition | bar | text whole |
|---|---|---|
| slots, Right Hand → Left Hand (no text changes) | 1 | 1 |
| slots, Left Hand → Body (empty → Work Clothes-B, two description lines) | 2 | 7 |
| slots, Body → Left Hand | 1 | 2 |
| A on Right Hand: the weapon list (three rows) | — (row 0 both) | 11 |
| A on Body: the armour list (only the empty line) | 1 | 8 |
| list, down 0 → 1 / 1 → 2 / up 2 → 1 | 1 / 2 / 1 | 4 / 5 / 5 |
| B from the weapon list | 1 | 10 |
| B from the armour list | 2 | 14 |

So for 7 frames choosing Body, and 12 going back from it, the bar is on
a row of the old list: taro's "~4 + ~5" and "~16", as Mesen counts them.

What takes the frames, measured with a scanline counter put in the loop
for a while and taken out:

* **One text row per frame, at most.** `tl_step` does not start a row
  while the tiles of the last one wait for the vblank (`TL_UP_N`): the
  stage is one row wide, and the next row would compose over it. So each
  changed row costs a frame even when it is four letters —the arrow's
  `> 19` of a parameter— and one of more than 16 pairs costs two. Going
  back from the armour list changes eleven rows: two of description, four
  of parameters, five of slots.
* **`eq_compose` takes most of the frame it runs in**: from line 235 to
  115-160 of the next —clear and name 15 lines, a two-line description
  30, the four parameters 72 without arrows and ~135 with them, the slots
  55—, so the frame after the press has some 60 lines left to typeset.
  On A, `eq_list_build` goes first —some 100 lines— and the two together
  cross the next vblank: one frame with no pad read.
* The bar moves in the first vblank after the press because `eq_bar`
  draws from the cursor, which the text layer did not exist to lag when
  the bar was made (172b924d, 2026-09-28: the text was composed whole
  every frame). Since the text layer (9041a3ce, 2026-10-03) the text
  arrives some frames after the cursor, as a debt declared there; the bar
  was left ahead of it.
