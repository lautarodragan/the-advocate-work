---
name: "Troop events"
description: "The characters' 32 battle systems, besides Talan's"
type: feature
status: done
assignee: taro
---

**Running the troops' event pages during battle.**

It's what makes each character's systems work: a switch-type skill
—`Detect Aura`, Talan's— turns on a switch, and the troop pages that look at
it run in battle.

**The mechanism already exists** since 2026-09-21, with Talan's system
(`talan-battle-system.md`): the troop pages are compiled
deduplicated, they run in battle with the same interpreter as the maps, their
messages come out on the battle screen, and a switch-type skill turns on its
switch. What's missing is **completing commands**: what a troop page can do
is an explicit list, `TROPA_COMANDOS` in `tools/port/eventos.py`, and it only
lets through what's known to work in battle.

Measured in the LDB on 2026-09-21:

- 300 troops, 163 with pages, **4287 pages and only 291 distinct** by content
  (the game copies them into each battle);
- **4278 depend only on `switch_a`**; 9 look at the turn or the HP;
- **32 switches** trigger them, one per system, each in 140 to 163 troops.
  Talan's are 134 (`DetectedAura`) and 135 (`AbsorbedAura`);
- `ConditionalBranch_B` is already there: the game uses only 2 of its 6
  types, switch and variable, and they translate to the maps' branches.

What blocks the pages left out, counted by pages when Talan's system was
finished:

- **`ChangePartyMembers`: 2520**, and it's by far what blocks the most;
- `PlaySound` 280, `ChangeCondition` 140, `PlayBGM` 140, `ChangeHP` 129 —in
  battle it has to write the battle HP and not `FAR_HP`—, `ChangeMonsterHP` 24;
- the conditions on turn, enemy HP and actor HP: 173 pages;
- the **equip** form of `ChangeEquipment`, which doesn't compile: only the
  one that removes a slot is there.

**And space is going to run out before commands do**: the whole game's troop
pages are some 48 KB between code and messages, and they don't fit anywhere.
Today they go in bank 1, which in the big cartridges was left with some
8.8 KB free. It calls for compressing, the block arrangement, or bringing
them through MSU-1.

Reference: EasyRPG's `Game_Battle::UpdateEvents` and `Game_Interpreter_Battle`.

**What `tasks/*/eventos-de-tropa-de-release.md` already did** (2026-09-28),
which is what's noticeable in `release`'s battles: the conditions on turn,
enemy HP and actor HP —all three, with their numbers in a header before the
page's code and not in bank 1 tables—, the hidden enemies with
`ShowHiddenMonster`, and `PlaySound` and `ShakeScreen` in the page. What
remains belongs to the systems: `ChangePartyMembers` is still by far what
blocks the most, and then `ChangeHP` and `ChangeMonsterHP` on the battle HP,
`ChangeCondition`, `ChangeMonsterCondition`, `ChangeEquipment` to equip,
`PlayBGM` and `FlashScreen`. **And the audio**: a page's `PlaySound` is
requested but its effect doesn't go into the battle package unless it's in
`SE_DE_TROPA_AL_PAQUETE`, because the package already limits samples; the
systems have effects of their own and are going to clash with that.

# Status

2026-09-30, in `testing/`: done by Yarará in their branch, on `main` at
1a82726 and with `main` merged at 3afc819. Commits: a23eedf (the per-page
tables to RODATA, **the space decision taro has to look at**), 9a5fcb0 (the
systems) and e23bd8f (`Play Radio`). 30 of the 32 systems work; what remains
is taro's: the space decision, the one on the radio's music, the one on
common event 35, and playing it (see below).

**On merging, install** `just -f tools/justfile install events battle`: they're
the two Rust projects that changed. The runtime and the Python don't need
anything —no `.py` was renamed or added—. `tools/snes/protocol/events.toml`
adds two opcodes and the generated files are already in the commits.

**No golden moved**, and `test_musica_techos.py` passed.

# What was measured at the start (2026-09-30, on 1a82726)

With a throwaway script over `rom/data/db/troops.json` and the list of
`TROOP_COMMANDS` in `tools/rm2k-snes/events/src/troops.rs` (the battle
branches count like the map ones). It counts pages with some trigger.

**The whole game**: 4451 pages, 1355 fit by their commands. **The 69 troops
of `release`**: 1671 pages, 532 fit —the same as `conversor.log` says:
"troop pages: 532 of 1671 in 124 distinct body(ies), 8863 B of code and 9121
B in 162 message(s)"—.

What blocks, in `release` (pages that use it; in parentheses, the ones only
it blocks):

    ChangePartyMembers       918 (918)   the 18 summons, 814 to 831
    ChangeHP                 203
    ChangeMonsterHP          152
    ChangeCondition          102
    ChangeMonsterCondition    69  (18)
    ChangeMonsterMP           51
    FlashScreen               51
    PlayBGM                   51
    ChangeEquipment           51

