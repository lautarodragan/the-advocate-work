---
name: "Los otros juegos arman y arrancan"
description: "Una receta que arme los siete juegos desde su toml y los arranque hasta el primer mapa, en snes9x y bsnes; y unas goldens de los mapas pintados de Sunset, el único camino del motor que ninguna prueba ejecuta"
type: feature
agents: [Cardón]
assignee: taro
---

taro, el 2026-10-11, aprobó la propuesta: pruebas de los otros juegos,
pero pocas.

1. **Que cada juego arme desde su `rm2k-snes.toml` y arranque.** Hoy un
   cambio en las herramientas puede romper Vampires Dawn o Book of Three
   y nadie se entera hasta el próximo relevamiento. Rojo si no arma o si
   no llega al primer mapa; de paso, el mismo cartucho en snes9x y bsnes
   (memoria sin inicializar en código que ABL no ejecuta). No va en
   `just pruebas` de ABL —VD sola tarda ~2 min en armar—: es una receta
   aparte, para antes de entregar o después de un cambio grande.
2. **Goldens de los mapas pintados de Sunset** (`[graphics]
   painted_maps`, `Way::Painted`): la plaza (2) y el bar (28), quieto y
   caminando. ABL no tiene mapas pintados.

Lo que **no**: goldens de pantallas o recorridos de cada juego (hornean
errores de nacimiento y multiplican lo que hay que mirar), ni pruebas de
mecanismos con un juego de escenario (eso es de los crates o del juego
de pruebas, fase 2).

## Bitácora de Cardón

Base: the-advocate `fc6f7456` (herramientas globales, sin tocar), ports
`1353abc`. Rama `cardon-otros-juegos` en `~/scratch/cardon/ports`; libro
`cardon-otros-juegos-arrancan` en `~/scratch/cardon/docs2`. Scripts de
exploración en `~/scratch/cardon/explorar/`.

### Dónde vive y cómo se corre

`justfile` nuevo en la raíz de los ports, que importa `maquina.just`, con
`just arrancan` (lo que se le pase va a pytest: `just arrancan -k sunset`).
Las pruebas, en `pruebas/` de la raíz: `juegos.py` (el arnés), 
`test_arrancan.py`, `test_pintados.py` y `golden/`. Del arnés de ABL se usa
sólo `emulator/retro.py` (por `pythonpath` en `pruebas/pytest.ini`): el
resto importa `lugares.py`, que fija el proyecto de ABL y pide su
`GAME_DIR`. El recorte a 15 bits pasó a `retro.fifteen_bits`, y
`tanda.quince_bits` lo llama. Cada juego se arma con su propio
`just cartuchos`, **sin el `GAME_DIR` de afuera** (si viniera heredado,
armaría con los recursos de otro juego). No entra en `just pruebas` de ABL.

### Cómo decide "llegó al primer mapa" (medido 2026-10-11)

* Título: se toca A cada 16 cuadros hasta que `ticks` deja de ser cero
  (el lazo principal arrancó). El toque único de ABL —30 cuadros de aire y
  un A— se perdía en Dooms 2 y El Dorado. Sin título (`TITLE_TILES` en
  cero) no se toca nada.
* Después, **por ticks y no por cuadros**: A en un tick de cada 16
  mientras haya página (`ev_active`), fundido, mensaje o menú. Por cuadros,
  El Dorado llegaba 5 cuadros antes en bsnes; por ticks los dos cores
  llegan en el mismo tick con la misma pantalla.
* Control = 30 ticks seguidos sin `ev_active`, `fade`, `msg_open` ni
  `menu_open`. Ahí se pide: el mapa medido (`PRIMER_MAPA`), pantalla de más
  de un color, y que el héroe camine para algún lado (24 ticks por lado).
* Colgada: un tick que no llega en 3000 cuadros (la carga más larga medida,
  ~200 cuadros en El Dorado).
* Los dos cores: mismo (tick, mapa, héroe, lado) y capturas idénticas a 15
  bits al llegar y después de caminar.
* MSU-1 sólo para VD (`[rom] msu = "required"`); los demás sin, que es lo
  que se juega.

