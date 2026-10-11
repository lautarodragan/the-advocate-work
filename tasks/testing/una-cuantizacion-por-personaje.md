---
name: "Una cuantización por personaje para las poses"
description: "Un personaje cuantizado distinto en otro mapa lleva su propio banco de poses: en VD son 420 de 1.239 bancos, y las poses (4,26 MB) no pueden ir al .msu"
type: feature
agents: [Mulita]
assignee: taro
---

De `testing/vampires-dawn-arma-desde-su-toml.md` (Aguará, 2026-10-11):
`record.rs` de mapdata guarda un banco de doce poses por (CharSet, índice,
datos), y un personaje que en otro mapa sale cuantizado distinto lleva un
banco propio —506 avisos "goes with a pose bank of its own" en el armado
de VD—. Es lo que más mapas de VD devolvería: los nueve que hoy quedan
afuera por la ROM (95, 164, 170, 219, 221, 222, 239, 338, 429), y lugar
para los que vuelvan con los otros arreglos. Cuánto ahorra no se midió;
del orden del MB por cuenta gruesa.

## Lo medido (Mulita, 2026-10-11)

Base: the-advocate `0bb1120a`, ports `c914245`, en worktrees propios
(`mulita-poses-por-personaje` en los dos). La medición es sobre el pedido
de `rm2k-snes-mapdata emit` del armado de VD **con los nueve de "poses"
devueltos** (14 afuera), copiado con un envoltorio de `rm2k-snes-mapdata`
en el PATH; los scripts están en `~/scratch/mulita/poses/`. (Ese armado
corta en las tropas, 257 de 255 —lo de Hurón—, pero el pedido ya está.)

* **985 personajes con banco, 1.498 bancos, 103 personajes con más de
  uno: 513 bancos de más.** Poses distintas: 10.095, 4,93 MB. Con un solo
  banco por personaje serían 5.257, 2,57 MB: **2,4 MB de techo**.
* **Seis personajes son 367 de esos 513**: `Extra2:2` (75 bancos),
  `F04:5` (70), `Darkages:1` (62), `Valnarposen:4` (57), `F04:1` (55) y
  `UnPoses2:1` (54), cada uno en los 426 mapas. Son los gráficos de
  `ChangeSpriteAssociation` —las transformaciones de Valnar y Asgar en
  lobo y murciélago—: el compilador les reserva un lugar en la tabla de
  gráficos de **todos** los mapas (`associations`), así que Wally los
  reparte en cada mapa como gráficos del comando 34, "mientras entren".
  Casi nunca entran: van **prestados** (`drawn with someone else's`) en
  329, 224, 187, 136, 83 y 69 mapas, y prestado quiere decir cuantizado
  al color más cercano de la paleta de otro —una distinta en cada mapa—.
  Sólo ésos seis, con un banco cada uno: 10.095 → 6.603 poses, **1,75 MB
  menos**.
* **Por qué cambian**: de los 513, 432 cambian la partición de los
  píxeles (otros colores juntados: prestado, o una paleta de 15 elegida
  sobre otras poses, o el tope del timer) y 81 sólo los índices (el mismo
  dibujo en otro orden dentro de una paleta compartida). La paleta del
  mapa no reduce colores: Adeleine no interviene en los sprites salvo
  `merge_least_visible` para el que pasa de 15.
* **Lo que se ve hoy**: esas transformaciones se dibujan con los colores
  de otro personaje en la mayoría de los mapas.

## Lo elegido

Los gráficos que **sólo muestra el héroe** —los de `ChangeSpriteAssociation`
y los del comando 34 sobre el héroe, que ninguna ruta le da a un evento—
son otra cara de un líder, y van como los líderes que comparten el lugar:
en la paleta de los líderes, con **sus colores propios**, que la consola
sube cuando el héroe los toma (`hero_cgram`, como con un líder). Así:

* su banco de poses es el mismo en todos los mapas (la búsqueda de los
  colores es la del personaje solo, ordenada);
* no le sacan paleta al mapa: los NPCs y los tiles prestados bajan solos;
* y se ven con sus colores, no con los de otro.

