---
name: "Otros juegos: el re-barrido"
description: "Volver a medir los siete juegos con las herramientas de hoy —qué arma, qué corta, qué páginas no compilan— y dejarlo como un research nuevo en el libro"
type: research
status: testing
assignee: taro
agents: [Aguará]
---

De taro, el 2026-10-10: retomar los otros juegos "en el orden que proponés". El relevamiento es del 2026-10-05 y las tareas que lo siguieron, del 06; desde entonces entraron las paletas de Adeleine, los encuentros en dos bytes, los decorativos y más. Esto es la foto nueva, sin arreglar nada.

## Cómo se mide (Aguará, 2026-10-10)

Con las herramientas globales (snes-rm2k 1afe6457), en un worktree propio de los ports (rama `aguara-rebarrido`, sin commits) y sin tocar código:

* **El cartucho entero**, como está commiteado en cada port (con sus muletas), y el request de `compile` guardado por un envoltorio en el PATH para `culprits --every-map`.
* **Sin muletas**: el mismo toml sin `system`, sin `excluded` y con `party = []`, excluyendo de a uno el mapa que nombre el error.
* **Cada mapa**: esta vez al lado del mapa de arranque (`maps = [arranque, m]`), en vez de solo con `BOOT_FRAMES = 255`: así no hace falta cambiar el runtime. Corre unos 2 s por mapa.
* Vampires Dawn, para ver detrás de su primer muro: una copia del juego (symlinks) cuyo `Music/` tiene sólo las 125 canciones que nombra el volcado, y `start_map = 8`.

## Resultado

En el libro, rama `aguara-rebarrido` de snes-rm2k-docs: `src/research/2026-10-10-otros-juegos-de-nuevo.md` y una sección "As of 2026-10-10" en cada `src/ports/<juego>/README.md`. Las ROMs, como están commiteados los ports, en `/shared/builds/otros-juegos/` (todas menos Vampires Dawn, que no arma).

Lo nuevo detrás:

* Vampires Dawn: `Music/` con 281 archivos y la pista en un byte (cuenta los que no se usan, también con `--without-tracks`); después, los miembros de las tropas en una tabla de un byte (470); y su mapa de arranque no entra en `BOOT_FRAMES` (46 de 44).
* Sunset tarda ~2 h 40 min en armar: 138 imágenes grandes en el fondo, ~4 min cada una medida sola. Sospechoso no verificado: `27a28646` (Adeleine por grupo de tiles).
* Las exclusiones commiteadas en los ports son las del relevamiento y sobran: BoT necesita sólo 46, Dooms 2 1/10/14/63, Frozen 1/2, Desert las doce del barrido.

No se miró nada en un emulador. No se tocó código; nada que instalar al mergear.
