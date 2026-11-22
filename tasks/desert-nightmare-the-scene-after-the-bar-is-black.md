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

`runs.txt` reads "126 frames the same" for 41794-43660: those are the
files, not the frames. taro paused the capture over the black and started
it again just before the hotel, with Mesen2's rewind. `dedupe_frames.py`
now says such a run's files and the span they cover (the ports'
`769676f`).

## Log

### 2026-11-22, Hornero: taken for Carpintero
