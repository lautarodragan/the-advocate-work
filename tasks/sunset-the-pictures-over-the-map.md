---
name: "Sunset: the pictures over the map"
description: "Sunset draws roofs, lights, shadows and fogs as full-screen pictures over the map; the ROM carries them as large pictures, which cover the map, and the scene goes black"
type: feature
status: done
assignee: Mulita
agents: [Mulita]
---

Measured by Mulita on 2026-10-11 in `sunset-the-map-22-scene-in-black.md`:
the scene that opens the game goes black because `WinterMist`, a fog at
95 % transparency, goes as a large picture —instead of the map— and the
transparency darkens towards black.

About 140 of Sunset's pictures are like that: roofs and ceilings with the
transparent colour (index 0 in 50-99 % of the picture), translucent lights and
shadows, fogs at 45-95 %. Almost every map has one. ABL's large
pictures are opaque screens over black, and that is what they were
designed for (`lo-que-las-imagenes-grandes-no-modelan.md` in the book).

The two paths are in the task above: leave them out with a
criterion, or do them as a layer over the map.

## taro's decision, on 2026-10-11

Not leaving them out: "Sunset is a very artistic game. Without those pictures
it would probably lose all its charm." First analyse how it uses them
—whether they act as extra map layers, as panoramic movements, etc.— and with that
invent a solution that works well; if they go as a map layer without losing
much, welcome.

## Mulita's log

Base: the-advocate `6f933ff8`, ports `b499ab4`, book `491624d`. Branches
`mulita-sunset-imagenes` in the three, worktrees in `~/scratch/mulita/`
(`the-advocate`, `ports`, `docs-wt`). Analysis scripts in
`~/scratch/mulita/imagenes/` (`recolectar.py`, `pormapa.py`, `ubicar.py`,
`grupos.py`, `capas.py`).

### What was measured (2026-10-11)

* 1,678 picture commands, 164 files. Following each page's `Teleport`s
  —Sunset shows the destination map's pictures at the door
  of the origin one, after the jump—, **62 of the 65 maps** show
  some picture that stays still over the map.
* **Sunset is a painted game**: the map is the panorama (the size of the
  map, fixed to it) and the ChipSet's layers are empty in almost all of them.
  The converter already carries it: the panorama in BG2 at 4 bits, 576 tiles
  grouped, and BG1 empty. Without pictures the map looks fine (the captures from
  `mira-*`), but the hero walks over the roofs and lights,
  shadows and fogs are missing.
* **The roofs are cut-outs of the panorama**: 83.7 % of their pixels are
  equal to the panorama beneath (100 % in the plazas, the statue street and
  the spring bar; the interiors of other seasons differ). They are
  "what goes in front of the hero" on a painted map.
* The pictures fixed to the map **always** fall at the map's corner with
  RM2k's camera from the `Teleport` that precedes them (`ubicar.py`); the ones
  shown without a previous jump (10, 5, 58) have no known camera, and
  centred on the map they match the others.
* ABL with the same rule would catch 2 (MeanwhileLashe on 81 and the montage on
  217): the rule goes as a project knob, off by default.

### The analysis

In the book: [`ports/sunset-over-imdahl/research/2026-10-11-las-imagenes.md`](https://lautarodragan.github.io/the-advocate-docs/ports/sunset-over-imdahl/research/2026-10-11-las-imagenes.html).
By group: roofs and ceilings (61 maps, cut-outs of the panorama: they go with
their cells' priority, free), lights (50) and shadows (22) —flat
masks at 10-35 %—, fogs (38, screen textures), animated ones (flags,
grass, clouds), the game's own menu and the title and credits plates. In mode 3
there is no layer left for the translucent ones: they go blended into the panorama. What
mode 1 would give for a painted map (exact roofs, shadows through
colour math) is written there, not done: it is taro's decision.

### The first version

* the-advocate `06b8321f`: `map_pictures.rs` in the converter (the rule) and in
  Wally (draws them). Knob `[graphics] map_pictures`, off by
  default. Wally blends the pictures into the panorama fixed to the map and raises
  the priority of the BG2 cells that the opaque ones cover; a map with
  roofs is no longer baked. The compiler doesn't receive those pictures: their
  commands are accepted without being carried out.
* ports `ce01ff9`: Sunset turns it on. 183 pictures on 64 maps.
* book `a5554be`: the investigation, the divergence
  `las-imagenes-dentro-del-mapa.md` and the port's page.
* Seen with captures (snes9x) of 28, 2, 13, 33, 7 and the scene on 22,
  against the original with Wine on the same cell: in
  `/shared/capturas/2026-10-11-sunset-imagenes/`. For the original I built
  variants of the game that start on the map with the door's
  pictures (`~/scratch/mulita/wine3/variante.py`).
* Red before: the scene on 22 black (task `sunset-the-map-22-scene-in-black.md`),
  and any map with roofs covered by a large picture.

### What I saw and isn't part of this

The plazas (40x30) and the streets (20x30) were already coming out grainy on main: the
panorama brings 2,000 to 4,800 distinct cells and 576 tiles fit; in the
spring plaza the canal and the pavilion come out broken. It is the panorama's tile
budget. What would fix it is uploading to the panorama only what
is seen (a window of ~33x29 cells), with DMA when the camera moves: it is the
next task that weighs most for Sunset.
