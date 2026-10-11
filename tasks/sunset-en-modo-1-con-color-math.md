---
name: "Sunset en modo 1, con color math"
description: "Los mapas pintados de Sunset no se juegan en modo 3: probar modo 1 con color math —techos exactos, luces y sombras que alcanzan a los personajes, el panorama sin el mosaico de los mapas grandes—"
type: feature
status: testing
assignee: taro
agents: [Mulita]
---

Sigue de `testing/sunset-las-imagenes-sobre-el-mapa.md` y de su research en el libro (`ports/sunset-over-imdahl/research/2026-10-11-las-imagenes.md`), que ya escribió qué daría el modo 1.

taro, el 2026-10-11, después de ver las capturas: "realmente no es jugable. No es un buen juego para portar a SNES, pero probaría Modo 1 y Color Math antes que otra cosa." Y aclaró que **nunca hubo una decisión que prohíba otro modo o color math**: modo 3 fue lo adecuado para ABL, y el color math se descartó para algo puntual. El libro lo decía como regla y se corrigió (`cartridge/mode-3.md`, `decisions/el-color-math-no-se-usa.md`).

## Bitácora de Mulita

Base: the-advocate `origin/main` 06b8321f, ports `main` 36adb9a, libro
`origin/main` 96483dc. Ramas `mulita-sunset-modo-1` en los tres, en los
worktrees de `~/scratch/mulita/` (`the-advocate`, `ports`, `docs-wt`).
Scripts, en `~/scratch/mulita/modo1/`.

### El diseño (2026-10-11)

Lo que más pesa es el mosaico, y no lo arregla ninguna cantidad de tiles
que entre: las plazas tienen 4.670-4.800 celdas distintas de 4.800, y en
VRAM no entran más de 1.024 por capa. Lo que sí entra es **lo que se ve**:
33x29 celdas, 957 tiles de 4 bits. Así que un mapa pintado va **pintado**,
un camino nuevo (`Way::Painted` en Wally, perilla `[graphics]
painted_maps`):

* modo 1, BG1 = la pintura a 4 bits, **un tile por celda, sin agrupar**;
  la ROM sube la columna o la fila que entra, desde el cartucho, en el
  vblank. Celda (x, y) en el slot `(y mod 29) + 29 (x mod 33)`; el
  cartucho las lleva columna por columna, así una columna es un DMA (o
  dos) y una fila 33.
* el tilemap es la ventana del mapa de siempre: `build_column` y
  `build_row` lo arman, y `paint_column`/`paint_row` pisan lo de BG1 con
  la pintura. Los bloques siguen siendo del mapa (pasabilidad, capa de
  arriba).
* VRAM `VENTANA_PINTADA`: sprites 256, 33x30 = 990 slots + uno en blanco
  en $1000, tilemap $5000, `window_map` $5800, BG2 en $6000 como siempre;
  libre $5C00-$5FFF.
* Una columna es un DMA o dos y va cuando hace falta; una fila son 33, y
  con 29 filas de slots la fila y la columna en el mismo vblank llegaban a
  la línea 262 (medido con una sonda de `$213D` al final del vblank). Con
  una fila de repuesto (30) la que viene se sube adelantada, 11 tiles por
  cuadro: el vblank termina en la línea 250-251.
* Lo que va delante del héroe, por la prioridad de las celdas de BG1,
  como en el mapa aplanado (con la máscara de BG1 bajo la ventana).
* Todo el runtime nuevo está adentro de `.ifdef paint_table`: un cartucho
  sin mapas pintados sale byte por byte igual. ABL no se mueve.

RAM nueva: `$7E7900-$7E791F` (el estado) y `$7EFE00-$7EFF3F` (la cola de
DMAs, al final del banco de la grilla: el conversor revisa que la grilla de
un mapa pintado no llegue).

### Lo que aporta cada parte (medido 2026-10-11)

Error medio por píxel (suma de los tres canales a 5 bits) contra el
panorama, y % de celdas con más de 8 píxeles mal, con Adeleine y Voodoo
de verdad (`~/scratch/mulita/modo1/medir_mosaico.rs`, un ejemplo de Wally
que no se commitea):

    panorama            576 agrupados   960 agrupados   uno por celda
    TownSquareSpring    10,53  85,6 %    9,45  82,1 %    2,30  20,7 %
    TownSquareWinter     8,59  72,7 %    7,57  66,3 %    2,12   8,9 %
    TownSquareSummer    10,83  89,4 %    9,92  84,7 %    2,56  21,7 %
    TownSquareAutumn     8,59  78,2 %    7,71  70,6 %    1,88   6,5 %
    TheStatue (320x480)  4,91  42,9 %    3,24  26,8 %    0,92   0,4 %
    GateStreet (320x480) 5,15  40,0 %    3,37  24,7 %    0,94   0,3 %
    InnSpring (320x240)  3,36  30,7 %    1,62   6,2 %    1,59   4,6 %
    BarSpring (320x240)  3,06  28,7 %    1,35   3,0 %    1,35   2,7 %

