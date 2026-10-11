---
name: "World 6: Yun Town and Drust Camp"
description: "The optional part of the world in release: Yun Town (67, 70 to 73) and Drust Camp (68, 103, 199 to 201); the timer by reach, InputNumber and comparing against more than 32767"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-01: "let's add maps first". With the cartridge at 8 MB and
phase 1 of compression, `release` uses 58 of 128 banks. The plan is
`el-mundo-y-lo-que-sigue.md`, milestone 5: Yun Town (the timer by
reach, and layout 2 for its upper layer) and Drust Camp (comparing
against more than 32767, the `InputNumber` of 68 ev10).

It comes from `main` at `2de10ea4`, with `a0863e9e` (Mulita) merged shortly after.

# What was missing, counted

With the compiler instrumented (an `eprintln` in the `scan` with the last
level-0 command of each page that doesn't compile, in a `target/` in the
scratchpad, not committed), over the request `release` builds with the ten
maps: **in Yun and Drust a single page doesn't compile**, 68 ev10. And it doesn't
compile because of the `InputNumber`, before reaching the comparison against 35421:
the ROM didn't have `InputNumber`.

What the plan counted and was no longer needed:

* **Layout 2 for 67's upper layer** (163 tiles) is already there:
  Sorbe brought it (milestone 2). 67 converts without touching anything.
