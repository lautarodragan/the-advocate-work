---
name: "The book says the console's font is ASCII"
description: "El Dorado's and Sunset over Imdahl's pages still say the console's font is ASCII, and the divergence says the menu draws ASCII; the boxes draw Latin-1 since 2026-10-16, and what the screens draw when building always did"
type: docs
game: [el-dorado, sunset-over-imdahl]
status: done
author: aguara
agents: [Calandria]
---

Seen by Aguará on 2026-11-22, in
[`the-text-screens-draw-latin-1`](the-text-screens-draw-latin-1.md), with
the book at its `main` of that day, the-advocate at `1b8825d8` and the
ports at `544f9bc`.

**What it says**:

* `src/ports/el-dorado/README.md`, lines 68-69: "And the German text: the
  console's font is ASCII; a font with Latin-1 is drawing work."
* `src/ports/sunset-over-imdahl/README.md`, lines 177-178: "the `ô`. The
  console's font is ASCII; a font with Latin-1 is drawing work."
* `src/divergences/letters-the-font-does-not-have.md`, "The text screens
  show the stand-ins: the menu, the shops, the battle, the slot screen
  […] draw ASCII".

**What is so**: since 2026-10-16 the message boxes draw the Latin-1 their
game uses: El Dorado's boxes carry `ä`, and Sunset's `ä` and `ô`
(`MESSAGE_PAIR_FIRST` 97 and 98 in their release builds); Sunset's `…`
is still `...`. And what the screens stage draws when building —End
Game's question and options, the title's options, the menu's commands,
the windows' terms, the slot screen's header— draws the database's text
with the game's font, Latin-1 included: `rm2k-snes-screens render` of
Zounds' End Game draws `¿Deseas salir?` and `Sí`. What the cartridge
composes at run time —names, items, skills, the battle's lines— is what
shows the stand-ins.

## Log

### 2026-11-22, Calandria: fixed in the book

Folded into [`the-text-screens-draw-latin-1`](the-text-screens-draw-latin-1.md):
El Dorado's and Sunset's pages say what is drawn since 2026-10-16, and the
divergence says what the text screens draw since that task's stage 1.
Book branch `calandria-latin1`.
