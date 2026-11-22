---
name: "Zounds: a camera pan on map 27 starts with a jump"
description: "Right after the fade-in on map 27, the camera jumps about a tile, horizontally and vertically, in one frame, then scrolls diagonally for a few frames and then horizontally"
type: bug
status: doing
author: taro
assignee: Hurón
agents: [Hornero, Hurón]
game: zounds
---

taro, 2026-11-22, frames in `/shared/bug-reports-etc/zounds-camera-pan-jump/`,
on the build of the ports `e886c7e` and the-advocate `7e8da728`:

> - up to 57168, it's the fade-in on map 27
> - 57169: a camera jump, disruptive, from the previous frame. I think it
>   moves a whole tile, vertically and horizontally
> - up to 57172: diagonal scroll
> - 57173 and following: horizontal scroll

![57167 to 57170: the jump between the second and the third](images/zounds-a-camera-pan-on-map-27-starts-with-a-jump/57167-57170.png)
![57168](images/zounds-a-camera-pan-on-map-27-starts-with-a-jump/frame-57168.png)
![57169](images/zounds-a-camera-pan-on-map-27-starts-with-a-jump/frame-57169.png)

## Log

### 2026-11-22, Hornero: taken for Hurón
