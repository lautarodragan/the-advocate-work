---
name: "A 2003 game's battle commands are its own"
description: "Zounds' battle menu shows the 2000 terms command_attack and command_defend, left as the editor's Japanese defaults —garbled as \"?UOE'\" and \"-hOEa\"—; an RPG Maker 2003 game names its commands in the database's battle commands: Atacar, Técnica, Defender, Objeto, Escapar"
type: bug
status: doing
assignee: Cardón
agents: [Cardón]
---

taro, on 2026-10-20, in their words, translated, with two captures
(copied to `/shared/captures/2026-10-20-zounds-battle-commands/`):

> A couple more bugs: some options of the battle menu look wrong. I
> think the first should say "Atacar", and maybe the third "Defender".

**Read in the dump** (Hornero): the menu shows "?UOE'", "Habilidad",
"-hOEa", "Objeto", "Huir". Those are the 2000 terms `command_attack`,
`command_skill`, `command_defend`, `command_item` and `battle_escape`;
Zounds' `command_attack` and `command_defend` are still the editor's
Japanese defaults, because RPG Maker 2003's battle never shows them: it
names its commands from the database's battle commands
(`db/battlecommands.json`): 1 "Atacar" (attack), 2 "Técnica" (skill),
3 "Defender" (defend), 4 "Objeto" (item), 5 "Escapar" (escape), and the
game's own 6 "Robar", 7 "Juglarismo", 8 "Tirar-Usar".

**Done**: a 2003 game's command window takes each command's name from
its battle commands by type —attack, skill, defend, item, escape—, in
the tools for every 2003 game rather than as a Zounds knob; Zounds shows
Atacar, Técnica, Defender, Objeto, Escapar. A golden of the window red
before. The game's own commands (Robar, Juglarismo, Tirar-Usar) are a
separate question: say what RM2k 2003 does with them per actor and
leave a draft if they don't fit the 2000 battle.

taro, the same day, on Zounds' own command 8 (translated):

> In the case of "Tirar-Usar", I think it's Kazar's custom option that
> lets you throw stones and other things in battle, and I think it
> replaces the normal "Use Items".

## What the database says (Cardón)

Each 2003 actor carries its own list in `battle_commands` —ids into
`db/battlecommands.json`, `0` the row command and `-1` an empty slot—,
and a class carries one too, which `ChangeClass` copies; easyrpg's
`Game_Actor::GetBattleCommands` skips the `0` and the `-1` and
`Scene_Battle_Rpg2k3::GetBattleCommandNames` writes each one's `name`.
Zounds' (`battle_type` 2, gauge):

* Unamë: Atacar, Técnica, Objeto, Defender, Escapar (9), row.
* Kazar: Atacar, Técnica, **Tirar-Usar** (8), Defender, Escapar (9), row.
* Bandurion: Atacar, Técnica, Objeto, Defender, row —no escape—.

So taro is right: Kazar's item command is 8, "Tirar-Usar", of type item
(4), in place of 4 "Objeto". Being of type item it does exactly what
"Objeto" does —`Type_item` opens the same item window, in easyrpg—: it
differs only in its name.

The escape: Zounds' actors do not carry 5 "Escapar" (type escape) but 9
"Escapar", of type **special** (6), which by itself does nothing
—`SpecialSelected` is `DoNothing`— and is the trigger of the troops'
pages with the `command_actor` condition: every troop has one per actor
that adds 1 to variable 186, writes "Escapando... \v[186]/\v[187]" and,
when it reaches \v[187], does `ForceFlee`. Zounds escapes by insisting,
with its own counter. The 2000 term `battle_escape`, "Huir", is what the
2003 battle writes in the party's window —Luchar, Auto, Huir—, which the
gauge battle opens with cancel.

6 "Robar" and 7 "Juglarismo" are of type subskill (2) —a command that
lists the skills of its own set—, but no actor or class of Zounds carries
them, no event changes battle commands (`ChangeBattleCommands`, 1009, is
not in the game) and no skill belongs to a subskill set (none has a
`type` of 4 or more): they are leftovers in the database the game never
shows.

Zounds is the only 2003 game among the ports.
