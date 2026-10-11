---
name: "La cámara que vuelve sobre una fila a medio subir pierde un cuadro"
description: "En un mapa pintado, si la cámara da la vuelta mientras sube adelantada una fila de la pintura, la sube entera en ese tick y se pierde un cuadro"
type: bug
status: draft
---

Medido por Mulita el 2026-10-11 (`sunset-en-modo-1-con-color-math.md`),
con `modo1/chequear.py` —VRAM contra el `.inc`, cuadro a cuadro— en el
mapa 2 de Sunset Over Imdahl: la fila que viene se sube adelantada, 11
tiles por cuadro, y "una vuelta atrás de la cámara con una fila a medio
subir la sube entera en ese tick, y en la plaza eso costó un cuadro
perdido". Lo dejó en "Lo que queda". El código de los mapas pintados
(`runtime/`, `.ifdef paint_table`) no cambió desde entonces
(the-advocate `fc6f7456`); no comprobado hoy.

**Qué se ve jugando**: un tirón de un cuadro al dar la vuelta caminando
en una plaza de Sunset. Nadie dijo haberlo notado.

**Cómo verlo**: el script de Mulita, `~/scratch/mulita/modo1/chequear.py`,
sobre el release de Sunset, caminando en la plaza (mapa 2) y volviendo
sobre los pasos.
