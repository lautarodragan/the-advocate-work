---
name: "The Vampires Dawn maps that don't fit in VRAM"
description: "Nine Vampires Dawn maps —Shannar, Uruya, Melsan, Asran among them— are left out because of VRAM: five with no layout that holds background, sprites and upper layer, two with no room for the message window and two because of their panorama in mode 1"
type: feature
status: draft
---

What is left out of Vampires Dawn because of VRAM, measured by Aguará on
2026-10-11 (`vampires-dawn-builds-from-its-toml.md`) and confirmed
by Mulita when returning the eleven from "the ROM"
(`one-quantization-per-character-for-the-poses.md`, 10 out). Each one with its
error in the comment of `excluded` in `vampires-dawn/rm2k-snes.toml`
(ports `a85b7e3`); not checked today.

| map | what it says |
|---|---|
| 15 Shannar | "this map can't carry a message window": 576 of background, 436 of sprites, 130 of upper layer, and no layout leaves the window's 8 KB |
| 150 Shannar danach | the same, only in the whole cartridge (alone, it fits) |
| 57 Shannar Hinrichtung | "fits no VRAM layout": 609 of background, 768 of sprites, 130 of upper layer |
| 99 Melsan | 451, 640, 177 |
| 165 Uruya | 817, 768, 95 (alone, it fits) |
| 225 Asran | 780, 704, 116 (alone, it fits) |
| 399 Wald12 | 716, 512, 136 |
| 402, 403 Schneeklippe | "there is no layout for a panorama in mode 1 that holds … 435 panorama tiles" |

**What is known of the cause**: it isn't the background. Tile merging
(`merge-similar-tiles-when-the-background-doesnt-fit.md`, Cardón, 2026-10-06) brings any
background down to the ceiling and "it is no longer what blocks any of them"; what
doesn't fit is the sprites and the upper layer, and merging background doesn't fix
it. Cardón left noted the possible next step: degrade the sprites with the same
criterion, "another kind of merging, more expensive: they are poses and palettes". The
window of 15 and 150 isn't the System's: its bank is 256 fixed tiles
(Tijereta, `window-in-the-tile-bank.md`). That 150, 165 and
225 fit alone and not in the whole cartridge is because in the whole one
more pages compile and more events fit (Aguará).

**What you see while playing**: those maps aren't in the cartridge, and an event
that leads to them loses the whole page (a `Teleport` to a map that isn't
there doesn't compile). How far it can be played without them wasn't looked at.

**How to see it**: remove the map from `excluded` and `just cartuchos release` in
`vampires-dawn/` of the ports (about two minutes; with the MSU-1, which the
project asks for as mandatory).
