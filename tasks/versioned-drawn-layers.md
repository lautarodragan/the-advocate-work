---
name: "Versioned drawn layers"
description: "Each map's layers as an artifact that is looked at in git"
type: test
status: wishlist
---

# What

Have the maps' drawn layers be a versioned artifact, like
`data/`: they are generated when the game's graphics change, they go to git, and the
build only reads them.

# Status

Noted and **measured**, not started. It is taro's, from 2026-09-20. What is done
is the step that makes it cheap: since that day the layer cache key comes from
the inputs, so a warm build no longer draws any map. What this would
add isn't speed but **taking the original game and the RTP out of the build**.

# How much it takes

Measured on 2026-09-20 with Pillow, over the drawings that
`Renderer.capas_animadas` returns: the lower layer, the upper one, and one more drawing for
each step of each animated family —water and animated tiles—. They all fit in 256
colours, so an 8-bit indexed PNG keeps them **without losing a pixel**;
the worst palette of the two batches has 167 colours.

    abl (29 maps)        78 drawings   1.3 MB
    pruebas (40 maps)   102 drawings   1.6 MB

The 40 of the test cartridge include the 29 of `abl`, so the whole artifact
is those 1.6 MB. The same raw pixels, at one byte each, are
114 MB: the PNG leaves them at 1.4%.

The breakdown says where the bulk is, and it is the one that doesn't need to be kept:

    base        40 drawings   842 KB
    upper       40 drawings    88 KB
    variants    22 drawings   680 KB

# A more compact form that is still readable

The variants are the whole drawing with **a few cells changed**: they are
42% of the weight and contribute 18,705 distinct 16x16 cells in total. Stored
as a strip of only those cells —one more indexed PNG, which opens and is looked at
the same way— they go from **680 KB to 21 KB**, and the whole artifact from 1.6 MB to less than
1 MB. The cost is that alongside it has to be stored which cell each one goes in, and that
what you look at is no longer the map but a strip of cells.

The other form, much more compact still, is to store not the layers but **the
17 ChipSets that draw them**: 518 KB, and they are still the original images.
But that versions the input and not the result, so it leaves the drawing inside
the build —which is precisely what no longer costs anything today—. It serves to remove the
dependency, not to remove the step.

# What it would take for the build not to need the game or the RTP

The layers are **one** of the things the build reads from `/extras/abl-rm` and
`/extras/rtp`. The data no longer: `data/` is Ditto's dump and that is where
the maps, the database and the tree come from. What remains is graphics and audio, and each
one has its own path:

    ChipSet        the maps' layers                render_map.atlas_por_nombre
    CharSet        the hero and the NPCs           render_map.Charsets.get
    FaceSet        the menu's faces                titulo.cara_de
    System         the message window              ventana.skin, titulo
    Title          the title screen                titulo
    Backdrop       the battles' background         escena
    Monster        the battlers                    escena
    Battle/Battle2 the battle animations           animacion
    Picture        those of `ShowPicture`          eventos.Recortes
    Music (.mid)   the songs, and the MSU-1 tracks rm2k-snes-audio, msu
    Sound (.wav)   the sound effects               rm2k-snes-audio

Versioning the layers crosses off **a single line** of that list, the first. The ones
that would stay out anyway are all the others, and two of them are the ones that weigh
the most: the CharSets —which are the converter's other big cost today,
`build_characters` and `sprite_colors`— and the `Music` folder, which is 230 MIDIs
from the game plus 111 from the RTP.

And there is one that never goes away this way: **the SoundFont**,
`/extras/soundfonts/`, where the samples come from. That one isn't the game's.

So "the build doesn't need the game" is a goal of several steps, not of
one, and the order that comes out of what was measured is: layers (1.6 MB), characters, and then
the rest. The font is already inside the repo —`tools/port/fuente.py` is
generated from easyrpg-player— and doesn't count.

**Checked on 2026-10-16 (Mulita)**, at the-advocate 759aa0ba: still not started. The names above are of the Python, which is gone:
the layers are drawn by `rm2k-render` and `wally`, the characters by
`wally`, the windows and title by `rm2k-snes-screens`, the battle by
`rm2k-snes-images`, and the font is `rm2k-snes-text`'s. `/extras` is gone
too: the game and the RTP are read from their zip, through `GAME_DIR` and
`RTP_DIR`. The sizes were measured on ABL alone and were not measured
again.
