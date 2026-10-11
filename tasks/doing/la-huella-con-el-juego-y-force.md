---
name: "La huella: los archivos del juego, y --force"
description: "Lo que el conversor lee de GAME_DIR (PNG, MIDI) entra en la huella por contenido; el RTP y el SoundFont, por su ruta; y un --force para rearmar a mano"
type: feature
assignee: Cardón
agents: [Cardón]
---

Sigue de `testing/el-volcado-fuera-de-la-huella.md`: con el ChipSet de Sunset retocado, `just cartuchos` dice "up to date" y la ROM queda vieja.

La decisión de taro, el 2026-10-11: no hashear el RTP ni el SoundFont; a lo sumo invalidar si cambia la ruta, o un `--force` para usar a mano si se modifican (no debería pasar nunca). Barajó un RTP en `.zip` validado por ruta, fecha y tamaño, sin decidirse. Hornero eligió: la ruta del RTP y del SoundFont en la huella, un `--force`, y los archivos del juego que el conversor lee, por contenido —ésos sí cambian si se retoca el juego—. taro puede ajustarlo.

## Cambio de encargo, el 2026-10-11

taro, al rato: "Si lo del zip no sería muy complicado, tal vez pensaría en usar .zip para los juegos también. Eso nos fuerza un poco a no modificarlos, sino siempre usar el sistema de parches." Así que: medir primero si la lectura de assets —juego, después RTP— pasa o puede pasar por un solo lugar; si sí, `GAME_DIR` y `RTP_DIR` como `.zip`, con la huella por el contenido del `.zip` —o ruta, tamaño y fecha, si hashearlo pesa—, el SoundFont por su ruta y `--force`; si no, el plan de arriba y la medición para que taro decida.
