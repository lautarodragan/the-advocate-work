---
name: "Six skills don't fit in battle"
description: "With the variable-width font and spacing 0, 6 of the 367 skill names overflow their place in battle"
type: bug
status: done
assignee: taro
---

Tordo measured it on 2026-10-03, counting by hand against the cell cap, while
making the spacing knob (`tasks/letter-spacing-as-a-knob.md`).
It wasn't run in the ROM: it remains to see which ones they are, what's shown, and whether the converter
should warn about it.

## What Benteveo found, on 2026-10-03

Since `spacing-without-touching-code` the converter names them: a WARNING
in `converter.log`, "skill names in the battle don't fit in 11 cells", with
each name, its pixels and what's shown.

What cut the most wasn't the pixels but the letters: the cartridge stored
11 letters of each name, from when a letter took up one cell, and that
cut 41 of ABL's battle skills with 0. Now it stores 13
—what a text layer row's record, `TL_RECORD`, allows with
the list's two columns— and 26 remain, all of fourteen letters or more.
By pixels 3 don't fit with 0 (Tordo's six were out of the baseline's 367;
the cartridge carries the ones the party can use) and 27 with 2.

For all of them to fit the row would need more room: move the dash and
the cost, or a bigger record, which doesn't fit in the layer's RAM
(`FAR_TEXT_LAYER` has 62 bytes free and 432 would be needed for eight
more letters). It wasn't done.

## Done (Carpintero, 2026-10-04)

Tools worktree from `fe0f90ee`; ABL in the clone
`/extras/scratch/carpintero/abl`, branch `texto-de-la-pelea`. It goes together with
`battle-skill-list-exhausts-the-pair-pool`: it's the same text layer.

**The cartridge stores skill and enemy names whole**, and the
console cuts them in their cells, by pixels, as it already did. With that none
is left cut by letters.

* The enemies were only the converter: an enemy's row has room to
  spare in its record.
* The skills were limited by a row's record (`TL_RECORD`): the
  list now writes each name **by reference** (`TL_BY_REF` in
  `text_layer.s`), a six-byte span —where the text is in the ROM and
  how many letters— whatever the length, and the composition reads them from there
  (`tl_ref_letter`). Only the skill list asks for it; everything else is
  written as before. RAM: 8 more bytes inside `FAR_TEXT_LAYER`.
* There was no need to enlarge the record (Benteveo's 432 bytes).

What the converter warns about with ABL, now all by pixels:

    spacing     skills        enemies    items
    +0          3             0          0
    +1          14            0          0
    +2          27            3          4

Before, with +1: 26 skills and 14 enemies. What remains doesn't fit in the
cells: making it fit would require moving the dash and the cost, and that changes the
screen; it wasn't done.

### Verified

* ABL's suite with +1: **five goldens change, only extra letters**
  —"Healing Syringe" whole in `battle-skill`, `-dos` and `-blanco`, and
  "DecayingShambler" in `msu-data-rom` and `-msu`—, looked at side by side. It
  was repeated until no new red appeared (two rounds): **1045
  green**. `abl.sfc` with +1: `17c71a14…`.
* `cargo test -p rm2k-snes-battle` (the test against the Python model
  now cuts the two names like it does), `just -f tools/justfile test`: 27.
* Talan's list with its 54, with 0, 1 and 2, looked at (`pozo-despues-*.png`).

## For taro

A battle with long-named skills and against an enemy with a long
name. The goldens side by side in
`/shared/captures/2026-10-04-texto-de-la-pelea/goldens/`.

On merging, reinstall `battle` and `convert`.
