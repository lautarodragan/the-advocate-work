---
name: "The sounds inside move routes"
description: "The converter drops the sound effects a forced move route asks for between steps"
type: feature
status: done
---

Seen on 2026-09-26 while measuring map 3: evilrhys's scene asks for a
dozen sounds inside forced move routes (Decision1, Blow1 to Blow6, Shot2,
Switch1), and the converter drops them on purpose (`RUTA_SONIDO` in
`tools/port/eventos.py`: read its comment and `git blame` to know
why). In RM2k they play when the route reaches that step.

Look at how many routes in the game use it, what the ROM would need (the route
would have to be able to fire an effect on the step: see how
`sonido_de_codigo` does it for pages) and whether the effects are already in the map's
package (they are if the page asks for them too).

# Done

2026-09-27, in `race-3-what-is-seen-and-heard.md`: order 35
plays in `MoveEvent`s, on the hero and on events. On map 3 it doesn't:
the effects of `evilrhys`'s scene don't fit in its package. Which maps
gained effects and which didn't, and why, is there and in
`SE_DE_RUTA_SIN_PAQUETE` (tools/audio/snes_music.py).
