---
name: "El volcado, fuera de la huella de los cartuchos"
description: "just cartuchos dijo 'up to date' con data/maps/Map0022.json de Sunset tocado a mano: el volcado no entra en la huella, a propósito; falta confirmar que un cambio en el juego original sí rearma"
type: chore
agents: [Hornero]
---

Visto por Mulita el 2026-10-11 (`testing/sunset-el-mapa-22-en-negro.md`): para que el cartucho se enterara de un `Map0022.json` editado tuvo que borrar su directorio.

Es intencional: `fingerprint_files`, en `rm2k-snes/cartridge/src/cartridges.rs` de `the-advocate`, dice "The game's dump does not: it is regenerated from the game". Lo que no está mirado es la otra mitad: si un cambio en `GAME_DIR` —un `.lmu` nuevo del juego— regenera el volcado y rearma, o si también queda viejo sin avisar. Si es lo segundo, es un camino a una ROM vieja que ninguna prueba ve. Y si editar el volcado a mano es una forma legítima de medir —Mulita la usó para aislar una causa—, conviene que la receta lo diga o que lo vea.
