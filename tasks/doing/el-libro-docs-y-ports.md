---
name: "El libro: docs/ de las herramientas y de ABL, y la sección de ports"
description: "docs/port, rpgmaker, snes y jetbrains.md de snes-rm2k, y docs/ de ABL, al libro en inglés; y la sección ports/, una entrada por juego"
type: docs
assignee: Tijereta
agents: [Tijereta]
---

De taro, el 2026-10-10: toda la documentación en un solo lugar, el libro
(`snes-rm2k-docs`), en inglés: "El libro es para personas y para IAs".
Esta tarea es una de cuatro en paralelo; las convenciones comunes están en
el encargo de Hornero, y Hornero arma el `SUMMARY.md` final, borra los
originales y actualiza las referencias.

## Mientras se trabaja (Tijereta, 2026-10-10)

Clon del libro en `~/scratch/tijereta/docs`, rama `tijereta-docs-ports`,
desde `149452a`. Fuentes: `snes-rm2k` en `e43e3e1b`, los ports en
`4eec80a`, este repo en `90f292b`.

* Los slugs de `port/`, `rpgmaker/`, `snes/`, `research/` de ABL quedan en
  castellano; los nuevos (`README.md`, `contributing/`, los de cada juego)
  en inglés o como el directorio del juego.
* Las citas a `workflow/decisiones/x.md` pasan a `../decisions/x.md`, las
  de `divergencias/` a `../divergences/x.md` y las de `docs/research/` a
  `../research/x.md`: los slugs no cambian, así que los enlaces a las
  secciones de Mulita, Calandria y Cardón se resuelven al mergear.
