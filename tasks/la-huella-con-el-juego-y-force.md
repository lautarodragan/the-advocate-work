---
name: "La huella: los archivos del juego, el .zip y --force"
description: "Los recursos del juego entran en la huella por contenido; el juego y el RTP pueden ser un .zip, descomprimido en el caché y en la huella por contenido; el RTP en directorio y el SoundFont, por su ruta; y un --force"
type: feature
status: testing
assignee: taro
agents: [Cardón]
---

Sigue de `el-volcado-fuera-de-la-huella.md`: con el ChipSet de Sunset retocado, `just cartuchos` dice "up to date" y la ROM queda vieja.

La decisión de taro, el 2026-10-11: no hashear el RTP ni el SoundFont; a lo sumo invalidar si cambia la ruta, o un `--force` para usar a mano si se modifican (no debería pasar nunca). Barajó un RTP en `.zip` validado por ruta, fecha y tamaño, sin decidirse. Hornero eligió: la ruta del RTP y del SoundFont en la huella, un `--force`, y los archivos del juego que el conversor lee, por contenido —ésos sí cambian si se retoca el juego—. taro puede ajustarlo.

## Cambio de encargo, el 2026-10-11

taro, al rato: "Si lo del zip no sería muy complicado, tal vez pensaría en usar .zip para los juegos también. Eso nos fuerza un poco a no modificarlos, sino siempre usar el sistema de parches." Así que: medir primero si la lectura de assets —juego, después RTP— pasa o puede pasar por un solo lugar; si sí, `GAME_DIR` y `RTP_DIR` como `.zip`, con la huella por el contenido del `.zip` —o ruta, tamaño y fecha, si hashearlo pesa—, el SoundFont por su ruta y `--force`; si no, el plan de arriba y la medición para que taro decida.

## El plan (Cardón, 2026-10-11)

Base: `the-advocate` `main` 6f933ff8 y ports `main` b499ab4, ramas `cardon-huella-del-juego` en `~/scratch/cardon/`.

* **Qué lee del juego.** Los lectores son tres funciones de búsqueda en tres crates —`resources::find` del conversor, `find_resource` de `rm2k-render` (Wally, las pantallas) y la de `rm2k-snes-audio`— más un par de rutas armadas a mano, y corren en procesos distintos. Que cada una anote lo que abre es tocar cinco crates y un canal entre procesos, y un lector que se olvide de anotar es el mismo camino a una ROM vieja. Lo que entra, entonces, es **lo que pueden leer**: los archivos del juego con las extensiones que aceptan —`.png`, `.bmp`, `.xyz`, `.mid`, `.wav`—, en cualquier carpeta. Afuera quedan los `.lmu`, `.ldb` y `.lmt` (llegan por el volcado), las partidas `.lsd` —que cambian cada vez que alguien juega el original con Wine—, el ejecutable, los `.ini`, los `.txt`, los `.mp3`/`.ogg` y los videos. Un PNG que el juego trae y no usa entra igual: retocarlo rearma de más, que es barato y no pasa.
* **Los nombres también**: cada archivo del juego entra con su ruta relativa al juego, porque renombrar un recurso cambia cuál se encuentra.
* **RTP y SoundFont, por su ruta**, en la huella. Las pistas de MSU-1 ya hashean el SoundFont por contenido (`midi_key`), así que con ellas no hace falta nada.
* **`--force`** en `rm2k-snes-cartridges`: arma los nombrados —o todos— sin mirar el sello. Las recetas `cartuchos` ya pasan `{{args}}`, así que `just cartuchos --force` sale sin tocarlas.
* **Quién más lee la huella**: `rm2k-snes-space` y el `--list --json` del arnés. Los dos reciben ahora los mismos flags de la máquina que el que arma: `rm2k-snes-space` acepta los de `rm2k-snes-cartridges`, y las recetas `espacio` y `cartuchos.py` se los pasan.

Medido antes del cambio, con las globales: `--list --json` tarda ~79 ms en ABL y ~22 ms en Sunset.

## Hecho, primera parte (el plan de arriba)

`the-advocate` `bd6fc5a5` (cartridge), ports `cd3c891` (las recetas `espacio`, el comentario de `cartuchos` y `cartuchos.py`), libro `887679c` (`internals/pipeline.md`, "When a cartridge is rebuilt"). La prueba de la huella, en rojo sin el arreglo (`cartridges.rs:331` y `:349`), verde con él. La tanda de ABL con `cartridge` de la rama: **1177 passed**, `abl.sfc` = `24dd24adb52f…`, la de `main`.

El costo, `--list --json` tres veces en caliente, antes → después: ABL 79 → 90 ms (559 archivos del juego, 15 MB), Sunset 22 → 27 ms (298, 7,8 MB), Vampires Dawn 63 → 99 ms (1838, 39 MB). No hace falta caché.

