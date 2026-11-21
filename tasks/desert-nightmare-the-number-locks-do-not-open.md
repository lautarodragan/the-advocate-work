---
name: "Desert Nightmare: the number locks do not open"
description: "Four locks are left out: an InputNumber with no message of its own, which the ROM does not do, and two codes past sixteen bits —71456, the warehouse's safe that ends day 1, and 136264—"
type: bug
status: testing
assignee: taro
game: desert-nightmare
agents: [Hurón, Tijereta]
---

Seen by Hurón on 2026-11-19, at the-advocate `62b6e5cb` and the ports
`1ea90bf`, for
[`desert-nightmare-what-it-takes-to-be-playable`](desert-nightmare-what-it-takes-to-be-playable.md).
Read from `just culprits` (`build/release/culprits.json`), not played.

The four map pages that do not compile are the game's number locks:

* map 28, event 12 page 3: the warehouse's safe, **71456** in five
  digits —its key is the way out of the warehouse, the end of day 1—;
* map 42, event 3 page 1: five digits into variable 210 (the chest of
  day 2, 26538 in the walkthrough);
* map 123, event 5 page 1: four digits, **1759**, the tailor's door of
  day 3;
* map 156, event 10 page 1: **136264** in six digits, the chest in the
  second vault of day 3.

All four put the `InputNumber` after the message is over —a
`ChangeFaceGraphic` or the box closed in between—, which in RPG_RT is a
window of its own with only the digits; the compiler takes an
`InputNumber` only inside the message before it (`number_inputs` in
`compile.rs` of the event compiler). And two compare against numbers a
variable of the ROM cannot hold: it keeps sixteen bits, saturating at
32767, and RPG_RT's go to 9,999,999 (`NUMBER_DIGITS_MAX` and
`runtime/number_input.s`).

## Log

### 2026-11-20, Tijereta: taken

By Tijereta, from Hurón's ranking in `desert-nightmare-what-it-takes-to-be-playable`. taro: "dale!".

### 2026-11-20, Tijereta: what the four pages do, and the design

Read from `data/maps/` of the ports at `a34b393`. Between the message and
the `InputNumber` each page has a `ChangeFaceGraphic` with no face (and map
156 a `ShowPicture`, the slip with the code). So RPG_RT's
`CommandShowMessage` does not join them, and `CommandInputNumber` pushes a
message with **only** the number: easyrpg's `Window_Message` opens its
window —the same message window, with the System's frame, where the
message options put it— and `StartNumberInputProcessing` puts the digits at
`y + contents_y`, the **first line**, past the face if there is one. The
ROM already draws digits under a message's lines (`number_tick`, the line
after the box's last); a standalone one is the same with a box of **no
lines**. So no new window kind: the compiler compiles a lone `InputNumber`
as `OP_NUMBER` with an empty box (`Messages::add(&[])`).

The codes, from the pages themselves: map 28 asks var 207 == **71456**
(5 digits), map 42 var 210 == **26538** (5), map 123 var 248 == **1759**
(4), map 156 var 274 == **136264** (6). 26538 and 1759 fit sixteen bits;
71456 and 136264 do not.

Every game in the ports, swept for constants past sixteen bits
(`ControlVars` and branches) and `InputNumber`s: the only branches past
them are DN's two safes. A Blurred Line's common 45 sets six variables to
999999 and Zounds' commons 65 to 9999999 (and mod 100000), but those go
through `ControlVars` and var-vs-var compares.

**The design, wide variables, chosen as the cheapest that is correct:**

* Making every variable 32 bits doubles their RAM and the save and touches
  every opcode that reads or writes one (`var_read`, `var_write`, `OP_VAR`'s
  arithmetic and saturation, the text's `\V`, the cell tests, menus, the
  debug screen…), for two variables.
* A wide compare alone is not enough: the number has to get to it, and a
  sixteen-bit variable cannot carry 71456.
* So a variable is **wide** when a branch compares it with a constant
  sixteen bits do not hold **and** nothing in the game does anything with
  it but `InputNumber` and branches against a constant (no `ControlVars`,
  no `\V`, no page condition, no troop page, nothing `extra` names). A wide
  variable keeps its slot for the low word and gets a **second slot for its
  high word, after every other slot** —so nobody's slot moves—; both
  travel in the save as any variable. `OP_NUMBER` gets a
  `high` byte —the high word's slot, or the variable's own when narrow— and
  writes the number whole into the two; `OP_IF_WIDE` (0x58) compares the
  two words as a signed 32-bit number with a 24-bit constant. A variable
  that fails the rule stays sixteen bits and its branch past them does not
  compile, as before: nothing that compiled stops compiling.
