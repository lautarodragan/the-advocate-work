---
name: "Sunset: la escena del mapa 22 en negro"
description: "En un cartucho chico de Sunset Over Imdahl (mapas 11, 22, 21, 23 y 10) la escena del mapa 22 queda en negro, con o sin la muleta del grupo"
type: bug
assignee: taro
agents: [Mulita]
---

Visto por Mulita el 2026-10-10, al cerrar `testing/el-grupo-vacio-al-empezar.md`: no es del grupo vacío, pasa también con `party = [1]`.

## La causa: son dos, una detrás de la otra

El 11 tiñe la pantalla a negro (`TintScreen` 0,0,0 en 25 cuadros) y salta
al 22 (17, 13). Ahí la escena es el ev1, autorun: `PlayBGM`, lluvia,
`ShowPicture` de `WinterMist` y su `MovePicture`, el tinte a
(110, 120, 120, 90) en 70 cuadros, los mensajes, y el salto a la tienda
(21), con los techos y la luz de la tienda como imágenes.

1. **La página no compilaba.** Pide `ChangeScreenTransitions [1, 19]` —el
   corte para mostrar—, que el compilador rechazaba ("no ROM map uses
   them"): `rm2k-snes-events culprits` lo da como el único culpable de una
   página del cartucho chico. Sin la página, nada saca el negro del tinte
   del 11. En el conversor se veía como "map 22: 2 automatic event page(s),
   1 runnable".
2. **Con la página corriendo, sigue negro: la niebla tapa el mapa.**
   `WinterMist` es una niebla de 320x240 que se muestra al 100 % de
   transparencia y baja al 95 %. La ROM la lleva como imagen grande —BG1 en
   modo 1, el mapa se va— y la transparencia oscurece hacia negro, así que
   al 95 % es una pantalla negra. Se ve en el cuadro exacto: con
   `sondear.py` el negro cae en el tick del `ShowPicture` y no en el del
   tinte; sacando el tinte del volcado sigue negro, sacando las dos de
   imágenes la escena corre entera —panorama, tinte, mensajes, y el salto
   al 21 con la tienda—. No hay otra causa detrás.

Lo que hace RM2k (easyrpg-player): `TransitionCutIn` dura un cuadro
(`Transition::GetDefaultFrames`) y `TransitionNone` cero; las imágenes se
borran al cambiar de mapa (`flags = 1 | 32 | 64` por omisión en
`Game_Pictures::ShowParams`), como hace la ROM. El original con Wine
(RPG_RT de 2015, en `~/scratch/mulita/wine2/`, Xvfb :94) muestra el
panorama con lluvia y la niebla que entra.

## Lo que se arregló: el corte para mostrar

* `rm2k-snes/events/src/compile.rs`: el corte (19) y "ninguna" (20) para
  mostrar compilan a `TRANSITION_CUTOFF`, igual que para borrar.
* `runtime/enter_map.s`, `fade_tick`: con `TRANSITION_SHOW` en el corte,
  el fundido termina en el tick de la carga, con el brillo entero y ese
  tick todavía congelado. Los comentarios de `teleport_transition.s` y
  `far_ram.s`, al día.
* ABL lo pide sólo en el 302, que no entra: `abl.sfc` cambia por el código
  del runtime y por los dos casos nuevos, no por el juego.

## Lo que no se arregló: las imágenes sobre el mapa

No es acotado. Sunset dibuja así sus techos, cielorrasos, luces, sombras y
nieblas en casi todos los mapas: unas 140 imágenes de pantalla entera
(320x240 a 656x480), la mayoría con el color transparente cubriendo entre
la mitad y el 99 % de la imagen, o mostradas al 45-95 % de transparencia
(`~/scratch/mulita/bin/pics.py` las lista con sus parámetros). Todas son
imágenes grandes para el conversor, que tapan el mapa: **cualquier escena de
Sunset con una de ésas queda negra o con la imagen sobre negro**. Las de ABL
son pantallas opacas (índice 0 en 0-13 %), que es para lo que se diseñaron.

Dos caminos, sin elegir:

* **Dejarlas afuera** (aceptadas sin hacerse) cuando son "sobre el mapa":
  el juego se ve sin techos ni nieblas, pero se ve. Pide un criterio —una
  perilla del proyecto o una regla por el índice 0 y la transparencia— y
  cuidar las que sí van sobre negro, como `ImdahlTitleImage` del 11.
* **Hacerlas**: una capa encima del mapa con el color transparente, y
  matemática de color para la transparencia, en un mapa que ya está en
  modo 3 con el panorama. Es una feature entera.

Ver `todo/sunset-las-imagenes-sobre-el-mapa.md`.

## Bitácora

* Cartucho chico en el toml de Sunset de mi worktree, sin commitear:
  `[cartridges.arranque]` (empieza en 11) y `arranque22` (empieza en 22),
  `flags = ["--no-title"]`, `party = [1]`.
* `build/` no se entera de un cambio en `data/`: `just cartuchos` dijo "up
  to date" con el `Map0022.json` tocado, y hubo que borrar el directorio
  del cartucho. Para medir alcanza; no lo seguí.
* En la escena sin imágenes la ventana de mensajes sale opaca y naranja:
  la página pide la ventana transparente y `ChangeSystemGraphics` (en el
  11). No es de esta tarea.
* Rojo antes del arreglo: con las herramientas de main (5094ef11) la tanda
  de ABL ni arma —"transicion-mostrar-corte.json: the test page doesn't
  compile"—.
* Verde: la tanda entera de ABL con `events` y `cartridge` de
  `mulita-sunset-22` adelante en el PATH, **1176** (las 1174 más las dos
  nuevas); `abl.sfc` = `f81ae57da625…`, distinto del `5852b723…` de main
  por el runtime y los casos nuevos. `just crate-test events`, verde.
* Después mergeé `main` en las dos ramas (Tijereta en
  `rm2k-snes-audio`, Calandria en los tomls de otros juegos) y **no** volví
  a correr la tanda sobre el merge.

## Al mergear

Ramas `mulita-sunset-22` en the-advocate, the-advocate-ports y
the-advocate-docs. Reinstalar en el global: `events` y `cartridge` (éste
por el runtime).

## Lo que no cubre la tanda

* **Sunset**: no tiene pruebas. Que la página del 22 ahora corre se miró
  con capturas de snes9x en el cartucho chico, no con una prueba; que sigue
  negro, también.
* `test_mostrar_con_el_corte` cubre el corte para mostrar en el salto del
  2 al 5 de ABL, con el borrar por omisión (el fundido). El corte para
  borrar y para mostrar juntos —que es lo que Sunset pide para el salto de
  la tienda en adelante— no lo corre ninguna prueba.
* No se miró en bsnes ni en el hardware.

Capturas, con el original al lado: `/shared/capturas/2026-10-11-sunset-22/`.
