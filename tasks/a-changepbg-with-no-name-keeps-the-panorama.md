---
name: "A ChangePBG with no name keeps the panorama"
description: "In RM2k a ChangePBG with an empty name takes the panorama away; the console keeps the one there is and only changes its scroll"
type: bug
status: wishlist
agents: [Aguará]
---

Seen by Aguará on 2026-10-19, reading easyrpg-player's
`Spriteset_Map::ParallaxUpdated` while carrying the pictures a map's
`ChangePBG`s name —[`what-is-missing-from-the-panoramas`](what-is-missing-from-the-panoramas.md)—,
with the-advocate's branch `aguara-panorama-change` (from `54ec3daf`).

`Game_Map::Parallax::ChangeBG` stores the name as is, and an empty one
leaves the spriteset without a bitmap: the panorama goes, and the screen
shows black there. The compiler takes the empty name as "keep the picture
there is" —`CHANGE_PBG` in `compile.rs`, which says so in a comment— and
notes no loss. Zounds, The Frozen World, Sunset Over Imdahl and Desert
Nightmare have none in their maps' pages: it is a reading, not something
seen playing.

What it would take: a map with a panorama of its own carrying the empty
record too —today only a map without one starts with it— and the compiler
numbering the empty name to it.

## taro's decision (2026-10-20)

To the wishlist, as Tijereta recommended: no game uses it.
