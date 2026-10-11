---
name: "La música y los miembros de tropa, sin el tope de un byte"
description: "Vampires Dawn corta en 'Music/ has 281 songs and the track goes in a byte' y detrás en los 470 miembros de tropa en una tabla de un byte: que entren"
type: feature
assignee: taro
agents: [Tijereta]
---

Del re-barrido del 2026-10-10 (research `2026-10-10-otros-juegos-de-nuevo` del libro): son los dos muros de todo el juego que le quedan a Vampires Dawn. El tope de la música cuenta todos los archivos de `Music/`, se usen o no. Misma línea que `testing/los-encuentros-en-dos-bytes.md`.

## Hecho, el 2026-10-10 (Tijereta)

Rama `tijereta-musica-y-tropas` en `the-advocate`, sobre 27010065.

### La música: sólo los temas nombrados, y sólo cuando no entra

`Game::track_numbers` numeraba todo `Music/` —281 en Vampires Dawn— y la
pista va en un byte de `song_msu`. Ahora, **si la carpeta entera no entra
en el byte**, numera sólo los temas del juego que algo nombra (`PlayBGM`,
el árbol de mapas, el `System`, y ahora también `ChangeSystemBGM`), y
después los del RTP como antes. Los nombrados salen del juego entero y
no del cartucho, así que el número sigue siendo el mismo en cualquier
cartucho, que era la razón del diseño.

Por qué así y no dos bytes:
- Es correcto: un tema que nada nombra nunca suena.
- Es más barato: no toca el runtime ni `song_msu`.
- Por qué plan B y no regla: ABL trae 230 temas y nombra unos cien; numerar
  sólo los nombrados también en ABL renumera sus pistas (medio giga para
  volver a copiar a la tarjeta) y mueve `abl.sfc`. Con el plan B, ABL
  queda igual: `musica.json`, `audio.json` y `musicdata.inc` de `release`
  salen idénticos a los de main.
- `ChangeSystemBGM` se acepta sin hacer, pero sus temas se cuentan desde
  ya: así hacerlo no renumera a VD. En ABL no agrega nada (sus once ya
  estaban en `Music/`).

### Las tropas: `troop_init` en palabras

`troop_init` (dónde empieza cada tropa en `troop_member`) pasa a palabras
y el índice de un miembro a 16 bits. `ba_member_x` lo arma cada vez desde
`BA_TROOP_K` y la plaza: **no hay RAM nueva**, y `SCN_INIT` ($6649) queda
libre. Sigue en byte el lugar de la tropa (`BA_TROOP_K`, $FF = no la
lleva): hasta 255 tropas por cartucho. Mueve `abl.sfc`, a propósito.

### Y las acciones de los enemigos, que eran el muro siguiente

Con las dos de arriba, VD se cortaba en "the actions of the cartridge's
enemies are 344 and `enemy_acc_init` is one byte": misma familia, así que
lo pasé igual. `enemy_acc_init` es de palabras; `BA_S5 + 1` guarda ahora
qué enemigo es (antes, dónde empezaba su lista) y `ba_eacc_x` arma el
índice. Sin RAM nueva. `enemy_acc_n` sigue en byte (lo acota
`ACTIONS_MAX`).

### Verificado
- Tres pruebas nuevas, cada una vista en rojo antes de su arreglo:
  `a_music_folder_past_the_byte_numbers_only_the_named_songs`
  (rm2k-snes-audio), `troops_with_more_members_than_a_byte_numbers_start_in_words`
  y `enemies_with_more_actions_than_a_byte_numbers_start_in_words`
  (mapdata). Los dos hashes de `mapdata/tests/python.rs` se movieron a
  propósito: la diferencia es `troop_init` y `enemy_acc_init` de `.byte` a
  `.word`, nada más.
- Tanda de ABL con mis herramientas: 1159 verdes. `abl.sfc` pasa de
  `f135f6af…` a `b0c61b1f…`, a propósito (las dos tablas y el runtime que
  las lee). La música de ABL, igual: `musica.json`, `audio.json` y
  `musicdata.inc` idénticos a los de main.
- Vampires Dawn con el juego de verdad (`Music/` entero, 281), arrancando
  en 8 y sin los 82 mapas que excluyó Aguará: la música, las tropas y las
  acciones pasan. **Lo que corta ahora**: "the music's sounds go over one
  bank: 41118 B" (la tabla de sonidos de la música, de todos los temas, en
  un banco de 32 KB). No lo toqué.

### No cubierto
Ninguna prueba ejecuta en la ROM una pelea con un miembro o una acción de
índice mayor que 255 (ABL no tiene tantos): el camino nuevo de 16 bits lo
ejecutan las peleas de ABL con índices chicos. Tampoco ninguna prueba arma
un cartucho con `Music/` pasado del byte: lo cubre la prueba del crate y el
armado de VD a mano.

### De paso, el arranque de VD (no hecho)
`BOOT_FRAMES` es una constante de la ROM: subirla a 46 mueve el cuadro en
que arranca el lazo en ABL y con él las pruebas que cuentan cuadros. Lo
barato sería que cada cartucho lleve el suyo —`max(44, la estimación)`,
emitido por el conversor—, así ABL no se mueve.

Al mergear, reinstalar: `rm2k-snes-audio mapdata` (el runtime entra solo,
desde el checkout).
