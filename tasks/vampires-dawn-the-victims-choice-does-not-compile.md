---
name: "Vampires Dawn: the victims' choice does not compile"
description: "The choice 'Talk / Suck Blood / Convert / Leave', whose options carry leading spaces and a \\_, refuses 210 pages on 48 maps, with no other culprit in them"
type: bug
status: done
---

Seen by Chajá on 2026-10-14, with the-advocate `3438a90c` (branch
`chaja-five-options`, on `14e200fc`) and the ports `f775b66`, while checking
what the cancel branch of a choice gives back to Vampires Dawn.
**Read in `just culprits`, not played.**

`just culprits` in `vampires-dawn/` names `ShowChoice` as the **only**
culprit of 210 map pages, on 48 maps, and all 210 are the same choice:

    "                     \_Talk/                  \_Suck Blood/
     Convert/                     Leave"

—options padded with leading spaces to centre them, and the first two with
the `\_` escape—, `cancel_type` 4. The first is event 46 of map 6, page 1.
In the game it is the menu of a person the vampire talks to; in the port the
page does nothing.

Which of the two refuses it —the `\_`, the width of the padded lines, or
something else— was not measured. With the tools of `14e200fc` the count is
the same: it is not the cancel branch's.

To reproduce: `just cartridges` and `just culprits` in `vampires-dawn/`, and
in `build/release/culprits.json` the pages whose culprits are only codes
10140, 20140 and 20141.

**Checked on 2026-10-16 (Mulita)**, at the-advocate 759aa0ba, **reading the compiler, not with `culprits`**: since `2a142635`
(merged in `a9b3e144`) a choice's options go through the same
`escape_tail` as a box, and an escape the console cannot show —`\_`
among them— is dropped and noted instead of refusing the box. If the `\_`
was the culprit the 210 pages compile now; whether the padded lines fit
was never measured. A `just culprits` in `vampires-dawn/` says which.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
210 pages on 48 maps are the game's main interaction, so todo. **Done** is
`just culprits` in `vampires-dawn/` naming none of those pages for
`ShowChoice`, and the choice shown in the ROM with its options readable, in
a test that opens event 46 of map 6. First step: that `culprits` run; if
the `\_` was the culprit it is not since `2a142635`, and what remains is the
padded width, measured against the choice window.

## Checked (2026-10-20, Chajá): the choice compiles; the pages stop elsewhere

The first step, done: `rm2k-snes-events culprits --every-map` with the
global tools (installed from the-advocate `8f290c39`) over the
`events-request.json` of Vampires Dawn's `release` built that morning
(ports `68bf55b`). **`ShowChoice` is no longer a culprit of any map page**:
it is not in the culprits' table at all, so the `\_` was what refused it,
and `2a142635` fixed it. The padded options were not measured on screen.

But the pages do not come back. Counting every map page with a
`ShowChoice` whose options include "Suck Blood" —476 pages on 133 maps; the
210 above were only those whose sole culprit was the choice—, **263 are
still left out**, all but one at a `ControlVars` or a `ConditionalBranch`
(two of them with a box or an `InputNumber` as well); the other, at a shop.
The most frequent are plain `ControlVars` setting variables past the 256th
—380, 468, 301, 351—, which have no slot
([`variables-are-capped-at-256-slots`](variables-are-capped-at-256-slots.md)),
and branches on actor 11's level. Event 46 of map 6, the one the Done
names, is left out whole: its page's condition names variable 468, "which
has no slot in far RAM" (`degradations.json`). The throwaway script that
counted it read the dump's maps and `culprits.json`.

So what this task asked for is done, and what keeps the victims' pages out
now is mostly the variables' cap, which has its own task. Whether this one
closes, or waits for the test of event 46 the Done asks for, is taro's call.

## taro's decision (2026-10-20)

Closed, as Chajá recommended: what this task asked for —the choice compiling— holds since Chajá's check above. What still leaves those pages out is the cap of 256 variables, and that is followed in [`variables-are-capped-at-256-slots`](variables-are-capped-at-256-slots.md).
