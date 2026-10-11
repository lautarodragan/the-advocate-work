---
name: "Tres textos que quedaron viejos"
description: "internals/events.md dice que el conversor es Python, internals/vram.md dice 'cuatro' repartos y lista cinco, y el encabezado de las pruebas de rm2k-rules nombra un Python y una prueba que no existen"
type: docs
---

Los vieron dos agentes y los dejaron anotados sin tocarlos, porque no
eran de su tarea. Siguen así hoy (the-advocate `fc6f7456`, libro
`f6e8d57`):

* **`internals/events.md` del libro**: "What is left on the Python side is
  the converter, which compiles what the routine later reads". El
  conversor es Rust. Lo anotó Tijereta el 2026-10-10 al traducirlo
  (`testing/el-libro-docs-y-ports.md`: "se tradujo tal cual").
* **`internals/vram.md` del libro**, sección "A map that shows its
  panorama uses one of its own": "There are four" y la tabla lista cinco
  repartos (`panorama`, `panorama_m1`, `panorama_bg`,
  `panorama_bg_sprite`, `panorama_bg_ceiling`). La misma tarea.
* **`rm2k/rules/tests/python.rs`** de the-advocate: el encabezado dice que
  "these rules also exist in Python, in the converter that still uses
  them" y nombra `tests/test_rm2k_rules.py`, que no existe (en `tests/`
  hay cuatro pruebas y ninguna es ésa). Lo anotó Calandria el 2026-10-04
  (`testing/el-justfile-mas-chico.md`): "no lo toqué: es del crate".

Una página de `internals/` tiene que estar al día (AGENTS.md); el
comentario de la prueba protege los hashes de `python.json`, así que lo
que diga tiene que seguir explicando por qué no se editan.
