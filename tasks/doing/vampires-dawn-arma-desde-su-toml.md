---
name: "Vampires Dawn arma desde su toml"
description: "Volver a barrer los mapas de VD con el main de hoy —MSU-1 obligatorio, 255 sonidos, NPCs, eventos en la RAM ya arreglados— y commitear sus exclusiones y su mapa de arranque, para que arme desde el rm2k-snes.toml como los demás"
type: feature
agents: [Aguará]
assignee: Aguará
---

taro, el 2026-10-11: lo siguiente para Vampires Dawn. Hoy el toml
commiteado tiene `excluded = []` y `start_map = 3`, y corta en el mapa 15
("this map can't carry a message window"). Tijereta lo armó con las 82
exclusiones del rebarrido de Aguará (2026-10-10) arrancando en el 8, sin
commitear esa configuración.

La tabla de qué lo frenaba (research `2026-10-10-otros-juegos-de-nuevo.md`
del libro, sección 2) es vieja: desde entonces se arreglaron las canciones
con más de 255 sonidos (28 mapas), los NPCs que no entran en OAM (25) y
los eventos que no entran en la RAM (15). Lo que queda es medirlo.

La ventana del mapa 15 la está arreglando Tijereta en paralelo
(`la-ventana-en-el-banco-de-tiles`): acá se excluye como cualquier otro, y
se saca de la lista cuando eso llegue.
