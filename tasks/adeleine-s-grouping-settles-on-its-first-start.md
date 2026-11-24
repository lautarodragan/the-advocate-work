---
name: "Adeleine's grouping settles on its first start"
description: "reduce_colors refines one starting grouping to its local minimum; on ABL's map 3 that leaves a palette with only white. Other starts, judged by the same cost, halve the error of the mode-1 maps"
type: research
status: draft
assignee: taro
author: carpintero
agents: [Carpintero, cardon]
---

Measured by Carpintero on 2026-11-16, at the-advocate `705d24f5` and the
ports `299088c`: the research "Is there a better palette grouping?" in the
book, under A Blurred Line's research, has the tables.

`reduce_colors` (`snes/adeleine/src/pack.rs`) picks its first centres
farthest-first by mean colour, runs k-means, then up to 12 rounds of
reassigning cells. On A Blurred Line's map 3 (mode 1, 75 colours for five
palettes of fifteen) it keeps 36 colours and one palette holds only white;
Core's blood lands with the floor and comes out brown. 50 rounds instead of
12 change nothing. 20 more random starts, keeping the one the same cost
likes best, take the error of the five mode-1 maps down 62% in the replay
(on wally's pictures: map 3 0.090 to 0.059 dE2000 per pixel, 32 0.099 to
0.023, 105 0.057 to 0.008, 255 0.015 to 0.005), no call worse; the blood
is red. Not measured: the pictures, the screens and the battle, which call
the same function, and every other game.

The throwaway code is in the scratch of Carpintero's study
(`patch_seeds.py` over Adeleine; the harness replays wally's dumps).

## Log

### 2026-11-24, Cardón: a question for taro

Measured (the book's research "Is there a better palette grouping?"): 20
more starts take the mode-1 maps' error down 62%, with no call worse, and
Core's blood red again on map 3. It changes what is seen in every game and
every picture that calls `reduce_colors`, and costs conversion time per
call, not measured on the pictures, screens, battle or other games.

**To decide**: whether to take the restarts, and how many.
**Recommendation**: yes, as a todo whose first step measures the time cost
on all nine games and the goldens that move, shown to taro before merging.
