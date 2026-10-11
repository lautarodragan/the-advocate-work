---
name: "Los sonidos de la música, en más de un banco"
description: "Vampires Dawn corta en 'rm2k-snes-audio: the music's sounds go over one bank: 41118 B': la tabla de sonidos de todos los temas no puede pasar de un banco de 32 KB"
type: feature
status: testing
assignee: taro
agents: [Tijereta]
---

Medido por Tijereta el 2026-10-10, al cerrar `la-musica-y-las-tropas-en-dos-bytes.md`: con `Music/` entero (281 temas), arrancando en 8 y sin los 82 mapas que excluyó Aguará, VD pasa la música, las tropas y las acciones y corta acá (`emit.rs` de `rm2k-snes-audio`). Es el muro siguiente de todo el juego.

## Hecho, el 2026-10-11 (Tijereta)

Sobre the-advocate `main` 5094ef11 y ports `main` 038ea64, rama `tijereta-sonidos` en the-advocate. Los ports no se tocaron.

**El "banco" del tope era el de LoROM.** `if body.len() > 0x8000` es del 2026-09-29 (29c710cf), dos días antes de que el cartucho pasara a ExHiROM. Hoy el empaquetado (`pack`, en `rm2k-snes-cartridge`) deja un `.block` de hasta 64 KB entero adentro de un banco, y `note_sound` lee `music_sounds + k` con X de 16 bits —la base del tema más seis por sonido—, así que con la tabla entera en un banco cualquier índice queda adentro. El cambio más chico que sirve es subir el tope a 0x10000: ni el runtime ni la tabla cambian, y la de ABL sale byte por byte igual.

Partir la tabla en varios bancos —un byte de banco por tema, y leerla de otra manera, porque `note_sound` usa Y para el registro de la voz y un `lda [dp], y` se lo pisaría: o un puntero en la página cero y salvar Y, o cambiar el DBR para copiar los seis bytes a la RAM lejana— queda para cuando un juego pase de 64 KB. VD usa 41118 B con sus 281 temas.

* Prueba nueva, `the_music_s_sounds_take_a_whole_bank_and_no_more` en `tests/python.rs` de `rm2k-snes-audio`: estira los temas del juego de prueba hasta 38736 B y después hasta pasar de 64 KB. **En rojo antes del cambio**, con el mismo error de VD (`the music's sounds go over one bank: 38736 B`); en verde después. El hash de `musicdata.inc` del juego de prueba no se movió.
* `abl.sfc` = `5852b72358b685be…`, igual que en `main`, y la tanda de ABL con mis herramientas: 1174 en verde.

**Qué corta ahora a VD**: con las 82 exclusiones de Aguará y arrancando en 8 (`~/scratch/tijereta/musica/vd.py`), pasa la música y corta en el empaquetado: `the data does not fit: a piece of 512 bytes needs a new bank, and the 127 banks the cartridge has for data are taken`. Los `.block` suman 11,69 MB contra 7,94 MB de los 127 bancos —sin contar las 82 muestras `.crossbank`—: 4,27 MB son `pose_N`, 2,21 MB `map_tiles_N`, 0,54 `map_cells_N`, 0,51 `pano_tiles_N`, 0,42 `big_tiles_N`, 0,39 `pages_N`; la música, 0,71 MB, y sus sonidos 0,04. Es otro muro, y grande: no se toca acá.

**Lo que la tanda no cubre**: una tabla de sonidos de más de 32 KB en una ROM que corra. ABL tiene una chica, y VD no linkea todavía; que `note_sound` la lea bien en un banco entero sale del razonamiento de arriba, no de una corrida.

Al mergear: `just install rm2k-snes-audio`.
