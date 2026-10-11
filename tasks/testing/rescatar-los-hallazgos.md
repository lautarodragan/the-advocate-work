---
name: "Rescatar los hallazgos"
description: "Leer las tareas de testing/ y pasar a tasks/draft/ los hallazgos que quedaron sueltos —errores no arreglados, caminos no cubiertos, 'lo siguiente, medido'—, y a 'Known issues' de cada port lo que se ve jugando"
type: docs
agents: [Calandria]
assignee: taro
---

taro, el 2026-10-11, creó el estado `draft` (ver el README de este repo y
"Un hallazgo que no se arregla" en `AGENTS.md`). Los hallazgos de antes
quedaron en las tareas de los agentes; ésta los rescata. El ejemplo del
formato es `draft/los-eventos-encima-del-heroe-sobre-los-techos-pintados.md`,
y el de "Known issues", la página de Sunset en el libro.

## Cómo se hizo (Calandria, 2026-10-11)

Se leyeron las 60 tareas de `testing/`. Cada hallazgo se miró contra hoy
—the-advocate `fc6f7456` (las herramientas globales), ports `a85b7e3`,
libro `f6e8d57`— con `git log`, las tareas posteriores y el código. Para
los de los otros juegos se armó el release de Frozen World, Desert
Nightmare, Dooms 2, Book of Three, El Dorado y Vampires Dawn en un
worktree propio de los ports (sin commits), y donde un mapa estaba
excluido se lo devolvió para ver el corte de hoy (Dooms 2 el 1, Frozen
el 1 y el 2, VD sin la perilla `system`). Los scripts de una vez, en
`~/scratch/calandria/tmp/`.

## Drafts nuevos (17)

* `los-comunes-paralelos-no-corren` — de `el-tablero-contra-rm2k`.
* `el-lider-y-los-renombrados-en-los-mensajes` — de `el-nombre-del-heroe-en-los-mensajes`.
* `lo-que-se-funde-en-las-pantallas-no-va-a-los-parches` — de `la-ventana-con-mas-colores` y `la-ventana-en-el-banco-de-tiles`.
* `las-ranuras-y-el-menu-de-dooms2-no-entran` — de `las-exclusiones-que-sobran`, `la-ventana-en-el-banco-de-tiles` y el punto 4 de `degradar-en-vez-de-fallar`.
* `el-heroe-que-destella-comparte-paleta` — de `las-exclusiones-que-sobran` (Frozen 1).
* `los-flujos-de-un-mapa-que-no-entran-en-la-wram` — de `las-exclusiones-que-sobran` (Frozen 2) y `vampires-dawn-arma-desde-su-toml` (VD 1).
* `los-mapas-de-vampires-dawn-que-no-entran-en-la-vram` — de `vampires-dawn-arma-desde-su-toml`, `una-cuantizacion-por-personaje` y `fusionar-tiles-parecidos`.
* `vampires-dawn-con-su-system` — de `la-ventana-en-el-banco-de-tiles`: **ya arma con `VDBlutsys`**, medido hoy.
* `las-paredes-invisibles-que-se-pierden` — de `los-eventos-que-no-entran-en-la-ram`.
* `las-imagenes-sobre-el-mapa-fuera-de-sunset` — de `eraseevent-de-verdad` (el WC de Desert).
* `el-titulo-que-no-entra-en-la-vram` — de `degradar-en-vez-de-fallar` (Desert, Frozen, VD).
* `las-variables-que-pasan-de-256` — de `degradar-en-vez-de-fallar` (VD).
* `los-bordes-de-techo-que-no-entran` — de `sunset-en-modo-1-con-color-math` y `los-otros-juegos-arman-y-arrancan`.
* `la-camara-que-vuelve-sobre-una-fila-a-medio-subir` — de `sunset-en-modo-1-con-color-math`.
* `textos-que-quedaron-viejos` — de `el-libro-docs-y-ports` y `el-justfile-mas-chico`.
* `una-pelea-con-el-grupo-vacio` y `borrar-un-evento-sin-prueba-de-lo-que-se-ve` — cobertura, de `el-grupo-vacio-al-empezar` y `eraseevent-de-verdad`.

