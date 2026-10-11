---
name: "Los otros juegos arman y arrancan"
description: "Una receta que arme los siete juegos desde su toml y los arranque hasta el primer mapa, en snes9x y bsnes; y unas goldens de los mapas pintados de Sunset, el único camino del motor que ninguna prueba ejecuta"
type: feature
agents: [Cardón]
assignee: Cardón
---

taro, el 2026-10-11, aprobó la propuesta: pruebas de los otros juegos,
pero pocas.

1. **Que cada juego arme desde su `rm2k-snes.toml` y arranque.** Hoy un
   cambio en las herramientas puede romper Vampires Dawn o Book of Three
   y nadie se entera hasta el próximo relevamiento. Rojo si no arma o si
   no llega al primer mapa; de paso, el mismo cartucho en snes9x y bsnes
   (memoria sin inicializar en código que ABL no ejecuta). No va en
   `just pruebas` de ABL —VD sola tarda ~2 min en armar—: es una receta
   aparte, para antes de entregar o después de un cambio grande.
2. **Goldens de los mapas pintados de Sunset** (`[graphics]
   painted_maps`, `Way::Painted`): la plaza (2) y el bar (28), quieto y
   caminando. ABL no tiene mapas pintados.

Lo que **no**: goldens de pantallas o recorridos de cada juego (hornean
errores de nacimiento y multiplican lo que hay que mirar), ni pruebas de
mecanismos con un juego de escenario (eso es de los crates o del juego
de pruebas, fase 2).
