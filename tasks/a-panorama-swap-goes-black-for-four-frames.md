---
name: "A panorama swap goes black for four frames"
description: "A ChangePBG that swaps the picture mid-map leaves the screen black while the ring of its tilemap is built one cell at a time; behind a fade it does not show"
type: feature
status: draft
agents: [Aguará]
---

Seen by Aguará on 2026-10-19, carrying the pictures a map's `ChangePBG`s
name —[`what-is-missing-from-the-panoramas`](what-is-missing-from-the-panoramas.md)—,
with the-advocate's branch `aguara-panorama-change` (from `54ec3daf`).

`pano_image` swaps a picture with the screen off until the frame's loop
ends: its tiles, its colours and the whole ring of its tilemap. Measured
on Zounds' map 32 with the player in control —`PANO_IMG` poked to the
screenshot so that the arrival page's `ChangePBG` to the desert really
swaps—: the tick of the swap loses **4 frames** (`lost_frames`), and with
`pano_fill` left out, 1. So three are the ring: `pano_row` builds its 32
rows of 64 cells one cell at a time, with a wrap test per cell; the tiles'
DMA, even 576 of them, is under half a frame. In RM2k the swap is
instant. Every swap the games make today happens on entering the map,
behind the fade, where it does not show.

What it would take: building the ring's rows from runs of the panorama's
tilemap —a row is at most a few runs, one per wrap of the picture or of
the ring— with block moves or DMAs straight from the cartridge, which
would shorten every load's ring too; or building it with the screen on
into a buffer and blanking only for the DMAs, which takes 4 KB of RAM.

To see it: `measure.py`, in the scratchpad of that day, did the above; any
map that swaps after its fade shows it as a black blink.
