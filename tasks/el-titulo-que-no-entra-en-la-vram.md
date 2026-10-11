---
name: "El título que no entra en la VRAM"
description: "Desert Nightmare, The Frozen World y Vampires Dawn arrancan sin su pantalla de título: la imagen pasa de los 544 tiles que title.s le deja"
type: feature
status: draft
---

Lo declaró Carpintero el 2026-10-06 como degradación
(`testing/degradar-en-vez-de-fallar.md`, punto 5): el conversor chequea el
título contra los límites que `title.s` afirma —544 tiles de imagen, 704
del menú— y, si no entra, el juego arranca sin título, con un WARNING. No
hay tarea que lo siga.

**Comprobado hoy** (the-advocate `fc6f7456`, ports `a85b7e3`, armados en un
worktree propio), del `conversor.log` de cada release:

| juego | imagen | tiles de imagen |
|---|---|---|
| Desert Nightmare | `Titelbild` | 872 de 544 |
| The Frozen World | `FrozenWorldTitle` | 736 de 544 |
| Vampires Dawn | (su título) | 896 de 544 |

Book of Three (425), El Dorado (206) y Dooms 2 (282) entran. Sunset no se
armó hoy.

**Qué se ve jugando**: el juego arranca directo en su primer mapa, sin la
pantalla de título ni su menú de Nueva partida / Continuar / Salir. Cómo
se carga una partida guardada en esos cartuchos no se miró.

**Cómo verlo**: `just cartuchos release` en el directorio del juego y
`grep "title screen" build/release/conversor.log`.
