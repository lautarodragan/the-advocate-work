---
name: "Vampires Dawn arma desde su toml"
description: "Volver a barrer los mapas de VD con el main de hoy —MSU-1 obligatorio, 255 sonidos, NPCs, eventos en la RAM ya arreglados— y commitear sus exclusiones y su mapa de arranque, para que arme desde el rm2k-snes.toml como los demás"
type: feature
agents: [Aguará]
assignee: taro
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

## Lo que se hizo (Aguará, 2026-10-11)

Base: ports `ebcde04` (rama `aguara-vd-toml`, worktree propio), herramientas
globales de the-advocate `0bb1120a`, sin tocarlas.

El barrido es el de "cada mapa solo" del 2026-10-10 (`barrer.py` del
scratch de Aguará): un cartucho `release` por mapa, `maps = [8, m]`, con el
juego entero de `~/juegos/vampires-dawn.zip` (las 281 canciones, ya sin la
copia de 125) y `--without-tracks`. El 8 de arranque porque el 3, el del
juego, no entraba en BOOT_FRAMES el 2026-10-10; se vuelve a medir.

Primera prueba: el 8 arma (4 s), el 15 corta en la ventana (576 de fondo,
820 de sprites, 130 de arriba), como se sabía.

**El arranque del juego, el 3, ahora entra**: `maps = [3]` solo arma (5 s);
lo que lo frenaba el 2026-10-10 (46 de 44 cuadros de BOOT_FRAMES) era con
la copia de 125 canciones y antes del MSU-1 obligatorio.

**Cada mapa solo, al lado del 8: 433 de 440** (2.843 s de CPU en total,
6 en paralelo). Los siete que no:

| mapa | qué lo frena |
|---|---|
| 1 | el mundo: `map_cells` son 147.232 B y en la WRAM entran 32.768 (la reserva de LZ2 de `far_ram.s`) |
| 15 | la ventana: 576 de fondo, 820 de sprites, 130 de arriba, y ningún reparto deja 8 KB + 2 KB |
| 57 | VRAM: 609 de fondo, 768 de sprites, 130 de arriba |
| 99 | VRAM: 451, 640, 177 |
| 399 | VRAM: 716, 512, 136 |
| 402 | panorámica en modo 1: 120 + 244 + 137 + 435 de panorámica |
| 403 | panorámica en modo 1: 123 + 248 + 141 + 435 |

Salen del barrido de ayer, entre otros, 28, 95, 165 (Uruya), 195, 225,
236 y 351. El 1 ya no corta en la animación (eso se arregló) sino en la
grilla.

**Pero solo no es lo mismo que entero.** Con esos siete afuera y el 3 de
arranque, el cartucho corta en el **150**, la ventana: entero gasta 609 de
fondo y 436 de sprites, y solo 384 y 312. En el cartucho entero compilan
más páginas —las que teleportan a mapas que solo no están— y con ellas
entran más eventos, y más hornean como fondo (`chara_01~horneado`). Así
que lo que manda es iterar sobre el cartucho entero: se excluye el mapa
que corta y se vuelve a armar (`iterar-vd.py` del scratch).

**Las vueltas sobre el entero** (`iterar-vd.py`, ~40 s cada una):

1. con los siete + el 3 de arranque: corta en el **150** (la ventana, ver
   arriba);
2. + 150: corta en el **165** (Uruya), VRAM: 817 de fondo, 768 de
   sprites, 95 de arriba —solo, entra—;
3. + 165: corta en el **225**, VRAM: 780, 704, 116 —solo, entra—;
4. + 225: **las tropas**: "277 troops of 255, 554 members". No es de un
   mapa: `BA_TROOP_K` es un byte (`emit.rs` en mapdata, 406fc5e0, que el
   2026-10-10 pasó a palabra sólo el comienzo de los miembros). Con las
   82 exclusiones de ayer eran 234 y entraba.

   Se baja excluyendo los mapas cuyas tropas no pide nadie más
   (`tropas.py` del scratch, encuentros + `EnterBattle` directos; cuenta
   304 porque no sabe qué páginas compilan): 98, 182, 327, 338 y 339,
   cinco cada uno. Con ésos las tropas entran (el 338 resultó no hacer
   falta para eso: ver la poda).
