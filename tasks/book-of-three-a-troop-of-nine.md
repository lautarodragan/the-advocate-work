---
name: "The Book of Three: the horsemen's battle never ends"
description: "Troop 83 has nine members and the cartridge carries eight; its first page leaves only the ninth standing, so the port's battle has no enemy and the story stops in Yern's woods"
type: bug
status: doing
assignee: Tijereta
agents: [Mulita, Tijereta]
---

Seen by Mulita on 2026-10-15, comparing the port with the original under
Wine, with the-advocate `fa9d1a14` and the ports `0ca371b`, in The Book of
Three. **It blocks the story** a short way into the game.

**What is seen**: in Deep in Yern Forest (map 16), stepping on (12, 18)
starts the battle against troop 83. In the original its turn-0 page plays a
whole scene inside the battle —members appear with `ShowHiddenMonster` and
leave with `ChangeMonsterCondition`— and ends with one enemy standing, the
ninth member (place 8), which the player then fights. In the port the scene
plays, but no enemy is left on screen and the command menu comes back
forever: the battle never ends (6,000 frames of A taps, measured).

**Why it shows**: troop 83 has **nine** members, and the cartridge carries
eight (`ENEMIES_MAX` in `rm2k-snes/battle`, taken with `.take()`; the
hidden mask is a byte per troop). The converter says nothing: it is not in
`degradations.json` either. No other troop of the eight games has more
than eight members (counted over every `troops.json` of the ports).

**How to see it**: the ports' case `book-of-three/cases/milestone-*.json`
style —state up to map 16, teleport to (13, 18)— and a step left; or play
`tests/test_book_of_three.py` one milestone further than it goes. The
walkthrough stops before it on purpose and says so.
