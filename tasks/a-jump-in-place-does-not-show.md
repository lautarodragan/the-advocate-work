---
name: "A jump in place does not show"
description: "A route with Begin Jump and End Jump and nothing between —a hop on the spot— shows nothing on the console; in ABL's Hover-Tram the two robbed passengers should hop"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
game: abl
---

taro, on 2026-11-18, playing the build of the ports `0316595` on Mesen,
translated:

> Everything renders correctly now (which is incredible :D) but no NPC
> jumped at the robberies. Honestly I don't remember how it is in the
> original either. Is it intentional that they don't jump?

It is not: in map 13's `EV0028`, `MoveEvent` on `Jump1` (event 1) and on
`Jump2` (event 6) is the route `[24, 25]` —Begin Jump, End Jump—, a jump of
zero cells, which RPG_RT draws as a hop on the spot, right before each
"TRAM PASSENGER" line ("All of my creds are gone!", "Someone's taken my
gold and silver plated chronometer!"). Both are still events after the
Hover-Tram's fork (`abl-the-hover-tram-s-crowd-is-cut`), so the fork did
not cause it; whether it ever showed is to be measured.

Done means: the hop drawn as RPG_RT draws it (height and frames, from
EasyRPG's `Game_Character` jump code and RPG_RT where it matters), for any
event and the hero; a ROM test on the tram scene; other jumps in place
across the games found (a sweep of routes with nothing between 24 and 25).