## El `.zip` (Hornero, a pedido de taro, 2026-10-11)

taro: "tal vez pensaría en usar .zip para los juegos también. Eso nos fuerza un poco a no modificarlos, sino siempre usar el sistema de parches". Paso 1: ¿hay un solo lugar que resuelva un asset?

**Hoy no hay uno: hay tres resolvedores y varios lectores sueltos**, en procesos distintos:

* `resources::find` del conversor (ChipSet, System, Title, GameOver, Backdrop, Monster, Picture, las animaciones), `find_resource` de `rm2k-render` (Wally, las pantallas, `rm2k-render`), y el de `rm2k-snes-audio` (Music, Sound, más un listado de nombres);
* rutas armadas a mano: `maps.rs:241` (System suelto en la raíz), `convert.rs:742`, `screens/game.rs:122`, `custom_menu.rs:954`, y el `read_dir` de `game_map_ids`;
* lo resuelto se consume como **ruta**: el `image` de cada crate, las etapas que corren en otro proceso con `--game-dir`/`--search-dir`, y programas externos —`fluidsynth` y `ffmpeg` reciben el MIDI y el WAV como archivo—;
* fuera de Rust: `ditto unpack "$GAME_DIR"` y `datos-vuelta` en las recetas de los ocho juegos, y el arnés de ABL —`resources.py` y `lcf` sobre los `.lmu`/`.ldb`—, todo a través de `lugares.JUEGO`.

Leer **adentro** del `.zip` en cada uno es tocar medio árbol. Pero **sí se puede armar un solo lugar** si el `.zip` se resuelve a un directorio antes de que nadie lea: todos los binarios que reciben `--game-dir`/`--rtp-dir` de la máquina lo leen por `Environment` (`rm2k-project`), y a las etapas se lo pasa el conversor ya resuelto. Si `Environment` cambia un `.zip` por su copia descomprimida en el caché del proyecto —una vez por `.zip`, con la clave del `.zip`—, ninguno de los diecisiete se entera. Lo que no pasa por ahí —el arnés en Python y las recetas `datos`— le pregunta la ruta a `rm2k-snes-project`, que ya es a quien el arnés le pregunta lo demás.

**Se armó, y se implementó** (Cardón, 2026-10-11):

* `rm2k-project` tiene `archive.rs` —un lector de `.zip` chico: stored y deflate con `flate2`, que ya estaba en el lock; sin ZIP64, con CRC, y negándose a escribir fuera— y `Environment::unpack(&project)`: si `game_dir` o `rtp_dir` es un `.zip`, lo descomprime una vez en `zip/` del caché del proyecto, con nombre `<zip>-<sha256 del .zip>`, escribiendo aparte y renombrando (las pruebas lo piden desde varios procesos a la vez), y desde ahí el valor es ese directorio, también en `as_flags`. **Si una herramienta no llama a `unpack` y le llega un `.zip`, `game()`/`rtp()` dan error**: una búsqueda que no encuentra nada en el juego cae al RTP sin avisar.
* Lo llaman los cuatro que leen la máquina: `Cartridges::load` (con eso `rm2k-snes-cartridges` y `rm2k-snes-space`), el conversor (`convert.rs` y `queries.rs`) y `rm2k-snes-msu`. Las etapas reciben el directorio del conversor; `rm2k-snes-volume-ceilings` sólo le pasa los flags a los otros.
* `rm2k-snes-project --game-dir X --unpacked game_dir` imprime de qué directorio leer: lo usan las recetas `datos` y `datos-vuelta` de los ocho juegos (Ditto lee un directorio) y `lugares.py` del arnés (`JUEGO_LEIDO`, `RTP_LEIDO`, que usan `resources.py` y `hoja.py`). A las herramientas el arnés les sigue pasando el valor tal cual, para que su huella sea la misma que la del que armó.
* **La huella de un `.zip` es su contenido** —medido con `sha256sum`, en caliente: VD 64 MB en 48 ms, ABL 9 MB, el RTP 11 MB en 9 ms; no hace falta ruta+tamaño+fecha—. Un juego en `.zip` entra como el `.zip` solo; un RTP en `.zip`, también por contenido, y como directorio sigue por su ruta. El SoundFont, por su ruta. `--force` sigue.
* **El directorio sigue andando**, con la huella de antes (los recursos por contenido). Lo mantengo: el original con Wine necesita el juego descomprimido, y medir con una copia retocada —como hizo Mulita con el volcado, o yo con el ChipSet de Sunset— es más fácil con un directorio. Exigir `.zip` no compraría nada que la huella no cubra ya. Lo que fuerza "no tocar el juego" es apuntar `maquina.just` a los `.zip`.
* Los nueve `.zip` están en `~/scratch/cardon/zips/` (`<port>.zip` y `rtp.zip`), con los archivos en la raíz y las carpetas como entradas propias —así vuelve también una vacía, `Movie`—, armados con `~/scratch/cardon/huella2/zipear.py`. **Sin el `.git` que tiene `~/juegos/abl-rm` adentro**: no es del juego.

