---
name: "Lo que se funde en las pantallas no va a los parches"
description: "De lo que el conversor pierde en las ventanas, sólo los colores de la ventana de mensajes llegan a parches/auto/; los colores de las pantallas a 8bpp, las celdas fundidas y los de End Game quedan en un WARNING del log"
type: chore
status: draft
---

Lo dejó dicho Tijereta el 2026-10-05 en
`testing/la-ventana-con-mas-colores.md`: los colores que se funden en las
ventanas de 8bpp (`borders.rs`: ítems, equipo, tienda, elección de actor)
"todavía no se escriben en los parches: es lo que falta de esta tarea". Y
`testing/la-ventana-en-el-banco-de-tiles.md` (2026-10-11) sumó más del
mismo tipo: las celdas que Adeleine funde para que entren en su banco
(`fit.rs`, `merge_least_visible_tiles`), el fondo de la ventana de
mensajes que se ve por el marco (`group_cells`) y los colores de End
Game (`merge_until`).

**Sigue así** en the-advocate `fc6f7456`: el pedido a
`rm2k-snes-patches` (`convert.rs`, la clave `windows`) lleva sólo las
fusiones de colores de la ventana de mensajes, y `WindowDecision` en
`rm2k-snes/patches/src/lib.rs` no tiene lugar para lo demás. Armados hoy
con esas herramientas (ports `a85b7e3`), Book of Three, The Frozen World,
Dooms 2 y Desert Nightmare dicen en `conversor.log` "the actor choice's
windows take N tiles…", "the item and equipment windows…", "the shop's
windows…", "the message window's frame and arrow took N tiles…" y "End
Game's windows have more colours than its palette…", y en
`build/release/parches/auto/ventanas/` queda sólo lo de la ventana de
mensajes.

Lo que se pierde con eso: la pregunta "qué se perdió" deja de tener una
sola respuesta para esas pantallas —es la razón de que exista
`parches/auto/`—. Hoy sólo ABL versiona sus parches, y ABL entra sin
fundir nada, así que todavía no hay un diff que lo extrañe: lo va a
extrañar el primer juego que los versione.

**Cómo verlo**: `just cartuchos release` en `book-of-three/` de los ports y
`grep WARNING build/release/conversor.log`.
