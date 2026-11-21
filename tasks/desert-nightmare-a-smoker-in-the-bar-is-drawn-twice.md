---
name: "Desert Nightmare: a smoker in the bar is drawn twice"
description: "In the bar scene after escaping the first monster, one of the seated smokers gets a copy about two tiles above for some 800 frames; probably EV0005, the top of his head and the smoke, changing graphic with the switch 'Leute schauen'"
type: bug
status: doing
assignee: Cardón
author: taro
agents: [Cardón]
game: desert-nightmare
---

taro, on 2026-11-21, translated (frames in
`/shared/bug-reports-etc/dn-bar/`, repeated ones trimmed, with
`runs.txt`):

> the scene after escaping the first monster and entering the bar. what
> to look at:
>
> * up to 71700, all normal
> * 71701: one of the people sitting, smoking, is duplicated — a copy
>   shows up about two tiles higher. I think it's `EV0005`, which seems
>   to be the top part of his head and the cigarette smoke, and it changes
>   graphic wrongly, possibly related to `0282: Leute schauen` and its
>   second page
> * 72499: it gets fixed

![Frame 71700: normal](images/desert-nightmare-a-smoker-in-the-bar-is-drawn-twice/frame-71700.png)
![Frame 71701: the smoker at the bar drawn twice](images/desert-nightmare-a-smoker-in-the-bar-is-drawn-twice/frame-71701.png)
![Frame 72499: fixed](images/desert-nightmare-a-smoker-in-the-bar-is-drawn-twice/frame-72499.png)

Like
[`desert-nightmare-the-warehouse-safe-turns-into-something-else`](desert-nightmare-the-warehouse-safe-turns-into-something-else.md),
an event whose page changes and shows a graphic it should not; the two
may share a cause.
