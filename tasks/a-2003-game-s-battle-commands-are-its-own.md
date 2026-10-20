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
