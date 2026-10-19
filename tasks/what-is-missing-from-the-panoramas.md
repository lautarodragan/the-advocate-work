---
name: "What is missing from the panoramas"
description: "What each panorama's path does not cover: ChangePBG to another image, those of a common event, the sky in mode 1 and the grain of the flattening"
type: feature
status: doing
assignee: Aguará
agents: [Aguará]
---

# What

What was left out of `panoramas.md`, for any game:

* **A `ChangePBG` that names another image.** Today it changes the loops and the
  speed and leaves the image. It would require converting each image that the
  map's pages name and uploading its tiles mid-map, with the
  screen off for a frame. In A Blurred Line there is none: the seven of the
  Hover-Tram name the map's own.
* **A `ChangePBG` in a common event, or in a map without a panorama.** Wally
  looks at the map's pages to know which axes are going to loop; one in a
  common event it does not see, and a map without a panorama has no layer to change.
* **The sky in mode 1.** At 2 bits an RTP sky ends up in four colors
  (105, the sunset). The study left another path untried: the
  panorama in BG2 at 4 bits and what is above in BG3 at 2, with BG3's
  priority above everything and the message window covering it via HDMA.
* **The grain of the flattening.** What is above goes in 8x8 cells: a cell
  that covers less than half ends up behind the hero. What is above with
  objects, in the edge cells, would fix it if there are palettes to spare.

# Why

None of them holds back A Blurred Line today: they are the edges of the rule, and what
another game is going to ask for.

# Log

**2026-10-19, taro**, playing Zounds: "a nice to have: showing the panorama
in this map. Is it feasible?" —`DownLoad Room` (map 32), in `Sala de
Máquinas` of the Hover Tram—. The map has no panorama of its own; its
parallel event 2, `SetBackGround`, sets `Zounds_DesertPan` (a BMP) with
ChangePBG at several scroll speeds, and at the end `Zounds_ScreenShot_01`
(a 320x240 PNG). Asked whether to take it out of the wishlist, measuring
the cost first: "Dale!".

Scope for now: the first two bullets —a ChangePBG naming another image, and
one in a map without a panorama—. `panorama-not-changed` in each game's
`build/release/degradations.json`, on 2026-10-19: Zounds 19 commands in 4
maps (20, 21, 31, 32), Frozen World 240 in 72 (113 in map 1), Sunset 8 in 3,
Desert Nightmare 3 in 2.
