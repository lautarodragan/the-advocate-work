---
name: "Las paredes invisibles que se pierden al recortar eventos"
description: "Cuando un mapa pasa de 120 eventos, el recorte deja afuera también paredes invisibles: en ocho mapas de Desert Nightmare el héroe puede pasar por donde el original lo frena"
type: bug
status: draft
---

Medido por Carpintero el 2026-10-10 (`los-eventos-que-no-entran-en-la-ram.md`):
cuando un mapa pasa de los 120 eventos de la RAM, `Game::trim`
(`rm2k-snes/convert/src/trim.rs`) deja afuera lo que menos pierde, y la
tercera clase es "una pared invisible". Desert: "9 pierden decoración y 8
de ésos paredes invisibles". Él mismo dejó anotado lo que queda: "las
paredes invisibles podrían ir a la pasabilidad del mapa, y la decoración
hornearse (`decorative_events`) en vez de perderse: el recorte corre antes
que Wally, así que hoy no se hornea lo que se va".

**Comprobado hoy** (the-advocate `fc6f7456`, ports `a85b7e3`): el
`conversor.log` del release de Desert Nightmare dice las mismas listas que
el 2026-10-10. Pierden paredes invisibles (sólo pared, o dibujo y pared):

| mapa | eventos con pared que se van |
|---|---|
| 2 Dusty Creek | 5 |
| 4 Werkstatt | 23 + 27 |
| 5 Wohngegend | 11 |
| 14 Polizeirevier | 20 + 27 |
| 61 Werkstatt-Nacht | 23 + 28 |
| 62 Wohngegend-Nacht | 13 |
| 66 Polizeirevier-Nacht | 20 + 26 |
| 172 Alte Minensiedlung | 12 |

En Vampires Dawn, el 164 (Thessa) pierde dos con dibujo y pared, los
eventos 253 y 254 (también comprobado hoy, en un armado de VD con su
propio System: el recorte no depende de eso).

**Qué se ve jugando**: en esos mapas el héroe camina por celdas que en el
original están bloqueadas. No se miró en un emulador cuáles son ni si
dejan llegar a algún lado que no se debe.

**Cómo verlo**: `just cartuchos release` en `desert-nightmare/` y
`grep "lose an invisible wall\|looks and a wall" build/release/conversor.log`;
los números de evento están en cada línea.