* `InputNumber` takes up to seven digits now (RPG_RT's cap); into a narrow
  variable it still saturates at 65535.

Opcodes: 0x5A `OP_IF_WIDE` at first, with 0x58 and 0x59 held as `OP_RESERVED_58/59`
(Calandria's and Chajá's) so the declaration compiles; neither took one, and after
merging main it is **0x58**, the next free, with no held ones.

### 2026-11-20, Tijereta: built and played

the-advocate `0d7ab7ed` and the ports `a93ca63`, branch
`tijereta-number-locks` in both. The four pages compile. Played in
snes9x with a throwaway script over the ports' `games.py`, each lock with
its code and with a wrong one:

    map  code     wide  right code                       wrong code
     28  71456    yes   switch 247 on, the safe opens     71457: "That was wrong."
     42  26538    no    switch 308 on, the chest opens    —
    123  1759     no    switch 488 on                     1758: "Nothing happened."
    156  136264   yes   switch 578 on                     136265: "That didn't work."

Map 28's page needs switches 246 (the poster) and 254, and 261 so the
warehouse's arrival scene does not run: set by hand after the jump.

Against EasyRPG (a new game started on each map, Hurón's build): the lone
`InputNumber` is the message window with the digits on the first line,
past the face when there is one (156), and so it is on the console. The
differences are the port's, not the lock's: the frame EasyRPG shows is the
game's own picture box, which the console does not draw on 28 and 42, and
on 123, where it does draw it, its pictures go over the text and the
digits cannot be read (noted in `desert-nightmare-own-message-frame` and
in the port's known issues). The cursor is the ROM's `>` and not RPG_RT's
frame around the digit, as under a message since that was done. Side by
side: `/shared/captures/2026-11-20-number-locks/`.

The keys go one at a time: one pressed while the digits' line is being
composed is lost (the harness waits for `msg_state` between presses). It
was so already under a message.

Tests: `test_desert_nightmare_safe.py` in the ports —71456 opens, 71457
and 5920 (71456 cut to sixteen bits) do not, and the variable reads back
whole from its two slots—, red at `4f38ea03` (the page did not compile)
and green with the branch; and in the event compiler,
`a_number_on_its_own_goes_in_a_box_with_no_lines`,
`a_wide_variable_takes_the_number_whole_and_compares_it_wide`,
`a_variable_is_wide_when_only_a_number_and_branches_touch_it`, with the
two that were already there updated (seven digits compile now, a lone
one too).

In Desert Nightmare's release, 207 and 274 are the wide ones: their high
words in slots 205 and 206, past the other 205.

### 2026-11-20, Tijereta: merged with main, verified, to testing

Main moved four times while this was being verified (Calandria's cell
events and one font, Chajá's ControlVars and copies that draw, Cardón's
painted cells); each was merged. On the way:

* **`OP_IF_WIDE` is 0x58**: neither of the held numbers was taken.
* **Zounds' `FAR3` overflowed by 53 bytes** with `wide_compare` in it, and
  Zounds has no wide variable: the converter now says how many a
  cartridge has, `WIDE_VARIABLES` in `mapdata.inc`, and the runtime
  leaves `wide_compare` and `op_if_wide` out without one, as it does the
  System table with one System.

Verified on the-advocate `98f2ae7d` and the ports `a4f94f4` (both
branches with main merged), with `events cartridge convert mapdata
screens` installed locally: `just test` green; `crate-test events` and
`mapdata` green; ABL's suite, with `test_cores` and `test_number`
(Drust Camp's six digits under a message), 1723 passed, 2 skipped, no
golden moved; `just boot` 175 passed, `test_desert_nightmare_safe.py`
among them; `just space` builds every cartridge of the nine games. What
is left after this, by cartridge (bank 0 / 1 / $C0 / $C1, bytes): Desert
Nightmare 4171 / 1181 / 2118 / 2876, Sunset 4099 / 1757 / 2124 / 1607,
Zounds 4114 / 1696 / 2333 / 1104, ABL 4078 / 1738 / 2290 / 2599.

**Not covered by the suite**: maps 42, 123 and 156 were played by hand
(a throwaway script), not by a test; the comparisons other than `==` on a
wide variable are only in the compiler's tests, no game uses them; a
wide variable in a saved game, loaded, was not tried (it travels as two
slots of the variables, which the save already carries).

**To install when merging**: `events cartridge convert mapdata` (with
`bytecode` inside them). Every cartridge changes: `OP_NUMBER` has one more
byte and `mapdata.inc` says `WIDE_VARIABLES`.
