---
name: "ABL's item text doesn't fit in what the windows leave"
description: "ABL's build warns that the most loaded item list asks for more tile pairs than the item and equipment windows leave"
type: bug
status: testing
assignee: taro
agents: [Chajá]
---

Seen by Tijereta on 2026-10-11 (`most-efficient-windows.md`),
tools `fc6f7456`, ports `a85b7e3`, building ABL's `release`.

**What is seen**: in the build, not when playing. `rm2k-snes-screens convert` says
in its answer:

    WARNING, item text: its list asks for 200 pairs of tiles at most, of
    the 167 the item and equipment windows leave

No other of the eight games says it. It wasn't checked what the ROM does
with an inventory that reaches that list —whether the text is cut, or which
names are lost— nor with which inventory it's reached.

**How to see it**: `just cartridges release` in `abl/` of the ports; the warning
is in what `screens` answers (the `says` of its `screens.json`).

A fact measured in passing: with the windows' background in a single color (the
book's research "The windows, made cheaper"), the windows leave 184.

**Checked on 2026-10-16** at the-advocate `759aa0ba`, by Cardón: the
warning stands, with other numbers —the release build's `converter.log`
in the ports checkout (2026-10-16) says 202 pairs of the 184 the windows
leave—: `release` carries the whole game since the ports' `74eb754`, and
the windows' background went flat with
[`windows-background-setting-and-flat-text-area`](windows-background-setting-and-flat-text-area.md).
The numbers are the build's to say; the description no longer carries
them. What the ROM does with such an inventory is still not looked at.

## Checked (2026-10-20, Tijereta)

Still so in A Blurred Line's release build of the ports `68bf55b`
(the-advocate `8f290c39`): its `converter.log` still has the "WARNING,
item text" line, and it is still the only one of the nine games with the
WARNING (Zounds' list takes all the pairs its windows leave, without
going past). What the ROM does with such an inventory is still not
looked at, and that is what would define it.

## Asked (2026-11-02)

Still so in ABL's release built that day (the-advocate `3656d606`): 202
pairs of the 184. taro, asked whether to measure it with a new test, in
their words, translated:

> Go ahead. Would it be a new test?

Yes: ABL's suite builds the worst inventory, opens the item screen and
compares; red if the ROM breaks the text, until it is fixed. Taken by
Chajá, launched by Hornero.

## Looked at (2026-11-02, Chajá)

Starting at the-advocate `5ef467fe`, ports `1f1d0ea`, docs `5a87d0a`.

**The warning was stale, not the screen.** The converter's pool for the
item and equipment screens' text was only what their windows leave in
the bank: (`ITEM_BORDER_MAP` − `SLOT_VRAM`) / 32 − 1 = 191 pairs, minus
ABL's 7 window tiles, 184. But since the-advocate `50bc7b47`
(2026-10-18, Hurón: "a held arrow waits for the text, and the items
screen gets more pairs") the runtime's `items_pool`, in
`runtime/screen_bank.s`, also gives those two screens the pairs from
`ITEM_MORE_VRAM` ($4000, the map's tiles and sprites, which neither
screen shows) up to the text layer's 448th: 192 more, 376 in all for
ABL. The converter was not told, so it kept comparing against 184.

And `fit::skin_for` could never have helped ABL: 202 is more than the
whole bank (191), and for that case it gives up on purpose ("if the text
alone takes the whole bank there is nothing to give it").

The same stale count **did** cost something elsewhere: Zounds' item and
equipment windows are redrawn with 16 tiles of their 25 so that its 175
pairs fit in the bank, when 192 of them had room past it.

**Which list it is.** The converter's worst case is not an inventory one
plays into: per cartridge, the ten widest names it carries, every count
at 99, and the widest description over them (`busiest_items` in
`rm2k-snes-screens`, which now names it in the line). For ABL's release:
items 9, 210, 219, 242, 265, 304, 341, 413, 414, 421, with the
description of 304, the Bronze Key. **The real game cannot reach it**: 9
is the `--------------------` separator and nothing gives it, nor 265 by
a constant `ChangeItems`; 210 and 304 are given one each, 413, 414 and
421 are sold in one shop on map 321, and nothing equippable reaches 99
(a throwaway scan of the dump: `ChangeItems` with a constant, shops and
troop pages). It does not matter: it fits.

**What the ROM draws with it**: everything. With that inventory written
into RAM, the item screen with the cursor walked down to the Bronze Key
is the reference pixel by pixel —ten names, ten `:99`, the two lines of
the description—, and the equipment screen, with Emily choosing her
weapon among it (her two gloves and the empty line), too. Captures in
`/shared/captures/2026-11-02-abl-item-text/`. ABL's `abl.sfc` with the
change is byte for byte the one built before it (sha256 `a85df642…0b2c`),
so that is what the old ROM drew as well.

**What changed**:

* `rm2k-snes-screens` counts the item and equipment screens' text pool
  as the runtime gives it, `ITEM_MORE_PAIRS` (192) besides what the
  windows leave, and says which list is the busiest: ABL's line is now
  "item text: its busiest list asks for 202 pairs of tiles at most, of
  the 376 the item and equipment screens have —184 below their windows
  and 192 of the map's—: items …", without WARNING, and the loss
  `text-pool-short` is gone from ABL.
* `fit::skin_for` redraws those windows only for the text that does not
  fit past the bank. Zounds' windows, redrawn until now with 16 tiles of
  their 25, are drawn as RM2k draws them.
* The cartridge checks the converter counts the same: `mapdata` emits
  `ITEM_TEXT_MORE`, and `screen_bank.s` asserts it is what `items_pool`
  gives. So the next change to `items_pool` cannot leave the warning
  stale again without failing the build.
* ABL's suite: `test_the_busiest_list_fits` (item screen) and
  `test_emily_s_weapons_with_the_busiest_list` (equipment screen) read
  the list from the cartridge's `converter.log`, write it into RAM,
  compare against the reference and have a golden each. On the old tools
  they are red at the log, whose line neither names a list nor fits; the
  screen comparison is green on a ROM byte for byte the old one.

**The other games** do not warn and did not: their busiest lists ask for
0 to 175 pairs, now of 358 to 377. Only Zounds moved, for the better: its
`zounds-exfont-items` golden changes by 386 pixels, all of them the
windows' frame —the top edges, the corners and the left edge whole again,
text and icons the same—. Before, after and difference in
`/shared/captures/2026-11-02-abl-item-text/`; blessed in the ports, in its
own commit.

**Not covered**: the equipment screen's own busiest page —its list with
the most equippable items for one actor and slot, and its parameters'
window— is not measured by the converter, and the test only looks at the
item screen's list from there. And a step that changes the whole page at
once on a page this full can still run the pool out halfway, which since
`50bc7b47` blanks the rows not typeset yet for a frame or two instead of
showing stale ones; with 376 pairs and 202 on screen no step of the test
did, and none is held over this list.

## Verified (2026-11-02, Chajá)

Tools `chaja-item-text`, ports `chaja-item-text`, docs `chaja-item-text`.
Before merging `main`: ABL `just cartridges` and `just tests` with the
branch's tools, 1639 passed and 2 skipped (main's 1637 and the two new);
`just space` in abl/, 126 of 126 as before; `abl.sfc` sha256
`a85df642…0b2c`, the same as main's. Ports `just boot`: 140 passed and
`zounds-exfont-items` red, looked at and blessed (above). Crate tests of
`screens` and `mapdata`, `just test`, `just lint`.

To install when merging: `screens`, `mapdata`, and `cartridge` with
`project` for the runtime's new `.assert`.
