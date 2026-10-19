---
name: "Scrolling a list shows the last row repeated for a moment"
description: "On the screens that list items, the rows that come in while scrolling repeat the last row that was on screen for one or two seconds before showing their item"
type: bug
status: done
assignee: taro
agents: [Hurón]
---

taro, on 2026-10-18, an old bug never prioritised: on the screens that
list items, when scrolling, the rows that come into the screen repeat the
last row that was on screen instead of the name of the item really in that
slot, for one or two seconds; then it fixes itself. It shows most holding
the arrow down, which scrolls fast. taro's guess: the visible part moves up
or down, but the rows left free are not redrawn at the same time, and keep
what was there.

Before this, `scrolling-the-item-list-redraws-the-whole-screen` (done,
2026-09-30, Hurón) moved the item screen to composing in `text_buf` and one
DMA per vblank. Since then the screens' text takes tiles only where it has
ink, shared by rows that say the same: a stale tile or a late upload of
those tiles is a suspect, as is the arrow repeat.

Done means: holding the arrow over a long list, every frame shows in each
row the item of its slot, measured frame by frame in a ROM test, on every
list screen that has the bug (items, and whichever others: skills,
equipment, shop, battle).

## Log

### Hurón, 2026-10-18: reproduced, and the cause

Started from the-advocate `f04e2029`, the ports `04422f7`. Branches
`huron-scroll-rows` in both.

**Reproduced** in ABL's item screen with thirty items written into RAM,
holding down from the first: the cursor moves every four frames —the
repeat, `arrows_repeat`— but the text stands still on the first page for
some seventy frames, and then one frame shows the list with its last rows
all saying the same item, next to a description that is already the new
one. taro's screenshots 6 to 10 (in `~/scratch/hornero/list-scroll/`) are
the same thing.

**The cause**, in `text_layer.s` as it was born (`9041a3ce`, 2026-10-03,
"Ítems, equipo, tienda y pelea componen su texto"; `git blame -C
--diff-algorithm=histogram` gives it for `tl_map` and the flush in
`tl_step`), two things that only meet when the arrow is held:

1. The tilemap switches only when *everything* the screen wrote is
   typeset. A step that scrolls the list takes more than four frames to
   typeset (measured then: six; the description is two lines), so with the
   repeat the screen writes again before the switch, every four frames,
   and the switch never comes: the text freezes. That is the "one or two
   seconds".
2. What ends the freeze is the pool running out —the pairs the old screen
   still shows wait for the switch— and then the tilemap switches
   **halfway**, on purpose ("a screen that changes so much at once that the
   pool runs out switches earlier"). Halfway means after the rows that take
   another row's tiles moved and before the rows that came in were typeset:
   those still show what they showed before, which is their neighbour's
   item, name, colour and count. With several steps piled up, several rows.
   Measured: at the switch, 9 pairs free and 92 waiting, of 184.

And even with one step at a time, the items screen's pool —184 pairs, the
VRAM between the bank and the windows' tiles— cannot hold the old screen
(about 125 pairs) and what a scrolling step adds (a description of some 50
and a row) at once, so a single step could also switch halfway.

The equipment and skills screens freeze the same way (measured on the old
ROM, holding down: the skills screen's text stood still 47–54 frames, the
equipment list flushed halfway three times); the shop and the battle use
the same layer.

### Hurón, 2026-10-18: the fix

In `runtime/text_layer.s` and `runtime/screen_bank.s` (the-advocate
`50bc7b47`, merged with main in `39313bcd`):

* **A held arrow waits for the text** —`tl_pace`, called from `tl_map`,
  which every composed screen calls once per frame right after reading the
  pad—: a repeat that `arrows_repeat` faked is undone while the text is not
  what the screen wrote, and tried again on the next frame. A press is
  never held back. Each step is then shown whole, and holding scrolls as
  fast as the text follows: 4–5 frames per step inside a page (RM2k's 4),
  6–10 per step that scrolls on the item screen, 8–12 on the skills screen.
  It is a divergence, in the book: "A held arrow waits for the text". The
  slower pace is the draft
  [`holding-an-arrow-scrolls-a-list-slower-than-rm2k`](holding-an-arrow-scrolls-a-list-slower-than-rm2k.md).
* **The items and equipment screens get the pairs from `$4000` up to the
  448th** —`items_pool`, `tl_more`—, map VRAM neither shows; 375 pairs
  instead of 184. They set `CM_DIRTY`, so the map comes back whole with
  `big_back_far` when the pause menu closes, like after a custom menu. The
  book's `internals/vram.md` says it.
* **If a pool still runs out halfway**, the rows not typeset yet go blank
  before the early switch —`tl_blank_dirty`— instead of showing what they
  showed before.

The three new routines live in `FAR3`: bank 1 overflowed in ABL's MSU test
cartridge with them in `FAR`.

**The test**: `test_holding_an_arrow_shows_every_row_s_item`, in ABL's
`tests/rpgmaker/test_menu_items_drawing.py` (the ports `a22439f`): thirty
items, hold down from the first to the last and up again, and every frame
has to show one top row's list whole and a description, and the pair has
to be a state the cursor was in. Red on `f04e2029` in snes9x (frame 93)
and bsnes (frame 92): text frozen on the first page since frame ~23, then a
list whose last rows all say "Apple : 2". Green in both with the fix.

**Measured with a throwaway probe**, holding down and up, on the old ROM
and on the new: the skills screen's text stood still 47–54 frames and now
at most 12 (one step); the equipment list switched halfway three times and
now never. **No test holds an arrow on equipment, skills, the shop or the
battle's lists**: they get the same pacing, and the shop and the battle
keep their pools.

**Run**: `just test` in the-advocate, 29 passed; ABL's whole suite with
these tools, 1567 passed and 2 skipped, and 1571 passed and 2 skipped on
the tree merged with main (the-advocate `39313bcd`, the ports `56a0261`); no
golden moved; the other games'
`just boot -k "not milestones"`, 47 passed. Captures for taro in
`/shared/captures/2026-10-18-list-scroll/`.

**On merging**: the runtime only; nothing in Rust changed. Reinstall
`cartridge` only if the global tools are installed from another checkout
than the one this lands in (the runtime's path is compiled in).

**2026-10-19, taro**: played in ABL, scrolling the item lists; "perfect". Done.
