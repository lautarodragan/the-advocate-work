---
name: "El texto de objetos de ABL no entra en lo que dejan las ventanas"
description: "El armado de ABL avisa que la lista de objetos más cargada pide 200 pares de teselas y las ventanas de objetos y equipo dejan 167"
type: bug
---

Visto por Tijereta el 2026-10-11 (`testing/las-ventanas-mas-eficientes.md`),
herramientas `fc6f7456`, ports `a85b7e3`, armando el `release` de ABL.

**Qué se ve**: en el armado, no jugando. `rm2k-snes-screens convert` dice
en su respuesta:

    WARNING, item text: its list asks for 200 pairs of tiles at most, of
    the 167 the item and equipment windows leave

Ningún otro de los ocho juegos lo dice. No se comprobó qué hace la ROM
con un inventario que llegue a esa lista —si se corta el texto, o qué
nombres se pierden— ni con qué inventario se llega.

**Cómo verlo**: `just cartuchos release` en `abl/` de los ports; el aviso
está en lo que contesta `screens` (el `says` de su `screens.json`).

Dato medido de paso: con el fondo de las ventanas de un solo color (el
research "The windows, made cheaper" del libro), las ventanas dejan 184.
