---
name: "El lugar de la tropa en dos bytes"
description: "BA_TROOP_K es un byte: un cartucho con más de 255 tropas usadas no arma (VD pide 277); pasarlo a dos bytes, para cualquier juego"
type: feature
agents: [Hurón]
assignee: Hurón
---

De `testing/vampires-dawn-arma-desde-su-toml.md` (Aguará, 2026-10-11):
"277 troops of 255, 554 members" corta el cartucho entero de VD, no un
mapa. El chequeo es `used.len() > 255` en `emit.rs` de mapdata; el
2026-10-10 (406fc5e0) pasó a palabra sólo el comienzo de los miembros.
Hoy VD deja afuera 98, 182, 327 y 339 sólo por esto.
