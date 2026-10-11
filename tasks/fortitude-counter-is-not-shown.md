---
name: "The Fortitude counter is not shown"
description: "Eisen's minigame (map 95) keeps the count in variable 48 and shows it with a picture the ROM does not draw"
type: bug
status: done
assignee: taro
---

From the plan `world-and-what-follows.md` (question 4). The minigame on 95
compiles and is playable, but without seeing how much Eisen can endure: the
Fortitude counter is a picture the ROM does not draw. taro left it as a debt on
2026-09-27.

The paths that were on the table: showing variable 48 with the timer's digits,
which are already in the ROM; a message when it goes down. Before choosing one
has to check whether the minigame can be lost: if not, the counter is only
information.

**It can be lost**, checked in milestone 4 (`world-4-tasgarde-eisen-and-the-bridge.md`): each
jump and each ladder on 95 subtracts 5 from variable 48, which starts at 99,
and with the variable at zero parallel 56 says "So... tired... can't go
on...", sends Eisen back to the entrance, turns off the three levers and resets
it to 99. The route of `test_recorrido_capitulo_golden.py`, which goes straight
to the three levers and the hatch, ends with 4: without seeing the counter, any
detour forces starting over without the player seeing it coming. So the counter
is not only information.

## Taken on 2026-09-30

Decided by Hornero, with taro's authorisation to decide without waiting for
him: the path is **showing variable 48 with the timer's digits**, which are
already in the ROM, in the place and at the moment the original shows its
picture —measure it with RPG_RT on Wine—. A message when it goes down does not
warn before losing, which is what matters. It changes what is seen: the goldens
that move wait for taro's approval.

## What the original does (Chimango, 2026-09-30)

Measured with the 2015 RPG_RT on Wine, on a copy of the game whose EV0001 on
map 4 takes Eisen to 95. The captures, in
`/shared/capturas/2026-09-30-fortitude/original-*.png`.

* **They are three pictures**, fixed to the screen —they do not move with the
  camera—: 1 is the `Fortitude` label (110x25, blue italics) centred at
  (70, 10); 2 is the tens and 3 the units, red 16x16 digits (`Picture/0.png`
  to `9.png`) centred at (55, 30) and (70, 30).
* **They appear** when the entrance scene ends (EV0001 or EV0005, both on 95),
  right before "A NOTE ABOUT FORTITUDE": all three at once, at 99, without a
  fade.
* **They change** only when common 9, `FortitudeDisplay`, runs: each jump and
  each ladder on 95 —thirty-one pages— subtracts 5 or 10 from variable 48 and
  calls it. The common clamps 48 to 0..99, sets the tens with a chain of
  `ConditionalBranch` and the units with common 10, `CalculateSecondDigit`, on
  variable 49; **below 10 it erases the tens** (" 9", not "09"). After a jump
  from 99, 94 is shown.
* **They go away on changing maps**, and with the teleport's fade: RM2k 2000
  does not have the 2003 pictures flag, and `ShowParams` starts with
  `erase_on_map_change` on (easyrpg, `game_pictures.h`). A teleport to the
  same map does not erase them: parallel 56's "So... tired" sends Eisen to the
  entrance of 95 and the counter stays, at 99. On coming back from 99 to 95
  (after the missiles scene) there is no counter until the next jump, which
  shows only the digits: **the label does not come back**.
* The tint does not touch them —`affected_by_tint` starts off— and the message
  below does not cover them.

## Why common 9 never ran in the ROM

Variable 49 is named only by commons 9 and 10, and the sweep that gives each
variable a slot (`indices::variables`) looks at the pages of maps and troops,
not the commons. Without a slot for 49 the common does not compile, and a
`CallEvent` to a common that does not compile is skipped: the thirty-one jumps
subtracted and nobody drew anything.

Giving it a slot is not enough, and it was tried: with the commons in the
sweep, common 9 compiles to **1,345 bytes**, and since `CallEvent` is compiled
by pasting the body in place of the call, it is 1,345 bytes per jump —40 KB on
map 95, not counting the digits— for a chain of `if`s that decides which digit
to show. And it would add 71 variables that only commons name, which would make
other commons compile on other maps: outside this task.

## How it was done: common 9, declared as a counter

**`OP_COUNTER` (0x35)**, with the variable, `x` and `y`. The project declares
in `rm2k-snes.toml`, `[events] counters`, that common 9 is the counter of
variable 48, and the event compiler (`compile_counter`):

