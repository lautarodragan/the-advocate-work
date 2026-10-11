---
name: "The battle's skill list exhausts the pair pool"
description: "With a full page of skills, the battle's text layer runs out of tile pairs: one row comes out halfway and the first row of the commands does not come out, already with letter_spacing at 0"
type: bug
status: done
assignee: taro
---

Measured by Benteveo on 2026-10-03, when making the converter count the pool
(`workflow/tasks/*/el-espaciado-sin-tocar-codigo.md`).

The battle's text layer has 191 tile pairs (`TL_POOL_WHOLE`, from
`SLOT_VRAM` to `ITEM_BORDER_MAP`). The skill list with fourteen
names, the description, the party's four rows and the commands' two
asks for more than that. Measured in the ROM, in the battle of the case
`batalla` with Talan —actor 14, who can get to know 54— in front and
knowing them all, with the list open:

* with 0, the seventh row comes out halfway ("Candl…") and the first row of
  the commands does not come out;
* with 1, it cuts off at the sixth.

The captures, `pozo-0-14.png`, `pozo-1-14.png` and `pozo-2-14.png`, in
`/shared/capturas/2026-10-03-espaciado-1/`. The converter warns about it as a
WARNING ("battle text: the skill list asks for…"), with a bound that exceeds
the pool in all three spacings.

Possible paths, unmeasured: more pairs for the battle —`$3800-$3C00` is the
scene's tilemap, so it does not come from there—, or not drawing what the list
covers in RM2k while it is open.

## Carpintero, 2026-10-04

Tools worktree from `fe0f90ee`; ABL in the clone
`/extras/scratch/carpintero/abl` from `4cd8eb6`, branch `texto-de-la-pelea`.

### What was measured before touching anything

Benteveo's experiment (Talan in front knowing his 54, the list
open) with `abl.sfc` at +1: before opening it there are 118 free pairs, and
with the list open 16, and even so the seventh row comes out cut and the first
row of the commands does not come out. The 16 are pairs that went back to the pool
after the tilemap change: the rows that were composed when there were none
stayed blank and are not composed again, because their record did not
change. What the screen asks for is about 205.

**The list does not scroll**: `ba_skill_list` gathers 16 at most
(`BA_SKILL_MAX`) and the screen shows 14. With the 54, Talan can only
use the first 16, and the last two without seeing them. That is another matter; it goes in its own
task.

### Where there is VRAM

In the battle, from word 0 to `$1FFF` there is nothing of the battle: it is the
map's sprites —and in some allocations tiles or a tilemap—, which
`back_from_battle` uploads again whole, and word 0 is the scene's
transparent tile (64 bytes at zero). With BG2's base at 0 and not
at `SLOT_VRAM`, pair 0 is that one and 255 pairs are left, the ones a byte numbers.

### What was chosen: 447 pairs, from word 0 up to the scene's tilemap

First 255 were tried —only up to `$1FFF`, what a byte numbers, and without
touching RAM—: with +1 it was enough and 20 were left free, but with +2 the list
was cut again (`pozo-con-255-pares-2.png`). So the text goes up to
the scene's tilemap, `$3800`: 447 pairs, and **that is a screen with
all its cells inked** —the battle writes in even rows, fourteen
rows of 32 cells—, so no font or spacing exhausts it. The
other paths were ruled out without writing them: not drawing what RM2k covers
moved goldens by removing text, and composing only the visible rows does not help
because the list does not scroll (see below) and what is missing is a whole
page.

What it cost, in `text_layer.s`:

* A pair's number becomes a word (`TL_PAIR`, `TL_FREE`,
  `TL_UPLOAD`). The free ones and the ones waiting for the tilemap change share
  an array, some from the bottom and others from the top.
* RAM: the stage where a row is composed (`TL_STAGE`, 2 KB) moved
  to `ANIMB_BUF` (`$7E7000`-`$7E77FF`), the frame of the map's battle
  animation: it is only built on the map, and every return to the map clears it
  (`anim_buf_clear`). It is stated in `far_ram.s`.
* Returning the pairs that were waiting for the change was a loop in the vblank; with
  447 it did not fit, and it becomes an `mvn` in `tl_step`, outside the vblank.

And in the battle: `battle_bank_upload` (in `screen_bank.s`) clears word 0
—the blank pair, which is also the scene's transparent tile— and gives
the text the 447; `BG12NBA` sets BG2's base at 0. What is in
`$0000`-`$37FF` belongs to the map and `back_from_battle` already uploads it again
whole. The converter warns against 447 and not against the shop's 191.

### Measured

In the ROM, with the case `batalla` and Talan knowing his 54 (and separately his 16
with the longest names), the list open and the cursor going through it. Free at
the worst moment, out of 447:

    spacing     free
    +0          170
    +1          132
    +2          113

With all three everything shows: `pozo-despues-0.png`, `-1` and `-2`.

### Verified

* ABL's suite with +1 with only this change: **1045 green, no
  golden moved**. And again with the names one: see the other task.
* `just -f tools/justfile test`: 27. `cargo test -p rm2k-snes-convert`.
* What the suite does **not** cover: there is no case with a list that exhausts the
  191; only the experiment above covers it, which was not committed.

### What was found along the way

**The battle's list does not scroll**: it gathers 16 at most and shows 14.
It goes in `tasks/la-lista-de-habilidades-de-la-pelea-no-se-desplaza.md`.

## For taro

A battle with skills, with the list open and moving the cursor, and
going back to the map: that the characters and the background are fine (the battle now also
overwrites the map's sprites and whatever allocation it has below
`$3800`; `back_from_battle` already restored them). The captures, in
`/shared/capturas/2026-10-04-texto-de-la-pelea/`, with their LEEME.

Branches: tools, `worktree-agent-af8dc9ad89d8d7220`; ABL,
`texto-de-la-pelea` of the clone `/extras/scratch/carpintero/abl`.

On merging, reinstall `convert` (it warns against 447) and `battle` (the other
task). The runtime travels with the checkout.
