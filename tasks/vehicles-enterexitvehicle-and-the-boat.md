---
name: "Vehicles: EnterExitVehicle and the boat"
description: "Zounds starts its boat on map 187 'Fishing Game' and boards it with EnterExitVehicle on two pages, plus a TeleportTargets; the compiler has no vehicles, and the System's boat/ship/airship music slots point at RTP songs the repo lacks"
type: feature
game: zounds
status: wishlist
author: aguara
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39`.

**Measured**: `EnterExitVehicle` (10840) on 2 map pages, `TeleportTargets`
(11810) on 1, `boat_map_id` 187 at (1, 13) in the tree's start; the
System names `boat1`, `boat2` and `vehicle1` as the vehicles' music (RTP,
missing from the repo). `ChangeVehicleGraphic`, `SetVehicleLocation` and
the vehicle branch of `ConditionalBranch` are not used. The two other
missing RM2k commands Zounds uses are in its debug common event only:
`ChangeParameters` (6) and `OpenMainMenu` (1).

**What it would take**: a vehicle is a second hero —its own sprite, its
passability rule (water), its music— that the hero boards and leaves;
none of the eight ports has needed it until now, so it is engine work
with Zounds as the first user. The fishing mini-game on map 187 is what
depends on it.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
Only Zounds' fishing mini-game needs it. **Done** is `EnterExitVehicle`
boarding and leaving the boat —its sprite, water as its passability, its
music—, `TeleportTargets` compiled, and a test game page that boards the
boat and crosses water; the other vehicles' commands are left for when a
game needs them. First step: easyrpg's `Game_Vehicle` and what of the
hero's movement it changes.

## Log

### 2026-11-22, Carpintero: Zounds is the only game that uses them

Counted in the `data/` of the nine games of the ports at `89f77b4`,
every map and common event: `EnterExitVehicle` (10840) is only in
Zounds, once each on maps 186 and 187; `TeleportTargets` (11810), only
on its map 2; `ChangeVehicleGraphic` (10650) and `SetVehicleLocation`
(10850), in none. So `game: zounds`. Still not compiled on
the-advocate `0ae40e0a`: `just culprits release` in `zounds/` gives
`EnterExitVehicle` as the culprit of its 2 pages, alone in both, and
`TeleportTargets` as one of the culprits of its page.
