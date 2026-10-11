---
name: "Las ventanas más eficientes"
description: "Analizar todas las ventanas —mensajes, menús, objetos, equipo, tienda, pelea, ranuras, elección de actor, nombre del héroe— con un fondo del System configurado por perilla (degradé o color sólido por HDMA/hblank), las caras fuera de BG1 y el cursor en objetos; medir y proponer"
type: research
agents: [Tijereta]
assignee: taro
---

taro, el 2026-10-11, después de hablar de la pantalla del nombre
(`wishlist/la-pantalla-del-nombre-del-heroe.md`): que se analice para
todas las ventanas, no sólo ésa. "Si podemos hacer las ventanas, en
general, más eficientes, es un win por todos lados."

Lo que dijo taro, para tener en cuenta:

* **La cara no tiene que ser pixel perfect**: se puede achicar un poco si
  hace falta redondear a 8 px o ahorrar una fila o columna de tiles.
* **No hace falta detectar si el fondo es un degradé**: una perilla del
  `rm2k-snes.toml` que reemplace el fondo del System por uno propio,
  configurable —un degradé, o un color sólido—. Con la perilla, de un
  System se toman sólo los números, los íconos y los bordes; el fondo se
  ignora.
* **La ventana de mensajes en el juego**: si tiene fondo, ocupa una franja
  entera de la pantalla, así que se podría cambiar de modo y/o de paletas
  en el hblank de su primera línea y de la última, si dan los ciclos.
* **Para ABL**, otra opción de la perilla: color sólido. Aunque no cambie
  nada de lo que se ve, tenerlo declarado permite asumir cosas y
  optimizar en el runtime. Su pregunta: ¿alcanza una sola paleta de 16
  colores para fondo, marco y texto en todas sus ventanas?
* **El análisis de cada juego se hace una vez** —estático, o con IA—, no
  en una herramienta: las herramientas sólo leen la perilla del proyecto y
  toman el camino de runtime que corresponda.
* **Código distinto por juego** ("macros"): no lo descarta, pero sabe que
  suma superficie de bugs y quizás no aporte. Hoy ya hay algo así: el
  runtime bajo `.ifdef paint_table` y `.ifdef MSU_REQUIRED`.

## El encargo (Hornero, 2026-10-11)

Un research en el libro, no la implementación: las seis ideas —la perilla
del fondo, la franja de la ventana de mensajes, el cursor en objetos, las
caras fuera de BG1, la paleta de 16 de ABL y el código por juego—, cada
una medida sobre los ocho juegos, con la perilla propuesta, el valor de
cada juego y un orden de implementación en pasos chicos. Base:
the-advocate `fc6f7456`, ports `a85b7e3`.

## Cómo se mide (Tijereta)

Los ocho juegos se arman en un worktree de los ports con un envoltorio de
`rm2k-snes-screens` que guarda cada pedido; después se vuelve a correr
`screens convert` sobre esos pedidos con Systems retocados —el fondo
sólido, el cursor transparente— y caras en blanco, y se cuentan las
teselas. Lo que cambia es lo que la idea ahorra. Los Systems se leen de
los `.zip`; las copias retocadas van a `~/scratch/tijereta/`.

## Lo que se hizo (Tijereta, 2026-10-11)

El research está en el libro, rama `tijereta-ventanas`:
`src/research/2026-10-11-las-ventanas.md`, "The windows, made cheaper".
No se tocó código de las herramientas ni de los ports. Lo principal:

- **La perilla** (`[windows] background`, un color o una lista de paradas
  de un degradé vertical) es lo que más rinde: con el fondo de una sola
  entrada, Book of Three, Frozen World y Vampires Dawn con su VDBlutsys
  dejan de fundir todas sus pantallas, y la ventana de mensajes de Frozen
  World pasa de 15 colores a 7. Un degradé cuesta una entrada y un canal
  de HDMA por grupo de ventanas que comparten líneas.
- **La franja**: el prototipo escribió 8 colores por línea con 8 canales
  sin una línea mal en snes9x, bsnes y Mesen-S; el límite son los canales
  (en el mapa siempre están libres el 5 y el 7). No gana VRAM, y el cambio
  de paletas lo traban las ventanas sin fondo. Sirve para el degradé y
  para la paleta de una cara en la ventana de mensajes. IRQ no: es de
  `irq_music`.
- **El cursor en objetos** salva la elección de actor de Dooms 2 (69 → 27
  teselas de 64); en la ventana de mensajes lo traba la máscara de objetos.
- **Las caras**: lo que ocupan en el banco del menú, de 0 (Sunset) a 216
  (Vampires Dawn) de 448. En la ventana de mensajes no se dibujan, y DN,
  Dooms 2 y VD las piden 1848, 722 y 8195 veces: entran en las celdas del
  área de texto que la cara deja libres.
- **ABL en una paleta**: la ventana de mensajes sí (13, 12 con fondo
  liso); todas las ventanas con las cuatro tintas, no (33).
- **Código por juego**: datos, no `.ifdef`; el riesgo es el camino que
  ninguna prueba corre.

Capturas en `/shared/capturas/2026-10-11-las-ventanas/`. Los guiones de
medición quedaron en `~/scratch/tijereta/ventanas/py/` y el prototipo en
`~/scratch/tijereta/hdma/`: descartables.

## Qué quedó sin medir

El hardware real (el FX Pak), cuánto dura `irq_music`, los grupos de
ventanas de la pelea, el cursor de 38 colores de Dooms 2 en una paleta de
objetos, y dónde irían las teselas de las caras en objetos.

## Al mergear

Nada que instalar. Sólo el libro.

Hallazgo sin arreglar: `draft/el-texto-de-objetos-de-abl-no-entra.md`.
