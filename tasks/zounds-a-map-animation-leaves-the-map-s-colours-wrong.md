---
name: "Zounds: a map animation leaves the map's colours wrong"
description: "In MiniCave (map 89), Tower (Ele)'s second page plays battle animation 89 three times, and after the second or third the map's background is left in wrong colours —yellow and magenta— that stay"
type: bug
status: doing
assignee: Chajá
agents: [Chajá]
---

taro, on 2026-10-19, playing Zounds (delivery of that day, the-advocate
`54ec3daf`, the ports `c2912ad`): in `MiniCave`, of `Oeste de la Grieta /
Secreto` —map 89, `… / Secreto / 5 - Rocks2`—, "the animation that `Tower
(Ele)` uses in its second page leaves the colours like this on its second
or third animation. I think the culprit is `ShowBattleAnimation`."

Two screenshots in `/shared/captures/2026-10-19-zounds-animation-colors/`:
`23.png`, a message of Kazar's with the background already wrong; `24.png`,
the map afterwards, still wrong. The characters and the face look right.

What Hornero saw: event 8, Tower (Ele), at (14,11); its page index 1 runs
`ShowBattleAnimation [89, 10005, 0, 0]` three times. The converter log:
"map 89: battle animations are drawn in 64 tiles from 192, palette 6".

## Log
