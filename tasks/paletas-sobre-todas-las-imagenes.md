---
name: "Palettes over the whole game"
description: "Compute the palettes with all the images at once"
type: feature
status: wishlist
---

# What

Compute the palettes **over all the game's images at once** —CharSets,
ChipSets and text— unifying the blacks and the nearly-equal grays that today each
image has on its own.

# Status

taro's idea, noted down so as not to lose it and **not tackled**. What motivates it is the
cartridge's limit: it is 4 MB, which is LoROM's ceiling, and the padding that
the blocks leave reaches 20 KB.

# Why

It is one of the two ideas there are for **when assets need squeezing**: the
visual impact would be minimal and what is gained is cartridge space, which is
what ends up filling up.

Who decides this is Adeleine, `tools/port/Adeleine.py`, which is the only
place where it is decided which color is lost: see "`tools/snes/voodoo/` no decide colores"
in `AGENTS.md`. Doing it requires looking at the whole game at once and not at a cartridge,
which is what makes it different from what Adeleine does today.
