---
name: "Una cuantización por personaje para las poses"
description: "Un personaje cuantizado distinto en otro mapa lleva su propio banco de poses: en VD son 420 de 1.239 bancos, y las poses (4,26 MB) no pueden ir al .msu"
type: feature
agents: [Mulita]
assignee: Mulita
---

De `testing/vampires-dawn-arma-desde-su-toml.md` (Aguará, 2026-10-11):
`record.rs` de mapdata guarda un banco de doce poses por (CharSet, índice,
datos), y un personaje que en otro mapa sale cuantizado distinto lleva un
banco propio —506 avisos "goes with a pose bank of its own" en el armado
de VD—. Es lo que más mapas de VD devolvería: los nueve que hoy quedan
afuera por la ROM (95, 164, 170, 219, 221, 222, 239, 338, 429), y lugar
para los que vuelvan con los otros arreglos. Cuánto ahorra no se midió;
del orden del MB por cuenta gruesa.