960 es lo que daría el modo 1 con BG1 a 4 bits sin streaming (casi el
doble que 576). En las plazas **no alcanza**: de 10,5 a 9,4. Lo que las
arregla es el streaming: 2,3, y lo que queda es la reducción a 7 paletas de
15 colores. En los interiores de una pantalla 960 ya casi alcanza; con el
streaming quedan igual. Así que se hace sólo el streaming, para los 60
mapas pintados.

Lo verificado: `modo1/chequear.py` corre un cartucho y en cada cuadro
compara los slots de VRAM de las celdas visibles contra los tiles del `.inc`
(snes9x, que bloquea los accesos a VRAM fuera del vblank). En 2, 13, 33, 7
y 28, caminando en las cuatro direcciones, diagonales y volviendo sobre los
pasos: ninguna celda mal fuera de los cuadros de carga (pantalla apagada) y
de los cuadros perdidos. Un cuadro perdido de más en 2 (vuelta atrás con la
fila a medio subir: se sube entera en el tick). `abl.sfc` sale igual,
`24dd24adb52f…`.

### Los techos, exactos (2026-10-11)

Las celdas que el techo cubre entero, por la prioridad de BG1; las que
cubre en parte, en BG2 a prioridad 1: la celda de la pintura con sólo los
píxeles del techo, en su paleta. 127 tiles; los bordes que no entran van
por celda entera. Sobre los 60 mapas: 34.895 de 1.586.793 píxeles del lado
equivocado (2,2 %); en la plaza de primavera 2.250 de 84.145 (antes 5.831).
Visto en el bar (28): el héroe pasa entre las vigas.

### El color math: medido, no va

* No alcanza a todos los personajes: el hardware hace color math sobre
  objetos sólo con paletas 4 a 7, y en la plaza de primavera hay objetos
  con las paletas 0, 3, 6 y 7 en pantalla.
* No hay VRAM para la máscara: con los slots quedan 1.024 palabras
  ($5C00-$5FFF): un tilemap de 32x32 sin tiles, o tiles sin tilemap.
* La pintura no lo necesita: sombras, luces y nieblas van mezcladas, y con
  un tile por celda salen como son.

Para hacerlo haría falta que el conversor dé a los personajes de esos mapas
las paletas 4 a 7 y que los bordes de techo cedan la mitad de los tiles de
BG2. Escrito en el libro: `ports/sunset-over-imdahl/research/2026-10-11-el-modo-1.md`.

### Capturas

`/shared/capturas/2026-10-11-sunset-modo-1/`: original / main / modo 1 en
2, 13, 28, 33, 7 y la escena del 22, con su `LEEME.txt`.

### Para mergear

Ramas `mulita-sunset-modo-1`: the-advocate `0bb1120a` (con `origin/main`
e9a9488f mergeado; el merge pedía importar `block` en `panorama.rs` de
mapdata, que Tijereta había cambiado por `msu_block`), ports `6048425`
(con c1a3966), libro `5d696e9`.

Reinstalar: **`project`, `wally`, `mapdata`, `convert` y `cartridge`**
—el runtime cambió y `cartridge` y `convert` lo llevan compilado; `project`
por el merge, no por esto—.

Sobre el merge, con esas herramientas: la tanda de ABL **1202 passed**, y
`abl.sfc` **24dd24adb52f…**, igual que main. Lo de los mapas pintados no
lo corre ninguna prueba: ABL no tiene, y Sunset no tiene casos. Lo que lo
cubrió es `modo1/chequear.py` (VRAM contra el `.inc`, cuadro a cuadro) y
las capturas.

Lo que queda:

* Una vuelta atrás de la cámara con una fila a medio subir la sube entera en
  ese tick, y en la plaza eso costó un cuadro perdido.
* Plazas y calles con más de 127 bordes de techo: el resto va por celda
  (2,2 % del lado equivocado en total). Se podrían dar 256 moviendo la base
  de BG2 y la ventana al índice 256.
* Los colores: 7 paletas de 15 por mapa.
* Los personajes sin sombra ni luz (ver el color math, arriba).
* Si un juego con mapas pintados pide `[rom] msu = "required"`, los tiles
  de la pintura se quedan en la ROM (son `.block` comunes, no `msu_block`):
  no se probó.
