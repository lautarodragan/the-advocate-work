---
name: "Pictures that go over the map, outside Sunset"
description: "In the station bathroom of Desert Nightmare (map 7) a 35% light mask comes out as a large picture and covers the room for about 8 seconds; the map_pictures knob that solves it in Sunset isn't turned on in other games"
type: bug
status: draft
---

Seen by Hurón on 2026-10-06 (`eraseevent-de-verdad.md`): in the
WC scene of Desert Nightmare (map 7), event 4 is a parallel one
that shows `Lichteffekt_Tankstelle_WC` and erases itself. In RM2k it is a
dark 35% mask over the room; in the ROM "it comes out opaque and covers the
room for ~480 frames: it looks like it hangs, but it continues. It is the
pictures' transparency, not the erasing". Captures from that day in
`/shared/capturas/2026-10-06-eraseevent/`.

What is known of the cause: it is a large picture, and a large picture
takes the map off the screen; its transparency darkens towards the black
behind (`divergences/lo-que-las-imagenes-grandes-no-modelan.md` in the book).
It is the same thing Sunset had with its roofs and fogs, which since
2026-10-11 are drawn inside the map with `[graphics] map_pictures`
(`sunset-las-imagenes-sobre-el-mapa.md`); that knob is turned
on only in Sunset.

**Not checked today on the console.** Built today (the-advocate `fc6f7456`,
ports `a85b7e3`), Desert's release carries 304 large pictures and doesn't
name this one among those it doesn't draw, so the expected thing is that it
stays the same. How many other pictures in the other games go over the map
wasn't counted.

**How to see it**: `just cartuchos release` in `desert-nightmare/`, play
up to the station bathroom (map 7) and compare with the original in Wine.
