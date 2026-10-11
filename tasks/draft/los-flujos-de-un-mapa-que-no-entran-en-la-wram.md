---
name: "Los flujos de un mapa que no entran en la WRAM"
description: "El código de un mapa (map_code) o su grilla (map_cells) que pasan de su reserva de LZ2 en la WRAM cortan el armado: deja afuera el mapa 2 de The Frozen World y el 1 de Vampires Dawn, el mapa del mundo"
type: feature
---

Dos mapas, el mismo tope: la reserva de LZ2 de `runtime/far_ram.s`, que
`check_streams` (`rm2k-snes/mapdata/src/materials.rs`) hace cumplir
cortando el armado.

* **The Frozen World, mapa 2** ("Plate Placement"): "a stream of map_code
  is 38179 bytes and 19968 fit in WRAM". Medido por Calandria el 2026-10-11
  (`testing/las-exclusiones-que-sobran.md`) y **comprobado hoy**
  (the-advocate `fc6f7456`, ports `a85b7e3`): con el 2 devuelto, `just
  cartuchos release` en `frozen-world/` corta ahí. Según el re-barrido del
  2026-10-10, el 1 del mismo juego pide 1,8 MB de código solo.
* **Vampires Dawn, mapa 1** ("Weltkarte", el mapa del mundo, 300x300):
  "a stream of map_cells is 147232 bytes and 32768 fit in WRAM". Medido por
  Aguará el 2026-10-11 (`testing/vampires-dawn-arma-desde-su-toml.md`); lo
  dice el comentario de `excluded` en `vampires-dawn/rm2k-snes.toml`. No
  comprobado hoy (VD tarda unos dos minutos en armar). Antes cortaba en
  la animación del ChipSet, que ya degrada
  (`testing/las-animaciones-de-tiles-en-wram.md`: "la grilla: 180.000 bytes
  contra 64 KB de WRAM").

Las animaciones de tiles, que tenían el mismo tipo de tope, ya degradan
(se quedan quietas las que no entran); el código y la grilla no tienen
qué perder sin cambiar lo que el mapa hace.

**Qué se ve jugando**: esos mapas no están en el cartucho, y un evento que
lleve a ellos pierde la página entera (un `Teleport` a un mapa que no
está no compila). En Vampires Dawn es el mundo: no se miró hasta dónde se
puede jugar sin él.

**Cómo verlo**: sacar el mapa de `excluded` en el `rm2k-snes.toml` del
juego y `just cartuchos release` en su directorio.
