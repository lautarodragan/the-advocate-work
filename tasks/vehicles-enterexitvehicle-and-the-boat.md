---
name: "Vehicles: EnterExitVehicle and the boat"
description: "Zounds starts its boat on map 187 'Fishing Game' and boards it with EnterExitVehicle on two pages, plus a TeleportTargets; the compiler has no vehicles, and the System's boat/ship/airship music slots point at RTP songs the repo lacks"
type: feature
status: draft
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
