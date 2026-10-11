---
name: "The save point"
description: "Saving from the save point, with its animation"
type: feature
status: done
---

### The save point: animates in place and saves to disk

**The animation of a still event has nowhere to keep its counter.** The ones that
walk carry it inside their route slot; the still ones have no slot, the
NPC's row has no free byte —+11 is the jump height— and the BSS is
at 7680 of 7680. So the column comes from the game clock, just like the water:
`vueltas` divided by `ANIM_CONTINUA[velocidad]`, and the same four-step
cycle with the third repeating the first. What's lost is the phase —in RM2k
each character starts its counter when the map creates it— and it's declared in
`assets/LIMITACIONES.md`.

What **does** cost VRAM is that it stops sharing tiles: a still event uses the
slot of its (CharSet, index, pose), and to animate it needs its own twelve
poses, like the ones that walk. That's twelve sprite tiles per event. Map 52
has **thirty** such events and asked for 572 sprite tiles against the 384 that
fit, so there's a ceiling: **a map with more than four animates none of them**, and not
some yes and others no —two identical fountains, one moving and the other frozen, looks
worse than both still—. Measured over the game's 328 maps: 312 have
four or fewer.

The phase was measured like the water's, and it's covered by
`escena 8 "9 55" 0 down "20 30 40 50"`: the cell (9,55) leaves it on screen
and the four frames fall on three different columns of the cycle. Without the `inc` that
corrects the phase it stays one column behind, which is 76 pixels.

**Saving opens the slots screen, as in RM2k.** `OpenSaveMenu` stacks
the same screen that "Resume the Story" opens from the title, in save mode
—"Save in which slot?", which is the LDB's `save_game_message`—, with the cursor on
the slot the game is using, which is `Scene_File::Start`'s `latest_slot`
without dates. A picks and saves there, B goes back without saving, and
it doesn't ask whether the slot was taken because `Scene_Save::Action` doesn't
ask either. The cartridge declares battery-backed SRAM in the header —`$02` and 8 KB— and
on the EverDrive that's a real battery.

Three things about how it's made:

* **It blocks inside the interpreter and costs no tick.** The screen runs
  its own frame loop from `op_save`, the same as from the title, and
  `vueltas` doesn't advance while it's shown. That's what RM2k does: the stacked scene
  stops the map's clock, and the page continues with the next command when it
  closes. That's why `OP_SAVE` takes its byte and doesn't cost a frame, and
  after closing the map continues with the tick that was due, however long the
  player takes.
* **On closing only what the screen overwrote is restored**, and not the whole map:
  `volver_al_mapa` uploads BG1's tile bank again with `load_map`, tints
  again, and restores the registers with `ppu_init`. Calling `cargar_mapa`
  would restart the events, the routes and the poses, which is exactly what has to
  survive. For that to be enough, **the screen lives at `$2000`..`$3600` of
  VRAM**, which is the intersection of BG1's bank in the four layouts of
  `vram_layout`, and the converter checks it. With the addresses of the title
  menu —`$4400` and `$5000`— it overwrote the sprites of the wide layout, which start
  at `$4000`: 267 pixels on the hero of map 73, only with party 11, because
  party 10's leader falls in block 0 and was spared. It costs two black
  frames on returning: 30 KB of DMA don't fit in one vblank.
* **The screen goes in every ROM**, with a title or without. With its tiles emitted
  only under `--con-titulo`, opening it from a ROM without a title was a DMA of zero
  bytes —that is, of 65536— that filled VRAM with garbage.

**Each slot with a save shows what RM2k shows**, which is what
`Window_SaveFile::Refresh` draws per file: the file's name, the
leader's name, the level —`lvl_short` in system colour 1 and the number
in two digits, "L 20" with Kersh, which comes from his `initial_level`— and the
party's **faces**, from the FaceSet and at 48x48, which is why the row is 48
pixels tall.

It was checked against the original game running the same scene in EasyRPG, and
not only read from the code. What differs on purpose: the hit points
don't go in, because this port doesn't have them; three faces fit and not four, and
packed together instead of at 56 px, because in 256 of width there's no more room without eating into
the border a tube television doesn't show; and the cursor is a ">" on a
black background and not the skin's box, which is how the menu from the title was.

