---
name: "Las ventanas más eficientes"
description: "Analizar todas las ventanas —mensajes, menús, objetos, equipo, tienda, pelea, ranuras, elección de actor, nombre del héroe— con un fondo del System configurado por perilla (degradé o color sólido por HDMA/hblank), las caras fuera de BG1 y el cursor en objetos; medir y proponer"
type: research
agents: [Tijereta]
assignee: Tijereta
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
