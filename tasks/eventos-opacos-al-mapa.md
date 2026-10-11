---
name: "Opaque events into the map"
description: "An event that is a fixed opaque tile is baked into the map"
status: done
---

# What

An event that is drawn with **an opaque tile of the ChipSet**, always the same
one and always in the same cell, is not drawn as an event: its tile goes into
the map's upper layer and its NPC row is born hidden. The event stays whole for
its logic —it triggers, it blocks the way, it is the target of a route—; what
is saved is its OAM object and its pass through `place_npc`.

The rule lives in `eventos_horneables`, in `tools/port/snes_convert.py`, with
the five conditions and the reason for each one. How many events each map
bakes is told by the converter in its report.

# Why

It comes from **the Lazer Teeth HQ, map 11**, which is the most loaded map of
the game —68 drawn events, 62 of them with a tile— and the one that
`pruebas/rpgmaker/test_paralelos.py` uses to measure whether the frame fits.

**What was measured, walking 1200 frames on map 11** (frames lost, with the
counter read and reset to zero every 50 frames: it saturates at 255, and a
measurement of 1200 frames in a row answers 213 because of that and not
because of what happened):

    drawn events        frames lost
    68 (as it was)            450
    50 (baking 18)            228
    31                        150
     9                         74

That is, it costs on the order of **seven frames lost per drawn event** on that
map, and baking the 18 that fall under the rule halves them. Standing still
none is lost: what produces them is the scroll's redraw, and the sprites are
what push it over the frame.

The three bottom rows are control measurements, with events hidden by hand:
they tell where the ceiling is and are not code that exists.

**The rule's ceiling is small, and it is the figure one has to have before
stretching it**: across the game's 328 maps there are 522 events drawn with a
ChipSet tile and **32 fall under the rule, in 12 maps** —19 of them on map
11—. Loosening everything except "opaque and with a fixed drawing" it would be
91 in 16 maps, 49 of them on map 11. The difference is the ones that **the game
moves**: on map 11, 46 of its 62 tile events are the target of a
`ChangeEventLocation` —it is the stones minigame— and those cannot be baked in
any way.

# What is not saved yet

**The sprite palette and the VRAM slot.** The baked event still goes into the
`npcs_dibujables` split as if it were drawn, on purpose: taking it out of there
frees a palette for the map, and with that **what is seen changes** —a graphic
that today is drawn with someone else's palette would get its own, and map 11
has one: `@tile:lasheint:49`—. It is an improvement, but it is a separate
decision and it moves goldens.
