---
name: "La pantalla del nombre del héroe"
description: "EnterHeroName (10740) no existe en el motor: sólo lo usa Dooms 2, una vez. Diseño conversado con taro: el cursor en objetos, el fondo de BG1 sólo del System, la cara fuera de BG1 y el degradé por HDMA"
type: feature
status: wishlist
agents: [Hornero]
---

taro, el 2026-10-11: a la lista de deseos, no frena a ningún juego entero.
De los ocho, sólo Dooms 2 la usa, una vez.

## Cómo es en RM2k

Tres ventanas sobre negro (`scene_name.cpp` de EasyRPG): la cara del
actor (64x64, de su FaceSet), el nombre (192x32) al lado, y el teclado
(256x160) abajo. En 256x224 no entra tal cual: el teclado ya mide el
ancho entero, y en alto suman 232 con los márgenes. El cursor es el del
System, estirado a la celda, y parpadea.

## Lo que se habló

* **El cursor en la capa de objetos.** Las pantallas de hoy hornean el
  cursor sobre el fondo: por cada posición guardan el rectángulo de celdas
  que cambia, y lo copian al tilemap (`target_bar` en `actor_choice.s`,
  `borders.rs` de screens). Con ~90 teclas eso no escala; con sprites se
  mueve sin tocar BG1. Los pixeles del System son opacos o transparentes,
  así que el cursor como sprite se ve igual.
* **BG1 sólo con el System** (idea de taro): una imagen de RM2k es de 256
  colores indexados, y el System también. Sin la cara, todo lo que hay en
  pantalla —fondo, marco, cursor, colores de la letra— sale de su paleta,
  así que entra entero a 8bpp sin perder nada. La cara iría en objetos o
  en BG2. Ojo: la CGRAM es una sola. Las paletas de BG2 son las entradas
  0–127 y las de objetos las 128–255, las mismas que usa BG1 a 8bpp: lo
  que se ahorra es mezclar la cara con el System, no la memoria de
  colores.
* **El degradé por HDMA.** Lo que se pasaba de tiles en las ventanas
  (`la-ventana-en-el-banco-de-tiles`) no eran colores sino celdas: un
  degradé estirado es una celda distinta en cada fila. Si el fondo de
  cada ventana usa una sola entrada de la CGRAM y un canal de HDMA la
  reescribe en cada línea, el fondo pasa a ser una sola celda repetida.
  Ventanas que comparten filas —la cara y el nombre— tienen degradés
  distintos: una entrada y un canal por ventana. Sólo sirve para un
  fondo estirado en vertical, no para uno con textura o en mosaico.
  Serviría también para las otras pantallas, no sólo ésta.
