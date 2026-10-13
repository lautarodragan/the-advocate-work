---
name: "The shop like the original"
description: "The System's windows and the red cursor bar, as items and equipment already have them, brought to the shop"
type: feature
status: done
assignee: taro
---

It was born on 2026-09-28, when taro approved the equipment screen, to write
down the VRAM matter below. It's what comes after items and equipment. taro
asked for it on 2026-09-28: "let's go with the shop". Today the shop is still
on black and with the ">" (`EQ_CURSOR` still exists because of it). The
screen is `rom/src/tienda.s`, and the reference is
`pantallas.pantalla_tienda`.

What has been done so far, which is where the mechanism comes from:
`items-screen-like-the-original.md` (Jacarandá) and
`equipment-screen-like-the-original.md` (Ñandú). Both build the windows
in BG1 behind BG2's text, share tiles and colours (`titulo.marcos`), and each
uploads its tilemap. The original shop still has to be captured with Wine, as
was done for the other two.

## The windows' tiles no longer fit where they are

The items and equipment ones, which are 24 at 8bpp, go in the same base as
the font (BG1 and BG2 start at `$2000`) and after it. With the font's 336
tiles at 4bpp they reach **exactly** `$3800`, where BG1's tilemap starts: not
a single tile is left free. Windows for the shop won't fit there unless they
share all their tiles with the other two screens'. The converter checks it in
`_controlar_marco_de_items`.

It isn't a problem of them living in VRAM all the time, because they don't
live there: they're uploaded when the screen opens, and on closing
`volver_al_mapa` restores the map with `load_map`. The rule is that the menu
only writes in the BG1 bank that `load_map` restores (`_controlar_ranuras`).
That way, closing the menu costs nothing more than that. If the menu wrote
outside that bank, on closing what it overwrote would have to be restored,
and that would feel like lag.