* **67's timer** is: with the digits in every map the
  converter stops ("the timer doesn't fit: the map already uses the 8 sprite
  palettes"). See below.

The page conditions of the new maps are switch ones, actor ones (68
ev7) and item ones (71 and 103): the ROM evaluates all three.

# The timer by reach

The timer's digits take up room in a sprite palette, and until today
they went in **every** map of `release`. Now they go in the ones where the timer
can be running: `timer_reach` in `tools/port/game_scan.py`, with the
pages that compile (the `scan`'s answer).

Each page is walked in order and without looking at its branches, following the map
it's in: a start after a `Teleport` belongs to the destination —the cans in
311 start it after jumping to 312—, and a `Teleport` after a
stop doesn't carry it —312's exit stops it and then goes to 313—. A
page in a map the timer reaches starts with it running; a
`CallEvent` to a common event walks the common event.

**Per map alone isn't enough**, measured: from 7, through the doors, you reach
all 96 maps of `release` (Lashe City leads to 64, 64 to the world). Not even with the
cut at the maps that stop it. You have to say where it never runs, and it's
a project list: `[graphics] timer_never_runs_in = [66]`, with its
why (the morning one stops on arriving at work, days before leaving
Lashe; the burning forest one stops at 312's exit). With that:

* 56 of the 105 maps carry the digits (the converter prints it: "the
  timer's digits go in…"): Lashe City, 64, 164, 312, 133 (a
  test map) and 95, because of the counter;
* the world and everything hanging from it, 17, 18, 310,
  311 and 313, and the other test maps don't carry them.

**Fortitude's counter in 95 uses the same digits** (`OP_COUNTER`), and
the first version left it without them: `test_contador` caught it. The maps
that call a common event from `[events] counters` always carry them; they're found by
the call and not by the bytecode because the `scan` doesn't know about the counters and
compiles it in place there.

The approximation **can only fail by leaving a map without digits**, which
then aren't visible: it doesn't break anything else.

# The `InputNumber`

It's 68 ev10, the door of Net's shop:

    VOICE  "What's the password?"
    InputNumber: six digits to variable 143
    if 143 is 35421: "Fine... come on in." and to 201

The other one in the game is 278 ev8 (four digits, against 727), which isn't in
any cartridge.

**In RM2k the number goes in the message window**, on the line below
its text, and the message doesn't wait for A: `CommandShowMessage` looks at the
next command, and if it's an `InputNumber` and the message leaves a line free, it puts it
inside. So the compiler joins the two into one opcode: `OP_NUMBER`
(`0x38`), with the variable's slot, how many digits and the message's
box. A lone `InputNumber`, or one after a four-line message,
still doesn't compile (there are none in the game), and neither do more than six digits.

In the ROM (`tools/runtime/number_input.s`): `op_number` opens the message
window like `op_message`, and when its lines are done, the digits line is
composed **with the same text compositor**, from a line in far
RAM (`NUMBER_LINE`, `$7E25B0`) instead of the text block. It's
`pick_active` at `PICK_NUMBER`: the choice and the number share the window,
the blocked page and the `pick_` bytes. The cursor is the choice's,
a `>` in the column before the digit: there's no sprite or drawing.

The keys are those of `Window_NumberInput::Update`: up and down change the
digit and wrap around, left and right move the cursor and wrap around,
A enters the number, B does nothing. It starts at zero with the cursor on the last
digit (`SetNumber(0)`, `ResetIndex`). A always refreshes the pages,
like `Window_Message::InputNumber`.

Two declared differences, in the comments: the keys count by
**edge**, like the choice, and easyrpg repeats them when held; and the number
is stored **saturated at 65535**, because variables are sixteen bits.

**Comparing against 35421**: the compiler accepts in "equal" and "not equal" a
constant from 32768 to 65534, as the variable's sixteen bits —the ROM
compares the words, and there the sign doesn't matter—. 65535 not, because it would
also be any saturated number; and no ordering comparison, which would be
signed. Saturating is what makes 100957 (35421 + 65536) not open.

Confirmed against easyrpg's source (it isn't compiled here):
`CommandShowMessage` (the `InputNumber` in the same window if
`pm.NumLines() < 4`), `CommandInputNumber`, `Window_NumberInput::Update`,
`SetMaxDigits` and `ResetIndex`, and `Window_Message::InputNumber` (the variable,
`SetNeedRefresh(true)` and `SetNumber(0)`).

# Tests

Mulita's work went in shortly after starting, so there are possible new cases;
none was needed: the tests use the game's pages.

* `rpgmaker/test_numero.py`: 68's door. The digits start at zero
  with the cursor on the last, and the keys wrap around; 35421 opens and leads
  to 201; 100957 stays at 65535 and doesn't open. **All three red** with the
  global compiler (the page doesn't compile: the digits don't open), and
  green with this branch's.
* `abl/test_yun_y_drust.py`: 67, 68 and the mines (103) just arrived at,
  with golden and `celdas_mal_dibujadas` at zero; and the world's two entrances
  (66 ev9 and ev11), walking, which lead to the town.
* The compiler's three in `compile.rs`: the number in the message
  window, the ones that don't compile, and the comparison as sixteen bits.

`just pruebas`: 952 green, and **`test_musica_techos.py` red**, which is
expected: the new themes, `arc1_v2` and `piperdun`, are missing. `just
techos` wasn't run. `just -f tools/justfile test`: 39 green. `cargo test -p
rm2k-snes-events` green. `NO_CACHE=1 just cartuchos` gives the three ROMs
identical to the cached ones (the `.o` and `.dbg` differ, which carry the date of the
generated `.inc` files).

# Goldens

* **New**: `yun-67-llegada`, `drust-68-llegada` and `drust-103-llegada`.
* **Moved**: the five of the Hover-Tram (map 13: `tram-900`, `tram-1200`,
  `tram-viaje-10`, `-30` and `-60`), 183 pixels —61 in the 1200 one— of the
  bottom row of passengers. It isn't the timer: 13 still carries it, and to
  make room for it a character goes down to thirteen colours. It was Future3:5, 53% of
  its pixels; since it's also in Yun's inn (72), the converter
  picks one that's in fewer maps, Future3:1, 25%, with its own pose
  bank.

In their commit, goldens only; the before and after in
`/shared/capturas/2026-10-01-yun-y-drust/`, with the password window.
**The merge awaits taro.**

# Space

With `just espacio`. The baseline is `a0863e9e` (`main`'s ROM, `6809f47d…`).

    release        banks    bank 0    bank 1     texts
    the baseline   58/128   245 B     3,828 B     94,417 B
    this branch    62/128   101 B     3,423 B    101,513 B

BSS 128 B and ZEROPAGE 4 B in both. Of bank 0's 144 bytes, 42 are the
code (`op_number` and `choice_tick`'s entry; measured in `test-special`,
which doesn't change maps: 1,045 → 1,003) and about 100 the tables of the new
maps —items and themes, as the plan says—. **Bank 0 is left at 101 bytes**:
the item tables to bank 1, which the plan puts in this milestone, weren't done
(they're nineteen reads in the runtime); with Puma adding three maps
on top, it's worth measuring on merging.

# What isn't done

* **`test_musica_techos.py` fails** (see above).
* **The earlier music drops a bit**: comparing the rates in
  `conversor.log` against the baseline's, four of the baseline's samples
  "limited by 311" go down from ~19 to 17.6 kHz (COWBL66, METRO60, SBRS160A,
  SYBS233), a copy of CRASH60B at 22 kHz goes away, and two go up (SIDE_60,
  ATMOS60A). It's 311's package again, now with the new samples
  of Yun's and Drust's themes in the baseline. Nothing was changed; taro decides it
  by listening.
* **The item tables to bank 1** (see "Space").
* **A lone `InputNumber`** or one after a four-line message doesn't
  compile: the game has none.

# What `just pruebas` doesn't cover

* The battles in the mines (103) and the ring (199): the encounters, their
  backgrounds and the new battlers (Slime2, bat, krawlie, spider, anima).
* The shops of the armoury (71) and of Net (201), and the inn (72).
* The other pages of Yun and Drust: it's checked that they compile, not that they do
  what they have to do.
* An `InputNumber` from a parallel page (the wait, like a
  message's): the game doesn't do it.

# On merging

Install `events` (`just -f tools/justfile install events`). `cartridge` didn't
change: it builds `number_input.s` from the checkout's runtime. The `.py` files only
changed in content.

# What taro has to test

* Enter Yun Town and Drust Camp from the world, walk, talk, the
  armoury, the inn, the mayor's house and the delicatessen.
* The door of Net's shop, in Drust: the digits window, the
  cursor (a `>`), and the password (35421) that opens it; a wrong number sends you
  back one step.
* The mines: the encounters and their battles.
* That the morning timer is still visible in Lashe City, and the
  burning forest one in 312.
* Listen to the themes that drop (see above).
