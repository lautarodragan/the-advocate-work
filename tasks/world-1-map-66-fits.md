---
name: "World 1: map 66 fits"
description: "Milestone 1 of el-mundo-y-lo-que-sigue: the world map in release, with the fifth VRAM layout, the background in two LZ2 streams and the end of the demo on stepping on Sorbe"
type: feature
status: done
---

# What

Milestone 1 of `world-and-what-follows.md`, which has everything measured
beforehand. It starts from `2be61a9`.

* **The fifth layout** at the end of `LAYOUTS`, `LAYOUT_VENTANA_FONDO_TECHO`:
  256 sprites, 544 background tiles at `$1000`, ventana_map at `$5400`,
  tilemap at `$5800`, 128 overlay and 256 window.
* **The background larger than 32 KB in two LZ2 streams**:
  `partes_comprimidas` splits it into chunks of `LZ2_TOPE_FONDO`, and
  `lz2_fondo` (in `descomprimir.s`) decompresses and uploads one before
  decompressing the other. The cap is now enforced **per stream**
  (`controlar_flujos`), and so is how many streams the ROM reads: with a
  three-stream background, or a stream that overflows its place, the
  converter doesn't build.
* **Map 66 in `release`**, through `cartuchos.py`'s `AGREGADOS`: raising
  `MENOR_A` to 67 would bring in map 65, which is a folder.
* **The end of the demo** moves from the fork of map 64 (deleted) to a fork of
  map 66: event 10, the entrance to Sorbe Village, shows "END OF THE DEMO" and
  returns to the title.
* **`Comment` is skipped when compiling**, which was in milestone 2 and had to
  be brought forward: without the fork, the page of map 64's farewell didn't
  compile, and its only command that didn't compile was the "LYS" note the
  author left behind the `Teleport` to the world (measured with `mundo-plan`'s
  `culpables.py`). No other map of the two cartridges has a `Comment`: the
  page count of `test-special` comes out the same.

# Done and checked

* **The converter alone changes nothing**: with the first commit's
  `snes_convert.py` on a copy of `2be61a9`, `release` and `test-special` come
  out byte for byte identical (`cmp` of `abl.sfc`, `prueba.sfc` and
  `abl.msu`). No map changes layout or streams.
* **`test_carga_descomprimida.py`** already walks all the maps of `release`,
  so it looks at map 66's two-stream background in snes9x and in bsnes. And a
  new test, `test_un_fondo_de_dos_flujos_no_se_sale_del_buffer`, writes a
  witness into `GRILLA_ALTA`, loads map 66 and checks that it's still there.
  **It was seen failing with the bug in place**: on the same copy of
  `2be61a9` with map 66 shoved in by brute force (the fifth layout and
  without the background cap, like the plan's `m0p2` variant), the witness
  comes out overwritten.
* **`test_mundo.py`**, new: map 66 just arrived (golden `mundo-66-llegada`,
  `celdas_mal_dibujadas` at zero) and a battle requested with `ENC_PIDE` that
  Kersh wins and returns to the map (golden `mundo-66-despues-de-pelear`,
  cells at zero). Talan alone, with what he has at the start of the game,
  loses against the wolf.
* **The race walkthrough** continues from the farewell to the world, walks
  from (71, 29) to Sorbe (75, 10) with encounters off and ends at the new
  sign. Its screenshots in `pruebas/snapshots/playthrough/carrera-*/` aren't
  blessed, as before.

# Space

Measured with `AGENTS.md`'s method on what `just cartuchos` left:

    release        75.6 %   bank 0 261 B   bank 1 8,185 B   BSS 138   ZEROPAGE 4
    test-special   19.2 %   bank 0 1,073 B bank 1 9,977 B   BSS 138   ZEROPAGE 4

Bank 0 **gained** 37 bytes in both: the DMA of the background tiles moved from
`load_map` to `lz2_fondo`, in bank 1.

# Debt

* **The battle in the world comes out without a background.** The cartridge
  carries three battle backgrounds and the world uses five other terrains
  (plains5, desert1, forest5, forest6, mroad2). It's question 6 of the plan;
  the recommendation is to leave it for after milestone 3. Not solved here.
* The world's other entrances do nothing —their destinations aren't in—, and
  `DaliaGoingToTasgarde` (ev14) doesn't compile because of
  `ChangeEncounterSteps`, which belongs to milestone 2.

# What taro has to test

* Finish the race and the farewell: he has to appear in the world with
  Talan's messages ("Outside Lashe City at last…"), and be able to walk.
* Walk around the world and fight: encounters are per zone, every 65 steps.
  On returning from the battle the map has to be drawn correctly. The battle
  comes out without a background, and that's known.
* Step on Sorbe Village, up and to the right of the arrival point: the
  end-of-demo sign and the return to the title.
* Save in the world: parallel 26 turns saving on with switch 236, which the
  farewell sets. No test looks at it.