By system (switch A), in `release`: **9 of 32** work in full —134, 135, 138,
141, 143, 144, 146, 813 and 860—, 803 works in 33 of its 51 pages and 801 in
1. What blocks each of the others:

    799 Inscribe          ChangeMonsterCondition, ChangeMonsterMP,
                          FlashScreen, ChangeMonsterHP, ChangeCondition,
                          ChangeHP
    801 LifeForStrength   ChangeHP (subtract, lethal) and ChangeMonsterHP;
                          and the ControlVars with an actor's HP, which
                          doesn't compile
    802 Sacrifice         ChangeCondition (remove death) and ChangeHP
    803 ControlMachines   ChangeMonsterCondition (18 of 51)
    809 Play Radio        PlayBGM, ChangeEquipment to equip, ChangeHP,
                          ChangeMonsterHP
    814-831 summons       ChangePartyMembers (remove Emily, 26, and add the
                          summon, 36 to 53)

The forms they use, from the whole LDB: `ChangeMonsterHP` always subtracting
a constant and lethal, on enemy 0, 1 or 2; `ChangeMonsterMP` subtracting 40;
`ChangeMonsterCondition` with states 22 (Control) and 23 (BarkWall), which
battle doesn't have; `ChangeCondition` always "remove state 1 from the
party", which is reviving; `ChangeHP` adding to the party or to Emily, or
subtracting 999 from Talan, lethal.

**The space**, `just espacio` over the base's cartridges:

    release        data banks 115 of 124, 9 free; gaps 8,799 B;
                   bank 0 50 B; bank 1 3,126 B
    test-special   bank 0 943 B; bank 1 5,630 B
    encounter-...  bank 0 1,003 B; bank 1 5,901 B

What the task said about space is no longer so: **the pages' code and
messages haven't been in bank 1 since 2026-09-27**, they're in RODATA, where
nine banks are to spare. What's still in bank 1 is **the per-page tables**
—`tpage_flags`, `tpage_sw_a` and `tpage_code`—, five bytes per page: with
today's 532 that's 2,660 B, and with the 1671 it would be 8,355 B, which
don't fit in the 3,126 left. Just the summons' 918 are 4,590 B.

# What was done (2026-09-30, Yarará)

**The space**: the per-page tables went to RODATA with the code and the
messages (a23eedf). **It's a space decision nobody asked for** and taro has
to look at it: it's the 2026-09-27 criterion (8d6757e) applied to what was
left. Without it, the summons' 918 pages didn't fit in `release`'s bank 1.
It reverts on its own, and then what's below doesn't fit.

**The mechanism**: a troop page runs with the map's opcodes, and the party
ones —`ChangePartyMembers`, `ChangeHP`, `FullHeal`, the `ChangeCondition`
that revives, `ControlVars` with an actor's HP— touch `party` and `FAR_HP`.
So each stretch of a page goes through `ba_sync_out` —the battle HP and SP
to `FAR_HP`/`FAR_SP`— and `ba_sync_in` —back, and the party: the one who left
leaves their place empty, the one who joined goes to the first empty one,
from `ba_actor_setup`, what `ba_build` does for one actor—. See
`battle_troop.s`. What that doesn't do like RM2k is in
`divergencias/lo-que-las-paginas-de-tropa-no-modelan.md`.

**The commands**, with their test in `rom/pruebas/rpgmaker/test_sistemas_de_tropa.py`:

    ChangePartyMembers     the map's opcode, OP_PARTY
    subtracting ChangeHP   OP_ACTOR (new, 0x36), with its bits: subtract,
                           lethal, by variable
    ChangeCondition        removing death is OP_ACTOR with ACT_REVIVE
    ChangeSP               OP_ACTOR with ACT_SP (no troop uses it: it's
                           for common event 35, see below)
    actor ControlVars      class 5 of OP_VAR: HP, SP and their maximums
    ChangeMonsterHP and MP OP_ENEMY (new, 0x37)
    FullHeal               already worked on the map; fits for the same
                           reason
    ChangeEquipment        equip armour, helmet or accessory on an actor:
                           OP_ACTOR with ACT_EQUIP, and battle takes the
                           new parameters in `ba_reparam`
    PlayBGM                accepted and not done (see below)

OP_ACTOR, `ChangeSP` and the `ChangeHP` by variable are also tested on the
map: `rom/pruebas/rpgmaker/test_curar.py`, with the `curar-restar` case.

`ChangeMonsterMP` compiles and the ROM does it, but **no test runs it**: only
799 uses it, which is still blocked by `ChangeMonsterCondition`.

The battle model (`rm2k-snes-battle`) runs the same thing in the pages: who
joins and leaves, the party's and the enemy's HP, `ControlVars` and the
branches by variable. A switch skill now turns on its switch for the pages
(`lit_by_skills`), without changing the answer's `state`: the 400 hashes of
`tests/model.rs` stay the same, measured.

