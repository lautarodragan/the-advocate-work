---
name: "`rm2k_rules::reach::standing` does not know a scene runs once"
description: "An autostart scene that turns on the switch of the page above it runs once, from where the hero first arrives; reach takes it as starting wherever a recall can put him, and on ABL's Hover-Tram that keeps four seated people out of the background"
type: feature
status: draft
assignee: taro
agents: [cardon]
author: cardon
game: abl
links:
  found-in: [abl-the-hover-tram-s-crowd-is-cut]
---

Seen by Cardón on 2026-11-18, in
[`abl-the-hover-tram-s-crowd-is-cut`](abl-the-hover-tram-s-crowd-is-cut.md),
with the-advocate at `55268148` (branch `cardon-hover-tram`).

**What happens**: map 13's `EV0028`, page 1, autostart, asks for nothing;
page 2 asks for switch 69, which page 1 turns on before it teleports the
hero away. So page 1 runs once in the whole game, from where the hero
arrives the first time —(2,7), from map 9—. `rm2k_rules::reach` starts it
where the hero can arrive on the map (`Run::on_arrival`), and on ABL that
is any open cell: its recalls of a computed place (`CE42`, `CE44`: the
hero's cell, five rows up) can put him on any cell one can step on, of
any map (`any_open`). Started on any aisle cell, the scene can seat him on
any seat from x=8 on, or beside one: `Leave1`, `EV0004`, `EV0007` and
`EV0026` stay objects for it.

**How to see it**: the converter's log of ABL's `release`, map 13: "17
event(s) stay objects, someone can stand behind what it draws past its
cell: 3, 4, 7, …". With the request's `reach.any_open` set to false by
hand, `wally map` takes all seven seated still people.

**Since 2026-11-18** ABL's map 13 has a fork that bakes its still crowd
by hand (stage 2 of the task above), so the case is no longer seen
there: it still holds for any other map whose scene runs once.

## Comments

### 2026-11-24, Cardón: a question for taro

**What to decide**: whether this is worth doing. Tijereta measured on
2026-11-22 (log above) that no map of any game hits it today —ABL's map 13
is forked by hand, and the other `any_open` maps change nothing—; it would
come back only on an unforked map with a once-run scene in a game that
recalls computed places.

**Options**: (a) `todo`: teach `rm2k_rules::reach::standing` that a page
turning on its own successor's switch runs once, from the first arrival;
(b) cancel, reopened if a converter log shows it.

**Recommendation**: (b): the measure says it costs nothing today, and the
rule is subtle enough to get wrong without a case that shows it.

### 2026-11-28, taro: a comment

> How would this task impact the Hover Tram scene, had it no fork?

## Log

### 2026-11-22, Tijereta: no game hits it today

Retitled with the function's path: `reach` is the module,
`rm2k/rules/src/reach.rs` in the-advocate, and the start of a page that
runs on arrival is decided in `standing` (`Run::on_arrival`, seeded with
`arrival`, which already holds the `any_open` cells), which `covered`
calls.

**Measured**, with the-advocate `0ae40e0a`'s global tools and the ports
at `89f77b4`: the bug needs `any_open`, and only three games set it
—their `converter.log` says "the hero can be on any cell one can step
on": ABL, Vampires Dawn and Zounds—; the other six start a once-run scene
only where the hero arrives, which is right. Those three were built with
a throwaway `wally` on the PATH that ran each map's request twice, as the
converter asked and with `reach.any_open` false, and compared the "stay
objects" lines. The fix can only take away cells `any_open` adds, so a
map where turning it off changes nothing cannot be touched by it.

* **Vampires Dawn and Zounds**: no map changes.
* **ABL**: maps 17, 199, 288, 291, 295, 307 and 315 keep one to three
  more events as objects ("someone can stand behind…") with `any_open`,
  and none of them has a page `on_arrival` takes —an autostart asking
  for nothing, under switch-only pages, that teleports the hero away—:
  that is the recall itself, taken on trust, not this bug. ABL has 39
  such pages (a loose filter over the dump: a superset of what
  `on_arrival` takes), all on maps where `any_open` changes nothing,
  map 13 included now that its crowd is baked by hand.

So today it shows in no log or degradation of any game; it would come
back on a map that has such a scene and is not forked, in a game that
recalls computed places.
