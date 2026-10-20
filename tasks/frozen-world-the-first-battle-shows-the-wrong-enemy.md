---
name: "Frozen World: the first battle shows the wrong enemy"
description: "The game's first battle, started by a plant on the map, shows a dark hooded figure —the final enemy's or the intro's wizard's graphic— instead of the plant"
type: bug
status: doing
assignee: Tijereta
agents: [Tijereta]
---

Seen by taro on 2026-10-19, playing Frozen World's delivery of that day
(the ports `acff443`, the-advocate `2c350d8f`), after Carpintero's fix of
the cursor's graphics.

**What is seen**: the first battle of the game is started by a plant's
sprite on the map, and on the battle map the enemy is a dark hooded
figure; a later battle shows the plant, as expected. taro thinks the
figure is the final enemy's, or at least the wizard of the intro: it makes
no sense so early. Captures in
`/shared/captures/2026-10-20-frozen-world-wrong-enemy/`: `1-first-battle.png`
(the figure), `2-plant.png` (a later battle with the plant).

**Probably related**: the battle is map 1, where the enemy is an event
whose graphic is set by the custom battle system; Carpintero's
[`frozen-world-the-cursor-keeps-the-wrong-graphic`](frozen-world-the-cursor-keeps-the-wrong-graphic.md)
changed how route graphics are numbered across jumps and in common
events, and
[`frozen-world-plates-in-the-battle-are-drawn-with-other-colours`](frozen-world-plates-in-the-battle-are-drawn-with-other-colours.md)
says map 1 has no palettes to spare.