**How many systems work in `release`**: 30 of 32 —the 9 from before, 801,
802, the 18 summons and 809, `Play Radio`, without its music—; 803 in 33 of
its 51 pages. Blocked are 799 (`Inscribe`) and the rest of 803
(`ControlMachines`), both because of `ChangeMonsterCondition`: battle has no
states, and doing them is a whole system —duration, restrictions, what
BarkWall (23) and Control (22) do—. 799 also asks for `FlashScreen` in
battle, which today tints the map's palette and not the scene's. "troop
pages: 1602 of 1671 in 149 distinct body(ies), 9941 B of code and 9515 B in
172 message(s)". In the whole game 4285 of the 4451 pages fit.

**`Play Radio`'s music doesn't play**: a troop page's `PlayBGM` is accepted
and not done, because its theme would go into the battle package and lower
the battle theme's rate —the same rule that leaves out the pages' effects—
and none of the three has an MSU-1 track. It's an audio decision for taro;
it's in `divergencias/lo-que-las-paginas-de-tropa-no-modelan.md`.

**The space afterwards** (`just espacio`, `release`): bank 0 **13 B** (from
50), bank 1 5,054 B (from 3,126, with the tables out), data banks 116 of 124
and 8 free. Bank 0 is eaten by the two opcode entries (9 B each), the actor
`ControlVars` one (10 B) and the new cases. **It's the next limit**: the
`Play Radio` test wanted Emily in the case's party, and that makes her a
cartridge actor with her items and her level in bank 0 tables —measured,
15 B against 13—, so the test leaves her out. The next thing that adds an
actor to the cartridge, or an opcode, doesn't fit without moving something
out of bank 0.

**Numbers used**: opcodes 0x36 (OP_ACTOR) and 0x37 (OP_ENEMY). Far RAM:
`$7E7A2A` (`BA_SYNC_I`), inside what already belonged to the pages
($7A10-$7A3F). Tuples in `test_*_golden.py`: none.

**What's missing in the game to play the summons**: after battle the party
is left with the summon in place of Lerle. In RM2k it's fixed by common event
35, `ResetAfterBattles`, which runs the `AfterBattleMint` autostart of the
maps with encounters; here it doesn't compile —see
`divergencias/llamada-salteada.md`—. Measured with this branch's compiler:
**each of its commands compiles** —what was missing was the actor
`ControlVars`, the `ChangeHP` by variable and `ChangeSP`, which are there
now—, and the whole common event compiles on its own (1,773 bytes) if the
variables it names have a slot. Called from a map, on the other hand, it's
skipped: **the variables only a common event names have no slot**. The
variable sweep goes through the maps and the troops and not the common
events (`indices.rs`), and adding them shifts the other variables' slots,
which is what makes a game saved with one cartridge load in another. It's a
decision for taro; with it, common event 35 runs after every random battle,
which is much more than the summons —it heals the 18, takes the radio away
from Emily, rebuilds Talan's aura skills and AG7's piece skills— and it has
to be measured separately.

# What taro has to test

With a saved game where the party has Lerle, Talan or Emily and their system
skills (it wasn't measured at what point in the game they arrive):

- **One of Lerle's summons** (`Droid`, `Wolf`… 268 to 285): in battle, when
  her action ends, Lerle leaves and the summon appears **on her row**, and
  gives orders from the next turn on. **After the battle it stays in the
  party in place of Lerle**: it's common event 35, see above.
- **Talan's `LifeForStrength` and `Sacrifice`**: with 40 HP or more, Talan
  falls; the first takes 70 off the enemy and the second raises the fallen
  with 1 HP. With less, the message "TALAN does not have enough HP…".
- **Emily's `Play Radio`**, with a tape on: the tape's effect comes out, and
  the music doesn't change.

# Numbers used

- Opcodes: 0x36 (OP_ACTOR) and 0x37 (OP_ENEMY).
- Far RAM: `$7E7A2A`, `BA_SYNC_I`, inside what already belonged to the troop
  pages ($7A10-$7A3F).
- Tuples in `test_*_golden.py`: none.
- New cases: `pelea-invocacion`, `pelea-vida-por-fuerza`,
  `pelea-vida-por-fuerza-sin-hp`, `pelea-sacrificio`, `pelea-radio` and
  `curar-restar`.

# The suites

`just pruebas`: 893 green (882 at the start). `just -f tools/justfile test`:
49. `cargo test -p rm2k-snes-events -p rm2k-snes-battle` green. With
`NO_CACHE=1 just cartuchos` the three ROMs come out identical to with the
cache: `abl.sfc` `e20182d1bd905de7…`, `special` `6784ab8fc7161ab7…`,
`encounter-every-step` `5dc9114cd97ff691…` (before merging 3afc819, which
only moved tasks).
