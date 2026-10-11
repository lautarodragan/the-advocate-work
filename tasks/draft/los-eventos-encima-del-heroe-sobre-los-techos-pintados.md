---
name: "Los eventos encima del héroe, sobre los techos pintados"
description: "En un mapa pintado (modo 1), un evento con prioridad 'encima del héroe' se dibuja por arriba de los techos; en RM2k los techos son imágenes y van arriba de todo"
type: bug
---

Visto por Cardón el 2026-10-11 (`testing/los-otros-juegos-arman-y-arrancan.md`),
herramientas `fc6f7456`, ports `a85b7e3`, en snes9x y bsnes igual.

**Qué se ve**: Sunset Over Imdahl, mapa 2 (la plaza), el DummyGuard en
(13,23): se dibuja sobre el techo que debería taparlo.

**Por qué, hasta donde se sabe**: en modo 1 los objetos suben un escalón de
prioridad (`oam.s`), así que "encima del héroe" queda en prioridad 3, por
arriba de BG1 alta, que es donde van los techos. En RM2k los techos de
Sunset son imágenes, y una imagen va arriba de todos los eventos (EasyRPG:
`Priority_PictureNew` > `Priority_EventsFlying`). No se comparó con el
original en Wine.

**Cómo verlo**: `just arrancan -k sunset` en la raíz de los ports arma el
release; ir al mapa 2 y mirar el guardia. Las caminatas de las goldens de
`test_pintados.py` se eligieron para que no lo muestren.

Cerca, sin comprobar si es lo mismo: un guardia de capa normal en (36,13)
del mismo mapa tiene las piernas sobre el borde de un techo; puede ser uno
de los bordes que no entran en los 127 (la deuda de
`testing/sunset-en-modo-1-con-color-math.md`).
