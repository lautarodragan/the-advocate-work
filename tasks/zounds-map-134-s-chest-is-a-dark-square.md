---
name: "Zounds: map 134's chest is a dark square"
description: "The chest at (2, 30) of map 134, the cave north of Misërenia, is drawn as a dark brown square on the console, closed and opened; RM2k draws it red"
type: bug
status: draft
game: zounds
---

Seen by Cardón on 2026-11-17, sweeping Zounds' chests for
[`zounds-some-chests-change-when-opened`](zounds-some-chests-change-when-opened.md),
with the-advocate `95863f36` and the ports `7ea4469`.

Map 134 ("2", under Cueva, Norte, Pueblo de Misërenia), event 47 at
(2, 30): `object1` character 6, the RTP's red chest, on its first page,
and facing left on its second, on switch 285. On the console it is a dark
brown square closed and a dark silhouette opened; EasyRPG draws it red.
The converter says, for that map:

    map 134: 10 graphic(s) without a palette of their own, drawn with someone else's: …, object1:6
    map 134: WARNING, by where they start up to 32 events are on screen at once and the cache has 27 slots: the ones drawn last wait for one

So it is drawn with another graphic's palette. It is the only chest in
Zounds that the converter lends a palette to (`grep "someone else's"` on
`converter.log`).

To reproduce: the debug room, `go_to_map(134, 2, 31)` in the ports'
harness, or EasyRPG with `--start-map-id 134 --start-position 2 31`.
Captures of both in `/shared/captures/2026-11-17-zounds-chests/`
(`console-map134.png`, `easyrpg-map134.png`).
