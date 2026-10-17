---
name: "Ditto does not read the 2003 fields"
description: "118 of liblcf's 1,043 field rows are RM2k3-only and Ditto's generator skips them: classes, battle commands, battler animations, System2, the 2003 terms and terrains land in `unknown` as raw bytes; reading them is the generator's flag plus the flag-width question"
type: feature
status: done
assignee: taro
agents: [Aguará]
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39` and liblcf `6854310`.

**What is there**: the generator (`rm2k/ditto/xtask/src/main.rs`) has
`is_2k3` per row and `continue`s on it. The structs whose rows are *not*
flagged already exist in the schema —`Class`, `BattleCommand`,
`BattleCommands`—; what is missing is the six `Database` chunks that hold
them (`0x1b`–`0x20`: `battlecommands`, `classes`, `battleranimations` and
three empty blocks), the four `BattlerAnimation*` structs (every row
flagged), and the per-record fields: `Actor.class_id/battle_commands/
battler_animation`, `Item.animation_data`, `Skill.battler_animation*`,
`State.affect_type`, `System.system2_name/menu_commands`, the five 2003
`Terms`, `Terrain`'s 23 side-view fields, `TroopPageCondition.command_*`.
In Zounds all of them are present and hold data.

**What it costs**: dropping the `continue` regenerates the lot; a 2000
game's dump does not change (the fields hold their defaults and are left
out). The one real question is the flags: a 2003 file packs the 2003 bits
into the same chunk, so the codec has to know the file's version
(`System.ldb_id`, or liblcf's `is2k3` switch) to read and write
`TroopPageCondition.flags` as 2 bytes —see
[`ditto-drops-the-2003-flag-bits`](ditto-drops-the-2003-flag-bits.md)—.
The consumers in `rm2k-snes/` read the resolved view by field and would
not notice new ones.

## Aguará, on 2026-10-15: done

the-advocate `f818d7e9` and `4700cdef` (the README), on the branch
`aguara-zounds-2003`. Every `Is2k3` row is generated; what the version
changes is on the writing side and is listed on `Writer::is2k3` in Ditto's
`src/lcf.rs` and in point 5 of its README: the flags' width, the 2003
fields kept out of a 2000 database and the persisting ones always in a
2003 one, `Actor`'s three `a|b` defaults, `Database.version`. Two liblcf
behaviours are not followed, measured against Zounds' file (RM2k3 1.08):
`Terms` 0x01/0x03 are persisted in 2003 too, and `Terms` 0x26/0x27 are
not. Zounds' dump has no `unknown` chunk left; the exact dump of ABL does
not change by a byte, its resolved view gains the new fields. The actors'
`final_level` in Zounds now reads 99 —the 2003 default—, which the study
read as 50.

**To install when merging**: `just install ditto events convert cartridge
rm2k-snes-audio` —Ditto for this; the other four because the branch also
touches `bytecode`, which is compiled into them—. Then `just dump` in a
port adds the 2003 fields to its `data/`, with their defaults: a one-time
diff per game, which nothing requires.
