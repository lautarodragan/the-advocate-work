---
name: "El libro: las divergencias, en inglés"
description: "Las 42 divergencias de divergencias/ al libro, traducidas, en divergences/"
type: docs
status: testing
assignee: taro
agents: [Calandria]
---

De taro, el 2026-10-10: toda la documentación en un solo lugar, el libro
(`snes-rm2k-docs`), en inglés: "El libro es para personas y para IAs".
Esta tarea es una de cuatro en paralelo; las convenciones comunes están en
el encargo de Hornero, y Hornero arma el `SUMMARY.md` final, borra los
originales y actualiza las referencias.

## Lo hecho (Calandria, 2026-10-10)

Rama `calandria-divergences` del clon del libro, sobre 149452a, en tres
commits: 387a431 y bd84ca9 son las 41 páginas y la introducción
(`src/divergences/`, con los slugs en castellano), y ef2c3ba la sección
del `SUMMARY.md`, agrupada por tema con entradas de borrador sin página
—el mapa y sus gráficos, eventos y movimiento, mensajes y ventanas, la
pelea, las otras pantallas, el control—. `mdbook build` sin warnings.
Eran 42 archivos contando el README: 41 divergencias.

Lo que se decidió al traducir:

* Los originales no tienen título —el nombre del archivo hace de título—:
  cada página recibió un `#` en inglés y sus secciones bajaron a `##`.
* Las rutas de código dicen de qué repo son ("in snes-rm2k", "in the ABL
  port (snes-rm2k-ports/abl)"); las de `tasks/` con comodín
  (`tasks/*/x.md`, `workflow/tasks/*/x.md`) pasaron a "the task `x.md`,
  in `tasks/` in snes-rm2k-work".
* Las citas entre divergencias son enlaces relativos. Las de
  `decisiones/` apuntan a `../decisions/<slug>.md` (cuatro:
  `call-event-a-un-cuerpo-compartido`, `el-cronometro-no-tiene-paleta-propia`,
  `las-imagenes-grandes-en-modo-1`, `los-translucidos-van-horneados`), la
  intro a `../decisions/README.md`, y la de `docs/research/` a
  `../research/graficos-de-rm2k-a-snes.md`: si Mulita puso alguna en
  `ports/abl/decisions/`, hay que corregirla al mergear.
* `docs/port/events.md` y `docs/port/vram.md` quedaron como texto ("in
  snes-rm2k"), sin enlace: no sé con qué nombre los deja Tijereta.
* El único rastro del ambiente era la carpeta de capturas en `/shared` de
  `la-ventana-sin-fondo-no-tapa-a-los-personajes`: quedó "kept outside the
  repositories, for review", y se pierde dónde están.

Al mergear no hay nada que instalar.
