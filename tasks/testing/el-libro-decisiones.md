---
name: "El libro: las decisiones, en inglés"
description: "Las 40 decisiones de decisiones/ al libro, traducidas: las de las herramientas a decisions/, las de ABL a ports/abl/decisions/"
type: docs
assignee: taro
agents: [Mulita]
---

De taro, el 2026-10-10: toda la documentación en un solo lugar, el libro
(`snes-rm2k-docs`), en inglés: "El libro es para personas y para IAs".
Esta tarea es una de cuatro en paralelo; las convenciones comunes están en
el encargo de Hornero, y Hornero arma el `SUMMARY.md` final, borra los
originales y actualiza las referencias.

## Lo hecho (Mulita, 2026-10-10)

Rama `mulita-decisions` de `snes-rm2k-docs`, sobre 149452a, en un clon
aparte; tres commits: las de las herramientas, las de ABL y el
`SUMMARY.md`. `mdbook build` sin avisos.

- **`src/decisions/`**: 37 decisiones y el `README.md`, traducido entero
  y con un índice agrupado (proyecto, eventos, rutas, gráficos y memoria,
  audio), que es también el orden del `SUMMARY.md`.
- **`src/ports/abl/decisions/`**: las dos que son del juego y no del
  motor —`la-camara-corrida-de-la-reja-es-del-juego` (lo que hace el
  original en el mapa 8) y `el-trueno-va-entero-y-paga-la-lluvia` (un
  efecto de un mapa de ABL)— y un `README.md` con su índice. Las mixtas
  —una regla del motor medida sobre ABL, como `los-lideres-comparten-…`,
  `la-orden-34-…` o `el-cartucho-pasa-a-8-mb`— quedaron en `decisions/`.
- `src/ports/README.md` y `src/ports/abl/README.md` son stubs de una línea:
  los de verdad son de Tijereta.
- El formato: el título va en inglés y "Qué / Por qué / Cómo se aplica"
  pasan a ser `## What / Why / How it applies`.

## Para Hornero, al mergear

- Los enlaces a `../research/…` y `../divergences/…` apuntan a slugs de
  Cardón y Calandria. Dos de los estudios
  (`2026-10-01-el-juego-entero-sin-msu-1`, `2026-10-01-los-mapas-por-el-msu-1`)
  son de `abl/docs/research/` de los ports, no de `snes-rm2k`: si Cardón
  los pone bajo `ports/abl/`, hay que corregir esos dos enlaces (en
  `el-cartucho-pasa-a-8-mb.md` y `el-juego-se-juega-sin-msu-1.md`).
- `el-color-math-no-se-usa.md` y `decisions/README.md` enlazan
  `../divergences/README.md`, que tiene que existir.
- La cita a `modo3-y-poses-en-caliente` (una nota de memoria, no pública)
  se cambió por un enlace a `cartridge/mode-3.md`.
