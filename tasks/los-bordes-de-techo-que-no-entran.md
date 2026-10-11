---
name: "Los bordes de techo que no entran en los 127"
description: "En los mapas pintados, los bordes de techo exactos van en BG2 y entran 127; en las plazas y calles de Sunset hay más, y los demás van por celda entera: el techo tapa de más o de menos"
type: bug
status: draft
---

Medido por Mulita el 2026-10-11 (`sunset-en-modo-1-con-color-math.md`):
en un mapa pintado, las celdas que el techo cubre en parte van en BG2 con
sólo los píxeles del techo; entran 127 tiles (`roofs(…, 127)` en
`rm2k-snes/wally/src/background/painted.rs`, the-advocate `fc6f7456`), y
"los bordes que no entran van por celda entera". Sobre los 60 mapas
pintados, 34.895 de 1.586.793 píxeles de techo quedan del lado
equivocado (2,2 %); en la plaza de primavera, 2.250 de 84.145. Ella dejó
escrito por dónde podría ir: "se podrían dar 256 moviendo la base de BG2 y
la ventana al índice 256".

Cardón lo vio jugando el 2026-10-11 (`los-otros-juegos-arman-y-arrancan.md`):
un guardia de capa normal, el evento 8 en (36,13) del mapa 2, con las
piernas sobre el borde del techo naranja; "probablemente un borde de los
que no entran en los 127", no comprobado. Las caminatas de las goldens de
`test_pintados.py` se eligieron para no mostrarlo.

**Qué se ve jugando**: en las plazas y calles de Sunset Over Imdahl, cerca
del borde de un techo, un personaje queda tapado de más o asomando por
encima de donde el original lo tapa.

**Cómo verlo**: `just arrancan -k sunset` en la raíz de los ports arma el
release; ir al mapa 2 y mirar el guardia de (36,13).
