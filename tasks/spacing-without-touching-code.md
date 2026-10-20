---
name: "Spacing without touching code"
description: "Changing [text] letter_spacing should not require touching the engine: the menu's bank computed rather than fixed, and the converter checking everything that has a counted width; ABL moves to +1"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-03, after trying Tordo's three ROMs, in their
words, translated:

> I'll go with +1. I like all of them, anyway, and I'd like to keep the
> knob

And he asked whether changing the spacing requires touching code. Today it does, in three fixed
places: the menu's bank (with +1 it is 2 tiles short, with +2 26), the names in
counted cells (slots, battle skills) and the pair pool of the
shop and the battle. See `tasks/letter-spacing-as-a-knob.md`.

## Done (Benteveo)

Tools worktree from `c66f453f`; ABL in the clone
`/extras/scratch/benteveo/abl` from `e700650`, branch `espaciado-1`.

### The menu's bank

**The ceiling cannot be raised.** Tordo saw that BG1 is free up to `$4C00`
in every layout, but between `$2000` and `$4C00` everything is already taken: the
menu's bank ($2000-$3C00, 448 tiles), its tilemap ($3C00), the windows
of the actor choice and of the menu on BG1 (`TARGET_VRAM`, $4000, 58 of 64
8bpp tiles) and their tilemap ($4800). Even packing perfectly, the menu would have
460 tiles, and with +2 it asks for 474.

What was done is that **the menu doesn't pay for what it doesn't show**: the
headers and the rows of the slots. If the names don't fit with the
bank in the usual order, `rm2k-snes-screens` packs it again with
that text at the end (`slots::Order::MenuFirst`), and the menu and the actor
choice compose their names from where their own tiles end
(`SLOT_MENU_TILES`, `tl_strip_menu`), on top of the slots' text. The
slots screen uploads the whole bank every time it opens, so it is not
affected. With 0 nothing is reordered, and the new runtime is only built if
`SLOT_MENU_TILES` differs from `SLOT_TILES`: **the ROM with 0 comes out byte for
byte the same** (37dde95f…, verified).

    spacing     bank    menu shows        menu names         slots
    +0          314     314                78 of 134          40 of 134
    +1          355     278                94 of 170          48 of 92
    +2          368     288                106 of 160         56 of 80

`tl_strip` could no longer overwrite the tilemap: `tl_strip_new` leaves the name
blank if it doesn't fit (`bcs full`). That it doesn't happen is guarded by the converter, which, if
it doesn't fit even after reordering, refuses, saying what each screen asks for.

### What gets cut

The converter warns —a WARNING in `converter.log`, one line per place, with
each name, its pixels and what is shown— and doesn't refuse: the console cuts and
carries on, as with the other things the cartridge carries less of. It checks:

* `rm2k-snes-screens`: the actors in the menu (13 cells) and in the slots
  (7), the medicines in the actor choice (two lines of 11) and the
  equipment on its screen (19).
* `rm2k-snes-battle`, which now receives the font: actors and enemies (14),
  skills (11), items (14) and skill commands (10).
* The item list and the shop are not checked: 20 letters fit in the 24
  cells they have with any font the engine accepts (a letter
  advances 8 at most).

With ABL:

    spacing     slots     enemies    skills        battle items
    +0          3         14         26            0
    +1          3         14         26            0
    +2          3         14         28            4

**Almost all of that is a cut by letters, not by pixels**, and it predates the
knob: the cartridge stores as many letters as cells, from when a letter
took up one. "Gang Member" doesn't fit in the slot with 0 because it has 11
letters and the slot stores 7, even though it measures 55 of 56 pixels; the fourteen
enemies are names of 15 letters or more that would fit.

### The skills

In battle the name was cut at 11 letters: 41 of ABL's skills
with 0, when by pixels 3 don't fit (Tordo counted 6 out of the 367 in the
database; the cartridge carries the ones the party can use). Now it stores 13, which
is what the record of one row of the text layer allows (`TL_RECORD`,
56 bytes, with both columns); enlarging it doesn't fit in RAM. 26 remain
cut with 0. That one does change the ROM with 0, and it goes in its own commit.

Making them all fit would require more cells (moving the dash and the cost) or a
bigger record: it wasn't done. The task for the six stays in `todo/`
with this noted.

### The pair pool

The converter counts what the most loaded lists ask for, with the widest
texts the cartridge can put in them (`rm2k_snes_text::cells`):
it's a bound, not what happens.

    spacing     shop     battle: skills       battle: items  (of 191)
    +0          142      283                  195
    +1          168      325                  228
    +2          191      350                  255

And measured in the ROM: the `battle` battle with Talan (actor 14, who can
come to know 54 skills) knowing all of them, with the list open.
**Already with 0 the pool runs out**: the seventh row of skills comes out half drawn
and the first line of the commands doesn't come out. With 1 it runs out at the sixth.
It predates the knob and wasn't fixed: see
`tasks/battle-skill-list-exhausts-the-pair-pool.md`.

### ABL at +1

`rm2k-snes.toml` with `letter_spacing = 1`, and the harness passes the project's
knob to the screens model (`screen_stage.spacing`), so
the `_dibujo` tests expect what they should.

**106 goldens of the suite change, letters only**: all looked at side by side.
The boxes that get rebuilt break lines in a different place, some
descriptions go to two lines, and the skill list shows two
more letters of the long names (that's the thirteen-letter change).
None from the walkthrough. The suite was repeated until no new red one
appeared: eight rounds, because of the scenes with several goldens in a row.

Two tests looked at one exact frame and shifted by a frame with the
rebuilt messages; the tests were touched, not the ROM:

* the farm celebration looked at the slots in a frame with the
  screen turned off by hand after the jump —the same happens with 0, one frame
  earlier, which `CADA` didn't look at—: `without_errors` no longer counts what isn't shown;
* `items-2` captured in the frame where the description arrived, which with
  1 goes on two lines and arrives one later: now it looks at 78. The debt
  of text that arrives after the cursor grows by one frame there (six to seven).

### Verified

* With 0, `abl.sfc` comes out the same, `37dde95f…`, with the runtime and
  converter commits. The thirteen-letter one changes it on purpose
  (`2ae0e1b3…` with 0).
* ABL's suite with 1, with `screens`, `mapdata`, `convert`, `battle` and
  `cartridge` local: **1045 green**. `abl.sfc` with 1: `e765fa06…`.
* `cargo test` of `text`, `screens`, `mapdata`, `battle` and `convert`, and
  `just -f tools/justfile test`: 27.
* What the suite does **not** cover: the reordering with 2 (built and measured,
  not played nor the suite run); the converter's refusal when it doesn't fit even
  after reordering (covered by the `screens` test with 24 slots).

## For taro

Play the +1: the messages, the menu with the whole party, a medicine from
the menu (the menu's names now go on top of the slots' text),
saving to a slot, a shop and a battle with skills. The goldens
side by side and the captures of the pool, in
`/shared/captures/2026-10-03-espaciado-1/`, with its LEEME.

Branches: tools, `worktree-agent-a06268194b190fc7f`; ABL,
`espaciado-1` of the clone `/extras/scratch/benteveo/abl`.

When merging, reinstall `screens`, `mapdata`, `convert` and `battle`. `text`
changed, but it's a library and goes inside those; the runtime travels with the
checkout.
