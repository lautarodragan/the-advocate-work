---
name: "Two pans without a wait move one after the other"
description: "A PanScreen without Wait followed by another on the other axis pans diagonally in RM2k —each axis has its own target and both move at once—; the console runs them one after the other. Zounds' map 97 and The Frozen World's intro"
type: bug
status: doing
assignee: Tijereta
agents: [Tijereta]
game: zounds
---

taro, on 2026-11-20, translated:

> In Zounds, map 97, the event that runs automatically, `AutoRun`, does a
> camera pan that, I think, should run diagonally.
>
> ```
> Pan Screen: Up 12 Tiles, Speed 4
> Pan Screen: Right 12 Tiles, Speed 4 (Wait)
> ```
>
> The second `Pan Screen` command has a `Wait` the first one doesn't. I
> imagine that, in RPG Maker, that made both pans run at the same time,
> resulting in a diagonal movement.
>
> On that map, it makes sense for the movement to be diagonal.
>
> A couple of commands later it does `Pan Screen: Reset Position, Speed 4
> (Wait)`, and that one does run diagonally.
>
> I think this also affects The Frozen World's intro, and it probably
> happens in other games.

EasyRPG agrees (`Game_Player::StartPan` in `src/game_player.cpp`): a pan
moves `pan_finish_x` or `pan_finish_y` by its distance, from the finish
the previous one left, and `UpdatePan` walks the current position toward
both finishes at once, at the last pan's speed. So a pan without a wait
followed by one on the other axis is one diagonal move, and two on the
same axis add up.
