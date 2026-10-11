---
name: "Las animaciones de tiles que no entran en WRAM"
description: "Un mapa cuyo flujo de anim_tiles no entra en WRAM corta el armado; que el mapa quede sin esa animación, con aviso"
type: feature
status: testing
assignee: taro
agents: [Cardón]
---

De taro, el 2026-10-10, en el orden propuesto. Del 2026-10-06: el mapa 1 de Vampires Dawn ("a stream of anim_tiles is 27264 bytes and 8192 fit in WRAM"), uno de Book of Three y uno de Desert Nightmare. Misma línea que `testing/degradar-en-vez-de-fallar.md`.

## Qué es el flujo y quién pone el tope (Cardón, 2026-10-10)

`anim_tiles` son los dibujos de la animación del ChipSet —el agua, tres
dibujos, y los tiles animados, cuatro— que `anim_upload` sube a VRAM cada
vez que cambia el reloj. Viven en WRAM mientras se está en el mapa, en
`ANIM_DRAWINGS` = `$7F6000`–`$7F8000` (`far_ram.s`): 8 KB, arriba del buffer
de carga del fondo y debajo de la grilla, y lo que va después —capa de
arriba y sprites, 24 KB— no puede pisarlos. El tope lo pone el runtime y lo
hace cumplir el conversor: `LZ2_CAP_ANIM` en `mapdata/src/materials.rs`,
contra el que `check_streams` cortaba el armado. Agrandarlo es achicar el
de los sprites; no se tocó.

Cada familia es una corrida contigua de tiles al final del banco del fondo
(Voodoo la numera), el banco ya lleva el dibujo 0 de cada uno, y la consola
sube los primeros `tiles` de cada dibujo. Así que **se puede perder menos
que la animación entera sin redibujar nada**: cortar la corrida a sus
primeros `k` tiles deja a los demás quietos en su dibujo 0.

Medido con las herramientas globales, un mapa por cartucho:

| mapa | bytes | corridas (tiles × dibujos) |
|---|---|---|
| Book of Three 46 | 10432 | agua 25×3, animados 22×4 |
| Desert Nightmare 182 | 9792 | agua 51×3 |
| Vampires Dawn 236 | 9792 | — |
| Vampires Dawn 351 | 9152 | — |
| Vampires Dawn 1 | 27264 | agua 142×3 |

El orden de Voodoo (el primero que encuentra, fila por fila) ya deja
adelante los más usados: en el mapa 1 de VD los primeros 42 tiles de agua
cubren casi todas las celdas de agua del mapa.

## Hecho (Cardón, 2026-10-10)

**Se pierde parte de la animación, no toda**: `mapdata/src/animation.rs`
corta cada corrida a sus primeros `k` tiles; los de atrás quedan quietos en
su dibujo 0, con un WARNING que dice cuántos tiles y cuántas celdas por
familia. Los `k` son los que más celdas del mapa dejan moviéndose dentro de
los 8 KB (contadas por la tabla de bloques; empates, más bytes y después la
primera familia). No se reordena la corrida —movería números de tile en la
tabla de bloques—; no hizo falta: el orden de Voodoo ya deja adelante los
más usados. "Menos cuadros" no se puede sin tocar el runtime: cuántos
dibujos tiene cada familia es fijo en `chipset_animation.s`.

Va en mapdata y no en wally porque el tope es de mapdata y porque no hay
que redibujar nada; queda escrito en el `lib.rs` del crate como la única
cosa que decide sobre lo que se ve. Un mapa que entra no pasa por ahí.

* snes-rm2k, rama `cardon-anim-tiles`: `1bdf72a0`. Prueba nueva
  `mapdata/tests/animation.rs`, vista en roja con `fit` sin hacer nada.
* ports, rama `cardon-anim-tiles`: `61e11d5`, el 46 de Book of Three y el
  182 de Desert Nightmare salen de `excluded`; los dos releases enteros
  arman con la rama.
* libro, rama `cardon-anim-tiles`: `fcd736f`, la divergencia
  `la-animacion-del-chipset-que-no-entra-en-la-wram.md` y una línea en el
  README de cada uno de los tres ports.

Medido, cada mapa en un cartucho con el de arranque de su juego:

| mapa | queda quieto | después corta |
|---|---|---|
| BoT 46 | 9 de 25 de agua (25 de 115 celdas), 2 de 22 animados (2 de 2185) | nada: arma |
| Desert 182 | 9 de 51 de agua (44 de 1469) | nada: arma |
| VD 236 | 9 de 51 de agua (26 de 1480) | la música: 281 temas y la pista va en un byte |
| VD 351 | 5 de 37 de agua (9 de 674) | la música, igual |
| VD 1 | 100 de 142 de agua (4275 de 262866) | la grilla: 180.000 bytes contra 64 KB de WRAM |

Tanda de ABL con `mapdata` local: 1159 verdes; `abl.sfc` sale idéntico,
`f135f6af…`. `just -f tools/justfile test` en verde.

**Lo que la tanda no cubre**: ningún mapa de ABL pasa del tope, así que el
corte no lo ejecuta ninguna ROM de la tanda; lo cubren la prueba del crate y
los cartuchos de BoT y Desert, que arman pero **nadie miró jugando**: que el
agua cortada se vea bien en la consola está sin ver.

Instalar al mergear: `mapdata` (`just -f tools/justfile install mapdata`).
