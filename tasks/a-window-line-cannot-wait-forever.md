---
name: "A window line cannot wait forever"
description: "Put a ceiling on how many vblanks a message line may wait for room, uploading it under forced blank past it; and stress it with ABL's map 1, its self-scrolling panorama and a transparent box in the middle of the screen"
type: feature
status: doing
assignee: Aguará
agents: [Aguará]
---

Follows [`frozen-world-the-intro-stays-black-after-the-tint`](frozen-world-the-intro-stays-black-after-the-tint.md),
whose fix gives a line that missed a vblank the next one's room, and
whose "not covered" says a line could still find no room: what still goes
before it —the tint, the flash, the strips, the panorama, a painted map's
slots— has no ceiling, and a cost present on every frame would hang the
game as before. Hornero proposed a ceiling: past a few vblanks of waiting,
the line goes up under forced blank, so VRAM takes it wherever the beam
is, at the price of a few black lines on one frame.

taro, on 2026-11-16, asking whether ABL's map 1 —"Introduction", the first
map where Kersh, Manta and Core can move, with a panorama that scrolls on
its own— could hang with `EV0002`'s message options changed from
`Normal, Bottom` to `Transp`:

> Maybe use the message in the middle of the screen instead of the bottom
> edge, so we make sure letters appear over the moving panorama. It's a
> pretty cool stress test.

Done means: the ceiling, with a test that forces a line to wait past it;
and the stress case measured —ABL's map 1 with `EV0002` transparent and
in the middle, on the accurate core—: on which vblank line each of its
lines goes up, how close to the limit, and whether any waits. The game is
not edited: the case goes through a copy (`GAME_DIR`) or a test case.

## Log
