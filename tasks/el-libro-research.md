---
name: "El libro: los research de las herramientas, en inglés"
description: "Los 9 estudios fechados de docs/research/ de snes-rm2k al libro, traducidos y sin actualizar sus números, en research/"
type: docs
status: testing
assignee: taro
agents: [Cardón]
---

De taro, el 2026-10-10: toda la documentación en un solo lugar, el libro
(`snes-rm2k-docs`), en inglés: "El libro es para personas y para IAs".
Esta tarea es una de cuatro en paralelo; las convenciones comunes están en
el encargo de Hornero, y Hornero arma el `SUMMARY.md` final, borra los
originales y actualiza las referencias.

## Lo hecho (Cardón, 2026-10-10)

Rama `cardon-research` de `snes-rm2k-docs`, sobre `149452a`, en un clon
aparte: un commit por estudio, uno para `src/research/README.md` y uno
aparte para el `SUMMARY.md`. Nada que instalar al mergear. Los nueve
quedaron en `src/research/<slug>.md` con el slug en castellano y el título
en inglés; el README explica que un research es una foto que no se toca.
Cinco —el mapa de Python, el juego de pruebas, las herramientas hoy, las
imágenes y los panoramas— los tradujeron forks míos; los revisé por
muestras y buscando castellano suelto.

Criterios que tomé, para verlos al mergear:

* La notación de los números pasó a la inglesa (5.601 → 5,601; 10,3% →
  10.3%); los valores, no.
* Las citas a `decisiones/x.md` y `divergencias/x.md` que existen pasaron
  a links `../decisions/x.md` y `../divergences/x.md` (seis: dan rotos
  hasta que entren las secciones de Mulita y Calandria); las citas entre
  research, a links relativos; `docs/port/…`, `workflow/…` y `rom/…`
  quedaron como texto, como estaban.
* Identificadores, nombres de módulo y salidas de scripts en castellano
  (`cartuchos`, `techos`, `## ARISTAS POR ARCHIVO`) quedaron tal cual:
  son nombres de ese día.
* Rutas de la máquina: una sola, "en el scratch" del juego de pruebas →
  "in the scratch directory"; y "una ruta de esta máquina" del mapa de
  Python → "a path on the development machine".

Verificado: `mdbook build` sin warnings; los links entre páginas de
research resuelven.
