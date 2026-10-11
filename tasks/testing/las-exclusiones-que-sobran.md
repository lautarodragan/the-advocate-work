---
name: "Las exclusiones que sobran en los ports"
description: "Los rm2k-snes.toml de los ports excluyen mapas del relevamiento que ya entran: dejar sólo los que hacen falta, medidos con las herramientas de hoy"
type: chore
assignee: taro
agents: [Calandria]
---

Del re-barrido del 2026-10-10 (`testing/otros-juegos-el-rebarrido.md`): las exclusiones commiteadas son las del relevamiento y sobran. Entonces Book of Three necesitaba sólo la 46, Dooms 2 la 1, la 10, la 14 y la 63, Frozen la 1 y la 2, y Desert las doce del barrido. Desde entonces entraron los gemelos y el recorte de eventos, la música y las tropas en palabras, y el grupo vacío, así que hay que medir de nuevo.

## Cómo se mide (Calandria, 2026-10-11)

Herramientas globales de the-advocate `5094ef11`; ports en `038ea64`, worktree propio (rama `calandria-exclusiones`). Para cada juego, el toml sin muletas —`excluded = []`, sin `system`, Dooms 2 con `start_map = 1`, Frozen con `below = 156`— y `just cartuchos release`; si el error nombra un mapa, se lo excluye y se vuelve a armar. Si el que corta es el System propio (no nombra mapa), se devuelve `system` y se repite.

## Por juego

### El Dorado

Arma tal como está commiteado: no excluye nada ni tiene muletas.

### The Book of Three

| qué | por qué |
|---|---|
| (ningún mapa) | el 46 volvió el 2026-10-10 con la animación recortada (Cardón); los 44, 69 y 74 arman |
| `system = "ablskin.png"` | con el suyo: "the window needs 267 tiles —27 of its frame and its arrow— and the bank has 256" |

### Sunset Over Imdahl

Arma tal como está commiteado —sin exclusiones ni muletas desde el grupo vacío (Mulita)—; no se tocó su toml.

### Dooms 2

Los errores de abajo no nombran el mapa: los cuatro son los del re-barrido, y se comprobó sacando cada uno de la lista (con los otros tres adentro, no arma).

| qué | por qué |
|---|---|
| 1 | elegir personaje; con él, "the slot screen and the menu gather 524 tiles and their bank fits 448" (482 con su System) |
| 10 | "the song uses 291 sounds and the index is one byte" |
| 14 | "the song uses 411 sounds and the index is one byte" |
| 63 | "the song uses 291 sounds and the index is one byte" |
| `start_map = 2` | porque el 1 queda afuera |
| `system = "ablskin.png"` | con el suyo, aun sin el 1: "the actor choice's windows are 66 8bpp tiles and reach $4840, and their tilemap is at $4800" |

Para las herramientas: el error del índice de sonidos no dice qué canción ni qué mapa; hubo que sacar el mapa de a uno.

### The Frozen World

| qué | por qué |
|---|---|
| 1 | "a page makes the hero flash, and actor 11 is drawn with rangedmelee[0], which an NPC of the map also uses. On the console they share a palette and both would flash" (también con el System de ABL y el 2 afuera) |
| 2 | "a stream of map_code is 38179 bytes and 19968 fit in WRAM: see the LZ2 reservation in runtime/far_ram.s" |
| `system = "ablskin.png"` | con el suyo: "the window needs 266 tiles —26 of its frame and its arrow— and the bank has 256" |

`below` pasa de 135 a 156, todos los mapas: el tope de 255 en el directorio de muestras ya no corta (degrada desde `las-muestras-que-sobran`). Los 69 y 84 arman.

### Desert Nightmare

| qué | por qué |
|---|---|
| (ningún mapa) | arma con los 189: lo que cortaba doce el 2026-10-10 ahora degrada con un WARNING —en nueve mapas los eventos que pasan de 120 quedan afuera, y lo que pierden es sólo su dibujo o una pared invisible (el recorte de Carpintero); los panoramas salen `mode1` o aplanados; los NPCs que pasan de 104 no se dibujan, y siguen andando—. No se miró ninguno en un emulador |
| `system = "ablskin.png"` | con el suyo: "the End Game screen uses 18 pairs of colours and a 4bpp palette has 16" |

`decorative_events = true` no es una muleta: es la perilla prendida a propósito (`ddb35a5`), y se queda.

### Vampires Dawn

No arma, y no se tocó su toml. Con el commiteado (System de ABL, sin exclusiones) corta primero en mapas: el 15, "this map can't carry a message window: it spends 576 background tiles, 436 sprite tiles and 130 upper tiles, and there is no layout that leaves 8 KB of tiles plus 2 KB of tilemap for the window"; sin el 15, el 57, "fits no VRAM layout: 609 background tiles, 768 sprite tiles (its animation box's 64 included) and 130 upper tiles". El barrido se cortó ahí, a propósito: a ~2 min por vuelta y con unos ochenta mapas que el re-barrido vio cortar, no rinde mientras sigan abiertos los muros de toda la partida (los 281 de `Music/`, los miembros de las tropas, el arranque del 3), en los que trabajan Tijereta y Carpintero. Con el System propio también corta primero el 15, así que no se pudo medir si su System hace falta: se deja.

## Resultado

Ports, rama `calandria-exclusiones` (`286201b`); libro, rama `calandria-exclusiones` (`245f1fc`, una sección "What it leaves out" en BoT, Dooms 2, Frozen y Desert). Verificado: `just cartuchos release` con los toml finales arma en BoT, Dooms 2, Frozen, Desert, El Dorado y Sunset (este último sin tocar). No se miró ninguno en un emulador. Nada que instalar al mergear: no se tocaron herramientas.

Para las herramientas: "the song uses N sounds and the index is one byte" no dice ni la canción ni el mapa, y "this map can't carry a message window" no dice el mapa en su línea (hay que leer el encabezado anterior del log).
