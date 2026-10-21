---
name: "A 2003 actor's command window is the 2000 one"
description: "Since 2026-10-20 a 2003 game's battle commands carry the names of each actor's own list, but the window is still the 2000 battle's five in its order: not the actor's order, not its presence, no row or subskill commands, and a special escape stood in for by the 2000 one"
type: feature
status: draft
---

Seen by Cardón on 2026-10-20, doing
[`a-2003-game-s-battle-commands-are-its-own`](a-2003-game-s-battle-commands-are-its-own.md),
with the-advocate `cardon-2003-commands` (from `5971f850`), in Zounds'
`release` in snes9x —case `battle-commands` of the ports' `zounds/cases`,
which opens a battle with Unamë and Kazar against troop 23—.

**What is seen**: each actor's window reads Atacar, Tecnica, Defender,
Objeto (Kazar: Tirar-Usar), Escapar —the names are the game's since that
day—. In RPG Maker 2003 the window is each actor's list, in its order,
read by easyrpg's `Game_Actor::GetBattleCommands`:

* Unamë and Kazar carry the item command **before** Defender: Atacar,
  Técnica, Objeto / Tirar-Usar, Defender, Escapar.
* Bandurion carries no escape command: Atacar, Técnica, Objeto, Defender.
* The `0` that ends their lists is the row command (`terms.row`,
  "Posición"); easyrpg does not show it, and RPG_RT was not checked.
* Their Escapar is command 9, of type **special**: it does nothing by
  itself, and every troop has a page per actor conditioned on it
  (`command_actor`) that adds 1 to variable 186, writes "Escapando...
  \v[186]/\v[187]" and does `ForceFlee` when it reaches \v[187] —between
  1 and 5 depending on the troop—. Here the console's escape stands in,
  with RPG Maker 2000's chance of failing, and those pages never run: see
  [`the-2003-battle-commands-callcommonevent-and-forceflee`](the-2003-battle-commands-callcommonevent-and-forceflee.md).
* A **subskill** command —Zounds' "Robar" and "Juglarismo", type 2—
  would list only the skills of its set; no actor or class of Zounds
  carries one, and no skill belongs to a set.
* `ChangeClass` and `ChangeBattleCommands` change an actor's list while
  playing; the console's names are fixed when the cartridge is built.
  Zounds uses neither.

The book's divergence:
[A 2003 game's battle commands](https://github.com/lautarodragan/the-advocate-docs/blob/main/src/divergences/a-2003-game-s-battle-commands.md).
