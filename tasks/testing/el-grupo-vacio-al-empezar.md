---
name: "El grupo vacío al empezar"
description: "RM2k arranca sin nadie en el grupo y sin héroe visible; el conversor pide un líder para dibujar, y Sunset y Desert necesitan party = [1]"
type: feature
assignee: taro
agents: [Mulita]
---

Del relevamiento del 2026-10-05 y del re-barrido del 2026-10-10: sigue siendo la muleta de Sunset Over Imdahl y Desert Nightmare.

## Qué hace RM2k con el grupo vacío (easyrpg-player)

Leído en `~/ref/easyrpg-player/src`:

* `Game_Player::ResetGraphic`: sin `GetActor(0)` el gráfico es `""`, y el
  héroe no se dibuja. **Nada más cambia**: no hay ninguna pregunta por el
  grupo en el movimiento, en los choques (`WouldCollide` mira capa y
  `through`, no el gráfico), en los disparos de eventos ni en los
  encuentros. El héroe invisible camina, choca, toca eventos y puede
  entrar en una pelea.
* `Scene_Menu`: el menú se abre. Ítems, Habilidades, Equipo, Estado y Fila
  van deshabilitados (en gris, y A suena el buzzer); Guardar y Salir no
  dependen del grupo.
* `Scene_Save::Save`: con cero miembros la partida se guarda sin caras ni
  nombre del líder.

## Lo que había

* El conversor paraba en `Database::leader` ("the party is empty") y Wally
  en el `first` de los líderes.
* El runtime ya dibujaba nada con `party_n = 0` (`pick_hero_graphic`, el
  `hero_poses + 2` en cero de `oam.s`) y la pantalla de ranuras ya sabía
  que un grupo vacío no tiene líder.
* `party_initial` salía como `.byte ` sin nada, que no ensambla.

## Bitácora

* Sunset, cartucho chico (mapas 11, 22, 21, 23, 10) sin la muleta: arma.
  El 22, la escena de la tienda de campaña, queda en negro **también con
  la muleta** (`party = [1]`, mismo cartucho): no es del grupo vacío.
* Desert Nightmare sin la muleta: el `release` arma (unos 5 minutos). En
  el mapa 1, el menú de "With Intro / No Intro / Quit", no hay héroe
  dibujado y `party_n` es 0; al elegir entra el actor 1 y el juego sigue
  (mirado con capturas de snes9x, no con una prueba).
* ABL: `abl.sfc` sale idéntico con sólo los cambios del conversor
  (`f135f6af…`). Con el del menú se mueve, a propósito.
* `test_grupo_vacio.py`, en `test-special` (para no tocar `release`):
  antes del arreglo del menú, rojas las de Ítems y Equipo —A abría la
  lista, y Equipo abría la elección de actor sobre cero filas— y la
  golden del menú. Las de "no se dibuja", "camina", "entra y se ve" y
  "guarda y carga" ya pasaban: el runtime ya sabía de `party_n = 0`.
* El primer lugar elegido para el caso, el 1 en (66, 40), es el de
  `parado-tapado`: el héroe queda debajo de un caño y no se ve. El 255
  abre un cartel, y el 21 suma a Talan solo. Quedó el 5 en (39, 34), el de
  `pelea-82-grupo-11-12`.

* Sunset sin la muleta: el `release` entero arma (2 h 11 min, con otras
  corridas). El título lleva al 21 con el grupo vacío.
* Con `hornero-integ` (71737293) y `main` de ports (a95aacb) mergeados:
  la tanda de ABL, 1174 en verde (las 1167 más las 7 nuevas); `abl.sfc`
  da `5852b723…`, distinto del `30c38ba8…` de main sólo por el arreglo
  del menú (sin él, antes del merge, salía idéntico).

## Al mergear

Ramas `mulita-grupo-vacio` en the-advocate, the-advocate-ports y
the-advocate-docs. Reinstalar en el global: `convert`, `wally`,
`mapdata` y `cartridge` (éste por el runtime, `runtime/menu.s`).

## Lo que no cubre

* **Una pelea con el grupo vacío.** RM2k la pierde enseguida
  (`Game_Battle::CheckLose` sin nadie que pueda actuar); el runtime no se
  miró ni se probó.
* **El arranque vacío del conversor** —`party_initial` sin bytes, Wally
  sin primer líder— no lo corre la tanda: ABL arranca con el 10. Lo
  corrieron Sunset y Desert, mirados con capturas.
* Habilidades ya iba en gris siempre; Estado y Fila no existen en el menú.
