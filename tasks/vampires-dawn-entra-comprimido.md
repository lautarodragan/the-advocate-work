---
name: "Vampires Dawn entra en el cartucho, comprimido"
description: "VD pide ~11,7 MB de bloques contra 7,94 MB de los 127 bancos (pose_N 4,27, map_tiles_N 2,21): comprimir hasta que entre; si no alcanza, MSU-1 obligatorio para VD"
type: feature
status: testing
assignee: taro
agents: [Tijereta]
---

Medido por Tijereta el 2026-10-11 (`testing/los-sonidos-de-la-musica-en-mas-de-un-banco.md`), con las 82 exclusiones de Aguará y arrancando en 8: `the data does not fit: … the 127 banks the cartridge has for data are taken`.

La decisión de taro, el 2026-10-11: probar con compresión. Dos cartuchos no —habría que migrar saves, y nada garantiza partirlo con elegancia—. Si sin compresión no alcanza, antes que dos cartuchos, el MSU-1 obligatorio para este juego; un chip de compresión sólo si las cuentas dan, y mejor no si el MSU-1 sigue siendo opcional en general, por la complejidad.

## La medición, 2026-10-11 (Tijereta)

Sobre el armado de VD con las 82 exclusiones y arrancando en 8, herramientas
de the-advocate 6f933ff8 —el `mapdata.inc` que se corta—. Los scripts, en
`~/scratch/tijereta/comprimido/`.

**Qué ya va comprimido.** El conversor lo dice al final de su log: el fondo
(`map_tiles`, 2268 KB de LZ2, 3196 crudos), la capa de arriba, el banco
inicial de sprites, la animación del ChipSet, la grilla y lo que vive detrás
de ella, y el bytecode: 3618 KB de LZ2 que eran 7547. Los battlers, los
fondos de pelea y los `big_map` van comprimidos de otra forma: el LZ2 no les
saca nada (100%). **Las poses no**: `pose_N` son 8748 bloques de 512 bytes
crudos, 4374 KB, y se suben por DMA directo de la ROM a la VRAM.

**Lo que rinde el LZ2 sobre lo que no va comprimido**, bloque por bloque
—cada uno tiene que poder descomprimirse solo—:

    clase          bloques     crudo      LZ2
    pose_N           8748    4374 KB   1518 KB  (35%)   -2856 KB
    pano_tiles_N       32     517 KB    418 KB  (81%)    -99 KB
    big_tiles_N        43     428 KB    355 KB  (83%)    -73 KB
    pano_map_N         32     173 KB     90 KB  (52%)    -83 KB
    font/slot/scr_pre  24     351 KB     59 KB           -292 KB, pero se leen
                                                        letra por letra: habría
                                                        que tenerlos en RAM
    npc_table_N       341     100 KB     73 KB           -27 KB, la lee la CPU
    sprite/map_cgram, ev_pos, battler, backdrop: nada

**Lo que se repite entre mapas.**

* Poses: ya se comparten entre mapas cuando son iguales byte por byte
  —`poses` en `record.rs`—: 14880 pedidas, 8748 distintas. Lo que queda son
  462 bancos de un mismo (CharSet, índice) **cuantizados distinto** en otro
  mapa. Si dos poses que difieren sólo en qué índice de paleta lleva cada
  color contaran como una, quedarían 7536: 606 KB crudos, ~210 KB después del
  LZ2. El resto de la diferencia son colores perdidos distinto en cada mapa:
  cuantizar cada personaje igual en todos sus mapas cambia lo que se ve y
  toca a Adeleine y a `wally`; no lo encaro.
* Tiles del fondo (8 bpp): distintos dentro de cada mapa 3196 KB, en todo el
  cartucho 2949 KB. Compartirlos entre mapas daría 8% crudo: cada mapa
  cuantiza su paleta y los índices no coinciden.
* Capa de arriba: 359 → 247 KB compartiendo tiles; banco de sprites: ya es
  353 KB de LZ2.
* Las poses partidas en sus 16 tiles: 56% son tiles en cero (las columnas 0 y
  3 casi siempre), 43500 tiles distintos no cero. Guardarlas sin los ceros
  con una máscara: 1932 KB; con los tiles compartidos en todo el cartucho:
  1633 KB. El LZ2 por pose gana: 1518 KB.

**Otros códecs, como cota.** El fondo en 8 bpp rinde mejor en "chunky" —un
byte por pixel, re-planarizado al cargar—: LZ2 1864 KB contra 2266, **-402
KB**; xz por bloque, 1863 planar y 1083 chunky, pero xz no corre en un 65816.
En 4 bpp el chunky empeora (poses 2137 KB, panoramas 511).

**Lo que cuesta, en tiempo y RAM.**

* Poses en LZ2: hoy una pose es un DMA de la ROM a la VRAM en el vblank, sin
  CPU. Comprimida hay que descomprimirla a la WRAM antes —al encolarla, en el
  lazo principal— y el DMA del vblank sale de ahí. Con el modelo del
  conversor (700 ciclos maestros por comando y 60 por byte, "del lado alto")
  una pose cuesta 13% de un cuadro en la mediana (21 comandos), 15% en el p90,
  22% en la peor (69). Una copia de 512 bytes a la WRAM con `mvn` ya son ~9%:
  cualquier esquema que no sea DMA directo de la ROM paga casi lo mismo.
  RAM: un anillo de VQ_MAX = 8 poses, 4 KB, que tiene que sobrevivir de
  encolar al vblank.
* Poses sin los ceros, por DMA directo: sin CPU ni RAM, pero hasta 12 DMAs
  por pose en vez de 4, y el vblank es el recurso apretado (VQ_PER_FRAME);
  rinde 414 KB menos que el LZ2.
