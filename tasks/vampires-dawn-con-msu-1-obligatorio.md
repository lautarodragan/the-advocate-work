---
name: "Vampires Dawn con MSU-1 obligatorio"
description: "VD no entra en los 127 bancos ni con lo razonable comprimido (faltan ~1 MB con las poses en LZ2, más sin ellas): que un proyecto pueda pedir el MSU-1 obligatorio y lleve al .msu lo que no entra"
type: feature
status: testing
assignee: taro
agents: [Hornero, Tijereta]
---

Sigue de `testing/vampires-dawn-entra-comprimido.md`, donde Tijereta midió todo: las poses en LZ2 son lo único que rinde en serio (−2,86 MB) y le cuestan a ABL cuadros —ocho rojas por CPU—; con ellas VD queda en 8,91 MB contra 7,94, y lo demás suma a lo sumo ~0,84 MB. El experimento está en las ramas locales `tijereta-vd-comprimido` de the-advocate y de los ports, sin mergear.

La decisión de taro, el 2026-10-11: antes que dos cartuchos, el MSU-1 obligatorio **para este juego**; ABL y los demás siguen jugables sin él ([[sin-msu-jugable]] en la memoria). Un chip de compresión no, mientras el MSU-1 siga siendo opcional en general.

Ya hay un camino: los fondos de batalla viajan en el `.msu` y la ROM los lee si encuentra su firma (`internals/msu-datos.md` del libro). Lo que haría falta: una perilla del proyecto que lo pida obligatorio, el reparto de qué va a la ROM y qué al `.msu` —las poses, que se suben en caliente, piden mirar cuánto tarda el MSU-1 en entregarlas—, y una pantalla que diga que falta el MSU-1 si no está. Tijereta anotó una opción sin CPU que no probó: las poses sin sus tiles en cero, por DMA directo en el vblank (−2,44 MB en VD), que achicaría lo que tenga que ir al `.msu`.

## Lo que pidió taro al confirmarlo, el 2026-10-11

"Vamos con el msu, pero dejemos el código del runtime y las herramientas lo más genérico posible, siempre apuntando a que todos los juegos tengan msu opcional." O sea: nada que sea "el modo de VD"; el mecanismo —qué datos pueden viajar en el `.msu` y cómo los lee la ROM— es el mismo para todos, y lo obligatorio es sólo que a un juego no le alcance la ROM sin él. La meta de fondo sigue siendo que cada juego entre sin MSU-1.

## Hecho, el 2026-10-11 (Tijereta)

Sobre the-advocate `origin/main` 2fc37808 y ports `main` f8407dc, ramas
`tijereta-vd-msu` en los dos. VD se arma como siempre en esta tarea: con las
82 exclusiones de Aguará y arrancando en 8 (`~/scratch/tijereta/vdmsu/vd.py`).

**El mecanismo, genérico.** Un proyecto pide `[rom] msu = "required"`; sin
la clave es `"optional"`, lo de siempre. El conversor **no** lo decide solo:
necesitar el MSU-1 cambia lo que el jugador necesita, y un mapa más no tiene
que cambiar eso sin que nadie lo decida. Con la perilla:

* el emisor marca con `.msu` las piezas que la ROM sólo lee por un camino
  que sabe leer el `.msu`, y que se leen al cargar un mapa o una pelea, no
  por cuadro: los flujos LZ2 de cada mapa, los de los battlers y respaldos de
  pelea y los mapas de las imágenes grandes (`lz2_decompress` → `lz2_msu`),
  los tiles de panoramas e imágenes grandes (`msu_dma0`), y las muestras
  (`upload_sample` → `msu_sample_l`). Las poses no: se suben en caliente;
* el empaquetado (`pack_with_msu`) manda al `.msu` las menos posibles, de la
  más grande a la más chica, hasta que el resto entra; en una región al final
  del `.msu`, con su firma, y cada etiqueta queda como banco `$3D` y unidad de
  256 bytes;
* la ROM, al arrancar, mira MSU-1, firma del `.msu` y firma de la región, y
  si algo falla muestra una pantalla (dibujada por el conversor con la
  fuente del juego) y se queda ahí.

