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

## Checked on 2026-10-16 (Carpintero)

Still not tackled, but its motivation moved: the cartridge is ExHiROM, 8 MB,
since 2026-10-01 (the book's `decisions/the-cartridge-goes-to-8-mb.md`), not
LoROM's 4 MB. And the names: Adeleine is `snes/adeleine/` in the-advocate,
in Rust (the Python left on 2026-10-02), and Voodoo `snes/voodoo/`. Doing it
"over the whole game" would now also have to say which game: the same
tools build nine.
