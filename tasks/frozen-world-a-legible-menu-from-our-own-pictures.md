---
name: "Frozen World: a legible menu, from pictures of our own"
description: "The custom menu is three pictures (one per highlighted row) whose gradient does not survive the console; redraw them flat in three colours, and let a port's patches carry files that replace the game's by name"
type: feature
status: doing
assignee: Aguará
agents: [Aguará]
---

Asked by taro on 2026-10-19: Frozen World's menu "always has to be seen,
and always has to be seen *well*". The cheapest step first, before the
custom windows: no runtime change.

**What there is**: the menu is three pictures, `Picture/MenuEquipPlates.png`,
`MenuItemManage.png` and `MenuPartyStats.png`, the same window with a
different row highlighted, shown by events. Their vertical blue gradient
and anti-aliased text come out of the colour reduction hard to read.

**What taro asked for**:

* New pictures, drawn from scratch rather than retouched, with the
  originals' colours: the blue of the background —the middle tone,
  vertically— flat; the white of the border and the text, with a black
  shadow 1 px down and right; the border in that same white and black.
  Three colours.
* Width and height multiples of 8.
* Square corners if a rounded one would share an 8 px tile with another
  layer; if the layer the picture goes on gives the rounded corner for
  free, better, but not worth complexity (about 6 px a corner).
* The build prefers a port's own files over the game's: the same folder
  structure as RM2k's, merged, a file of ours replacing the game's of the
  same name. Taro's proposal for where: `frozen-world/patches/manual/`.

The `.zip` of the game is never edited (AGENTS.md).
