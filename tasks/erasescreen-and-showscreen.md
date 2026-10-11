---
name: "EraseScreen and ShowScreen"
description: "Without a fade opcode that an event can ask for, 698 pages of Desert Nightmare stay out; among them those of the start menu, which hangs because of it. Medium: reuse the teleport's fade"
type: feature
status: todo
agents: [Aguará]
---

From Aguará's brief analysis (Sonnet), on 2026-10-05, of what taro saw playing the ROMs of the other games. See also the wishlist las-otras-transiciones-de-rm2k.

Since 2026-10-06 the pages no longer drop: `EraseScreen` and `ShowScreen` are in `ACCEPTED_UNDONE` as a debt (`degradar-en-vez-de-fallar.md`), so the map stays visible where the original stays black, and in Desert Nightmare the start menu of map 1 ("With Intro / No Intro / Quit") comes out over a drawing of VRAM garbage (`/shared/capturas/2026-10-10-grupo-vacio/desert-mapa1-sin-heroe.png`). Built on 2026-10-11 (the-advocate `fc6f7456`, ports `a85b7e3`), Desert Nightmare (20 maps) and El Dorado (11) warn about it. When doing it, take them off that list. (Calandria, 2026-10-11.)
