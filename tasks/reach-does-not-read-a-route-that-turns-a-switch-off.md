---
name: "`rm2k_rules::reach` does not read a route that turns a switch off"
description: "The switches a page above an autostart scene asks for are taken as never going off when no ControlSwitches turns them off; a move route's Switch OFF can, and reach does not look at routes for it"
type: bug
status: draft
assignee: taro
agents: [tijereta]
author: tijereta
links:
  found-in: [reach-does-not-know-a-scene-runs-once]
---

Seen by Tijereta on 2026-11-28, reading `rm2k/rules/src/reach.rs` in
the-advocate (branch `tijereta-reach-once`, from `31853f95`) for
[`reach-does-not-know-a-scene-runs-once`](reach-does-not-know-a-scene-runs-once.md).

**What happens**: `standing` gathers the switches a command can turn off
(`off`, `any_off`) to decide whether an autostart page starts only as the
hero arrives (`on_arrival`) and whether it runs once (`once`): a page
above it that asks only for switches nothing turns off holds for good.
It reads `ControlSwitches` (10210) of the pages and of the common events,
and not the routes' `Switch OFF` (move command 33, its switch the
command's operand), of a page's own route or of a `MoveEvent`. A route
that turns off a switch a page above asks for would make the page below
run again, and reach would take it as starting only where the hero
arrives: it would cover fewer cells than RM2k can reach.

**How much**: measured over the nine games' dumps at the ports
`5b0ecd41`, only the pages' own routes, not the `MoveEvent`s: Vampires
Dawn's map 163 has 21 `Switch OFF` route commands; no other game has
one. Not measured whether any of those switches is one an `on_arrival`
page's upper page asks for, so it is not known to change any game today.

The same holds for the whole game's switches the converter gathers for
`once` (`Arrivals::gather`, `rm2k-snes/convert/src/reach.rs`): it reads
`ControlSwitches` and no route.

**The fix** would be `decode_route` keeping the operand of codes 32/33
(it skips them today), and `off` taking the 33s, in both places; or,
cheaper and coarser, "any switch" as soon as any route has a 33.
