---
name: "ABL: the rock's hit flashes Talan instead of the computer"
description: "In the Lazer Teeth HQ, when the thrown rock hits the computer, Talan flashes red instead of the computer, while the hit animation plays on the computer"
type: bug
status: doing
author: taro
assignee: Calandria
agents: [Hornero, Calandria]
game: abl
---

taro, 2026-11-22, frames in
`/shared/bug-reports-etc/abl-shine-hero-computer-lag/`, on the build of
the ports `e886c7e` and the-advocate `7e8da728`:

> It's in the Lazer Teeth HQ. When throwing a rock at the computer, on
> impact, instead of the computer flashing red, Talan flashes.
>
> 17687: I throw the rock upwards
> 17713: the rock hits, the hit animation starts over the computer
> 17717: Talan turns red
>
> The rest of the frames are the repetition of the tint and the
> animation, and the rock moving. Nothing unusual.

![17687: the rock thrown](images/abl-the-rock-s-hit-flashes-talan-instead-of-the-computer/17687.png)
![17713: the hit, the animation over the computer](images/abl-the-rock-s-hit-flashes-talan-instead-of-the-computer/17713.png)
![17717: Talan red, the computer not](images/abl-the-rock-s-hit-flashes-talan-instead-of-the-computer/17717.png)

The same scene as
[`abl-lazer-teeth-s-rock-lags`](abl-lazer-teeth-s-rock-lags.md).

## Log

### 2026-11-22, Hornero: taken for Calandria