### Lo medido con los `.zip`

* **Las ROMs, byte por byte.** En los seis ports que arman en `main` —Sunset, El Dorado, Book of Three, Frozen World, Dooms 2, Desert Nightmare— la misma huella de ROM con las globales y el directorio, con las herramientas de la rama y el directorio, y con las de la rama y los dos `.zip`; la segunda vez, "up to date", y `just espacio` anda con el `.zip`. **Vampires Dawn no arma en `main`** (el mapa 15 no puede llevar la ventana de mensajes, con las globales igual): con el directorio y con el `.zip` corta en el mismo lugar con el mismo `conversor.log`, 256 líneas. ABL: la tanda con los dos `.zip`, **1177 passed** y `abl.sfc` = `24dd24adb52f…`; con el directorio, también. Script: `~/scratch/cardon/huella2/zip-vs-dir.sh`; log, `zip-vs-dir2.log`.
* **`just datos` con el `.zip`** da el `data/` commiteado en los ocho, y en ABL `datos-vuelta` da 330 de 330 iguales. Cada copia descomprimida es igual a su original con `diff -r` (sin el `.git` de `abl-rm`), el RTP incluido.
* **El costo.** La huella, `--list --json` en caliente: ABL 85 ms con el `.zip` y 95 con el directorio; VD 108 ms con el `.zip` y 99 con el directorio; Sunset 27 en los dos. Con el `.zip` se lee una vez: la huella usa el hash que ya tomó `unpack` (antes de eso, VD daba 156 ms). Descomprimir VD la primera vez, 249 ms; después, 48.
* **A mano en Sunset**, con una copia del juego (`~/scratch/cardon/huella2/a-mano.sh`, log `a-mano.log`): reescribir una partida `.lsd` no rearma; retocar el ChipSet rearma —el pixel del medio cae en un tile que no se usa, y la ROM da igual, `2175c7f9…`—; el RTP por otra ruta rearma, y volver también; `--force` rearma sin tocar nada; el `.zip` de la copia retocada rearma, la segunda vez "up to date", y el `.zip` rehecho del original rearma y da la ROM de siempre. El chequeo solo, sin nada que armar: 31 ms con el directorio, 38 con el `.zip`.
* **Lo que la tanda no veía**: con los `.zip`, la primera corrida dio 7 rojas y un error. Las de música y de MSU corren `rm2k-snes-audio` suelta con `banderas("juego")`, que le pasaba el `.zip`, y `test_hover_tram.py` abría el PNG desde `os.environ["GAME_DIR"]`. Arreglado: `banderas` da los directorios descomprimidos, y sólo `cartuchos.py` pasa los valores tal cual.

## Resultado

Ramas `cardon-huella-del-juego`:

* `the-advocate` (`bd6fc5a5`, `e1946ac1`, `921bf73b`): la huella con los recursos del juego, el RTP y el SoundFont por ruta, `--force`; `rm2k-project` con `archive.rs` y `Environment::unpack`, `--unpacked`; el conversor, `rm2k-snes-msu` y los cartuchos llaman a `unpack`.
* ports (`cd3c891`, `050c3a3`, con `main` mergeado): las recetas `espacio`, `datos` y `datos-vuelta` de los ocho, y el arnés de ABL.
* libro (`887679c`, `74c0e05`, con `main` mergeado): "When a cartridge is rebuilt" y "A game or an RTP as a `.zip`" en `internals/pipeline.md`; una línea en `ports/README.md` y en la de ABL.

**Al mergear, reinstalar** `just install cartridge convert patches project rm2k-snes-audio`: `project` cambia todos los binarios que lo compilan adentro, y los demás no lo usan.

**Para pasar a los `.zip`**: mover `~/scratch/cardon/zips/` adonde corresponda y apuntar `maquina.just` (`juegos`, `RTP_DIR`) y el `GAME_DIR` de cada `justfile` a `<port>.zip` y `rtp.zip`. Wine sigue con el directorio de `~/juegos`.

**Lo que la tanda no cubre**: la tanda corre con lo que diga `maquina.just`, así que hasta que apunte a los `.zip` el camino del `.zip` lo ejercitan sólo las pruebas de `rm2k-project` y las corridas a mano de arriba. El rearmado por un cambio en el juego, en el RTP o con `--force` se midió a mano en Sunset; la tanda arma desde un juego que no cambia. La corrida de ABL con el directorio fue antes del último cambio de `cartridge` (leer el `.zip` una sola vez), que sólo toca el camino del `.zip`; la del `.zip`, después. Las copias viejas en `build/cache/zip/` no se borran solas: cada `.zip` distinto deja la suya.
