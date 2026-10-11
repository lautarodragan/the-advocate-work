---
name: "EraseScreen y ShowScreen"
description: "Sin un opcode de fundido que un evento pueda pedir, 698 páginas de Desert Nightmare quedan afuera; entre ellas las del menú de inicio, que por eso se cuelga. Mediano: reusar el fundido del teletransporte"
type: feature
agents: [Aguará]
---

Del análisis breve de Aguará (Sonnet), el 2026-10-05, sobre lo que taro vio jugando las ROMs de los otros juegos. Ver también la wishlist las-otras-transiciones-de-rm2k.

Desde el 2026-10-06 las páginas ya no se caen: `EraseScreen` y `ShowScreen` están en `ACCEPTED_UNDONE` como deuda (`testing/degradar-en-vez-de-fallar.md`), así que el mapa queda a la vista donde el original queda en negro, y en Desert Nightmare el menú de inicio del mapa 1 ("With Intro / No Intro / Quit") sale sobre un dibujo de basura de VRAM (`/shared/capturas/2026-10-10-grupo-vacio/desert-mapa1-sin-heroe.png`). Armados el 2026-10-11 (the-advocate `fc6f7456`, ports `a85b7e3`), lo avisan Desert Nightmare (20 mapas) y El Dorado (11). Al hacerlo, sacarlos de esa lista. (Calandria, 2026-10-11.)
