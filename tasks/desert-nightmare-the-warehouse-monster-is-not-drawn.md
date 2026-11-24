---
name: "Desert Nightmare: the silhouette coming down from the warehouse's cabinet is not drawn"
description: "On map 28, the warehouse's last room, the silhouette that comes down from the cabinet before the monster's battle is a small picture with no sprite tiles to spare, and the scene plays without it; map 21's shadow is drawn since 2026-11-21"
type: bug
status: todo
author: aguara
agents: [Aguará]
game: desert-nightmare
links:
  found-in: [desert-nightmare-the-screen-goes-black-before-the-first-monster]
  relates: [a-map-s-small-pictures-go-in-all-or-none, desert-nightmare-interiors-painted-now-that-the-box-is-a-window]
---

Seen by Aguará on 2026-11-21, closing
[`desert-nightmare-the-screen-goes-black-before-the-first-monster`](desert-nightmare-the-screen-goes-black-before-the-first-monster.md),
with the-advocate at `aguara-dn-black` (from `a537d967`) and the ports at
`aguara-dn-black` (from `d17237a`).

**What is seen**: in the warehouse's last room, map 28, after "None of the
doors lead out...", the room stays as it is for six seconds and then the
battle animation: RPG_RT shows over it a dark silhouette coming down from
the cabinet, a few pixels every half second (`LagerhausDach_Szene2` to `4`,
picture 1, at 50 %), and a piece of the cabinet (`LagerhausDach_Szene1`).
The same on the entrance, map 21: RPG_RT shows a shadow crossing the room
(`Lagerhaus_Szene2` and `3`, with the map). Until that task the screen
went black instead.

**Why**: they are small pictures now —a few objects each— and the maps
have no room in their sprites: map 28's sprite bank takes 256 of its 256
tiles with its characters, and not even the 4 tiles of the green marks
(`Interaktion`) fit. The converter's log says it as "WARNING, the pictures
'TextboxInnen, TextboxRahmen, Interaktion, …, LagerhausDach_Szene2, …'
aren't drawn here". `LagerhausDach_Szene1` and the cabinet's piece of map
21 are a scene's, and accepted without being done: see "whether it stays"
in `rm2k-snes/convert/src/map_pictures.rs`.

**What could make room**: a picture shown only while a page runs could
take the tiles of what that page hides or of a cache slot; or the map's
pictures could go in without the ones that never fit —see
[`a-map-s-small-pictures-go-in-all-or-none`](a-map-s-small-pictures-go-in-all-or-none.md)—,
though on map 28 that alone does not make room.

## Log

### 2026-11-22, Hornero: map 21 draws its shadow, map 28 still not

At the ports `89f77b4` and the-advocate `0ae40e0a`, the release's
`converter.log`: map 21 now carries `Lagerhaus_Szene2` ("the pictures
'Lagerhaus_Szene2, Kartencursor', 4 objects in 4 tiles from 128"), but map
28 still warns "the pictures 'Interaktion, …, LagerhausDach_Szene2, …'
aren't drawn here: with their 9 tiles the map fits no VRAM layout". The
silhouette coming down from the cabinet is still missing.

### 2026-11-22, Hornero: to todo, retitled

taro: the monster shows now, so the title names what is still missing,
map 28's silhouette. To be taken up with Hurón's
[`desert-nightmare-interiors-painted-now-that-the-box-is-a-window`](desert-nightmare-interiors-painted-now-that-the-box-is-a-window.md),
which changes what map 28's sprites have to share.
