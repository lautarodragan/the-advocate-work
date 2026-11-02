---
name: "RM2k's ExFont icons in names and texts"
description: "A `$` and a letter in a name, a description or a message is one of RPG_RT's ExFont icons; the port draws the two characters, and Zounds uses them throughout its items and skills"
type: feature
status: doing
assignee: Hurón
agents: [Hurón]
---

taro, on 2026-11-02, in their words, translated:

> Could you make the build process remove all the special characters we
> can't process yet? Or add them to the runtime, if possible. Zounds uses
> them a lot in items (`0061: $NUltra Poción Roja`, for example — the
> `$N` I think turns into an icon, out of RPG Maker's font).

RPG_RT draws `$A`–`$Z` and `$a`–`$z` as the 52 icons of its ExFont
(easyrpg's `font.cpp` and `exe_reader.cpp`, which can read a game's own
from the `RPG_RT.exe`). Counted by Hornero with a loose `\$[A-Za-z]`
over each port's `data/` (false positives possible): Zounds about 230
—items 117, skills 57, maps 40, common events 11—, Vampires Dawn 30,
Frozen World 6, ABL 4, The Book of Three 3.

**Done**: every screen that draws a name or a text —message boxes, the
menu, items, skills, shops, battle— shows the icon where RPG_RT does, or,
where it cannot, drops the code instead of drawing `$N`; what is dropped
is written in a divergence and in each port's Known issues. Where the
icons come from (the game's exe, EasyRPG's free ExFont, its licence) is
the first thing to settle.

## Hurón's log

Starts from the-advocate 244f4013, the-advocate-ports c82effe,
the-advocate-docs 9a90e38; branches `huron-exfont`.

### Where the icons come from (2026-11-02)

* **From the game's own `RPG_RT.exe`**, its `BITMAP` resource named
  `EXFONT`, as easyrpg's `EXEReader::GetExFont` reads it: a 156x48 BMP at
  8 bits, 13x4 icons of 12x12, index 0 the colour key and the rest ink —the
  text colour paints it, like a letter—. **All nine games carry an
  `RPG_RT.exe`, and all nine carry the same ExFont** (same bytes; Zounds'
  `RPG_RT_a.exe` differs only in its palette). It is read at build time
  from `GAME_DIR`, like the ChipSets, and never committed.
* **EasyRPG's free ExFont is not used**: `src/exfont.h` and
  `resources/exfont.png` are part of easyrpg-player, GPLv3 (by
  filosofiamanga, with no licence of its own), and the-advocate carries no
  licence that GPLv3 data can go into. A game without an exe —the test
  game— has no icons, and the codes are dropped.

### What is a code (RPG_RT's rule)

easyrpg's `Utils::ExFontNext`: a `$` followed by `A`-`Z` is icon 0-25 and
by `a`-`z` icon 26-51, anywhere —names, descriptions, messages—; any
other `$` is a `$`. In a message, `\$` is the gold window's escape and its
`$` is not a code. (Maniacs' `$[n]` is not RM2k.)

Counted again with that rule over each port's `data/` (a throwaway script),
the loose count holds: no price, no `\$` among them. ABL's 4 are two
glitch texts on a sign (`%$@&%$dhbdfj3`): RPG_RT draws icons there too.
Zounds: 25 distinct icons, items' names and descriptions, skills', 46
message lines and one choice.

### The design (2026-11-02)

* **An icon travels as two characters**, its left and right halves, from
  the private use area (`rm2k_snes_text::exfont`): the composer takes
  glyphs at most 8 columns of ink, and two 6-column halves drawn one
  after the other —each with its shadow, the later ink over the earlier
  shadow, `buf & keep | set`— are the 12x12 icon drawn whole. They keep
  RM2k's 6 pixels each; letter spacing does not widen them.
* **`plain_text_but` turns the codes into halves**, and `plain` stands in
  nothing for a half: every screen that draws ASCII drops the icon, so no
  screen shows `$N`. A message box's lines get theirs in `escape_tail`
  (`with_wait_marks`), where `\$` is already the gold window's escape; the
  reflow writes them back as codes.
* **Message boxes** carry the halves as letters, like Latin-1: `Window`'s
  slots are Latin-1's 96 and then the 104 halves, and an icon's halves go
  together or not at all. Same cap as the Latin-1 letters, 32.
* **Text screens** (items, equipment, shop, battle, skills): their tables
  carry the console's 96, `TL_FIGURE`'s place, and the halves of the icons
  the database's items and skills use (`texts::screen_icons`), a byte each
  from 129. Since they no longer match the message window's glyphs, the
  window's advance/reach tables are now `msg_font_advance` and
  `msg_font_reach` (messages.s, gold_window.s), and `font_advance` /
  `font_reach` are the screens'. The menu's bank (`slot_pre`) carries the
  same glyphs as the screens', because a skill's name is written by
  reference from one text in the battle's list and on the actor choice;
  the actors' names, which the bank and a box's `\N` write, drop theirs.

### Zounds' icons are in `RPG_RT_a.exe` (2026-11-02)

The first build drew the zodiac: Zounds' `RPG_RT.exe` carries the stock
ExFont (the same bytes as the other eight games'), and its descriptions
count on another one —"+35$N" is "+35 Hp"—, which is in the
`RPG_RT_a.exe` that came with the repository (Hp, Mp, At, Df and item
pictures). So the lookup follows easyrpg (`Font/ExFont`, `ExFont`, then
`RPG_RT.exe`) and the project file can name the file: Zounds'
`advocate.toml` says `[text] exfont = "RPG_RT_a.exe"`. Which exe the game
really runs with is taro's to say; if it is `RPG_RT.exe`, that line goes.

### The boxes' cap went from 32 to 64

With the stock cap Zounds' boxes lost four icons (18 Latin-1 letters and
the halves of eleven icons are 40). The second letter of a pair now waits
in `FAR_MSG_SECOND` plus one instead of with bit 7 (`dec a` / `inc a`
where `and #$7F` / `ora #$80` were, a byte less), so a letter only has to
be below `MESSAGE_PAIR_FIRST`. Zounds' release carries 40 now
(`MESSAGE_PAIR_FIRST = 136`). A game with 32 or fewer builds the same.
Found on the way: the gathering pass numbers every drawable letter, and
with the 104 halves the 161st wrapped to 0 —"not carried"—, so `$g` was
never counted; capped at 255 now, with its test shown red first.

### Where it stands

* the-advocate `b8e28d6a`, the book `2975f45`, the ports `76fe932` (case,
  test, `[text] exfont`) and `66fcff8` (the two new goldens).
* Captures before and after, and both ExFonts, in
  `/shared/captures/2026-11-02-exfont/`.
* Draft for what is still dropped in battle:
  [`a-troop-page-s-box-drops-its-icons`](a-troop-page-s-box-drops-its-icons.md).
