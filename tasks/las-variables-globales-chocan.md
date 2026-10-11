---
name: "Global variables collide"
description: "Two branches that add a variable at the end of pagina_cero.s, ram_baja.s or ram_lejana.s always collide"
type: refactor
status: todo
---

The `main.s` split spread the code out by subsystem, but memory is still
declared in three global files: `rom/src/pagina_cero.s`, `ram_baja.s` and
`ram_lejana.s`. Two branches that each add a variable add it at the end of
the same file, and they collide there even if they work on subsystems that
have nothing to do with each other. Seen by the split's critic, on 2026-09-25.

To investigate before deciding:

* whether each subsystem can declare its variables in its own file with
  `.segment "BSS"` / `"ZEROPAGE"` and go back to its own —the order in RAM
  changes, and that changes the ROM and the `.sym` files: measure which tests
  notice—;
* which variables have to stay together or in a fixed order (those cleared
  as a block, those saved in the save file —`partida_tabla`—, those the
  symbol table exports to the tests by name);
* whether something cheaper is enough, like leaving padding lines per
  subsystem or an alphabetical order that spreads the additions.

And far RAM has a trap of its own, which `AGENTS.md` names in
"Sub-agentes": its addresses are chosen "the next free one", so two
branches can choose the same one without git seeing it. Whatever is decided
here should close that too.
