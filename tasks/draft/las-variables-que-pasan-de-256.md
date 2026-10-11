---
name: "Las variables que pasan de 256"
description: "Vampires Dawn nombra 600 variables y la RAM lejana tiene lugar para 256: las páginas que usan una de las otras 344 quedan afuera"
type: feature
---

Lo declaró Carpintero el 2026-10-06 como degradación
(`testing/degradar-en-vez-de-fallar.md`, punto 2): las variables que no
tienen lugar salen de la lista con un WARNING, la página que usa una queda
afuera, y un evento cuya condición de página usa una también. Antes era un
corte del armado; ahora es una pérdida que no sigue ninguna tarea.

**Comprobado hoy** (the-advocate `fc6f7456`, ports `a85b7e3`): el
`conversor.log` del release de Vampires Dawn dice "the game names 600
variables and 256 fit in far RAM: the pages that use one of the 344 past
it are left out". Ningún otro de los ocho juegos pasa de 256.

**No medido**: cuántas páginas de VD se caen por esto. `rm2k-snes-events
culprits --every-map`, sobre el pedido de `compile` del armado, lo dice.

**Cómo verlo**: `just cartuchos release` en `vampires-dawn/` y
`grep "variables and" build/release/conversor.log`.
