---
name: "Los errores que no nombran el mapa ni la canción"
description: "'the song uses N sounds…' no dice qué canción ni qué mapa, y 'this map can't carry a message window' no lleva el número de mapa en su línea"
type: chore
status: testing
assignee: taro
agents: [Hornero, Cardón]
---

Anotado por Calandria el 2026-10-11, al barrer las exclusiones de los ports: para saber qué mapa sacar hubo que sacarlos de a uno, o buscar el encabezado anterior en el log. Barato y le ahorra vueltas a cada barrido.

## Lo hecho (Cardón, 2026-10-11)

En `the-advocate`, rama `cardon-errores-y-huella`:

* **El conversor** (`rm2k-snes/convert`): `Stop::in_map`, en `fail.rs`, le pone `map N: ` adelante a un corte que no nombra al mapa en su primera línea —y no lo repite si ya lo nombra—. Lo usan las tres etapas por mapa: `maps::prepare`, cada llamada a Wally de `run_all` y `maps::map_info`. Con eso, "this map can't carry a message window" sale `map 15: this map can't carry…`, y también los de Wally que no lo decían (los `attempt` del panorama, `drawable_npcs`…). El de `vram_layout` en `map_info` lo dice además explícito, como ya lo hacía el del panorama.
* **La música** (`rm2k-snes/rm2k-snes-audio`): `in_song`, en `compile.rs`, le pone a lo que corta una canción —`build_events`, `pack`, `fold`— la canción y los paquetes que la llevan, que en un cartucho son los mapas: `song "Graig", in map 10: the song uses 291 sounds and the index is one byte`. Un paquete que no es de un mapa sale por su nombre (`package pelea`). `check` ya nombraba la canción.
* **`rm2k-snes-mapdata`**: los dos de `ev_pos_bytes` ("the map has N events…", "a twin at…") no llevaban el número; ahora sí.

Los demás de la misma clase que se miraron y ya lo dicen: los `stop!` de las dos vueltas por mapa de `convert.rs`, `map_entry`, `pages`, los de `record.rs` y `materials.rs` de mapdata. No se tocaron los que cortan por algo interno —`bytecode::walk`— ni los de la emisión que comprime todo junto (`compress_many` no sabe de qué mapa es cada bloque; `materials.rs` corta antes, con el número).

Verificado, con las herramientas de la rama adelante en el PATH, en un worktree de los ports:

* Dooms 2 sin excluir el 10: `rm2k-snes-audio: song "Graig", in map 10: the song uses 291 sounds and the index is one byte`.
* Vampires Dawn con su toml: `map 15: this map can't carry a message window: it spends 576 background tiles, …`.
* Pruebas nuevas: `a_stop_in_a_map_names_it_once` (convert) y `a_song_that_stops_says_which_maps_carry_it` (audio). Son de funciones nuevas: antes no compilaban, no hay rojo que mostrar.

## Resultado

Rama `cardon-errores-y-huella` de `the-advocate` (con las dos tareas, y `tijereta-sonidos-de-una-cancion` mergeada); en los ports no hay commits. Con las herramientas de la rama adelante en el PATH (`convert`, `mapdata`, `rm2k-snes-audio`, `cartridge`), en un worktree de los ports con `main` 4072372: la tanda de ABL da 1176 passed, y `abl.sfc` = `ea49ff07fd9d…`, la misma de `main` con lo de Tijereta. `just test` y las pruebas de los cuatro crates, en verde.

Al mergear, reinstalar: `just install convert mapdata rm2k-snes-audio cartridge`.

Lo que la tanda no cubre: ningún mensaje de error —ninguna prueba de ABL corta un cartucho—; se vieron a mano en Dooms 2 y Vampires Dawn. Y la huella: la tanda arma desde un `data/` que no cambia; el rearmado se midió a mano en Sunset.
