---
name: "El libro: el tablero contra RM2k, en inglés"
description: "El artifact \"El motor contra RPG Maker 2000\" al libro como HTML tal cual, traducido al inglés, y enlazado desde una página"
type: docs
status: testing
assignee: taro
agents: [Aguará]
---

De taro, el 2026-10-10: el tablero que Aguará inventarió y Hornero publicó
el 2026-10-06 (`el-tablero-contra-rm2k.md`) pasa al libro "copiando
su .html como está, y vinculándolo desde el libro, en vez de convertirlo
todo a markdown. Sí lo traduciría a inglés." Es la quinta de las tareas en
paralelo de la documentación al libro.

## Lo hecho

En `snes-rm2k-docs`, rama `aguara-board` del clon `~/scratch/aguara/docs`
(base 149452a), dos commits:

* `4e24aac`: `src/engine-vs-rm2k/index.html`, el HTML publicado traducido
  —mdBook lo copia tal cual y queda en `engine-vs-rm2k/index.html`—, y
  `src/engine-vs-rm2k.md`, la página del libro que explica qué mide y
  enlaza a él. Sigue diciendo que es una foto del 2026-10-06, commit
  3d0c787c de snes-rm2k.
* `a4f7c6e`: la entrada en `SUMMARY.md`, después de `fitting.md`, aparte
  para que Hornero la mergee con las de los otros.

Lo traducido es todo lo visible: título, encabezado, pie, las etiquetas de
`ST` (done, partial, patch, degrades, missing, n/a) y en el JSON
`nombre` y `nota`. Los nombres de comandos de RM2k quedan iguales (el
script que lo armó lo verifica para las pestañas 1 a 3). **Las claves de
estado quedan en castellano** (`hecho`, `parcial`…): son clases de CSS y
no se ven, y un comentario en el CSS lo dice.

`donde` pasó de texto a lista: las divergencias y decisiones son links a
`../divergences/<slug>.html` y `../decisions/<slug>.html` (slug en
castellano, 46 links); el resto queda como texto con el repo adelante
—`snes-rm2k: tools/…`, `snes-rm2k: docs/…`, `snes-rm2k-work: tasks/…`,
`snes-rm2k-ports: …` para lo que decía `ABL:`—. Ninguna nota nombraba el
ambiente.

Lo que queda para el merge, de Hornero:

* las 8 decisiones citadas se ven todas del motor, así que van a
  `../decisions/`; si alguna termina en `ports/abl/decisions/`, el link
  cambia;
* las rutas `snes-rm2k: docs/research/…` y `docs/port/…` quedan como
  texto de la foto, aunque esos archivos se muden al libro;
* `snes-rm2k-ports: menus/consola.toml` es la ruta del 2026-10-06; hoy
  ABL está en `abl/`.

## Cómo se verificó

* `mdbook build --dest-dir` (v0.5.4) sin warnings, y el `index.html`
  servido es byte por byte el de `src/`.
* El JSON del bloque `data` del HTML servido parsea con `json.loads`: 271
  ítems.
* En un Chromium headless (Playwright), sin errores de consola ni de
  página, en claro y oscuro: mismos números que el original en el mismo
  navegador —73%, 194 de 266, 97/93/4/13/59/5—, 31 filas que abren en 271
  ítems, el filtro de la leyenda anda (sacar "done" deja 174), y las
  capturas a 1000 y 400 de ancho se ven como el original.
