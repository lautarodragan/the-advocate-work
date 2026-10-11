---
name: "The weather"
description: "The opening's rain"
type: feature
status: done
---

### The rain

`WeatherEffects` draws the rain —it rains in the opening, first light and then
medium—. It compiles to `OP_WEATHER` with the type and the
strength, and the rule is that of `Game_Screen::UpdateRain`: each drop lives twelve
frames, falls four pixels and moves one to the left per frame, and an
extinguished one is born with a ten percent chance at a random spot.

**The rain is stuck to the map**, as in RM2k, and not to the screen. In RPG_RT the
drops live on
a screen-sized surface that wraps around at the edges, and it is
pasted shifted by the pan, which is how much the camera moved
(`Weather::DrawParticles`). Here the surface is 256x256: the x and the y of
each drop are bytes, each frame's step wraps around on its own, and to
draw them the map scroll is subtracted from them —the shake included— in eight
bits. Of the surface 224 of the 256 lines are visible, so on screen the
density is the same as before.

Four things are ours and are declared:

* **The density, not the count.** RM2k has 20, 60 and 100 drops in 320x240;
  here they are 15, 45 and 75 in 256x224.
* **The randomness is our own xorshift**, seeded every time the weather changes and
  equal on both sides: RM2k's cannot be reproduced.
* **The ten percent is 26 out of 256**, 10.2%: with `% 100` the ROM paid for the
  divider for every extinguished drop on every frame.
* **The drop is a 4x16 streak** with the slope of RM2k's 6x24 one, in
  three opaque greys depending on how much life it has left, which is where RM2k fades it
  with transparency.

On the console each drop is two 8x8 objects with priority 2, at the end of the
OAM: they pass in front of the upper layer, any character covers them —on the
console the object with the lowest index wins—, and the message window covers them with
the same mask as the "above" events. The screen tone tints them, like
everything, because their colours go in a character palette. Their six tiles and their
three colours are reserved like the timer's digits, and **a map without room
in the sprite palettes draws no rain**: the ROM carries `M_LLUVIA_BASE` at
zero, and who decides is the converter when allocating the sprite palettes, in
`gotas_de_lluvia`. In the demo it happens on
maps 2, 8 and 10, which do not use it. Snow, fog and sand are not
drawn and turn the rain off; the weather does not travel in the save.

In OAM the drops do not go through `emit_object`: the X always stays between 0 and
255, so `lluvia_oam` writes them directly, and of the Y it discards what falls
between 224 and 247 —from 248 onwards the PPU draws it peeking in from the top—.
With that and long addressing instead of the WMADD window, heavy
rain went down from 58 to 24 lines in `lluvia_tick` and `build_oam` from 130 to 84.

It is enforced by `pan-lluvia` and `sacudir-lluvia` in the suite, which move the camera with
heavy rain through the test page —a `WeatherEffects` in its file in
`pruebas/casos/`—: in the opening the camera does not move, so on its own it does not
look at the drops' scroll. And
`apertura` compares with rain, which is what requires the case to count the ticks
to the end: the rain never settles, so cutting when the scene
looks still leaves the drops from twenty-odd ticks earlier.
