---
name: "BOOT_FRAMES por cartucho"
description: "El mapa de arranque de Vampires Dawn pide 46 cuadros de BOOT_FRAMES y la ROM tiene 44, una constante: que cada cartucho lleve el suyo sin mover a ABL"
type: feature
status: testing
assignee: taro
agents: [Carpintero]
---

Del re-barrido del 2026-10-10 (`testing/otros-juegos-el-rebarrido.md`): el mapa 3 de VD no entra en `BOOT_FRAMES` (46 de 44). Subir la constante mueve en ABL el cuadro en que arranca el lazo, y con él las pruebas que cuentan cuadros. La propuesta de Tijereta: que el conversor emita el de cada cartucho, `max(44, la estimación)`, así ABL no se mueve.

## Lo hecho

La propuesta de Tijereta, tal cual (rama `carpintero-boot-frames` de the-advocate: `3b03dffc` y el merge de `main`):

* `runtime/far_ram.s` ya no tiene `BOOT_FRAMES`: tiene `BOOT_FRAMES_FLOOR = 44`, con el porqué.
* `rm2k-snes-audio cartridge` lee ese piso —como antes leía la constante— y escribe en el `musicdata.inc` del cartucho `BOOT_FRAMES = max(piso, techo de la estimación)`, junto al encabezado (más abajo, `rm2k-snes-assemble` reparte el archivo en bancos y los comentarios se pierden). Ya no se niega a armar; el único tope es el byte de `boot_frames`: más de 255 no arma.
* El piso queda en el runtime y no como perilla del `rm2k-snes.toml`: lo que protege es del runtime, y ningún juego pide otro.
* El libro (rama `carpintero-boot-frames` de the-advocate-docs): la decisión `el-arranque-esta-dimensionado-para-el-paquete-de-arranque.md` y `internals/audio.md`.

No hizo falta opcode.

## Verificado

* Antes, con las globales: el mapa 3 de VD solo (`maps = [3]`, sobre la copia del juego de Aguará con `Music/` recortado) no arma: "the boot doesn't fit in BOOT_FRAMES ... 46 frames, against 44".
* Después: arma, `BOOT_FRAMES = 46`, y en snes9x sale de la espera en el cuadro 46 (`nmi_seen`): no se pasó.
* ABL: `abl.sfc` `5852b72358b6…`, igual que main; ABL estima 40,5 y queda en 44. La tanda, con mis herramientas sobre the-advocate `main` 0b1ed124 mergeado y los ports en 493f39e: 1174 en verde.
* `just crate-test rm2k-snes-audio` y `just test` en verde sobre el merge.

## Lo que no cubre la tanda

* Ningún cartucho de ABL pasa el piso: el camino "gana la estimación" lo ejecutan sólo la prueba unitaria de `cartridge::boot_frames` y el VD armado a mano de arriba.
* **El mapa 3 de VD ("Intro") se ve roto**: en vez del panorama (el título de Vampires Dawn, `mode3`) la pantalla muestra rayas y bloques rojos, quietos. No es por el arranque: con el piso en 90 se ve igual. Queda para otra tarea.

## Al mergear

Reinstalar `rm2k-snes-audio` (`just install rm2k-snes-audio` en `~/the-advocate`), **junto con el merge**: el binario lee `runtime/far_ram.s` del checkout del que se instaló, y uno viejo con el runtime nuevo no encuentra `BOOT_FRAMES`, y uno nuevo con el runtime viejo define dos veces el símbolo. Lo demás que arma (`cartridge`, `convert`, `project`) no cambia de código.
