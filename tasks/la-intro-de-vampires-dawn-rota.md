---
name: "La intro de Vampires Dawn, rota"
description: "El mapa 3 de VD ('Intro') arma solo, pero en vez del panorama con el título muestra rayas y bloques rojos quietos; no es BOOT_FRAMES"
type: bug
status: testing
assignee: taro
agents: [Hurón]
---

Visto por Carpintero el 2026-10-11 (`testing/boot-frames-por-cartucho.md`): con el piso en 90 se ve igual, así que no es el arranque. Si es un error del motor con los panoramas, puede estar en otros juegos también.

## La causa (Hurón, 2026-10-11)

**Es del motor, y está en cualquier juego**: un DMA de cero bytes en la SNES es uno de 65536, y `load_map`, `load_sprite` y `load_above` (`runtime/load_graphics.s`) disparaban el suyo con lo que dice el registro del mapa sin mirar si era cero.

* **Los tiles de sprites en cero borran la VRAM.** El mapa 3 de VD, solo en el cartucho (`maps = [3]`, `party = []`), no dibuja a nadie: `SPRITE_TILES = 0` y `SPRITE_CGRAM = 0` en su registro. El DMA subía 64 KB del búfer de LZ2 —WRAM sin inicializar, que snes9x llena de `$55`— sobre la VRAM entera desde `$0000`: volcada, toda la VRAM es `$5555` salvo los tilemaps, que se escriben después. Las rayas son ese patrón (columnas alternadas de color 1) y los bloques rojos, el tilemap del panorama con sus paletas. El lazo corre bien (`ticks` avanza); no es un cuelgue.
* **Los colores del fondo en cero ensucian la CGRAM.** Un fondo que es todo panorama no tiene colores (`MAP_CGRAM = 0`): la paleta pasaba 128 veces por la CGRAM entera, ventana incluida. Con el 3 junto al 4 y al 27 —así su página compila y se ve el mensaje—, el mapa ya tiene sprites y el panorama sale, pero la ventana de "Skip Intro ?" sale **blanca**. **ABL lo tiene hoy en el 94 y el 99** (todo panorama, `MAP_CGRAM = 0`); no se veía porque las otras paletas se suben después y ninguna prueba lee la CGRAM.

Con el 4 y el 27 en el cartucho, el 3 ya tiene 52 tiles de sprites —dos candidatos a líder, que salen de los otros mapas—: en el juego entero lo que se vería es la ventana blanca, no las rayas, que son de armarlo solo.

Contra RM2k (el original con Wine, `RPG_RT_2015.exe`): el panorama entero y el "Skip Intro ?" sin fondo, abajo, con Yes/No.

## El arreglo

Un `beq` después de cada `sep #$20` que sigue al cálculo del largo (Z es del `asl`): rama `huron-vd-intro` de the-advocate, `6f933ff8`. Prueba nueva en ABL, `pruebas/rpgmaker/test_dma_de_cero.py`: una copia de `release` con los sprites del 94 en cero en el registro; la VRAM desde `M_VRAM_MAP` tiene que quedar igual que sin tocar. **En rojo antes del arreglo**, con las globales: "sin sprites, 19050 palabras de la VRAM desde $1800 quedaron distintas".

## Verificado

* El mapa 3 de VD armado solo con el arreglo: el panorama, quieto, como el original. Con el 4 y el 27 en el cartucho, la ventana del "Skip Intro ?" ya no es blanca. Las capturas, con el original al lado: `/shared/capturas/2026-10-11-vd-intro/`.
* ABL, con the-advocate `6f933ff8` (`cartridge` y `project` instalados en local) y los ports en `b499ab4`: la tanda, 1177 en verde (1176 + la nueva), ninguna golden se movió. `abl.sfc` `24dd24adb52f…` (antes `ea49ff07fd9d…`).

## Lo que no cubre la tanda

* **La CGRAM**: el emulador no la deja leer, así que la guarda de los colores —la que cambia algo en ABL, en el 94 y el 99— sólo la cubre el haberla mirado en VD. Ninguna golden de ABL la veía: ninguna muestra la ventana en esos mapas.
* Los tiles y colores de la capa de arriba en cero (`load_above`): no los vi en ningún mapa; las guardas están por lo mismo, sin camino que las ejecute.
* Un mapa de verdad sin sprites: la prueba lo fabrica parchando el registro del 94.

## Lo que queda y no es de esto

* El mensaje sin fondo de la intro sale sobre una franja negra: en un mapa con el panorama en modo 3, el panorama es el BG2 que la ventana usa en sus 80 líneas. Ya era una divergencia (la ventana sin fondo y la capa de arriba); quedó dicho en ella, rama `huron-vd-intro` del libro, `88c8b9c`.

## Al mergear

* the-advocate: `huron-vd-intro` (`6f933ff8`), sólo el runtime. Reinstalar `cartridge` en el global no hace falta si se mergea en `~/the-advocate`: el runtime lo arma desde ahí.
* the-advocate-ports: `huron-vd-intro` (`b499ab4`), la prueba y su línea en el README. Sin goldens.
* the-advocate-docs: `huron-vd-intro` (`88c8b9c`).
