---
name: "Sunset: las imágenes sobre el mapa"
description: "Sunset dibuja techos, luces, sombras y nieblas como imágenes de pantalla entera sobre el mapa; la ROM las lleva como imágenes grandes, que tapan el mapa, y la escena queda negra"
type: feature
status: testing
assignee: Mulita
agents: [Mulita]
---

Medido por Mulita el 2026-10-11 en `testing/sunset-el-mapa-22-en-negro.md`:
la escena que abre el juego queda negra porque `WinterMist`, una niebla al
95 % de transparencia, va como imagen grande —en lugar del mapa— y la
transparencia oscurece hacia negro.

Unas 140 imágenes de Sunset son así: techos y cielorrasos con el color
transparente (índice 0 en 50-99 % de la imagen), luces y sombras
translúcidas, nieblas al 45-95 %. Casi todos los mapas tienen alguna. Las
imágenes grandes de ABL son pantallas opacas sobre negro, y para eso se
diseñaron (`lo-que-las-imagenes-grandes-no-modelan.md` del libro).

Los dos caminos están en la tarea de arriba: dejarlas afuera con un
criterio, o hacerlas como una capa sobre el mapa.

## La decisión de taro, el 2026-10-11

Dejarlas afuera no: "Sunset es un juego muy artístico. Sin esas imágenes
probablemente pierda totalmente la gracia." Primero analizar cómo las usa
—si hacen de más capas de mapa, de movimientos panorámicos, etc.— y con eso
inventar una solución que funcione bien; si van como capa de mapa sin perder
mucho, bienvenido.

## Bitácora de Mulita

Base: the-advocate `6f933ff8`, ports `b499ab4`, libro `491624d`. Ramas
`mulita-sunset-imagenes` en los tres, worktrees en `~/scratch/mulita/`
(`the-advocate`, `ports`, `docs-wt`). Scripts del análisis en
`~/scratch/mulita/imagenes/` (`recolectar.py`, `pormapa.py`, `ubicar.py`,
`grupos.py`, `capas.py`).

### Lo que se midió (2026-10-11)

* 1.678 comandos de imágenes, 164 archivos. Siguiendo los `Teleport` de
  cada página —Sunset muestra las imágenes del mapa de destino en la puerta
  del de origen, después del salto—, **62 de los 65 mapas** muestran
  alguna imagen que se queda quieta sobre el mapa.
* **Sunset es un juego pintado**: el mapa es el panorama (del tamaño del
  mapa, fijo a él) y las capas del ChipSet están vacías en casi todos.
  El conversor ya lo lleva: el panorama en BG2 a 4 bits, 576 tiles
  agrupadas, y BG1 vacío. Sin imágenes el mapa se ve bien (las capturas de
  `mira-*`), pero el héroe camina por encima de los techos y faltan luces,
  sombras y nieblas.
* **Los techos son recortes del panorama**: el 83,7 % de sus píxeles es
  igual al panorama debajo (100 % en las plazas, la calle de la estatua y
  el bar de primavera; los interiores de otras estaciones difieren). Son
  "lo que va delante del héroe" de un mapa pintado.
* Las imágenes fijas al mapa caen **siempre** en la esquina del mapa con la
  cámara de RM2k del `Teleport` que las precede (`ubicar.py`); las que se
  muestran sin salto previo (10, 5, 58) no tienen cámara conocida, y
  centradas en el mapa coinciden con las demás.
* ABL con la misma regla atraparía 2 (MeanwhileLashe en 81 y el montaje de
  217): la regla va como perilla del proyecto, apagada por omisión.

### El análisis

En el libro: `ports/sunset-over-imdahl/research/2026-10-11-las-imagenes.md`.
Por grupo: techos y cielorrasos (61 mapas, recortes del panorama: van con
la prioridad de sus celdas, gratis), luces (50) y sombras (22) —máscaras
planas al 10-35 %—, nieblas (38, texturas de pantalla), animadas (banderas,
pasto, nubes), el menú propio y las placas de título y créditos. En modo 3
no queda capa para las translúcidas: van mezcladas en el panorama. Lo que
daría el modo 1 para un mapa pintado (techos exactos, sombras por
matemática de color) está escrito ahí, sin hacer: es decisión de taro.

### La primera versión

* the-advocate `06b8321f`: `map_pictures.rs` en el conversor (la regla) y en
  Wally (las dibuja). Perilla `[graphics] map_pictures`, apagada por
  omisión. Wally mezcla las imágenes en el panorama fijo al mapa y sube
  la prioridad de las celdas de BG2 que tapan las opacas; un mapa con
  techos ya no va horneado. El compilador no recibe esas imágenes: sus
  comandos se aceptan sin hacerse.
* ports `ce01ff9`: Sunset la prende. 183 imágenes en 64 mapas.
* libro `a5554be`: la investigación, la divergencia
  `las-imagenes-dentro-del-mapa.md` y la página del port.
* Visto con capturas (snes9x) de 28, 2, 13, 33, 7 y la escena del 22,
  contra el original con Wine en la misma celda: en
  `/shared/capturas/2026-10-11-sunset-imagenes/`. Para el original armé
  variantes del juego que empiezan en el mapa con las imágenes de la
  puerta (`~/scratch/mulita/wine3/variante.py`).
* Rojo antes: la escena del 22 negra (tarea `testing/sunset-el-mapa-22-en-negro.md`),
  y cualquier mapa con techos tapado por una imagen grande.

### Lo que vi y no es de esto

Las plazas (40x30) y las calles (20x30) ya salían granuladas en main: el
panorama trae 2.000 a 4.800 celdas distintas y entran 576 tiles; en la
plaza de primavera el canal y el pabellón salen rotos. Es el presupuesto de
tiles del panorama. Lo que lo arreglaría es subir al panorama sólo lo que
se ve (una ventana de ~33x29 celdas), con DMA al moverse la cámara: es la
siguiente tarea que más pesa para Sunset.
