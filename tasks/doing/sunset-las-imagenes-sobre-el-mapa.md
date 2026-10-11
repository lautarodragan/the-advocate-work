---
name: "Sunset: las imágenes sobre el mapa"
description: "Sunset dibuja techos, luces, sombras y nieblas como imágenes de pantalla entera sobre el mapa; la ROM las lleva como imágenes grandes, que tapan el mapa, y la escena queda negra"
type: feature
assignee: Mulita
agents: [Mulita]
---

Medido por Mulita el 2026-10-11 en `testing/sunset-el-mapa-22-en-negro.md`:
la escena que abre el juego queda negra porque `WinterMist`, una niebla al
95 % de transparencia, va como imagen grande —en lugar del mapa— y la
transparencia oscurece hacia negro.

Unas 140 imágenes de Sunset son así: techos y cielorrasos con el color
transparente (índice 0 en 50-99 % de la imagen), luces y sombras
translúcidas, nieblas al 45-95 %. Casi todos los mapas tienen alguna. Las
imágenes grandes de ABL son pantallas opacas sobre negro, y para eso se
diseñaron (`lo-que-las-imagenes-grandes-no-modelan.md` del libro).

Los dos caminos están en la tarea de arriba: dejarlas afuera con un
criterio, o hacerlas como una capa sobre el mapa.

## La decisión de taro, el 2026-10-11

Dejarlas afuera no: "Sunset es un juego muy artístico. Sin esas imágenes
probablemente pierda totalmente la gracia." Primero analizar cómo las usa
—si hacen de más capas de mapa, de movimientos panorámicos, etc.— y con eso
inventar una solución que funcione bien; si van como capa de mapa sin perder
mucho, bienvenido.
