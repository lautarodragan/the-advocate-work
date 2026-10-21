---
name: "A 2003 game's battle commands are its own"
description: "Zounds' battle menu shows the 2000 terms command_attack and command_defend, left as the editor's Japanese defaults —garbled as \"?UOE'\" and \"-hOEa\"—; an RPG Maker 2003 game names its commands in the database's battle commands: Atacar, Técnica, Defender, Objeto, Escapar"
type: bug
status: testing
assignee: taro
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

## Cardón, on 2026-10-20: done

Branches `cardon-2003-commands`: the-advocate `44f5c211` (origin/main
`26bf4b37` merged), the ports `a3f94da` (main merged), the docs `babb2b9`
(main merged).

* `command_names`, in `rm2k-snes/battle/src/rules.rs`, names the console's
  five commands per actor: a 2000 game with its terms and the actor's
  `skill_name`, as before; a 2003 one with the first command of the
  actor's own list of each type, then the database's first of that type,
  then the 2000 term. The model answers them in `texts.commands`; the
  converter emits `actor_command_txt`, five words per actor, which
  replaces `ba_command_txt` and `actor_skill_txt` in
  `runtime/battle_skills.s`. A command that says what a text the
  cartridge already has points to it, so a 2000 game adds no text and
  keeps every number; `use` and `skill` joined `FROM_THE_MODEL`, so
  `[battle.terms]` cannot give `command_item` or `command_skill` (no
  project did).
* Zounds shows Unamë: Atacar, Tecnica, Defender, Objeto, Escapar; Kazar:
  the same with Tirar-Usar. The escape is named by the database's
  command 5, "Escapar", which is also the name of the game's own command
  9. "Huir" is what RPG Maker 2003 writes in the party's window.
* Tests: `rm2k-snes/battle/tests/command_names.rs`; the ports'
  `tests/test_zounds_battle_commands.py` with the case `battle-commands`
  and the goldens `zounds-battle-commands-uname` and `-kazar`, red with
  the tools of 5971f850 (Unamë's, 785 pixels). Captures, before, after and
  the difference, in `/shared/captures/2026-10-20-zounds-battle-commands/`.
* Book: the divergence "A 2003 game's battle commands", Zounds' page and a
  known issue for the order; the draft
  [`a-2003-actor-s-command-window-is-the-2000-one`](a-2003-actor-s-command-window-is-the-2000-one.md)
  holds what does not fit: the actor's order and presence, the row and
  subskill commands, the special Escapar, a list changed while playing.

What was run, with the branch's tools first in the PATH: `just test`,
`just rust-test`, `just lint` green on the merged tree. ABL's suite: 9
red, 8 of them red with the tools of 5971f850 too —save, title-slots and
the slot screen's menu goldens, delcentric pump 83, the rain's sound—, and
`test_menu_custom_ways_in[1-bsnes]` green on a rerun. `just boot`: 3 red,
all red with the tools of 5971f850 too —`test_zounds_skill_screen` twice
and the record player in `test_zounds_common_pictures`—. ABL's `abl.sfc`
is not byte for byte the same (the runtime's code and table changed);
its goldens are. `just space`: bank 0 and bank 1 the same as before on
every cartridge of ABL and Zounds.

What the suite does not cover: no 2000 game has commands named per actor
beyond the skill one; the Zounds test plays one battle with two actors.

To install when merging: `battle`, `mapdata` and everything that carries
the runtime —`project`, `cartridge`, `convert`—.
