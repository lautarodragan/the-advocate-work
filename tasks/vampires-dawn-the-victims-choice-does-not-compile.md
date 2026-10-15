---
name: "Vampires Dawn: the victims' choice does not compile"
description: "The choice 'Talk / Suck Blood / Convert / Leave', whose options carry leading spaces and a \\_, refuses 210 pages on 48 maps, with no other culprit in them"
type: bug
status: draft
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
