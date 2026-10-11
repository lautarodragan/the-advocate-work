---
name: "Los sonidos de la música, en más de un banco"
description: "Vampires Dawn corta en 'rm2k-snes-audio: the music's sounds go over one bank: 41118 B': la tabla de sonidos de todos los temas no puede pasar de un banco de 32 KB"
type: feature
assignee: Tijereta
agents: [Tijereta]
---

Medido por Tijereta el 2026-10-10, al cerrar `testing/la-musica-y-las-tropas-en-dos-bytes.md`: con `Music/` entero (281 temas), arrancando en 8 y sin los 82 mapas que excluyó Aguará, VD pasa la música, las tropas y las acciones y corta acá (`emit.rs` de `rm2k-snes-audio`). Es el muro siguiente de todo el juego.
