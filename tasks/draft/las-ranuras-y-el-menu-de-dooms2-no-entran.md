---
name: "Las ranuras y el menú de Dooms 2 no entran en su banco"
description: "Con el mapa 1 de Dooms 2 (elegir personaje) en el cartucho, la pantalla de ranuras y el menú juntan más tiles de los 448 de su banco; el mapa queda afuera y el juego arranca en el 2"
type: bug
---

Medido por Calandria el 2026-10-11 (`testing/las-exclusiones-que-sobran.md`):
con el mapa 1 adentro, "the slot screen and the menu gather 524 tiles and
their bank fits 448" con el System de ABL, y 482 con el del juego
(Tijereta, `testing/la-ventana-en-el-banco-de-tiles.md`, que lo dejó como
"tarea aparte": "son caras, no ventanas"). Es probablemente lo mismo que
Carpintero dejó sin hacer el 2026-10-06 en
`testing/degradar-en-vez-de-fallar.md`, el punto 4: "los nombres que no
entran en el banco del menú… probarlo en Dooms 2"; no se comprobó que sea
el mismo corte.

**Comprobado hoy** (the-advocate `fc6f7456`, ports `a85b7e3`): con el 1
devuelto y `start_map = 1`, `just cartuchos release` corta en
"rm2k-snes-screens: the slot screen and the menu gather 482 tiles and
their bank fits 448". El error sale de `rm2k-snes/screens/src/slots.rs`
(`SLOT_TILES_MAX`), sin degradar: corta el cartucho entero. Por eso
`dooms2/rm2k-snes.toml` excluye el 1 y arranca en el 2.

**Qué se ve jugando**: el juego no muestra la elección de personaje
—arranca en el mapa 2, "Jack"—, y cualquier evento que lleve al 1 pierde
la página entera (un `Teleport` a un mapa que no está en el cartucho no
compila).

Lo que se sabe de la causa: son las caras (Tijereta). Que el 1 las sume
porque es donde se elige personaje —más candidatos a líder, cada uno con
su cara— es la sospecha obvia, no comprobada.

**Cómo verlo**: sacar el 1 de `excluded` en `dooms2/rm2k-snes.toml` y
`just cartuchos release` en `dooms2/`.