Cambia en cinco lugares: `events` (qué gráficos le da una ruta a un
evento: `graphics_on_events` en el scan), `convert` (`hero_graphics` a
Wally), `wally` (los pone en la paleta de los líderes, y da los colores
de cada gráfico que cae en una paleta de líderes), `mapdata` (la tabla
`hero_colors` del cartucho, y un byte por gráfico detrás de
`route_graphic`) y el runtime (`hero_poses_of_graphic` apunta
`hero_cgram` ahí, y `graphic_hero` corre `apply_tint`).

**Medido con eso** (el mismo armado de VD con los nueve): 1.498 → 1.163
bancos, 10.095 → 6.717 poses, **4,93 → 3,28 MB, 1,65 MB menos**. Los
mapas con algo prestado, de 365 a 77. Lo que queda por cuantización:
168 bancos de más, 714 KB de techo, repartidos (`Object1:7` 10 bancos,
`leuteposen3:4` 8, `chara07:4` 7…).

**Por qué ésos y no todos**: los seis son 1,65 de los 2,4 MB de techo y
tienen un arreglo que además mejora lo que se ve. Los 168 bancos que
quedan son de personajes cuantizados distinto en pocos mapas cada uno
(otras poses visibles, una paleta compartida en otro orden, el tope del
timer); unificarlos pide que el reparto de paletas de Wally respete un
orden de índices por personaje en todo el cartucho, y eso puede costar
paletas —más prestados, que es un error visible—. No se hizo: 714 KB de
techo, y VD ya entra.

## Lo hecho

Ramas `mulita-poses-por-personaje`:

* the-advocate: `d3f1c486` (events, convert, wally, mapdata y runtime) y
  el merge de origin/main (`5d7d5601`, lo de Hurón) en `335194a8`.
* ports: `ce6e7a7` (el caso `grafico-heroe-propio`: la orden 34 sobre el
  héroe a `Crown7:3`, y `Crown7:3` en `test_graphics` de `release`),
  `41bbe3a` (sus cuatro goldens), merge de origin/main `0982cf0`, y
  `e575020` (VD: vuelven los once de "la ROM").
* the-advocate-docs: `ff1e9ad`, la decisión
  `decisions/los-graficos-que-solo-muestra-el-heroe.md`, y una nota en la
  de la orden 34 sobre el héroe. Links revisados.

**Verificado**, con `just install-local .local-tools events wally mapdata
convert cartridge`:

* `just test` (27) y `crate-test` de events, wally, mapdata y convert en
  verde. Las pruebas de hashes contra el Python sacan lo nuevo como ya
  sacaban lo demás que vino después (`without_hero_colors`, y
  `graphics_on_events` del scan), y con eso dan los mismos hashes.
* La tanda de ABL: 1202 verdes antes del caso nuevo, sin mover una
  golden; con el caso y sobre el merge, **1203 verdes**, `abl.sfc`
  `27d989db75901791…`. El caso nuevo, visto en rojo sin el `apply_tint`
  de `graphic_hero`: 212 pixeles en el cuadro 20.
* VD con los once devueltos (**10 afuera**, de 21: 1, 15, 57,
  99, 150, 165, 225, 399, 402, 403): `just cartuchos` rc 0, 138 s; 12.362
  piezas en 127 bancos y 1.281 en el `.msu` (6.092.634 B). Poses: 6.744
  distintas, 3,45 MB. Bancos libres enteros: 0 (el reparto llena la ROM
  con lo que podría ir al `.msu`); lo que queda de margen son los
  streams de LZ2 que todavía están en la ROM y pueden irse: ~0,64 MB.
  En snes9x con el `.msu`: arranca en el 3 y con A pasa a la casa.

Capturas en `/shared/capturas/2026-10-11-una-cuantizacion-por-personaje/`.

**Lo que no cubre nada**: un `ChangeSpriteAssociation` a un gráfico que
no es de un líder (el de la tanda, `sprite-actor`, es `Future1`; pasa por
la misma rutina que la orden 34); ninguna transformación de VD se miró en
la consola, ni los once mapas devueltos. La orden 34 sobre el héroe ahora
corre `apply_tint`, que cuesta CPU en ese cuadro: no se midió si se nota.

Al mergear: reinstalar `events`, `wally`, `mapdata`, `convert` y
`cartridge` (el runtime cambió).
