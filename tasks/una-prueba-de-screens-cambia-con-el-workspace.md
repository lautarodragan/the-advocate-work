---
name: "Una prueba de screens da distinto con el workspace entero"
description: "the_boxes_of_the_maps_and_the_common_events da 4 cajas con cargo test -p rm2k-snes-screens y 5 con cargo test --workspace, desde el merge de las caras y los escapes (3f34ca23)"
type: bug
status: testing
agents: [Hornero]
assignee: taro
---

Visto el 2026-10-06 al mergear lo de Mulita y Carpintero. Bisectado: en
`ea1c5beb` (el padre) pasa con el workspace entero, en `3f34ca23` falla
(`left: 5, right: 4`, `screens/tests/python.rs:327`). Con `-p
rm2k-snes-screens` solo, pasa. ABL no cambia (la tanda en verde, la misma
huella), y los binarios se instalan crate por crate, así que la ROM la arma
el comportamiento de `-p`.

La diferencia entre las dos corridas es la unificación de dependencias y
features del workspace: `serde_json` con `preserve_order` (lo piden
`rm2k-snes-audio` y `convert`) es el sospechoso, junto con el
`without_waits` de `text/src/refit.rs`. No se siguió, por el límite de uso.

## Resuelto, el 2026-10-11

No era el workspace. Bisectado de nuevo con `crate-test screens` —que
prueba el proyecto solo— desde `97ddd8be`, donde nació la huella: el
primer commit rojo es `73b263a3`, de las caras y los escapes, con `-p`
también. Ese commit aceptó a propósito `\.`, `\!` y `\|` en mitad de
una caja, y la caja del fixture que existía para el camino de "no
compila" usaba justo un `\|` en el medio: pasó a compilar y la tabla dio
5 cajas. La diferencia con `-p` que se vio el 2026-10-06 no se reproduce
—ninguno de los proyectos tiene features—; probablemente fue un build
viejo.

Arreglado en `00710e92` de `the-advocate`: la caja usa `\$`, que sigue
sin compilar, y vuelven las 4 cajas con la huella de antes, sin tocarla.
Pasa igual con `crate-test screens` y con `cargo test --workspace`.
