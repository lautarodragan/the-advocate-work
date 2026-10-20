---
name: "Artistic-decision patches"
description: "What is lost in the conversion, as versioned files"
type: feature
status: todo
---

# What

The **artistic decisions** —what is lost going from RPG Maker to the
SNES— come out of the converter as **versioned files**, and over time they
become the source: the converter **reads** them instead of making them again.

Taro summed it up like this, in their words, translated:

> *it's like a terraform or liquibase but for RPG Maker games*

# Status

Decided on 2026-09-20, in two phases. Phase 2 **is decided**, it is not a
possibility.

**Phase 1 is done for three classes**: the colors that get merged in the two
layers of a map, the size each battle animation is drawn at, and
—since 2026-09-21, with the battle scene composed on the console— the
fifteen colors of each battler. They go out to `patches/mapas/<id>.toml`,
`patches/animaciones/<n>.toml` and `patches/battlers/<nombre>.toml`; the converter writes them next to each ROM
it builds, `just patches` copies the playable ROM's ones into git, and
`just patches-check` —and `test_patches.py`, inside the suite— fail saying
**which decision changed**. The other two still leave no trace; at the end is
what each one costs.

# The distinction that orders it

Going from RM2k to the SNES there are two classes of transformation:

* **Non-lossy**: they need no judgment and don't change what is seen. Baking
  opaque events into the map, `separar_del_heroe`, reusing mirrored tiles.
  **They are not patches**: they are optimizations and stay where they are.
* **Lossy, or "artistic decisions"**: something is lost and someone chose what.
  **Those are the patches.**

The five there are today, all automatic; the first three already leave a
written trace and the last two don't yet:

* the **colors that get merged** when an image doesn't fit in the palettes
  (`tools/port/Adeleine.py`) — written, per map;
* the **animations drawn at another size**, like the one in the Emitter Room
  (`tools/port/animacion.py`) — written, per animation number;
* the **fifteen colors of each battler** in the battle scene
  (`tools/port/escena.py`) — written, per image and hue;
* the **voices dropped from a MIDI** and the **trimmed samples** when they
  don't fit in the ARAM (`tools/rm2k-snes/rm2k-snes-audio/`);
* **`DECORAR_TRANSLUCIDO`**: a translucent CharSet replaced by another
  graphic.

# Phase 1: reflection

The converter **writes** what it decided, structured and versioned, and the suite
fails if what is committed doesn't match —like `protocolo --check`—. It doesn't
change behavior.

What it gains, and this is the point: **the diff warns**. If a change makes a map
lose two more colors or a song lose a voice, it shows in the diff instead of
only in the ROM. It's what the goldens do with pixels, for the
decisions.

# Phase 2: the file rules

The converter **reads** what was decided and applies it; deciding again is an
explicit command, like a `plan`/`apply`. With that the decisions **stop changing
on their own** when an algorithm changes, and can be **edited by hand** when one
isn't liked.

That's why phase 1 has to write **the desired state and not a report**: which
color merges with which, which voice is dropped, what size that animation goes
to, with a **stable key** that allows reading it back. A text for humans is no
use for phase 2.

# And the underlying why

It's the same that was done with `data/`: first a dump, then the source. And
it fits with the two repos: the engine knows **how** to convert; the patches say
**what** was decided for this game.

# What got done of phase 1

## The shape, which was the delicate point

One file per map and one section per layer, in TOML. Each merge says which
color the lost one goes to —15-bit RGB, which is the console's depth— and
they go **in order**: applying them top to bottom rebuilds the whole mapping
that `merge_least_visible` returns today, so phase 2 is walking the
list and not deciding again. The order really matters and is not tidiness: in
map 2 a color merges with another that further down is merged in turn.

The key is the **map id**, which belongs to the game: it doesn't move with the
converter's internal order, nor with the cartridge's map list, nor with
Adeleine's algorithm. The colors go by value and not by index in any
palette, for the same reason.

**And the cartridge is not part of the key**, by taro's rule of 2026-09-21: the
versioned decision is always the playable ROM's and the test cartridges
adapt however they can. Those are the 29 maps of `abl`; the eleven extra ones the test
cartridges carry are situations the game doesn't have, and there each one
decides on its own. For this class the question doesn't even come up —the layer
merges depend on the map and its ChipSet and nothing else—, and it is measured:
`abl` and the three test cartridges emit the same 29 files byte for
byte.

The format doesn't get in the way of the direction of making which maps go in, where it starts and with
which party stop being loose arguments: a key that names the game's situation
keeps working, and what would change is where the list of
situations comes from, not how each one is identified.

## The animations, which were the second

Done on 2026-09-21, and it came out as planned: the note above said that
the size is a function of the box and nothing else, and on looking it turned out true.
`animacion.tamano(ancho, alto)` looks at the box the animation takes up in RM2k
—the union of all the cells of all its frames— and the console's box,
which is **a single one for the whole ROM** and not per map: the why is in
`animacion.py` and it's that the `ShowBattleAnimation`s of all maps share
the already converted frames. So the key is the RM2k animation number
and nothing else, same as the map id in the other class.

**What does depend on the map is another decision**, and it was left out on
purpose: whether the animation is drawn or not. `animacion_de_mapa` returns "doesn't go" when the
map already took the eight sprite palettes, and that does look at the cartridge. Putting it
in the animation's file would mix the cartridge with the game again;
it's a separate class, and one of the unwritten ones.

