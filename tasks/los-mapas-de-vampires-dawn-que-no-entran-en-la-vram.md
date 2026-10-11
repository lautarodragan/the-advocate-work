---
name: "Los mapas de Vampires Dawn que no entran en la VRAM"
description: "Nueve mapas de Vampires Dawn —Shannar, Uruya, Melsan, Asran entre ellos— quedan afuera por la VRAM: cinco sin reparto que aguante fondo, sprites y capa de arriba, dos sin lugar para la ventana de mensajes y dos por su panorámica en modo 1"
type: feature
status: draft
---

Lo que queda afuera de Vampires Dawn por VRAM, medido por Aguará el
2026-10-11 (`testing/vampires-dawn-arma-desde-su-toml.md`) y confirmado
por Mulita al devolver los once de "la ROM"
(`testing/una-cuantizacion-por-personaje.md`, 10 afuera). Cada uno con su
error en el comentario de `excluded` en `vampires-dawn/rm2k-snes.toml`
(ports `a85b7e3`); no comprobado hoy.

| mapa | qué dice |
|---|---|
| 15 Shannar | "this map can't carry a message window": 576 de fondo, 436 de sprites, 130 de arriba, y ningún reparto deja los 8 KB de la ventana |
| 150 Shannar danach | lo mismo, sólo en el cartucho entero (solo, entra) |
| 57 Shannar Hinrichtung | "fits no VRAM layout": 609 de fondo, 768 de sprites, 130 de arriba |
| 99 Melsan | 451, 640, 177 |
| 165 Uruya | 817, 768, 95 (solo, entra) |
| 225 Asran | 780, 704, 116 (solo, entra) |
| 399 Wald12 | 716, 512, 136 |
| 402, 403 Schneeklippe | "there is no layout for a panorama in mode 1 that holds … 435 panorama tiles" |

**Lo que se sabe de la causa**: no es el fondo. La fusión de tiles
(`testing/fusionar-tiles-parecidos.md`, Cardón, 2026-10-06) baja cualquier
fondo al tope y "ya no es lo que traba a ninguno"; lo que no entra son los
sprites y la capa de arriba, y fusionar fondo no lo arregla. Cardón dejó
anotado el paso siguiente posible: degradar los sprites con el mismo
criterio, "otro tipo de fusión, más caro: son poses y paletas". La ventana
de los 15 y 150 no es la del System: su banco es de 256 tiles fijos
(Tijereta, `testing/la-ventana-en-el-banco-de-tiles.md`). Que 150, 165 y
225 entren solos y no en el cartucho entero es porque en el entero
compilan más páginas y entran más eventos (Aguará).

**Qué se ve jugando**: esos mapas no están en el cartucho, y un evento que
lleve a ellos pierde la página entera (un `Teleport` a un mapa que no
está no compila). Hasta dónde se puede jugar sin ellos no se miró.

**Cómo verlo**: sacar el mapa de `excluded` y `just cartuchos release` en
`vampires-dawn/` de los ports (unos dos minutos; con el MSU-1, que el
proyecto pide obligatorio).