5. + esos cinco: **la ROM**: "a piece of 65536 bytes needs a new bank, and
   the 127 banks … are taken, even with the 2645 piece(s) that may go to
   the .msu". De los `.block` de `mapdata.inc` (`bloques.py`): 7,49 MB
   fijos en la ROM, 5,12 de ellos poses (10.002 de 512 B), y 6,71 MB que
   pueden ir al `.msu`. Ayer, con 82 afuera, las poses eran 4,3.

   **Las poses se repiten por cuantización**: el conversor guarda un banco
   de doce poses por (CharSet, índice, datos), y un personaje que en otro
   mapa sale cuantizado distinto lleva un banco propio —506 avisos "goes
   with a pose bank of its own" en este armado; hasta 6.072 poses, 3,1 MB,
   antes de la deduplicación de poses idénticas—. Eso es lo que hay que
   medir como arreglo siguiente.

   Para armar hoy se buscan los mapas que más bancos propios aportan
   (avisos de cuantización + personajes que nadie más usa) y se busca el
   prefijo más corto de esa lista que entra (`busqueda.py`).

**La búsqueda** (`busqueda.py`, binaria sobre 40 candidatos ordenados por
avisos de cuantización + personajes propios): alcanzan los primeros ocho,
164, 219, 222, 170, 429, 95, 239 y 221. Después, **la poda**
(`podar.py`): cada uno de los 13 agregados por tropas o poses se probó
devolviéndolo, de a uno. Ninguno vuelve: 98, 182, 327 y 339 rompen las
tropas (256 de 255); 338 y los ocho de poses, la ROM. Así que el 338, que
entró por tropas, en realidad lo sostiene la ROM. Es un mínimo local, no
el global: otro orden de candidatos podría dar menos.

## El resultado

`vampires-dawn/rm2k-snes.toml`, ports `c914245` en `aguara-vd-toml`:
`start_map = 3` (el del juego) y **23 afuera** —417 de 440 adentro—,
cada uno con su porqué en la línea:

| qué frena | mapas |
|---|---|
| la ventana de mensajes | 15 (también solo; Tijereta), 150 (sólo en el entero) |
| ningún reparto de VRAM | 57, 99, 399 (también solos), 165, 225 (sólo en el entero) |
| panorámica en modo 1 | 402, 403 |
| la grilla en WRAM (147.232 B de 32.768) | 1 |
| las tropas en un byte (277 de 255) | 98, 182, 327, 339 |
| la ROM: lo que no va al `.msu`, sobre todo poses | 95, 164, 170, 219, 221, 222, 239, 338, 429 |

**Verificado**: `just cartuchos` en `vampires-dawn/` del worktree, desde
cero (`build/release` borrado) y con el toml commiteado: rc 0, 137 s
(130 s la primera vez, con Tijereta corriendo al lado). `vampires-dawn.sfc`
8.388.608 B (sha256 `52d80b8d7c367533…`), `vampires-dawn.msu`
22.980.864 B (`edebede5bea80193…`); 12.903 piezas en 127 bancos, 64
lentos, y 2.227 en el `.msu` (6.473.120 B). Poses: 8.320 distintas de
14.868. En snes9x (libretro, con el `.msu`): arranca en el 3 con "Skip
Intro ?", y con "Yes" pasa a la casa. Capturas en
`/shared/capturas/2026-10-11-vampires-dawn-desde-su-toml/`. ABL no se
tocó: el commit cambia sólo `vampires-dawn/rm2k-snes.toml`, así que no
se corrió su tanda. **Jugarlo no se jugó**: ni un paso más allá de la
casa, ni Mednafen, ni sin `.msu`.

## Lo siguiente en las herramientas (medido, no implementado)

1. **Una cuantización por personaje para las poses** —el que más
   destraba—. `record.rs` de mapdata guarda un banco de doce poses por
   (CharSet, índice, datos): un personaje cuantizado distinto en otro
   mapa lleva banco propio. En este armado son **420 de 1.239 bancos**
   (avisos "goes with a pose bank of its own"); las poses son 4,26 MB de
   los 8 de la ROM, y no pueden ir al `.msu` porque se suben en caliente.
   Compartir la cuantización devolvería los nueve mapas de "la ROM" y
   haría lugar para los que vuelvan cuando se arreglen los otros; cuánto
   ahorra exacto no se midió (la deduplicación de poses idénticas ya se
   come una parte), del orden del MB por cuenta gruesa.
2. **`BA_TROOP_K` en dos bytes** (`emit.rs`, el chequeo `used.len() >
   255`): devuelve 98, 182, 327 y 339 —cuatro—, y con 277 tropas sin
   ningún mapa de por medio.
3. La ventana (15, 150) la está haciendo Tijereta; VRAM (57, 99, 165,
   225, 399) y las panorámicas son los de siempre.

Al mergear no hay nada que instalar: no se tocaron las herramientas.
