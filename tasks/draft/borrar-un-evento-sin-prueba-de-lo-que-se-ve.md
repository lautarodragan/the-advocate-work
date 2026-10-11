---
name: "EraseEvent: ninguna prueba mira lo que se ve"
description: "Que un evento borrado deje de dibujarse, deje de bloquear y que una paralela que se borra se corte no lo cobra ninguna prueba: se miró jugando Desert Nightmare"
type: test
---

Lo dejó Hurón el 2026-10-06 en `testing/eraseevent-de-verdad.md`: las
pruebas de `EraseEvent` (tres del crate de eventos y
`pruebas/rpgmaker/test_borrar_evento_de_verdad.py` de ABL, en
`test-special`) "no cubren que el evento se deje de dibujar, que deje de
bloquear ni que la paralela se corte: el evento de prueba no tiene gráfico
ni es paralelo. Eso se miró jugando Desert Nightmare, no lo cobra ninguna
prueba."

Son tres caminos del runtime que existen sólo por esto: `apply_pages`
le esconde la fila al evento borrado y le suelta la ruta, `conditions_ok`
lo saca de la lista de paralelas, y `pair_ev` corta la paralela que lo
corre (`op_erase_event`, `runtime/interpreter_movement.s`). ABL usa
`EraseEvent` en la cantera (mapa 150 y común 36), y Desert Nightmare en
157 páginas paralelas sin gráfico.

**Cómo verlo**: en los casos de `test_borrar_evento_de_verdad.py`, un
evento con gráfico y en la capa del héroe que se borra (que no se dibuje y
que se pueda pasar por su celda), y una paralela que se borra a mitad de
su página (que lo de después no corra).
