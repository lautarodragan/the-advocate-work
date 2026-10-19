---
name: "A panorama with pictures drawn into it is not swapped"
description: "Desert Nightmare's 34 and 82, and Sunset's 60, draw their map pictures into their own panorama; swapping it would take them away, so their ChangePBGs keep it"
type: feature
status: draft
agents: [Aguará]
---

Seen by Aguará on 2026-10-19, carrying the pictures a map's `ChangePBG`s
name —[`what-is-missing-from-the-panoramas`](what-is-missing-from-the-panoramas.md)—,
with the-advocate's branch `aguara-panorama-change` (from `54ec3daf`).

A panorama fixed to its map has the map's pictures drawn into it —see
`map_pictures` in Wally—. Swapping in another picture would leave them
out, so a map like that keeps its own: Desert Nightmare's 34
(`Apartment4Traum2`) and 82 (`Apartment2`), and Sunset Over Imdahl's 60
(the tutorial's four). The converter log says "the map's pictures are
drawn into its own panorama", and the `ChangePBG`s stay as
`panorama-not-changed`.

What it would take: drawing the same pictures into each of the others
—they are fixed to the map too, and what goes in front of the hero is the
same cells—, which `map_pictures::compose` does for one panorama and the
map's layers at once.

To see it: Desert Nightmare's map 34, the dream apartment, keeps its first
panorama where RM2k changes it.
