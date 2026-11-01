---
name: "Zounds: a debug door to the first dungeon"
description: "One more door in Zounds' debug map, to the start of the first dungeon —the cave inside the crack—, with the switches, variables, items and party the game has there"
type: tooling
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, on 2026-11-01, in their words, translated:

> Another little thing, smaller: could you add a new door to Zounds'
> debug map, that leaves you at the start of the first dungeon?

The first dungeon is the cave inside the crack, the one that plays
`Zounds_Dungeon_01` (see
[`zounds-desert-flower-plays-in-the-cave`](zounds-desert-flower-plays-in-the-cave.md)
and [`zounds-no-way-back-from-map-81`](zounds-no-way-back-from-map-81.md)).
The debug map and how its doors are made: [`zounds-a-debug-map`](zounds-a-debug-map.md).

**Done**: a door on Zounds' debug map (map 1000) to where the game first
enters the dungeon, setting the switches, variables, items, gold and party
the game has at that point —read from the dump, following the story—;
a test that walks through it and lands there; the port's page in the book
says it.
