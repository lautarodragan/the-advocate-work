---
name: "The Auditorium audience"
description: "The NPCs that are decoration, baked into a ChipSet of their own"
type: feature
status: done
---

# What

Bake into a ChipSet of their own the sprites that are **decoration**: the
Auditorium audience, which never moves, and any others in the same situation.

# Status

**Done on 2026-09-21 on map 18**, the Auditorium. Its 31 audience events are
tiles of the upper layer of ChipSet 54, which is the map's own; the fork is in
`juego/mapas/Map0018.json` and the picture's recipe in
`juego/chipsets/0054.json`.

What it gained, from the converter, against the same numbers from before:

    cartridge  characters   sprite palettes     sprite tiles      NPCs
    abl           8 -> 6         8 -> 6            219 -> 158     36 -> 5
    juego         9 -> 7         8 -> 6            219 -> 158     36 -> 5
    pruebas      10 -> 8         8 -> 5            211 -> 147     36 -> 5

And what it cost, which is background and was to spare: **21 -> 64 colours of
the 103** the map has, with **zero merged**; 54 -> 102 background tiles and
29 -> 43 blocks, that is, 224 B more of block table.

**The map is drawn the same**: RM2k's render with and without the fork comes
out with zero pixels of difference across the 320x240.

# Why

The other of the two ideas for **when assets need squeezing**. A sprite that
never moves pays for sprite bank, sprite palette and OAM slots for nothing:
baked into the ChipSet it is a background tile, which is what is already shared
between maps with the same chipset.

On 18 the limit was not theoretical: the map was **stuck at 8 of 8 sprite
palettes**, which is where
`decisions/a-graphic-that-doesnt-fit-isnt-drawn.md` starts deciding
for us. And it was deciding: the five `18-*` goldens changed on baking because
**now people are drawn that the port had been discarding**.

# Which is "decoration", measured

The question that had been noted —"an event that never walks but can be talked
to is still an event"— was answered by looking at the map:

* **zero commands in all their pages**: they do not talk, they do not trigger
  anything;
* **a single page**, so their drawing does not depend on any switch;
* **`animation_type` 0** in the map's 41 pages: none animates;
* and **nobody names them**: the two pages of `EV0036` —259 commands, the
  whole cutscene— address events 1, 9, 16 and 37 and nobody else.

Of the map's 36 drawn events five remain as sprites: the `Director`, who is on
the stage; `Dessen` and the two `WalkIn*`, which the cutscene moves; and
`EV0019`, the woman with yellow hair, who is the only one whose sprite goes
out of her cell —two pixels, measured— and who is left as she is so that the
fork makes no decision about how she looks.

# The drawing order, which is what had to be confirmed

Baked, the audience goes from being sorted by Y with the hero to being
background: nobody can cover it again. It works because **on map 18 one does
not walk freely**: `EV0036` is autostart and does not release the player. The
hero's three positions come from the cutscene, and all three are in the middle
aisle —x 7 to 12, which the audience does not occupy— or behind everyone:

* he enters at **(9,14)** from map 17 and from 83, which are the only teleports
  that point here;
* he walks to **(6,12)**, the last row, next to `Dessen`;
* the two `WalkIn*` go up columns 8 and 10, which are aisle too.

That is, no sprite ever ends up on a cell in front of a baked one, and the only
walkable cell from which they would be seen from behind —row 7— is stepped on
by nobody in the game.

# The slots, and how they were chosen

There are **four (graphic, direction) combinations** for the 31 events, and
two upper tiles each —the head falls on the cell in front and the body on its
own—, so **eight tiles**:

    graphic             direction   events    head     body
    Future1  index 0        0          3       120      121
    Future2  index 6        0          9       122      123
    Future2  index 2        3          5       124      125
    Future3  index 5        0         14       126      127

ChipSet 25, which 54 comes from, has **art in 143 of its 144 upper slots**, so
there is no empty one: what makes overwriting eight free is that **54 is
private to map 18**, and 18 draws ten —0 and 105 to 119—. The other 134 are
free to use, and
`test_fork_does_not_overwrite_a_slot_its_map_draws_with_the_old_art` guards
it.

**The passability is written by the ChipSet, and it is what holds up the
baking**: the body tile goes at 0 —an event in the hero's layer is a wall, and
with loose tiles the cell would be left open and the player would walk over the
people— and the head one at 15, which is what the cell in front gave. The map's
open cells go from 197 to 166: the 31, no more.

# What was needed from the mechanism

The map fork already existed —map 11 debuted it, see
`map-11-redesigned.md`— and was not touched. The only thing added to it is
a third operation in the ChipSet picture's recipe, `from_charset`, which is
the first that **brings pixels from outside the ChipSet**.

Its trap, which one does not see coming: **both PNGs are indexed and their
indices do not mean the same thing.** Copying a CharSet's bytes into a ChipSet
gives a sprite painted with the ChipSet's palette. It is copied by colour, and
the missing one is added at an index the ChipSet does not use; index 0 is left
out of the search on both ends because it is the colour key.

# How to reproduce it

The throwaway scripts were left in `/extras/scratch/fork-auditorio/`:
`inventario.py` lists the 37 events with their pages, `celdas.py` says which
tile each cell with people has and the one above, `ev36c.py` says whom the
cutscene names, `pasa.py` draws the passability, `ranuras.py` counts the free
upper slots, `generar.py` builds the fork's three files and `render18.py`
takes RM2k's render with and without the fork, which `comparar.py` compares
pixel by pixel.

The captures are in `/extras/capturas/auditorio/`.