Todo el runtime nuevo está bajo `.ifdef MSU_REQUIRED`: `abl.sfc` sale
`24dd24adb52f…`, igual que en la base.

**VD arma**: 13241 piezas en los 127 bancos y **1533 piezas, 5,26 MB, en el
`.msu`** (19 MB el `.msu` entero, con los fondos y los efectos). Lo que se
fue: 313 `map_tiles`, 293 muestras, 280 `map_cells`, 236 `sprite_tiles`, 127
`above_tiles`, 102 battlers, 49 `anim_tiles`, 43 `big_tiles`, 36 respaldos,
31 `pano_tiles`, 16 `big_map`, 7 `map_code`: casi todo lo que puede ir, porque
lo que se queda —4,27 MB de poses, 0,91 de la música en `.crossbank`, 0,39 de
páginas…— son 7,10 MB para 7,94. Arranca en snes9x y en Mednafen
(`snes_faust`) con su `.msu`, en el 8, y sin él muestra la pantalla.

Para que entrara hizo falta otra cosa: la cadena de `.crossbank` iba última,
y para entonces las piezas enteras habían tomado todos los bancos enteros; si
no entra, el empaquetado ahora prueba con la cadena primero. ABL entra de la
primera manera y no cambia.

**Cuánto tarda**, en snes9x, que no demora los seeks: cargar del `.msu` le
cuesta a cada mapa de 1 a 8 cuadros más que de la ROM (el 66, con el fondo
más grande, 94 contra 86), porque los literales del LZ2 van de a un byte por
la CPU. **En Mednafen cada seek son uno o dos cuadros** (medido el
2026-09-26, ver `internals/msu-datos.md`), y un mapa de VD hace de 0 a 5 por
sus flujos —la mayoría 3 o 4— más uno por panorama y uno por cada muestra
del `.msu` que su paquete sube: eso no lo medí cuadro a cuadro.

**Lo que corta a VD después**: nada al armar; jugarlo es otra tarea. Las 82
exclusiones siguen —son mapas que no convierten por otras razones— y cuando
entren van a pedir más ROM: lo que queda para mandar es poco, porque lo que
se queda son las poses. Ahí sirve lo que ya está anotado arriba: las poses
sin los tiles en cero, por DMA directo.

**Las pruebas.** ABL entra, así que el camino lo corren dos cartuchos nuevos
de su tanda: `test-msu`, con `--msu-everything` —todo lo que puede ir, al
`.msu`, aunque entre— y `test-msu-rom`, su gemelo con todo en la ROM. Lo que
se carga con cada mapa, contra el conversor (`test_carga_descomprimida.py`);
el arranque cuadro por cuadro con el panorama del 6, una pelea con sus
battlers y la envolvente de la música del 66, contra el gemelo
(`test_msu_gemelos.py`); y la pantalla, sin `.msu` y con la región de otro
armado (`test_msu_obligatorio.py`, golden nueva `msu-falta`). La tanda: **1202
en verde**, con `abl.sfc` = `24dd24adb52f…`. Capturas en
`/shared/capturas/2026-10-11-msu-obligatorio/`.

**Lo que la tanda no corre**: una imagen grande leída del `.msu` —ningún mapa
de `test-msu` la muestra—, el respaldo liviano de un fondo de pelea leído de
ahí —con MSU-1 la pelea usa el de calidad—, la espera de los seeks —ningún
core de la tanda la demora; Mednafen sí, y no la medí—, la consola de verdad,
y VD jugado más allá de su primer mapa.

RAM nueva: ninguna. Opcode: ninguno.

## Al mergear

Ramas `tijereta-vd-msu` en the-advocate (e9a9488f), en los ports (3a6ca29,
con la golden en su propio commit, 6dc0ca2) y en el libro (1d5a4f8).
Reinstalar `just install cartridge rm2k-snes-audio mapdata convert` —no tocó
`project`—, y correr la tanda de ABL, que ahora arma también `test-msu` y
`test-msu-rom`.