* compiles **`CallEvent` to common 9** as `OP_COUNTER` instead of pasting its
  body: 4 bytes per jump instead of 1,345;
* compiles **a `ShowPicture` of a digit in the counter's pictures** —the ones
  common 9 uses for digits, 2 and 3— as the same `OP_COUNTER`. It is what the
  entrance scenes do (EV0001 and EV0005): 48 at 99 and the two pictures with
  "9". It shows the variable's value and not the picture's, which is the same
  as long as the page shows the digits of the value it has just set: this is
  assumed, and it is written in `compile_counter`;
* takes **where** from the common: the middle of the centres of its two digit
  pictures, scaled to the console's screen, and the number centred there
  —(41, 20), the two 8x16 glyphs side by side—. It verifies that they are two
  pictures and each one always in the same place; if not, it stops the
  conversion.

The ROM (`counter_set`, in bank 1, and `counter_oam`) clamps to 0..99, erases
the tens below 10 and draws with the timer's glyphs, **below the timer and with
its palette untinted**, just as the original does not tint its pictures. The
counter goes away on changing maps (`enter_map_no_events`); a teleport to the
same map does not touch it, as in RM2k. `timer_oam` was split into
`glyph_oam`, which draws one glyph, and both use it.

Why this way and not the other ways:

* **Compiling the common as it is** (giving 49 a slot): 1,345 bytes per call,
  40 KB on 95. Discarded above.
* **A digit picture = a glyph**, a general rule without declaring anything: it
  still needs the common to compile, and on top of that it adds the
  `ShowPicture`s, ~110 per call. And each glyph centred in its picture leaves a
  gap between the tens and the units, because the pictures are twice as big.
* **Declaring it in the project** reinterprets a common, and that is a decision
  of the game: that is why it goes in the `.toml` and not in the compiler,
  which does not know about ABL. What is taken on trust is that common 9 draws
  48 in two digits without a leading zero; what is verified is where.

**What is not done:**

* **The `Fortitude` label** (picture 1): the timer's glyphs are digits and a
  colon. It remains as a debt, accepted without being done.
* **The clamping of the variable**: the common writes 48 clamped; the ROM
  clamps only what it shows. Nobody else reads it, and parallel 56 asks
  "<= 0", which gives the same.
* **A game saved on 95** comes back without a counter until the next jump:
  RM2k's pictures travel in the save, and the counter does not.
* **Above the window**: like the timer and the picture, priority 3. In RM2k the
  window covers the pictures; it is noticed only with a message at the top with
  the counter up (the "What are you doing, Professor?" of EV0055).

**Both live in bank 1** (`tools/runtime/counter.s`): after merging Cachirla's
`wanted_fits` bank 0 went over by 32 bytes. Left in bank 0 are the dispatch of
`op_counter`, the `glyph_oam_far` bridge and the three lines of the erasing,
the palette and the startup. `just espacio`: 55 bytes free in `release`'s bank
0.

## The test

`test_contador` (`rom/pruebas/rpgmaker/test_comandos_golden.py`), with the case
`contador`: on 95, 48 at 99 and pictures 2 and 3 with "9" like the entrance
scene; then the real jumps —the pages of events 15 and 16, called with
`CallEvent`, which subtract 5 and call common 9—, the second from 12; a black
tint and a `Teleport` to 6. Five new goldens: 99, 94, 7 without tens, 7
untinted on black, and 6 without a counter.

Of the bytecode: with the local compiler, `release`'s request with and without
the declaration, against the base answer, **only 33 pages of map 95** change
—the 31 jumps, parallel 56 and the two entrance scenes—.

## For taro

* **The new goldens wait for your approval.** Side by side with the original,
  in `/shared/capturas/2026-09-30-fortitude/`: `original-*` (Wine),
  `ahora-contador-*` (the ROM) and `lado-a-lado-99.png` /
  `lado-a-lado-94.png`. The "before" is that there was nothing:
  `antes-capitulo-95-llegada-sin-contador.png`. No existing golden moved.
* **When merging, install** `events` and `cartridge`: `just -f tools/justfile
  install events cartridge` (the runtime changes, and the compiler reads
  `[events] counters`).
* What `just pruebas` does not cover: the real entrance scene (EV0001) and
  parallel 56's "So... tired". Both compile to `OP_COUNTER` —it is in the
  bytecode diff— but no test plays them; playing them is what is missing.
