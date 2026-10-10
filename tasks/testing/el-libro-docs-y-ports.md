---
name: "El libro: docs/ de las herramientas y de ABL, y la sección de ports"
description: "docs/port, rpgmaker, snes y jetbrains.md de snes-rm2k, y docs/ de ABL, al libro en inglés; y la sección ports/, una entrada por juego"
type: docs
assignee: taro
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

## Cómo quedó (Tijereta, 2026-10-10)

Rama `tijereta-docs-ports` del clon `~/scratch/tijereta/docs`, siete
commits sobre `149452a`; el `SUMMARY.md` va en uno propio (`031f761`).
`mdbook build` sin warnings; los únicos enlaces que no resuelven en la
rama son a `decisions/`, `ports/abl/decisions/`, `divergences/` y
`research/`, y todos existen en los clones de Mulita, Calandria y Cardón.

* `internals/`: los siete de `docs/port/`. `pipeline.md` queda con el
  diagrama de binarios y salidas, y enlaza al `pipeline.md` del libro para
  lo demás; lo que `cgram.md` y `vram.md` repetían del modo 3 y de lo que
  se pierde, enlazado a `fitting.md` y `cartridge/mode-3.md`. Las
  variables, con los nombres de hoy (`SOUNDFONT`, `RTP_DIR`), en su commit.
* `reference/`: `chipsets.md`, `rtp.md`, `emulators.md` (ya estaba en
  inglés: sólo perdió las menciones de la máquina) y el FAQ de Bregalad,
  tal cual, como archivo estático.
* `contributing/`: los cuatro repos y `jetbrains.md`.
* `ports/`: qué es un port, ABL (su README, armado con el del port y el
  de su `docs/`; su pipeline, su RTP y los tres research) y una página
  por cada uno de los siete, como foto al 2026-10-06: lo del relevamiento
  y lo de cada tarea de `testing/` que lo nombra.

**Lo que quedó viejo en el original y se tradujo tal cual**, para quien
actualice: `events.md` dice que "lo que queda del lado de Python es el
conversor", y el conversor ya es Rust; `vram.md` dice que los repartos
del panorama "son cuatro" y lista cinco. El README de ABL llamaba
`abl-snes` al repo de las herramientas: en el libro dice snes-rm2k.

Al mergear no hay nada que instalar: es sólo el libro.
