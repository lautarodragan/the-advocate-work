---
name: "Battle animations"
description: "The sound, the light and the frames of ShowBattleAnimation"
type: feature
status: done
---

### Battle animations: the sound and the light

`ShowBattleAnimation` is two halves, and this is the one of **the sound and
the light**: its sound effects and its flashes, on the frame where RM2k puts
them. The drawing is in the next section. There are eleven in the intro —three
in the Linkage Block, eight in the Emitter Room, all of fire— and without them
those scenes are silence and nothing.

It compiles to `OP_ANIMATION` with the timeline inside: for each `timing` of
the animation, on the even frame `2 * (frame - 1)`, its sound effect and its
flash, of the screen or of the target event. There is only one at a time, as
in `Game_Screen::ShowBattleAnimation`, and it advances once per frame before
the flashes (`animacion_tick`). With "wait", the page waits for as long as it
lasts. Three things are ours:

* **The flash is a `FlashScreen` or a `FlashSprite`** that starts at the
  strength RM2k gives the first frame and goes down linearly over ten; there it
  goes down in steps. Ten, and even on purpose: the screen flash works in two
  phases according to the parity of what it has left, and with eleven it
  started with the one no page of the game takes, which is the one that was
  left untested.
* **The hero is not flashed.** Whom he shares a palette with depends on the
  party, which the compiler does not see; for `FlashSprite`s the converter
  checks it and stops the whole ROM, and an animation is not worth that. Nor an
  event that shares a graphic with another, and that **stayed conservative**
  since the flash became per palette row (see below): today the target's could
  be emitted anyway. It was not done in the same round because it changes what
  is drawn on the maps where two events share a graphic, and that asks for
  measuring the suite again.
* **The drawing is not there.** They are 96x96 cells with zoom of up to double
  and their own palette; it is the system next door, and it is below.

It is enforced by `animation` in the suite —82 on the hero, which flashes the
screen—, through the test page in `tests/cases/animation.json`: the Emitter
Room scene cannot be triggered from a test. The sound effects are enforced by
each map's audio package, which counts them as one more.

### The drawing of battle animations

They are drawn too. The whole system is in `tools/port/animacion.py`, which is
the only place where it is decided where each pixel falls and what colour it
is; the ROM decides nothing of that.

**A 64x64 box, the same one for the whole ROM.** It is four 32x32 objects in 64
tiles, which is one row of blocks of the OAM name grid: a 32x32 object reads
four tiles from four consecutive rows, so four objects fit in a row and not one
more. More than that there was not anyway: the sprite VRAM left free on map 2
is 101 tiles and a 96x96 box is 144. That the box **does not depend on the
map** is what lets the 388 `ShowBattleAnimation`s of the game's 81 maps share
the same frames already converted in the cartridge.

**The animation is shrunk whole until it fits**, keeping its proportion, and
how much it was shrunk the converter emits animation by animation. The intro's:

| animation | from     | to    | frames  | in the cartridge |
|-----------|----------|-------|---------|------------------|
| 77        | 192x192  | 64x64 | 20      | 40 KB            |
| 78        | 144x176  | 52x64 | 24      | 48 KB            |
| 79        | 512x384  | 64x48 | 28      | 56 KB            |
| 82        | 536x416  | 64x49 | 28      | 56 KB            |

Shrinking them is what makes the big ones exist: at 11% 82 is a glow and not a
blaze, but it is there, and the measured alternative was that it not be.

**The frames go pre-rendered in the cartridge and are uploaded by DMA.** One
every two console frames, which is how long an RM2k frame lasts: 2 KB, that
is, four of the five poses of the vblank budget, and they are **subtracted**
from `vq_tope` instead of fixing it, same as a step of the ChipSet animation.
They go one per frame and not one continuous block per animation because 28
frames are 57 KB and a bank has 32.

**A whole sprite palette for itself alone**, like the sign: its fifteen
colours are the animation's and are overwritten when another one starts, so a
character put there would change colour with it. Maps 2 and 3 filled all
eight, so on the maps that show animations **the characters share seven**;
what that merges is in `assets/LIMITACIONES.md`. If with seven the timer does
not fit, the timer wins, it goes back to eight and that map does not draw: it
happens to map 9, and it says so.

**Where it lands.** With "screen" scope it goes to the centre of the console's
screen, which is `DrawAt(screen_width / 2, screen_height / 2)`; with the
other, on the target, which is `GetScreenX()` and `GetScreenY(false)` minus
half a character and the offset of `Animation::Position`. That offset is
**baked into the anchor** the table carries, so the console only subtracts. A
target without an NPC row, or hidden, has nowhere to take the position from
and the animation is not drawn.

What is lost is in `assets/LIMITACIONES.md`: a cell's transparency, the flash
on the animation and the `global` ones.

In the suite it is enforced by `animation-drawing` —78 on the hero, with one of
its empty frames and the three most loaded ones— and `animation-event` —the
same one on Manta, stuck to the left edge, where `emit_object` clips the box—.
They are two cases and not one because in the ROM they are two paths: the hero
comes from `hero_x` and an event from its row, through `npc_de_evento`.
