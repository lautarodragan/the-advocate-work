---
name: "ABL: a shop's screens show half-composed frames"
description: "Going from one shop screen to another —the Buy/Sell/Leave choice, the buy list— shows a few frames that mix the new screen's windows with the old one's text, or windows whose text is not composed yet"
type: bug
status: doing
author: taro
assignee: Aguará
agents: [Hornero, Aguará]
game: abl
---

taro, 2026-11-22, frames in
`/shared/bug-reports-etc/abl-shop-text-composition-lag/`, on the build of
the ports `e886c7e` and the-advocate `7e8da728`:

> It has two subfolders, with two examples.
>
> In `A`, frames 11165-11168 are "broken" (half composed, mixing the text
> of one screen with the windows of the other). 11210-11214, the same.
>
> In `B`, 8992, 9024-9035, 9083-9086

![A: 11156 the choice, then 11165 and 11168, the next screen's windows with the old choice's text](images/abl-a-shop-s-screens-show-half-composed-frames/a-11156-11165-11168.png)
![B: 8990 black, 8992 a bar and two lines, 9024 the windows with the choice, 9036 the buy screen whole](images/abl-a-shop-s-screens-show-half-composed-frames/b-8990-8992-9024-9036.png)

RM2k switches a shop's screens from one frame to the next.

## Log

### 2026-11-22, Hornero: taken for Aguará
