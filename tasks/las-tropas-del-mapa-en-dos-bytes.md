---
name: "El lugar de la tropa en dos bytes"
description: "BA_TROOP_K es un byte: un cartucho con más de 255 tropas usadas no arma (VD pide 277); pasarlo a dos bytes, para cualquier juego"
type: feature
status: testing
agents: [Hurón]
assignee: taro
---

De `testing/vampires-dawn-arma-desde-su-toml.md` (Aguará, 2026-10-11):
"277 troops of 255, 554 members" corta el cartucho entero de VD, no un
mapa. El chequeo es `used.len() > 255` en `emit.rs` de mapdata; el
2026-10-10 (406fc5e0) pasó a palabra sólo el comienzo de los miembros.
Hoy VD deja afuera 98, 182, 327 y 339 sólo por esto.

## Lo que se hizo (Hurón, 2026-10-11)

Base: the-advocate `0bb1120a`, ports `c914245`; ramas
`huron-tropas-dos-bytes` en los dos, worktrees en `~/scratch/huron/`.

**La intención del byte**: `git log -S 'troops of 255'` da 406fc5e0
(Tijereta, 2026-10-10), que dice "sigue en un byte el lugar de la tropa
—`BA_TROOP_K`, con $FF 'no la lleva'—: hasta 255 tropas por cartucho, y
el conversor lo dice si pasa". Un límite declarado, no una razón: el byte
era lo que había en `FAR_BATTLE + 45`, y +46 y +47 están libres (`BA_ACC`
empieza en +48).

**Los lectores** (grep de `BA_TROOP_K` en `runtime/`, revisados a mano):
el que lo escribe, la búsqueda en `troop_id` de `battle.s` —que además
contaba en `BA_S1` de a un byte contra `TROOPS_N`—; `ba_member_x`,
`troop_hidden` del armado, `ba_page_build`, `ba_exp_allocate`, el fondo y
los battlers de `battle_scene.s`, y los dos de `battle_victory.s`. Las
pruebas de ABL no leen `BA_TROOP_K` de la RAM: leen las tablas
(`troop_id`, `troop_hidden`, `troop_exp`), que no cambian. Las tablas por
tropa (`troop_id`, `_exp`, `_gold`, `_init`, `troop_page_init` en
palabras; `troop_n`, `troop_hidden`, `troop_page_n`,
`scene_troop_backdrop` en bytes por tropa) ya se indexaban con X de
dieciséis bits: lo único de un byte era el lugar.

**El cambio** (the-advocate `5d7d5601`): `BA_TROOP_K` es una palabra en
+45/+46, $FFFF "no la lleva". Como `ENC_REG`, ningún lugar llega a $FF00
—el conversor corta en 32768, para que el doble indexe las tablas de
palabras en dieciséis bits—, así que los chequeos de 8 bits leen
`BA_TROOP_K + 1`. La búsqueda en `troop_id` cuenta en dieciséis bits. El
chequeo de `emit.rs` pasa de 255 a 32768. Prueba nueva en
`mapdata/tests/python.rs` (300 tropas), vista en rojo antes ("300 troops
of 255, 611 members").

**Verificado**:

* `just crate-test mapdata` y `just test` (27) en verde.
* ABL, en `abl/` de mis ports con `PATH=<worktree>/.local-tools/bin`
  (project, mapdata, convert, cartridge): `just cartuchos` y `just
  pruebas`, **1202 passed**, ninguna golden movida. `abl.sfc` pasa de
  `24dd24ad…` a `4bb9b84e…`: `mapdata.inc` sale idéntico al de main
  (`df57da5a…` los dos), así que lo que cambia es sólo el código del
  runtime —ABL lleva menos de 256 tropas y la tabla no se mueve—.
* Vampires Dawn, sacando de `excluded` los cuatro de las tropas: ya no
  corta en las tropas sino en la ROM ("a piece of 65536 bytes needs a new
  bank, and the 127 banks … are taken"). De a uno: 98 arma, 98+182 arma,
  y 327 o 339 encima ya no (la ROM). **Vuelven dos**, 98 y 182; 327 y 339
  pasan a "poses" en el toml (ports `29d4c24`). El cartucho lleva 266
  tropas (`TROOPS_N`), `vampires-dawn.sfc` `c6b6fe5c…`.
* **Una pelea con el lugar arriba de 255, corrida**: un caso descartable
  (no commiteado) que hace `EnemyEncounter` de la tropa 332 —lugar 260;
  truncado sería el 4, la tropa 1, de cuatro enemigos— en snes9x y en
  bsnes: `BA_TROOP_K` = 260, un enemigo, 400 HP (el Fireworm), su
  battler y su fondo; y ganándola (HP y ataque tocados a mano), "590
  Experience Points gained", que sale de `troop_exp` en el lugar 260.
  Capturas en `/shared/capturas/2026-10-11-tropas-dos-bytes/`.

**Lo que no se cubrió**: el oro de la victoria con un lugar alto (el
Fireworm da 0), `troop_hidden` con un miembro oculto arriba de 255, y las
páginas de tropa (`ba_page_build`) arriba de 255 no se ejecutaron con un
caso que las mire; el código es el mismo patrón que los que sí. Ninguna
prueba de la tanda arma un cartucho con más de 255 tropas: la cobertura
de ese camino es la corrida de arriba, que no queda como prueba. Jugar VD
no se jugó.

El libro: una foto nueva arriba en `ports/vampires-dawn/README.md`
(docs `269aa1e`, rama `huron-tropas-dos-bytes`); ninguna página de
`internals/` describe `FAR_BATTLE`.

Al mergear: reinstalar `mapdata` y `convert` (el chequeo), y el runtime
entra por el checkout de `~/the-advocate`.
