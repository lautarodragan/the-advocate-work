---
name: "Holding an arrow scrolls a list slower than RM2k"
description: "On the composed screens a held arrow waits for the text, and a step that scrolls takes 6-12 frames to typeset where RM2k repeats every 4"
type: feature
status: draft
assignee: taro
agents: [cardon]
author: huron
links:
  found-in: [scrolling-a-list-shows-the-last-row-repeated-for-a-moment]
---

Seen by Hurón on 2026-10-18, fixing
[`scrolling-a-list-shows-the-last-row-repeated-for-a-moment`](scrolling-a-list-shows-the-last-row-repeated-for-a-moment.md),
with the-advocate `50bc7b47` (branch `huron-scroll-rows`), in snes9x.

**What is seen**: since that task the repeat of a held arrow waits until
the text shows what the screen wrote (`tl_pace` in `text_layer.s`; the
book's divergence "A held arrow waits for the text"). Inside a page that
is RM2k's pace, a step every four or five frames; a step that scrolls the
list takes six to ten on ABL's item screen —thirty items— and eight to
twelve on the skills screen, so holding scrolls at half RM2k's speed or
less.

**How to reproduce**: hold down over a long list in Items or Tech Skill
and count the steps per second once the list scrolls.

**What would close it**: typesetting a scrolling step in under four
frames. What it costs now is the description's two lines —some fifty
letters— and the adoptions of the rows that move (each `tl_adopt` and
`tl_choose` is tens of lines). Nothing in `tl_pace` counts frames, so a
faster layer gets RM2k's pace on its own.

## Comments

### 2026-11-24, Cardón: a question for taro

**What to decide**: whether to chase RM2k's pace when a held arrow scrolls
a long list (6-12 frames a step against RM2k's 4). The wait is a written
divergence in the book ("A held arrow waits for the text"), so this is
making it smaller, at a cost not measured: a scrolling step typeset in
under four frames means a faster text layer (`tl_adopt`, `tl_choose`, the
description's two lines), not a fix to a line.

**Options**: (a) `todo`: measure where a scrolling step's frames go and
make the layer faster; (b) `wishlist`, the divergence stands.

**Recommendation**: (b): it is felt only holding over thirty items, and
the font's composers are being rewritten anyway (unrolled per writer, the
reason for `FAR4`); measure it again after them.

## Log
