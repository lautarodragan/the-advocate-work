---
name: "Los eventos que no entran en la RAM del mapa"
description: "EV_MAX: un mapa con más de 120 eventos corta el armado; que entren los que importan y avise"
type: feature
status: testing
assignee: taro
agents: [Carpintero]
---

Del informe de `testing/los-npcs-que-no-entran.md`: `EV_MAX`, 120 eventos por mapa, RAM del banco 0. Lo superan 38 mapas de Vampires Dawn y 11 de Desert Nightmare.

## Lo medido (2026-10-10, the-advocate 27010065, ports bd64aed)

Cada evento es una fila de `ev_pos_buf` (4 bytes), `ev_flags` (1) y
`pick_by_ev` (2) en el banco 0, y en varios lados el índice es un byte
("EV_MAX is 128"). Los mapas que pasan llegan a 328 eventos (VD 28), así
que subir el tope no es salida.

Qué son los que sobran, por mapa (script en
`~/scratch/carpintero/eventos/medir.py`): en Vampires Dawn, 24 de los 38
tienen más de 120 eventos **con comandos**; casi todos son tiras de
eventos invisibles, debajo del héroe, de tocar, con `ControlSwitches` +
`Teleport` al mismo destino —el borde del mapa, 70 celdas que llevan al
mismo lugar del mapa 1— o con un `ControlVariables`. En Desert Nightmare
sobran sobre todo eventos que sólo se ven (gráfico, sin comandos).

## Lo hecho

Dos pasos, los dos en el conversor (`convert/src/trim.rs`, `Game::trim`),
antes de que ninguna etapa lea el mapa:

1. **Gemelos, sin perder nada.** Eventos con las mismas páginas, invisibles,
   quietos, fuera de la capa del héroe, sin nombrar, sin páginas
   automáticas ni paralelas, que no se borran ni nombran "este evento":
   el de id más bajo se queda con la fila y los demás son una celda en una
   tabla de ROM detrás de las posiciones del mapa (una palabra con cuántos
   y 6 bytes cada uno). `twin_in_cell` (`runtime/action_key.s`) la mira
   cuando ninguna fila está en la celda. RAM nueva: ninguna (usa `npc_ptr`).
2. **Si no alcanza, se deja afuera lo que menos pierde**: nada, sólo cómo
   se ve, pared invisible, se ve y bloquea, páginas que corren, nombrado;
   dentro de cada clase el id más alto. El evento deja de existir: el
   compilador y Wally reciben `dropped_events` y leen el mapa sin él.

Medido: con los gemelos ningún mapa de VD ni de Desert pierde una página
(sin ellos, 22 de VD perdían salidas). VD: 24 de 38 entran enteros, 14
pierden decoración. Desert: 2 de 11 entran, 9 pierden decoración y 8 de
ésos paredes invisibles. `~/scratch/carpintero/eventos/recorte-*.txt`.

`--test-events-max` baja el tope para las pruebas: el cartucho
`test-twins` de ABL (mapa 255) y `test_gemelos.py` cubren el camino de la
ROM.

Ramas: `carpintero-eventos` en the-advocate, en los ports y en el libro
(`src/divergences/los-eventos-que-no-entran-en-la-ram.md`). Al mergear,
reinstalar `convert events wally mapdata`, y `cartridge` no (no cambió:
el runtime sale del checkout). `abl.sfc` cambia a propósito; la tanda
entera en verde sin mover goldens.

Lo que queda: las paredes invisibles podrían ir a la pasabilidad del
mapa, y la decoración hornearse (`decorative_events`) en vez de perderse:
el recorte corre antes que Wally, así que hoy no se hornea lo que se va.

## La decisión

Se pierde, y se elige qué. Lo decide el conversor al leer el juego
(`convert/src/trim.rs`, `Game::trim`), y el mapa se lee sin ellos en las
tres etapas que lo leen —el conversor, el compilador y Wally—: el
compilador y Wally lo reciben en sus pedidos, `dropped_events`, y así los
índices son los mismos en todos lados. Un evento que se va deja de existir:
una página que lo nombra no compila.

Orden, de lo que menos se pierde a lo que más; dentro de cada clase, el id
más alto primero:

1. nada: sin comandos, nadie lo nombra, no dibuja, no bloquea;
2. sólo cómo se ve;
3. una pared invisible (en la capa del héroe);
4. cómo se ve y una pared;
5. páginas que corren;
6. nombrado por alguien (sus páginas y las que lo nombran).

"Nombrar": `MoveEvent`, `ChangeEventLocation`, `TradeEventLocations`,
`FlashSprite`, `ShowBattleAnimation`, la rama por dirección de un evento,
`ControlVariables` con un personaje de operando y `CallEvent` de un evento
del mapa; en las páginas del mapa, los eventos comunes y las de prueba.

## La salida sin pérdida (hecha: los gemelos)

Medida antes de hacerla con `~/scratch/carpintero/eventos/fusion.py`. Lo
que costó: una palabra por mapa en el bloque `ev_pos` (el registro estaba
lleno en sus 128 bytes, así que no hubo campo nuevo), 6 bytes por gemelo,
unos 70 bytes de `CODE` en el banco 0, y un cartucho de prueba más.
