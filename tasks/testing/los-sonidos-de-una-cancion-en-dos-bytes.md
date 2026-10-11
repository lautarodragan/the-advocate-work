---
name: "Los sonidos de una canción, más de 255"
description: "Dooms 2 deja afuera los mapas 10, 14 y 63 por 'the song uses 291 sounds and the index is one byte' (411 en el 14)"
type: feature
assignee: taro
agents: [Hornero, Tijereta]
---

Medido por Calandria el 2026-10-11 (`testing/las-exclusiones-que-sobran.md`). Misma familia que `testing/la-musica-y-las-tropas-en-dos-bytes.md`. Mirar antes cómo quedó la tarea de Tijereta de los sonidos en más de un banco, que toca lo mismo.

## Hecho, el 2026-10-11 (Tijereta)

Sobre the-advocate `main` 70d4348a, ports `main` 33fde63 y libro `main` 67a671e; rama `tijereta-sonidos-de-una-cancion` en los tres. `main` no se movió mientras tanto.

**Qué cortaba**: `pack` (`stream.rs` de `rm2k-snes-audio`) se negaba a pasar de 256 sonidos porque las tres familias de notas (`OP_NOTE`, `OP_NOTE_VOL`, `OP_NOTE_PAN`) nombran el sonido en un byte. Los temas de Dooms 2 son Graig (mapas 10 y 63) y Demons (14).

**El cambio**: un opcode nuevo del stream de música, `OP_SOUND_PAGE` = **0x65** (`page: byte`), el siguiente libre: las notas que siguen nombran los sonidos desde página × 256. El codificador lo emite sólo cuando la página cambia, así que un tema de 256 o menos nunca lo dice. En el runtime (`music_frame`, `runtime/music.s`) mueve `MUS_BASE` a `song_sounds` del tema más página × 1536; `note_sound` no se toca y no cuesta un ciclo más. `music_start_done` ya repone la base al empezar o volver a empezar, que es la página 0. Descartado: notas de dos bytes (mueve la música de ABL) o un prefijo por nota (veinticuatro opcodes o un costo por nota).

Las repeticiones no necesitaron nada: la página es estado del lector, como su caché, y un `OP_REPEAT` reemplaza bytes idénticos en el mismo lugar del stream plano, así que los lee en la misma página. Al principio creí que `fold` tenía que filtrar por página; la prueba mostró que no.

**En rojo antes**: `a_song_with_more_than_256_sounds_writes_what_it_has_to` (600 sonidos), con el mismo error de Dooms 2 ("the song uses 600 sounds and the index is one byte"). Además `a_repeat_reads_its_bar_in_the_page_it_is_in`, que pliega compases de las páginas 0 y 1 (ésa no pudo verse en rojo: sin el opcode no compila).

**ABL**: `musicdata.inc` byte por byte igual al de `main`; `abl.sfc` pasa de `f81ae57da625…` a `ea49ff07fd9d…`, sólo por el código nuevo del runtime. Tanda con mis herramientas: **1176 en verde**. `just test` y los crates bytecode, cartridge, mapdata, events, convert y rm2k-snes-audio, en verde. No cambió ningún hash de `mapdata/tests/python.rs` ni de las pruebas de huellas.

**Dooms 2**: sin el 10, el 14 y el 63 en `excluded`, `just cartuchos release` arma. Excluye sólo el 1 (elegir personaje, la pantalla de ranuras y el menú), y sigue con el System de ABL. Con el arnés de ABL apuntado a `dooms2.sfc` (`~/scratch/tijereta/sonidos/dooms2_musica.py`, descartable), la ROM le escribe al DSP exactamente lo que dice el stream de Graig y de Demons, enteros y el principio de la segunda vuelta; con `sound_page` mutilado (lee la página y no mueve la base) da distinto en el cuadro 8138 de Graig, el primero de la página 1.

**El arnés de ABL** (`consola.py`, `stream_del_tema`) le pasaba al decodificador 256 sonidos; ahora, hasta el final del banco. En ABL no cambia nada (`test_musica_escrituras.py` y `test_bateria_suena.py` en verde).

**Libro**: `internals/audio.md` (cómo nombra una nota su sonido) y `ports/dooms2/README.md` (qué deja afuera).

**Lo que la tanda no cubre**: ningún tema de ABL pasa de 256 sonidos, así que `OP_SOUND_PAGE` en la ROM no lo ejecuta ninguna prueba de la tanda; lo cubren las dos pruebas del crate (el modelo del decodificador) y la corrida a mano sobre el cartucho de Dooms 2. Los mapas 10, 14 y 63 no se jugaron en un emulador, ni se escuchó la música.

Al mergear: `just install cartridge rm2k-snes-audio` (bytecode es biblioteca; `rm2k-snes-assemble` escribe `music_opcodes.inc` desde ella). El runtime entra solo, desde el checkout.

Para Cardón: el mensaje "the song uses N sounds and the index is one byte" ya no existe; queda uno nuevo en el mismo lugar, para más de 65536 sonidos, que no puede pasar antes del tope de 64 KB de la tabla.