* Fondo chunky: sólo al cargar el mapa, con la pantalla apagada; re-planarizar
  8 bpp con tablas son ~2000 ciclos por tile: un mapa de 1000 tiles, ~medio
  segundo más de carga.
* Panoramas e imágenes en LZ2: al cargar, a `LZ2_BUFFER`.

**Las cuentas.** Faltan 11,69 − 7,94 = 3,75 MB, más lo que se pierde al
repartir en bancos. Las poses dan 2,79; el fondo chunky 0,39; panoramas,
imágenes y sus mapas 0,25. Todo junto, 3,43 MB: **no alcanza por ~0,3 MB**
aun sin contar el desperdicio, y lo que no es poses cuesta mucho más por KB.

## Lo probado: las poses en LZ2, y por qué no se mergea

Lo que más rendía, implementado en las ramas `tijereta-vd-comprimido` de
the-advocate (commit de Tijereta) y de los ports. **No es para mergear**:
queda como registro de lo medido.

* `poses` en `record.rs` (rm2k-snes-mapdata) escribe cada pose distinta como
  su propio stream de LZ2 y emite `POSE_RING`, `POSE_RING_SLOTS` y
  `POSE_BYTES`. Las huellas de `mapdata/tests/python.rs` no se mueven: el
  texto pasa por `with_the_poses_raw`, que descomprime y da el viejo byte por
  byte.
* `vram_queue` (runtime/load_graphics.s) la descomprime al encolarla a su
  lugar de un anillo de 8 × 512 bytes en `$7FF000-$7FFFFF` —la punta de la
  mitad alta del `$7F`; `check_map` le saca esos 4 KB a lo que vive detrás de
  la grilla: lo que más usa VD de esa mitad son 17.770 bytes (mapa 292) y
  ABL 12.080 (mapa 43)—, y la entrada de la cola apunta ahí. Un byte de BSS,
  `vq_ring`.

**VD con eso**: los `.block` bajan de 11,69 a **8,91 MB** contra 7,94 (poses
de 4374 a 1518 KB). **Sigue sin entrar: faltan ~0,97 MB**, más lo que se
pierda al repartir. Lo demás medido —fondo chunky 0,39, panoramas e imágenes
0,25, poses a menos de permutación ~0,2— suma ~0,84 MB en el mejor caso: no
alcanza. Y las 82 exclusiones son mapas que hoy no convierten: van a pedir
más.

**ABL no lo puede pagar.** Con todo lo demás en verde, la tanda queda en 8
rojas (1169 de 1177), todas por tiempo de CPU:

* `test_la_carrera_entera`: la vuelta del 49 gasta 1217 cuadros de hardware
  en 976 ticks, 241 de más contra un tope de 48. Contado por tick —con un
  contador temporal, ya sacado—: de los cuadros con 0 poses para
  descomprimir pierden 23 de 510, con 1 pose 38 de 269, con 2 **100 de 117**,
  con 3 o más **todos** (80). El lazo de la carrera tiene ~10-15% de cuadro
  libre, y cada pose cuesta ~13%. Un tope de dos poses por cuadro no mejora
  nada (286 de más).
* las seis `test_batalla[batalla-*]`: la captura sale atrasada —el menú de
  comandos donde la golden ya muestra el de ítems—, por cuadros perdidos
  antes de la pelea;
* `test_la_celebracion_con_la_cache_de_ranuras`: eventos sin ranura en el
  cuadro 65, la caché va un cuadro atrás.

`abl.sfc` con eso: `d1e666eeefe2…`. Lo que se arregló en el camino y vale
para cualquier intento que repita esto: el índice del anillo hay que
enmascararlo al leerlo (la RAM arranca con basura y una pose cayó sobre la
grilla: `test_la_grilla_vuelve_entera_de_una_pelea` lo cazó); Goombario
pide el ancho de A al llamar a `ring_place`; y dos pruebas de los ports
—`cache_de_ranuras.py`, `test_paradise.py`— leen la pose de la ROM y tienen
que descomprimirla; `test_reservas_de_la_wram.py` tiene que permitir
`POSE_RING`.

**Lo que no sirve o no se probó, y por qué:**

* Descomprimir con DMA a `$2180` en el lazo (≈2% de cuadro por pose): una
  DMA general fuera del vblank choca con el HDMA de la ventana y en la
  primera revisión de la CPU cuelga la consola —ver
  `battle_animation_frames.s`—.
* Copiar con `mvn` un formato sin los tiles en cero: ~7% por pose, la mitad
  del LZ2; con los números de la carrera sigue perdiendo cuadros.
* Descomprimir en la espera del vblank, con lo que sobre: no pierde cuadros,
  pero la pose puede llegar un cuadro tarde, y la OAM ya cuenta con ella —en
  un mapa con turnos o caché se vería otro personaje un cuadro—.
* Subir sin los tiles en cero por DMA directo de la ROM en el vblank (sin CPU
  ni RAM): 1932 KB en VD (−2,44 MB), pero hasta 12 DMAs por pose en vez de
  4, y el vblank es lo apretado (`VQ_PER_FRAME`); habría que medir si entra
  sin bajar el tope de poses por cuadro.

**Conclusión**: con lo razonable VD no entra, y lo único que rinde en serio
—las poses— le cuesta cuadros a ABL. Lo que sigue es el MSU-1 obligatorio
para VD, que abre Hornero. Si se hace, las poses comprimidas no hacen falta;
si se quiere achicar lo que va por el MSU-1, la opción que no le cuesta CPU a
ABL es la última de la lista.

## Al mergear

Nada que instalar: sólo esta tarea va a `main`. Las ramas
`tijereta-vd-comprimido` de the-advocate (7d5bb4ea) y de los ports (213e1ef)
son el registro del experimento y **no se mergean**.
