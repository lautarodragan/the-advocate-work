---
name: "Una pelea con el grupo vacío"
description: "RM2k pierde enseguida una pelea sin nadie en el grupo; qué hace la ROM no se miró, y los ocho ports arrancan con el grupo de la base de datos, que en varios es nadie"
type: test
status: draft
---

Lo dejó Mulita el 2026-10-10 en "Lo que no cubre" de
`el-grupo-vacio-al-empezar.md`: "Una pelea con el grupo vacío.
RM2k la pierde enseguida (`Game_Battle::CheckLose` sin nadie que pueda
actuar); el runtime no se miró ni se probó." Lo demás del grupo vacío
—no dibujarse, caminar, el menú, guardar y cargar— sí lo cubre
`test_grupo_vacio.py` de ABL, en `test-special`.

Por qué vale una prueba y no sólo jugarlo: desde esa tarea ningún port
lleva la muleta `party = [1]` (los ocho `rm2k-snes.toml` dicen `party =
[]`, ports `a85b7e3`), y RM2k deja que el héroe invisible camine, toque
eventos y entre en encuentros al azar. Una pelea con cero actores es un
camino del runtime (los recorridos de `party_n` en `battle.s` y
`battle_troop.s`) que nada ejecuta hoy.

**Cómo verlo**: el caso del grupo vacío de ABL (mapa 5, en (39,34), el de
`pelea-82-grupo-11-12`) con un `EnterBattle` o un encuentro antes de que
entre nadie, comparado con lo que hace el original en Wine.
