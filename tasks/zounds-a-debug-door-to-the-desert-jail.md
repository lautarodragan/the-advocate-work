---
name: "Zounds: a debug door to the desert's jail"
description: "One more door in Zounds' debug room: to the desert's jail —or dungeon—, past the crack, the desert's maze and the flags, with what the game has set by then"
type: feature
status: doing
assignee: Mulita
agents: [Mulita]
---

taro, on 2026-11-02, in their words, translated:

> Could you add another door to the debug map? One that leaves you in the
> desert's jail (or dungeon or whatever, I don't remember), after
> finishing the first dungeon (the crack) and going through the desert's
> maze and the flags (a total rip-off of Ocarina of Time's desert,
> honestly).

## What is known

The debug room is map 1000, `zounds/patches/manual/maps/Map1000.json` in
the ports, a fork; `[debug]` in `zounds/advocate.toml` says what it is,
and each door's page says in its comments what it sets and from where.
The new door follows the same pattern: what the game has set **by the
time the hero first stands in that place**, played the normal way —the
crack done, the maze and the flags crossed—: switches, variables, items,
party, levels if the existing doors set them.

Which map the "jail" is, and what is set on the way, is read from the
game's events, not guessed.

## Log