How it's made, because it isn't just one more variant of the pre-rendered row: the
party is given by **the saved game** —the six bytes of `grupo` in the slot's SRAM,
at `PARTIDA_GRUPO`— and for each actor that can join the party with
the ROM's maps, `miembros_posibles`, the converter emits a block of 36
cells with their face. `ranura_pintar` uploads the row and
then, if it has a save, `ranura_grupo_pintar` reads the party from SRAM and
writes on top the rectangles that belong to it, with `ranura_rect_subir`: one DMA
per row of cells, with the source pointer the DMA itself leaves where it
finished. **The leader's name and level are not blocks**: they're composed by
`ranura_texto_escribir` one letter per cell, see "What depends on the
actor is composed with glyphs" below. Where each face and each name goes is
said by two converter tables —`ranura_cara_vram`, four per slot
so as not to multiply by three, and
`ranura_nombre_vram`—, like `ranura_vram` for the rows. Each face carries its
palette, reduced to 15 colours with `reducir` like the title image, in
palettes 1 to 7 of BG2; in RM2k index 0 of the FaceSet is transparent, just
as in a CharSet, and `ABLFaces` uses it: drawn opaque each face was a
red square. An actor without a face —DummyHero— draws nothing, like `DrawFace`
with an empty name.

The full variant can't be seen by the suite —the emulator's SRAM starts
blank— and it's covered by `test_la_pantalla_de_ranuras_muestra_el_grupo_guardado`,
which saves with Talan and DummyHero in the party, resets, goes in through "Resume the
Story" and compares the screen **pixel by pixel** against `titulo.render_ranuras`
with that party, with the cursor on the first row and then on Talan's,
which is what repaints it in the vblank. Against a reference with no party or with
Kersh it's some 400 pixels, so the zero isn't empty.

It's covered by `test_guardar_pantalla` and `test_guardar_vuelve`, from
`pruebas/rpgmaker/test_tanda_pantallas.py`, in six frames and all at zero: the screen
on opening and with the cursor two slots down, and the map back after
cancelling and after choosing, in two ticks. The presses inside the
screen go with `toques_hardware`,
which counts hardware frames from boot: one press per tick can't
land where there are no ticks. And what's left in SRAM is looked at by
`pruebas/rpgmaker/test_guardar.py`, which now **goes through the screen** —moves the cursor down
and presses A— instead of writing `ranura` by hand; `menu_abierto` is the byte
the ROM leaves it to know when, because waiting by ticks there would hang.

What gets saved is said by **one table and nothing else**, `partida_tabla` in `main.s`:
pairs of (address in WRAM, how many bytes). Saving and loading both walk it,
so they can't drift apart, and adding a field is one line. Today
it's 154 bytes: where the hero is, on which map, the party, the tint, the
timer, the gold and the 128 bytes of switches.

The copy goes **by DMA in both directions**, and what makes it possible is the
WRAM window: bus B doesn't reach SRAM, but it does reach `WMDATA`, so
SRAM goes on the bus A side and WRAM on the other. Saving is a DMA from B to A —bit
7 of DMAP— and loading the same one in reverse.

Two details that took their while and are noted where they bite, above
`SRAM_MAGIA` in `main.s`: that the save lives at `$0100` and not at `$0000`, and that
the magic is compared against immediates.

A slot is valid if it has the magic `ABLS` and the sum of its bytes checks out. Both
things are needed: unwritten SRAM brings garbage —snes9x fills it with $60— and
a test ROM that took it as good would load an invented save.

**What gets written can't be covered by the pixel suite**, because saving
doesn't change a pixel. It's covered by `pruebas/rpgmaker/test_guardar.py`, which does the only thing that
proves something: it goes to another map, turns on a switch, saves, **resets the console for
real** and looks at where it starts. SRAM survives the reset and WRAM doesn't, so
if the save comes back it's because it came out of the cartridge. With `guardar_partida`
cut on purpose, three of its four tests go red.
