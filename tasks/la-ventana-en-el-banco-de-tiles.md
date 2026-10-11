---
name: "La ventana en el banco de tiles"
description: "Un System con el fondo en degradé estirado pide un tile por tono: la ventana de mensajes pasa de 256 tiles y la elección de actor de su rango de VRAM"
type: feature
status: testing
agents: [Tijereta]
assignee: taro
---

Lo que quedó detrás de `la-ventana-con-mas-colores` (Tijereta, 2026-10-05).
Con el System original y los colores ya reducidos por Adeleine, la ventana
de mensajes de The Frozen World pide 266 tiles de 256 y la de The Book of
Three 267; la elección de actor de Dooms 2 se pasa de `$4800`.

Fusionar más colores hasta que entren (`adeleine::merge_until` con los tiles
como condición) se probó y no sirve: Frozen queda en 4 colores y Book of
Three en 2. Lo que hace falta es del lado de los tiles —agrupar los
parecidos, como `adeleine::group_tiles` con los panoramas, o un fondo
repetido en vez de estirado—, y es de criterio: taro tiene que verlo.

## El encargo (Hornero, 2026-10-11)

taro, el 2026-10-11, lo eligió como lo siguiente para los otros juegos:
frena a cuatro —Book of Three (267 de 256), Frozen World (266), Vampires
Dawn (262, el mapa 15: "this map can't carry a message window") y Dooms 2
(la elección de actor pasa de `$4800`; con el mapa 1, las ranuras y el
menú juntan 482–524 tiles de 448)—. Lo de criterio lo decide quien lo
hace, con capturas antes y después en `/shared/capturas/` para que taro
lo mire; si se ve bien, está bien. Que sea genérico: nada por juego, y
ABL —que ya entra— no se mueve (`abl.sfc` byte por byte igual, si se
puede; si no, goldens mostradas).

## Lo que se hizo (Tijereta, 2026-10-11)

Ramas `tijereta-ventana-tiles` en the-advocate, en los ports y en el libro.
La decisión, con los dos caminos que se midieron y dónde se rompe cada uno:
"A window with a gradient is fused until it fits" en el libro.

- **Ventana de mensajes**: el área de texto ya tiene un tile por celda; lo
  que se pasaba era el marco y la flecha (26–28 de 16). Se funde **el fondo
  que se ve a través del marco** (`group_cells`) y el marco va encima tal
  cual: los adornos quedan, el degradé del área de texto queda como en RM2k.
- **Las pantallas a 8bpp** (elección de actor con la barra del menú,
  objetos y equipo, tienda, pelea): `fit.rs` corta sus celdas como
  `borders` y, si no entran, Adeleine (`merge_least_visible_tiles`, nuevo)
  funde de a una la que menos se ve. Viaja en el `Skin`, así `convert` y
  `render` dibujan lo mismo.
- **End Game**: no eran tiles sino colores (pares que no entraban en una
  paleta, también Desert Nightmare): `merge_until` con el negro fijo.
- **Objetos y equipo dejan lugar a su texto**: `item_pairs` mide la lista
  más cargada y las ventanas se funden también si entran en el banco pero
  dejan al texto sin pares. Lo encontró la ROM de Book of Three: con las
  ventanas fundidas hasta el tope, al volver al menú salían "L 23" y
  "999". Y era de antes: Frozen World dejaba 82 pares de los 132.

Descartados, medidos: el fondo repetido (el marco seguía en 14–16 celdas
más la flecha, y el degradé se vuelve serrucho) y fundir ventanas enteras
por k-means (con Royal el marco y la barra solos son 85 de 64; se comía
esquinas). Fusionar colores se había descartado el 2026-10-05.

Los cinco juegos vuelven a su System, salvo Vampires Dawn: sus pantallas
entran, pero la ROM se pasa por una pieza de 64 KB, así que conserva el de
ABL con el comentario de por qué. Los mapas 15 y 150 de VD no son de la
ventana: es el mapa el que no deja los 8 KB fijos de la ventana.

## Qué quedó

- **Dooms 2, mapa 1**: con su System las ranuras y el menú juntan 482 de
  448, y son caras, no ventanas. Tarea aparte.
- **Vampires Dawn con VDBlutsys**: la ROM, no la ventana.
- Nadie jugó las pantallas fundidas: hay capturas de la ROM de la ventana
  en juego (BoT, Frozen, Dooms 2) y del menú y la pantalla de objetos (BoT,
  Dooms 2); la elección de actor, el equipo y la tienda sólo por `render`.
- La tanda de ABL no ejecuta ningún camino de éstos: ABL entra y sale byte
  por byte igual. La prueba que sí los ejecuta es `system_gradient.rs`, en
  `screens`, sin ROM.

## Al mergear

Reinstalar `adeleine`, `rm2k-render` y `screens` (lib en los dos primeros:
`screens` es el binario que cambia). Capturas en
`/shared/capturas/2026-10-11-la-ventana-en-el-banco-de-tiles/`.
