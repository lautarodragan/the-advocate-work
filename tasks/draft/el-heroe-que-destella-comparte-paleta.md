---
name: "El héroe que destella comparte paleta con un NPC"
description: "Si una página hace destellar al héroe y su gráfico lo usa también un NPC del mapa, el conversor corta: en la consola compartirían paleta y destellarían los dos. Deja afuera el mapa 1 de The Frozen World"
type: bug
---

Medido por Calandria el 2026-10-11 (`testing/las-exclusiones-que-sobran.md`)
y **comprobado hoy** (the-advocate `fc6f7456`, ports `a85b7e3`): con el 1
devuelto a The Frozen World (y el 2 todavía afuera), `just cartuchos
release` corta en "map 1: a page makes the hero flash, and actor 11 is
drawn with rangedmelee[0], which an NPC of the map also uses. On the
console they share a palette and both would flash".

El corte es a propósito, y no degrada: `crate::stop!` en
`rm2k-snes/convert/src/convert.rs`, que mira cada `OP_FLASH` sobre el
héroe en las páginas que corren en el mapa. Lo que se sabe de la causa
está en el mensaje: el destello es de la paleta, y el héroe y el NPC
dibujados con el mismo CharSet comparten una.

**Qué se ve jugando**: el mapa 1 de Frozen se llama "Battle Screen", y no
está en el cartucho; un evento que lleve ahí pierde la página entera (un
`Teleport` a un mapa que no está no compila). Qué parte del juego se
pierde con eso no se miró.

Y no es lo único del 1: según la página de Frozen en el libro, "map 1 asks
for 1.8 MB of code alone" (el re-barrido del 2026-10-10), es decir que
detrás de éste puede estar el de `los-flujos-de-un-mapa-que-no-entran-en-la-wram`.

**Cómo verlo**: sacar el 1 de `excluded` en `frozen-world/rm2k-snes.toml` y
`just cartuchos release` en `frozen-world/`.