Y una línea en dos tareas de `todo/`: `eraseScreen-y-showscreen` (ya no
deja páginas afuera, es deuda; qué se ve en Desert y El Dorado) y
`changesystemgraphics` (también VD y Desert, que juega entero con el
System de la intro). El draft de ejemplo nombra ahora el de los bordes.

## Known issues

En el libro, rama `calandria-known-issues`: la sección arriba de todo en
las ocho páginas de ports (en ABL, el texto de presentación pasó a "The
port"). Cada línea nombra su draft o su tarea de `todo/`.

## Descartados: ya arreglados o cubiertos

* Sunset negro a los 30 s (`ignorar-changesystemgraphics`) y la ventana
  opaca y naranja (`sunset-el-mapa-22-en-negro`): los arreglaron las
  imágenes dentro del mapa y el modo 1; la captura `modo1-22-01600` de
  `/shared/capturas/2026-10-11-sunset-modo-1/` muestra la escena con la
  ventana sin fondo.
* La intro de Desert que terminaba en negro por el mapa 2 excluido
  (`eraseevent-de-verdad`): Desert ya no excluye nada.
* Sunset tarda horas (`sunset-tarda-horas-en-armar`, `otros-juegos-el-rebarrido`):
  arma en 33 s (`los-otros-juegos-arman-y-arrancan`).
* Las rayas de la intro de VD (`boot-frames-por-cartucho`):
  `la-intro-de-vampires-dawn-rota`.
* Los mapas 40 a 93 de Dooms 2 (`las-caras-y-los-escapes-de-espera`):
  `las-muestras-que-sobran`.
* El System propio de Book of Three, Frozen, Desert y Dooms 2:
  `la-ventana-en-el-banco-de-tiles`.
* Los recursos del juego fuera de la huella (`el-volcado-fuera-de-la-huella`):
  `la-huella-con-el-juego-y-force`.
* `ChangeFaceGraphic` fuera de `ACCEPTED_UNDONE` (`el-tablero-contra-rm2k`):
  `changefacegraphic-en-las-deudas`.
* El rojo de `the_layers_are_the_ones_the_python_made` y la prueba de
  screens que cambiaba: `los-colores-de-la-ventana-en-el-pedido-de-wally`
  y `00710e92`.
* Los muros de VD de la música, las tropas, las poses, el arranque y los
  errores sin mapa: sus tareas de `testing/`.
* Las diagonales y giros del héroe en las rutas (`cuatro-atajos-para-los-otros-juegos`):
  `wishlist/ruta-los-movimientos-que-faltan`.
* `EraseScreen`/`ShowScreen`, `ChangeSystemGraphics`, las caras, los
  colores y las esperas: sus tareas de `todo/` (con la línea de arriba).

## No rescatados, a criterio

* `SUB_MAX` podría volver a pasarse (`cuatro-atajos-para-los-otros-juegos`):
  no se vio pasar.
* Las rutas de ABL que se cortan a velocidad 3
  (`la-ruta-del-mirador-deja-trabada-la-direccion`): hacen lo que RM2k, y
  el modelo era sin las esperas de los tintes.
* Las copias de `build/cache/zip/` que no se borran
  (`la-huella-con-el-juego-y-force`), los 168 bancos de poses que quedan
  (`una-cuantizacion-por-personaje`: VD ya entra) y los mapas pintados con
  MSU-1 obligatorio (`sunset-en-modo-1-con-color-math`): no hay nada roto.
* El panorama "basura celeste" de Desert del 2026-10-05
  (`otros-juegos-el-relevamiento`): los panoramas se rehicieron después y
  nadie lo volvió a ver; no comprobado.
* Los "no se jugó" y "la tanda no cubre" que no nombran un caso concreto.

## Visto de paso, sin draft

El release de Desert de hoy dice que en 157 mapas no dibuja las imágenes
`TextboxInnen` y `TextboxRahmen` —el marco propio de sus mensajes—; no
sale de ninguna tarea de `testing/`, y la página de Desert ya dice que
"136 maps don't draw some of their pictures". Queda para quien mire
Desert.

## Al mergear

Nada que instalar. Mergear `calandria-known-issues` del libro.
