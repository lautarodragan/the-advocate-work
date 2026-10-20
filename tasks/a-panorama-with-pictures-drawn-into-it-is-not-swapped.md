---
name: "A panorama with pictures drawn into it is not swapped"
description: "Desert Nightmare's 34 and 82, and Sunset's 60, draw their map pictures into their own panorama; swapping it would take them away, so their ChangePBGs keep it"
type: feature
status: todo
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

## Defined (2026-10-20, Tijereta)

Checked against the release builds of the ports `68bf55b` (the-advocate
`8f290c39`): still so —"the map's pictures are drawn into its own
panorama" for Desert Nightmare's 34 and 82 and Sunset Over Imdahl's 60,
in their `converter.log`—. **Done**: each picture those maps' `ChangePBG`s
name is carried with the map's pictures drawn into it, as
`map_pictures::compose` does for the first, so the swap keeps them; the
three maps no longer list `panorama-not-changed`, and a Wally test with a
map whose panorama carries pictures and has a second one. **First step**:
whether `compose` can be called once per panorama with the same cells in
front of the hero, and what the extra pictures cost in ROM.
