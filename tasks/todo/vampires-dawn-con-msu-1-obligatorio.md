---
name: "Vampires Dawn con MSU-1 obligatorio"
description: "VD no entra en los 127 bancos ni con lo razonable comprimido (faltan ~1 MB con las poses en LZ2, más sin ellas): que un proyecto pueda pedir el MSU-1 obligatorio y lleve al .msu lo que no entra"
type: feature
agents: [Hornero]
---

Sigue de `testing/vampires-dawn-entra-comprimido.md`, donde Tijereta midió todo: las poses en LZ2 son lo único que rinde en serio (−2,86 MB) y le cuestan a ABL cuadros —ocho rojas por CPU—; con ellas VD queda en 8,91 MB contra 7,94, y lo demás suma a lo sumo ~0,84 MB. El experimento está en las ramas locales `tijereta-vd-comprimido` de the-advocate y de los ports, sin mergear.

La decisión de taro, el 2026-10-11: antes que dos cartuchos, el MSU-1 obligatorio **para este juego**; ABL y los demás siguen jugables sin él ([[sin-msu-jugable]] en la memoria). Un chip de compresión no, mientras el MSU-1 siga siendo opcional en general.

Ya hay un camino: los fondos de batalla viajan en el `.msu` y la ROM los lee si encuentra su firma (`internals/msu-datos.md` del libro). Lo que haría falta: una perilla del proyecto que lo pida obligatorio, el reparto de qué va a la ROM y qué al `.msu` —las poses, que se suben en caliente, piden mirar cuánto tarda el MSU-1 en entregarlas—, y una pantalla que diga que falta el MSU-1 si no está. Tijereta anotó una opción sin CPU que no probó: las poses sin sus tiles en cero, por DMA directo en el vblank (−2,44 MB en VD), que achicaría lo que tenga que ir al `.msu`.

## Lo que pidió taro al confirmarlo, el 2026-10-11

"Vamos con el msu, pero dejemos el código del runtime y las herramientas lo más genérico posible, siempre apuntando a que todos los juegos tengan msu opcional." O sea: nada que sea "el modo de VD"; el mecanismo —qué datos pueden viajar en el `.msu` y cómo los lee la ROM— es el mismo para todos, y lo obligatorio es sólo que a un juego no le alcance la ROM sin él. La meta de fondo sigue siendo que cada juego entre sin MSU-1.
