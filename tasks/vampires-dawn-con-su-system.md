---
name: "Vampires Dawn ya arma con su propio System"
description: "El port de VD usa el System de ABL porque con VDBlutsys la ROM no entraba; desde que las poses bajaron 1,65 MB, con el suyo arma. Falta mirarlo y decidir si la perilla se va"
type: chore
status: draft
---

Tijereta, el 2026-10-11 (`testing/la-ventana-en-el-banco-de-tiles.md`):
los cinco juegos volvieron a su System salvo Vampires Dawn, "sus pantallas
entran, pero la ROM se pasa por una pieza de 64 KB". Lo dice el
comentario de `system = "ablskin.png"` en `vampires-dawn/rm2k-snes.toml`
(ports `a85b7e3`).

**Ya no es cierto.** Esa medición es de antes de
`testing/una-cuantizacion-por-personaje.md` (Mulita), que bajó las poses
de 4,93 a 3,28 MB. Comprobado hoy, the-advocate `fc6f7456` y ports
`a85b7e3`, en un worktree propio: con la línea de `system` comentada,
`just cartuchos release` en `vampires-dawn/` arma (rc 0, 2 min 12 s):
12.352 piezas en los 127 bancos y 1.297 en el `.msu`. Las pantallas se
funden con WARNING, como en los otros juegos: el marco de la ventana de
mensajes (28 tiles), la elección de actor (158 de 64), ítems y equipo
(151 de 31), la tienda (166 de 96) y End Game (20 colores).

**Lo que no se hizo**: no se arrancó en un emulador ni se miraron las
pantallas fundidas, y la perilla no se tocó —es del toml del port—.

**Qué se ve jugando hoy**: las ventanas, el menú y la pelea de Vampires
Dawn salen con el System de A Blurred Line, no con el del juego.

**Cómo verlo**: comentar `system` en `[graphics]` de
`vampires-dawn/rm2k-snes.toml` y `just cartuchos release` en
`vampires-dawn/`.
