---
name: "El S-DD1 para las poses: medir antes de decidir"
description: "Comprimir las poses con LZ2 le cuesta cuadros a ABL; el S-DD1 descomprime en el camino del DMA, sin CPU. Medir cuánto rinde, si convive con el mapa del cartucho y qué soporta el hardware, sin tocar el cartucho"
type: research
status: testing
assignee: taro
agents: [Carpintero]
---

taro, el 2026-10-11, después de ver lo que costaban las poses en LZ2 (`vampires-dawn-entra-comprimido.md`): "¿el S-DD1 nos permitiría comprimirlas sin introducir lag?". Y: "en el fx pak el star ocean corre, así que ese chip tiene que soportarlo. lo que nunca probé es msu + otro chip".

Antes, el mismo día, había dicho que evitaría otro chip mientras el MSU-1 sea opcional, por la complejidad: esto es para decidir con números.

## La medición, 2026-10-11 (Carpintero)

Todo en `~/scratch/carpintero/sdd1/`. No hay compresor S-DD1 libre a mano
(ni en `~/ref` ni en GitHub): escribí uno descartable, `src/sdd1c.cpp`, el
inverso exacto del descompresor de Andreas Naive. Cada bloque comprimido se
descomprime con **el descompresor de bsnes sin tocar**, incluido desde
`~/ref/bsnes-libretro` (`src/ref.cpp`), con basura después del bloque, y
vuelve byte por byte igual: 0 diferencias en las ~60.000 piezas de ABL y VD.
`medir.py` arma la tabla; `carga.py`, lo que cuesta el fondo al cargar.

Lo de ABL sale de `build/release` de los ports (b499ab4, herramientas
6f933ff8, `abl.sfc` 24dd24adb52f3187); lo de VD, de `vd-bloques/` de Tijereta
(herramientas 6f933ff8).

**Lo que rinde** (crudo → LZ2 → S-DD1; las poses, en cuatro streams de 128
porque cada fila del bloque 4x4 es un DMA aparte y cada DMA arranca un
stream):

    ABL poses       752 KB →  317 (42%) →  245 (33%)
    ABL fondo      1165 KB →  710 (61%) →  691 (59%)
    VD  poses      4374 KB → 1604 (37%) → 1232 (28%)
    VD  fondo      3196 KB → 2268 (71%) → 2172 (68%)

El banco de sprites y la animación del ChipSet rinden mejor en LZ2. Sumando
donde gana: ABL ~641 KB (usa 86 de 127 bancos: no le hace falta), VD ~3,46 MB
contra 3,75 que le faltan, antes del desperdicio y de los 82 mapas
excluidos: **VD no entra tampoco**. Sin lag: el DMA mueve los mismos 512
bytes por pose en el vblank, más un `sta $4801` por DMA. Al cargar un mapa,
el fondo pasa de 3,1 cuadros de LZ2 (mediana) a 0,2 de DMA.

**El mapa**: el S-DD1 saca los bancos `$40`–`$7D`; los 4 MB de arriba se ven
sólo por cuatro ventanas de 1 MB en `$C0`–`$FF`, con registros. El FX Pak y
Mednafen llegan a 8 MB (bsnes, Mesen2 y snes9x a 16): no agranda nada. Es
un mapper nuevo, con cambios de ventana en el runtime y páginas por mapa en
el empaquetador; eso es lo caro.

**El hardware**: el core S-DD1 del firmware del FX Pak instancia el MSU-1, y
el firmware lo prende para cualquier ROM con `.msu`; el changelog de v1.10.2
arregla el volumen del MSU-1 "en Cx4, OBC1, SuperFX, SA-1, S-DD1". En Zeldix
reportan el hack de MSU-1 de SFA2 andando en el sd2snes Pro (no dice si el
hack sigue usando el chip). Con nuestra ROM nadie lo probó: la prueba en el
hardware está en el research. Los cuatro emuladores cargan el MSU-1 con
cualquier placa.

**Recomendación: ahora no.** ABL no necesita el espacio y VD no entra igual.

Todo, en el libro: `src/research/2026-10-11-el-s-dd1.md`, rama
`carpintero-s-dd1` de the-advocate-docs (7aaaa6f).

## Al mergear

Nada que instalar. Mergear `carpintero-s-dd1` del libro. No se tocó código
de the-advocate ni de los ports.