The way out discussed with taro, **unmeasured**: give BG1 a tile base of its
own (`BG12NBA` allows one per layer, in steps of 4096 words), for example
`$4000`, and take the windows there. According to the comments on
`RANURA_VRAM` in `snes_convert.py`, in every allocation BG1's bank covers at
least `$2000..$4C00`, and the menu uses up to `$3C00` (the slots' tilemap).
If so, some 96 tiles at 8bpp fit in `$4000..$4C00` without touching the font
and with nothing to restore on closing. First it has to be measured against
the real allocations, which is what the converter does, and not against the
comment.

## Measured on 2026-09-28, with the actor choice

The actor choice (`actor-selection-like-the-original.md`) already uses
that way out: BG1 with its base at `$4000`, 60 tiles at 8bpp and its tilemap
at `$4800`. Measured against the allocations (`_controlar_objetivo`): the
smallest BG1 bank is `VENTANA_FONDO`'s, `$1000..$4C00`; all the others reach
at least `$5000`. So `$4000..$4C00` is always inside. For the shop:

- With BG1's tilemap where items and equipment have it (`$3800`), the whole
  `$4000..$4C00` area is left for tiles: **96 at 8bpp**.
- With the tilemap right there, like the choice, **64**.
- The two screens aren't opened at the same time as the choice, so they can
  overlap. The items and equipment windows (24 tiles) could also move there,
  and that would give the 24 back to the font.

## What the original does

Captured on 2026-09-28 with the 2015 RPG_RT and Wine, at 320x240, on a copy
of the game whose map 4 starts with Kersh and Core, items, a thousand gold
and a type-0 `OpenShop` with weapons, armour, a helmet, medicines and a
material. The captures are in `/shared/captures/2026-09-28-tienda/original-*.png`,
and were checked against easyrpg's `Scene_Shop` and `Window_Shop*`.

- **The main one**: the help at the top (32 high) empty, the middle (128) an
  empty window, and at the bottom the message one (80) with the greeting and
  below it the three commands, 16 pixels further in. The bar crosses the
  window (x = 11 to 308).
- **Buy**: the help with the description of what the cursor marks; on the
  left the list (184 wide, seven rows) with the name and the price, in grey
  what can't be afforded; on the right, one above the other, the party (48),
  "Owned Items" and "Equipped Items" in red with their counts (48), and the
  gold with the currency in red (32); at the bottom the message, one line.
- **The party** is each member's charset, facing front: walking and in colour
  if they can equip it, still and in grey (`Tone(128,128,128)`) if not, and
  next to it an arrow from the System —blue if it goes up, red if it goes
  down, a dot if it stays the same, an "E" if they already have it on—. With
  a medicine, in colour and without an arrow.
- **The quantity**: the list window becomes one with the item, "x" and the
  quantity —with a tiny bar over the digits— and the total with the currency
  in red below. The party, the count and the gold remain.
- **The "done" ones** ("Done", "Thanks."): the list window empty, the rest
  the same.
- **Sell**: the list across the full width, in two columns, without the
  right-hand column; the sell quantity is like the buy one, with the party.

## What differed in the ROM

Everything on black, the ">" as cursor, the message at the top where RM2k
puts the help —without description—, the gold, the count and the list in a
single column, and the terms in white.

## What was done

- **Three layouts** (`pantallas.TI_CAPAS`), which share the help at the top
  (48, two lines, as in items):
  - the main one: the middle empty (80) and at the bottom the message (96)
    with the greeting and the commands right below, like RM2k;
  - the buy one, which the two quantities and the two "done" ones also use:
    the list (96, five rows) or the quantity; below, side by side, "Owned
    Items" and "Equipped Items" in red with their counts (152 wide) and the
    gold with the currency in red (104), which is RM2k's right-hand column
    moved down; and the one-line message (32);
  - the sell one: the list (144, eight rows) and the message.
- **The help shows the description** of what the cursor marks, and the
  shopkeeper's message moved down to its window, as in RM2k. Before, the
  message went at the top and the description wasn't there.
- **The "done" ones leave the middle window empty**, like RM2k: before, they
  showed the list.
- **The bar** instead of the ">": over the command —from x = 12 to where the
  others are—, over the list's row —the equipment one, from x = 4 to 244— and
  over the quantity's two digits, like RM2k's little bar.
- **A two-line greeting moves the commands down one.** The re-greeting of
  message sets 1 and 2 is 31 and 32 letters long ("Are you going to buy
  something?", "I dont have all day you know!!!!") and 30 fit in a line; the
  bottom window has room for that case, and with a one-line greeting the
  commands move up, right under the message as in RM2k. The other messages
  are 26 at most, and the converter checks that they fit in one.
- **The windows in BG1 with their own base, `$4000`**, and the tilemap at
  `$3800`, where the items and equipment one is. That's **39 tiles** at 8bpp
  of the 96 that fit, and **4 colours**, in CGRAM 64..67 —where the items
  ones are—. `_controlar_tienda` checks against the allocations that they
  fall in what `load_map` restores; `shop-120` and `shop-200`, which look
  at the map after closing the shop, didn't change.
- **What's stored is little** (`pantallas.tienda_compacta`): the three layers
  as runs of rows, without repeating a run that's already stored —16 tilemap
  rows for the three, 1024 bytes—, and each bar only in the rectangle that
  changes, without repeating identical ones: 628 bytes for the 18 positions.
- **Every frame everything is restored**, as in equipment (`ti_ventanas`):
  the rows of the mode's layer below the help, 1408 bytes, and the bar on
  top. With the text's 1792 that's some 3.3 KB per vblank; calculated, some
  twenty-seven of its thirty-seven lines. In bsnes, which doesn't allow
  writing VRAM outside vblank, the twenty-two screens of the tests came out
  pixel for pixel identical to the reference.
- `items_ppu_prender` falls through into `pantalla_ppu_prender`, which
  receives `BG12NBA` in A: the shop passes it BG1's own base.
- The new code goes in bank 1 (`tienda.s`); bank 0 didn't change.
- `EQ_CURSOR` and `PANT_NOMBRE` went in their own commit: the ">" and the
  item-name column in this screen remained only because of the shop. The
  ROMs came out byte-for-byte identical.

## What doesn't fit

- **The list and the right-hand column, side by side**: with 8-pixel letters
  a twenty-letter name with its price is 26 cells and "Equipped Items" with
  its count 17; with the four of the frame that's 47, and the screen has 32.
  The column moves down, between the list and the message.
- **The seven-row list**: below the help (48), the count and the gold (48)
  and the message (32), 96 remain: five rows. The sell one, which doesn't
  have the count, has eight. The two sell columns, for the same reason as in
  items: one.
- **The party, with its sprites and its arrows**: it has nowhere to go in
  this layout without taking rows from the list —RM2k's window is 136 by
  48—, and it's a separate job from the windows: each party member's charset
  as sprites, facing front, walking in three frames, a grey version of each
  for the one who can't equip it, and the System's four arrows —8x8, in four
  frames— with the `CmpEquip` computation. It stays as a declared divergence;
  if taro wants it, it's a task of its own.
- **The list's little arrows** saying there's more above or below: the items
  one doesn't have them either.
- **The one-line help** and the font at 6 pixels: as in items and
  equipment, already declared.
- **Set 0's message starts one space further in** in RM2k ("
  What do you want to buy?"): splitting the lines eats the space, as it
  already did.

## Tests

- `test_shop_drawing.py` compares each mode against `pantalla_tienda`, which
  now draws the windows and the bar (`Texto.ventanas`). With two new tests,
  among the three the bar passes through every place with a different patch
  —the last row of each list and the last command, which cross the
  background's band—:
  - the weapons one (EV0021), as it was: each mode once;
  - new, the armour one (EV0023, set 1): the two-line re-greeting with the
    bar on Leave, selling with ten items and the list scrolled, the sell
    quantity and "sold";
  - new, the spare parts one (EV0025 with switch 150): eleven items, the bar
    on the fifth row and the list scrolled.
- **New goldens**, ten, from the ROM in those same states:
  `shop-main`, `shop-buy-2`, `shop-how-many-2`,
  `shop-bought`, `shop-sell`, `shop-armors-regreeting-leave`,
  `shop-armors-sell-run`, `shop-armors-how-many-sale`,
  `shop-armors-sold` and `shop-spare-parts-run`. Until now the
  shop had no golden of its screen, only of the map around it, and those
  didn't change.
- Before, now and the original, side by side, in
  `/shared/captures/2026-09-28-tienda/`, with the goldens from the last commit.
- Verified with `just cartridges` and `just tests` on this branch, with
  `main` merged —it hadn't moved—: all green. No music theme started
  clipping, so there's no ceilings commit.
- **What `just tests` doesn't run**: the shop in bsnes. It was run by hand,
  with the three shop tests pointed at bsnes, and the twenty-two screens came
  out identical to the reference; that's what says each frame's DMA fits in
  vblank. Nor does it run a buy-only or sell-only shop (`OpenShop` type 1 or
  2), which goes straight into the list: its path didn't change, but the
  layer comes out of the same table.
- `just space`, before (`main` at `24dc8b6e`) and after: in `release` the
  data gaps went from 13,910 to 9,432 B, bank 1 from 3,739 to 3,333 and bank
  0 stayed at 224; in `test-special`, from 23,213 to 18,735, from 6,243 to
  5,837 and 1,117. No cartridge uses one more data bank.

## What taro has to look at

- A shopkeeper: the main one with the greeting at the bottom and the
  commands below, the bar crossing the window; the armour one in Lashe City
  Interiors, which greets again in two lines when coming back with B.
- Buy: the description at the top, the bar in the list, "Owned Items",
  "Equipped Items" and the currency in red; with more than five things, that
  the list scrolls with the bar.
- The quantity: the little bar over the digits, and "Done" with the middle
  empty.
- Sell, with many things in the inventory, and "Thanks.".
- Leaving, and the map as always (BG1 has another base in the shop and the
  map restores it).
