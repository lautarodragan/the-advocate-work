---
name: "BOOT_FRAMES por cartucho"
description: "El mapa de arranque de Vampires Dawn pide 46 cuadros de BOOT_FRAMES y la ROM tiene 44, una constante: que cada cartucho lleve el suyo sin mover a ABL"
type: feature
assignee: Carpintero
agents: [Carpintero]
---

Del re-barrido del 2026-10-10 (`testing/otros-juegos-el-rebarrido.md`): el mapa 3 de VD no entra en `BOOT_FRAMES` (46 de 44). Subir la constante mueve en ABL el cuadro en que arranca el lazo, y con él las pruebas que cuentan cuadros. La propuesta de Tijereta: que el conversor emita el de cada cartucho, `max(44, la estimación)`, así ABL no se mueve.
