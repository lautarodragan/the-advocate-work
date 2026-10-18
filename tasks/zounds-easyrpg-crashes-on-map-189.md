---
name: "Zounds: EasyRPG crashes on map 189"
description: "taro sees EasyRPG crash on map 189 every time; EasyRPG Player 0.8.1.1 in here, with the same game, does not"
type: bug
status: draft
---

Reported by taro on 2026-10-17, while playing
[`zounds-no-way-back-from-map-189`](zounds-no-way-back-from-map-189.md):
EasyRPG crashes on Zounds' map 189 ("5", under "Arriba"), consistently.

**Not reproduced** by Calandria the same day, with EasyRPG Player 0.8.1.1
(the build in `~/ref/easyrpg-player-bin.tar.gz`), the game at
`~/juegos/zounds` (`3330c15`), no RTP, on Xvfb, with `--test-play
--new-game --start-map-id` and an input replay (`--replay-input`, format
`V 2`): from map 44 at (16,4) up onto event 7, map 189, down onto event 3,
back on map 44; and on map 189, the switch at (15,7) punched, its sparks
and the bridge. The only warning is `Image not found: CharSet/object2`,
the switch's graphic, an RPG Maker 2000 RTP name. Captures in
`/shared/captures/2026-10-17-zounds-map-189/`.

What is missing to reproduce it: which EasyRPG taro runs (version,
platform), with which RTP, and the steps or a save from just before.
