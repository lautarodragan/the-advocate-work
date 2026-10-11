---
name: "Los comunes paralelos no corren"
description: "La ROM no corre los eventos comunes paralelos, salvo los del equipo de ABL; cinco juegos tienen alguno —Vampires Dawn 35, entre ellos las transformaciones— y no está mirado qué se pierde en cada uno"
type: feature
status: draft
---

Lo vio Aguará el 2026-10-06 armando el tablero contra RM2k
(`el-tablero-contra-rm2k.md`): "los comunes en paralelo no corren
—6 en ABL, 35 en Vampires Dawn—, que no estaba en ningún estudio". Sigue
igual en the-advocate `fc6f7456`: el comentario de `party_common_events`,
en `rm2k-snes/events/src/indices.rs`, dice "The ROM does not run parallel
common events", y la única excepción son los que sólo miran el equipo,
que corren al cerrar el menú (la divergencia
`los-comunes-del-equipo-corren-al-cerrar-el-menu` del libro).

**Cuáles son**, contados el 2026-10-11 en el `data/db/commonevents.json`
de cada port (ports `a85b7e3`; disparador paralelo y con comandos):

* ABL: 1 `TalanLateForWork`, 2 `DisableSaving`, 3 `Raining`, 36
  `ManageQuarryTimer`, y 37 `UpdateAG7 Skills`, que es el del equipo y sí
  corre a su manera;
* The Book of Three: 16 `DisableSaving`, 18 `Reraise KO'd chars`, 21
  `Eilonwy's Upgrades`, 22 `LegendariesActivated`;
* Desert Nightmare: 4 `Hauptmenü`, 23 `Vergiftet`;
* Sunset Over Imdahl: 4 `MenuCaller`;
* Vampires Dawn: 35, entre ellos las invocaciones (`Skelett beschwören`,
  `Dämon beschwören`…) y las transformaciones (`Wolfsverwandlung`,
  `Fledermausverwandlun`, `Verwandlung beenden`);
* Dooms 2, El Dorado y The Frozen World: ninguno.

**Lo que no se sabe**: qué se pierde jugando en cada juego. Ninguno se
miró en un emulador, y alguno puede estar cubierto por otro camino (un
`CallEvent` desde un mapa). Lo que se midió el 2026-09-27 sobre hacerlos
de verdad —otro intérprete, el cuerpo en cada cuadro mientras el switch
esté prendido— y por qué no se hizo entonces está en ese mismo comentario
y en `los-comunes-automaticos-y-la-consola.md`: el 2 de ABL,
`DisableSaving`, no tiene switch y correría siempre.

**Cómo verlo**: la lista sale de `commonevents.json` de cada port
(`trigger` 4); lo que se pierde, jugando hasta donde el switch de cada uno
se prende y comparando con el original en Wine.