Resultado, por juego (control en el tick, mapa):

    book-of-three        3054   2
    desert-nightmare    10138  16   (menú propio del 1: "With Intro")
    dooms2               1934  15
    el-dorado            1108   2
    frozen-world         2682   9
    sunset-over-imdahl   8442  10
    vampires-dawn         490   4   ("Skip Intro ?" por la primera opción)

Los siete arman y llegan, idénticos en snes9x y bsnes. Armar desde cero,
en serie: BoT 13 s, DN 55 s, Dooms2 13 s, El Dorado 5 s, Frozen 20 s,
Sunset 33 s, VD 132 s. `PRIMER_MAPA` es lo que alcanza el port, **no está
comparado contra RM2k**.

### Las goldens de Sunset

Plaza (2) y bar (28), quietos en las celdas de las capturas de Mulita
—(28,10) y (4,11)— y caminando tres celdas para cada lado con la foto a
mitad del tercer paso: plaza desde (25,17), con la cámara moviéndose en
los cuatro; bar desde (10,9), donde la cámara casi no tiene para dónde.
Se llega jugando la intro y con el salto de puerta (`ir_al_mapa` como el
de ABL): es el `release`. Se exige `PAINT_ON` = 1, el registro "painted"
en el `.inc`, que el héroe camine 48 px para cada lado y, en la plaza, que
la cámara se mueva. snes9x y bsnes contra la misma golden, a 15 bits: dan
igual. Lado a lado en
`/shared/capturas/2026-10-11-los-otros-juegos-arman-y-arrancan/`.

**Hallazgos** (no arreglados, son del motor):

* En un mapa pintado los eventos "encima del héroe" se dibujan **sobre los
  techos**: los objetos suben un escalón en modo 1 (`oam.s`), y "encima"
  queda en prioridad 3, arriba de BG1 alta. En RM2k las imágenes (los
  techos) van arriba de todo (easyrpg: `Priority_PictureNew` > 
  `Priority_EventsFlying`). Se ve con el DummyGuard (13,23) del mapa 2,
  caminando desde (15,20). No comparado contra el original con Wine.
* Un guardia de capa normal (evento 8, (36,13) del mapa 2) con las piernas
  sobre el borde del techo naranja. Probablemente un borde de los que no
  entran en los 127 (deuda de Mulita); no lo comprobé.

Las caminatas están elegidas para que ninguno de los dos quede en una
golden.

### Rojo comprobado (a mano, y vuelto atrás)

* `start_map = 999` en el toml de Dooms 2: "dooms2 no arma", con la salida.
* `TOPE = 300`: "300 ticks tocando A y el jugador no tuvo el control".
* El Dorado esperando el mapa 3: "tiene el control en el mapa 2 y no en el 3".
* Un pixel de una golden tocado: "difiere de su golden en 1 de 57344".
* Lo que **no** se comprobó en rojo: que los dos cores difieran (haría falta
  una ROM que lea memoria sin inicializar); la comparación es la misma de
  `test_cores.py`.

### Lo que no cubre

* Si los mapas se ven bien (a propósito), salvo los dos pintados.
* Lo que pasa después del primer mapa, peleas, menús, guardar.
* Las otras opciones de las preguntas de las intros ("No Intro", etc.).
* Que `PRIMER_MAPA` sea el de RM2k.

### Para mergear

Ramas: ports `cardon-otros-juegos` (`b94b479` el arnés y la receta,
`a85b7e3` las goldens; `origin/main` 1353abc ya adentro), libro
`cardon-otros-juegos-arrancan` (`29a5114`, una sección en `testing.md` y
una línea en `contributing/README.md`). Nada que instalar: no toca las
herramientas.

Sobre la rama, con las herramientas globales (`fc6f7456`): `just arrancan`
**8 passed**, rc 0, 106 s con los cartuchos ya armados (Dooms 2 se
rearmó); desde cero suma ~270 s de armado. La tanda de ABL **1203
passed**, rc 0, y `abl.sfc` `27d989db75901791…`, igual que main.
