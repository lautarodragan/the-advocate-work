---
name: "El marco propio de los mensajes de Desert Nightmare"
description: "Desert dibuja sus mensajes con dos imágenes propias, TextboxInnen y TextboxRahmen; el release de hoy no las dibuja en 157 mapas"
type: bug
---

Visto por Calandria el 2026-10-11, de paso
(`testing/rescatar-los-hallazgos.md`), herramientas `fc6f7456`, ports
`a85b7e3`: el armado del release de Desert Nightmare avisa que en 157
mapas no dibuja las imágenes `TextboxInnen` y `TextboxRahmen`, que son el
marco propio de sus mensajes.

**Cómo verlo**: `just cartuchos` en `desert-nightmare/` de los ports, y
buscar esos nombres en `build/release/conversor.log`. No se miró en la
consola qué se ve en lugar del marco.

La página del port en el libro ya decía, más en general, que "136 maps
don't draw some of their pictures" (del 2026-10-10); no se comparó qué
mapas son de esos 157.
