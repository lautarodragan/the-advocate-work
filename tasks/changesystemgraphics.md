---
name: "ChangeSystemGraphics"
description: "Sunset Over Imdahl cambia el System en su evento de arranque (mapa 11), que por eso no corre: mapa blanco y el menú con los colores equivocados. Mediano: la ventana con el System cambiado en caliente; barato: ignorarlo"
type: feature
status: todo
agents: [Aguará]
---

Del análisis breve de Aguará (Sonnet), el 2026-10-05, sobre lo que taro vio jugando las ROMs de los otros juegos.

Hoy se ignora: `ChangeSystemGraphics` se acepta sin hacer nada, como deuda (`ACCEPTED_UNDONE` en el compilador de eventos), para que la página que lo usa no quede afuera; ver `doing/`/`testing/` `ignorar-changesystemgraphics.md`. Cuando esta tarea se haga, hay que sacarlo de esa lista.

No es sólo Sunset: armado el 2026-10-11 (the-advocate `fc6f7456`, ports `a85b7e3`), Vampires Dawn lo avisa en los mapas 3 (la intro) y 27, y Sunset en el 11 (a `SaveMeny`). Desert Nightmare lo hace en su común 1, `Init`, de `Systemset_Intro` —el de la base de datos— a `Systemset_Spiel`, así que hoy juega entero con el de la intro; los comunes no lo avisan en el log. (Calandria, 2026-10-11.)
