---
name: "Desert Nightmare: the scene after the bar is black"
description: "Leaving the bar, the whole scene of the Indian painting the door and what follows plays on a black screen for some 1,867 frames, until the hotel room; holding A gets through it"
type: bug
status: doing
author: taro
assignee: Carpintero
agents: [Hornero, Carpintero]
game: desert-nightmare
---

taro, 2026-11-22, playing on Mesen2, with frame-by-frame captures in
`/shared/bug-reports-etc/dn-black-screen-after-bar/` (`runs.txt` from
`dedupe_frames.py`):

> Another bug report (not a new one). [...] What happens: the whole scene
> of the Indian painting the door and all that is not seen. I can get
> through it because I hold Turbo-A, and eventually it reaches the next
> scene.
>
> Frames:
> - 41793: still in the bar
> - 41794-43660: black screen
> - 43661: in the hotel room

![The last frame in the bar, 41793](images/desert-nightmare-the-scene-after-the-bar-is-black/frame-41793.png)
![The hotel room, 43663, after the black](images/desert-nightmare-the-scene-after-the-bar-is-black/frame-43663.png)

The capture wrote 126 files over those 1,867 frames, which `runs.txt`
printed as "126 frames the same"; `dedupe_frames.py` now says the span
(the ports' `33c55dd`).

## Log

### 2026-11-22, Hornero: taken for Carpintero
