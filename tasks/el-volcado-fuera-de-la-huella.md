---
name: "El volcado, fuera de la huella de los cartuchos"
description: "just cartuchos dijo 'up to date' con data/maps/Map0022.json de Sunset tocado a mano: el volcado no entra en la huella, a propósito; falta confirmar que un cambio en el juego original sí rearma"
type: chore
status: testing
assignee: taro
agents: [Hornero, Cardón]
---

Visto por Mulita el 2026-10-11 (`testing/sunset-el-mapa-22-en-negro.md`): para que el cartucho se enterara de un `Map0022.json` editado tuvo que borrar su directorio.

Es intencional: `fingerprint_files`, en `rm2k-snes/cartridge/src/cartridges.rs` de `the-advocate`, dice "The game's dump does not: it is regenerated from the game". Lo que no está mirado es la otra mitad: si un cambio en `GAME_DIR` —un `.lmu` nuevo del juego— regenera el volcado y rearma, o si también queda viejo sin avisar. Si es lo segundo, es un camino a una ROM vieja que ninguna prueba ve. Y si editar el volcado a mano es una forma legítima de medir —Mulita la usó para aislar una causa—, conviene que la receta lo diga o que lo vea.

## Lo medido (Cardón, 2026-10-11)

Nadie regenera el volcado solo: `data/` se commitea y lo reescribe la receta `datos` de cada juego, a mano. Así que la respuesta es "queda viejo", en dos tiempos. Medido en Sunset, en un worktree de los ports, con una copia del juego en `~/scratch/cardon/huella/juego` como `GAME_DIR` y `release` armado con las globales de 70d4348a (scripts `medir.sh` y `activos.sh` de esa carpeta; los logs, `antes.log` y `despues.log`):

| paso | `just cartuchos release` | ROM |
|---|---|---|
| armado desde cero | built | `54ceac6f9556b0a8` |
| Map0039.lmu con un tile cambiado (5092 -> 5001) | up to date | `54ceac6f…` |
| `just datos` con ese juego: `data/maps/Map0039.tiles` cambia | **up to date** | `54ceac6f…` (viejo) |
| desde cero, con ese `data/` | built | `c6f43b98638ad200` |
| el ChipSet del juego retocado entero, `data/` igual | **up to date** | `c6f43b98…` (viejo) |
| desde cero, con ese ChipSet | built | `41b52b748ba44dcd` |

* El `.lmu` solo no cambia la ROM, y está bien: el port lee el volcado, no el `.lmu` (`data/README.md` de cada juego). El cambio llega con `just datos`, y ahí se quedaba viejo sin avisar.
* **Editar el volcado a mano es el mismo camino**: un `data/` distinto del que armó la ROM. Lo que hizo Mulita es legítimo —el volcado es texto a propósito—, así que la receta tiene que **verlo**, no decirlo.
* Lo que el conversor lee del juego original mismo —PNG, MIDI— tampoco está en la huella, y queda viejo igual (la última fila). El RTP y el SoundFont, lo mismo, sin medir.

## Lo hecho

`the-advocate`, rama `cardon-errores-y-huella`, commit "Cartuchos: el volcado entra en la huella": `fingerprint_files` suma todo `data/`, y su comentario dice ahora qué queda afuera y por qué. La prueba `everything_that_builds_the_rom_is_in_the_fingerprint` pide `data/maps.json` y `data/ditto.json`; en rojo sin el arreglo (`cartridges.rs:307`), verde con él.

Con el arreglo, la misma corrida: después de `just datos` el cartucho se rearma solo y da `c6f43b98…`, igual que desde cero; devolver `data/` con `git checkout` lo rearma a `54ceac6f…`, la de antes. La ROM de Sunset con las herramientas de la rama es `54ceac6f…`, igual que con las globales.

**No se arregló lo del juego original**: meterlo en la huella pide `--game-dir` en los que sólo la leen —`rm2k-snes-space` (`just espacio` no se lo pasa) y el `--list --json` del arnés de ABL—, que si no verían viejo todo cartucho. El juego original no se edita, y cuando cambia de verdad lo que cambia es el `.lmu`, que llega por el volcado. Queda dicho en el comentario de `fingerprint_files`; si taro lo quiere, es una tarea aparte, que toca los dos repos.

## Resultado

Rama `cardon-errores-y-huella` de `the-advocate` (con las dos tareas, y `tijereta-sonidos-de-una-cancion` mergeada); en los ports no hay commits. Con las herramientas de la rama adelante en el PATH (`convert`, `mapdata`, `rm2k-snes-audio`, `cartridge`), en un worktree de los ports con `main` 4072372: la tanda de ABL da 1176 passed, y `abl.sfc` = `ea49ff07fd9d…`, la misma de `main` con lo de Tijereta. `just test` y las pruebas de los cuatro crates, en verde.

Al mergear, reinstalar: `just install convert mapdata rm2k-snes-audio cartridge`.

Lo que la tanda no cubre: ningún mensaje de error —ninguna prueba de ABL corta un cartucho—; se vieron a mano en Dooms 2 y Vampires Dawn. Y la huella: la tanda arma desde un `data/` que no cambia; el rearmado se midió a mano en Sunset.