The file says **which rectangle it goes to** —`tamano = [64, 49]`, which is what
phase 2 reads instead of recomputing it, with `parches.leer_animacion`— and, so
the diff can be understood, what it came from: the box in RM2k pixels and how many
frames there are. The percentage isn't written: it's for reading and not for applying, and
it comes from the other two.

That the cartridge is not part of the key **is not assumed**, as with the layers:
`--check` compares all the cartridges that show a versioned animation, and
a test in the suite redoes `tamano(*original)` from what is written, which is what
would catch the day the size starts depending on something else.

What was measured on 2026-09-21, so as not to measure it again: `abl` shows thirteen
animations and what is emitted takes 10,435 B; 91 is shown only by one case of the
suite, so it isn't versioned and `--check` reports it; the four cartridges
emit the same byte for byte, and the ROMs didn't move either with cache or with
`SIN_CACHE=1`.

What remains unwritten of this class is **the fifteen colors** each animation
is reduced to: it's an artistic decision of the real kind —colors are lost
and someone chose which—, it has the same key, and it's almost the same
format as the layer merges. It wasn't done here because the task was the
size.

## The battlers, which were the third

They came out on 2026-09-21 with the battle scene composed on the console, which
brings each monster down to fifteen colors. They go in their minimal form: the palette that
remained and how many merges were needed, not the whole list of merges, which
measured 179 KB. The key is the image and its hue (`battler_hue`), which is what
tells apart two battlers with the same drawing.

## What's missing, with what it costs

* **The character palettes.** The one most like what's coming:
  it really depends on the cartridge —who pays the timer's entry is
  decided by `npcs_dibujables` looking at the whole map, and with `--heroe-encima` or with
  other possible leaders the allocation is different—. With taro's rule in place, what's
  versioned is what `abl` decides and the cartridge that can't apply it decides
  on its own; what has to be designed is what happens when it **can** be applied but
  the palette it reserves isn't free. That's the case taro asked to look at and in
  the layers it doesn't exist, so that's where it will really be decided.
* **The voices dropped from a MIDI and the trimmed samples.** It has its
  own task, `audio-in-two-lossy-steps.md`. The most expensive one, and
  the one worth stopping before forcing it. What's dropped isn't decided by a song
  but by the ARAM allocation among **all** of the cartridge's, with a priority
  that depends on where the ROM starts: the key "the song" isn't enough to
  identify the decision, and the key "the cartridge" is the one taro discarded. With
  `abl` as the only versioned situation it can be done, but the file would
  have to describe the whole allocation and not a loss per song, and that's another
  format.
* **The fifteen colors of each animation.** The cheap one left ready: same
  key as the size —the animation number—, same format as the layer
  merges, and the decision is visible too. It's described above.
* **`DECORAR_TRANSLUCIDO`.** Looked at, and it yields little: the decision is already
  versioned and edited by hand, in the `SIN_TRAMA` list of `rpgmaker/rm2k.py`,
  and the other thing it does —baking the graphic against its cell's background— is of the
  non-lossy kind. What would be missing to emit is which graphic was treated that way in each
  map, which is little more than repeating the list.

# Checked on 2026-10-16

At the-advocate `759aa0ba` and the ports `4b2d41e`, by Cardón. Phase 1
stands as described and phase 2 has not started: the converter still
decides again on every build. What moved, so the text above can be
followed:

* **Where things are**: the Python modules are Rust crates —Adeleine is
  `snes/adeleine/`; the patches themselves, `rm2k-snes/patches/`
  (`rm2k-snes-patches`, with `--check`)—, and the versioned files are in
  `abl/patches/auto/maps/`, `animations/` and `battlers/` of the ports.
  `just patches` and `just patches-check` are still ABL's recipes.
* **`DECORAR_TRANSLUCIDO` and `SIN_TRAMA`** are now `[graphics] opaque`
  in each game's `rm2k-snes.toml`: still edited by hand, still versioned.
* **"The 29 maps of `abl`"**: `release` carries the whole game since the
  ports' `74eb754` (2026-10-14).
* **The classes that left no trace now leave one, as a report**: since
  `5d5df69d` (2026-10-15) the converter writes `degradations.json` next to
  the ROM, every loss of the event compiler and of its stages —still
  animations given up, rain and pictures not drawn, the ChipSet animation
  cut, events left out—. It is not versioned and it is not the desired
  state phase 2 asks for, but it is the list of what is lost, by place.

## Checked (2026-10-20, Chajá)

Phase 2 has still not started for what the converter decides. What moved
since the check above:

* each game's project file is `advocate.toml` since 2026-10-20 (the
  ports' `71c4143`): `[graphics] opaque` lives there now;
* `abl/patches/` is two folders by who writes them, as its README says:
  `auto/` —the converter's maps, animations and battlers, plus
  `music/ceilings.toml`, each theme's volume ceiling, measured over the ROM
  by `just ceilings` and charged for by `test_music_ceilings.py`— and
  `manual/`, what a person decided, one folder per kind of asset in RM2k's
  own names (`ChipSet/`, `maps/`; the ports' `f85a6ed` and the-advocate's
  `92e18a22`, 2026-10-19). What is in `manual/` rules and no tool writes
  there: it is the "edited by hand" half of phase 2, but for whole files,
  not for the converter's decisions this task is about.
