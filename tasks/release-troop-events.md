---
name: "Release's troop events"
description: "The troop pages that release's battles ask for: the Rat King who calls his rats, the take-off in the agents' battle, and the turn and HP conditions"
type: feature
status: done
assignee: taro
---

# What

The part of `troop-events.md` that's noticeable **in the battles
`release` can fight today**, which is what taro asked for on 2026-09-28 with
two cases from the first big milestone:

> - the battle with Rat King isn't like the original. in our version, he appears
>   with two rats from the start. in the original, rat king summons rats every
>   so often.
> - the events of the battle with the 2 agents: in the first turns the
>   text "the hover tran is taking off" appears and I think it comes with a
>   sound effect
> - I don't know if there are more things currently tied to battle events

The 32 character systems remain in the big one.

# Status

2026-09-28, in `testing/`: done by Ceibo in his branch, on `main` at
40f4011, in two commits —d2d820a (the autorun that compiles to nothing) and
208c828 (the rest)—; `just cartuchos` and `just pruebas` green. What's left
is taro's: play it (see below) and decide on the thunder.

# The inventory

Measured with a throwaway script over `data/db/troops.json`, the maps in
`cartuchos.MAPAS_DEL_JUEGO` —their `EnemyEncounter`s and the tree's encounters— and
the built `release`'s `tropa_id`: **69 troops**. Seventeen of those are only
asked for by the test pages (159, 161, 219-227, 232-236); the rest, by the game.

The rule for when each page runs is easyrpg's and was already in the ROM
(`ba_pag_probar`): before asking for orders, before each action and after
the last, the first one whose conditions are met and that hasn't run this turn.

    troop             in RM2k                          the ROM before   now
    97 Rat King       starts alone; calls one rat      all three from   same as
    (map 26)          with the king at 60% and the      the start,       RM2k
                      other at 30%, with its message    no messages
    102/104 agents    turn 1: thunder, shake and       nothing          shake and
    (map 32)          "The Captain has taken off in                     message; the
                      the ship!"; 104 also brings                       thunder doesn't
                      a hidden guard who calls at                       sound (see
                      30%                                               below)
    86 Lazer Teeth    "It's not too late to            nothing          same as
    (map 9)           surrender!" every 3 turns with                    RM2k, with
                      Talan at 50%; "Give up!" every                    Talan in the
                      2 with Talan at 30%                               party
    all 69            turn 0: turns on 498, which      nothing          turns it on
                      after the battle runs                             (the common
                      common event 35                                   event doesn't run)

## What already ran

The `switch_a` pages with commands from `TROPA_COMANDOS`: Arden's betting
(138), Saldra's and Arden's stealing (141, 146), MindBlast and MindProbe (143, 144
in 82), Detect Aura and Absorb Aura (134, 135) and ObtainEnemySouls (860).

## What didn't run because of a missing condition or command

**Turn 0, in all 69.** Each troop in the game carries a "turn 0" page
—base 0, no multiple— that turns on switch 498, `TheAfterBattleMint:)`. In
the maps with encounters an autorun event with that switch calls common event 35,
`ResetAfterBattles`: it heals actors 36 to 53 —the summons—, removes them from
the party, restores to AG7 the skills of his parts and turns off 498. Troops
102 and 104 carry another that turns on 461, `InFight,NeedReset`, which no
`release` map looks at.

**The Rat King (97, map 26's `EnemyEncounter`).** It isn't per turn: the two
rats (`GiantRat`, members 1 and 2) are **hidden** in the troop —`invisible`,
which the port didn't read—, and they're shown by two pages **by HP of enemy 0**, the
king, with `ShowHiddenMonster`:

- at 60% or less, "The KINGRAT cries out for help!" and rat 1;
- at 30% or less, "The KINGRAT cries out for help again! Its subhuman voice
  sounds desperate!" and rat 2.

Each one inside a branch by a switch (1005, 1006) that the page itself
turns on, so they come out once **per game**: if you lose or flee, in the
rematch they don't come back. That's RM2k's.

**The agents (102 and 104, map 32's `EnemyEncounter`).** Two variants of the
same battle on the hover tram's terrace; 104 brings the second hidden
guard, who is called by a page by HP of enemy 0 (30% or less: "AGENCY GUARD:
This guy's tougher than he looks! Give me some help here!"). Both have a
**turn 1** page —the first round of actions, after giving the
orders— with `PlaySound` `Thunder9`, a two-second `ShakeScreen` that waits,
and "TALAN: The Captain has taken off in the ship!".

**The Lazer Teeth (86, map 9).** Two pages by turn **with a multiple** and HP
of Talan (actor 14): base 1 every 3 with Talan at 50% or more, and base 0 every 2 with
Talan at 30% or less. Only messages.

**easyrpg's turn condition** is
`Game_Battle::CheckTurns(turno, turn_b, turn_a)`: `turn_b` is the base and
`turn_a` the multiple —the opposite of what liblcf's names suggest—, and
with multiple 0 it's "exactly at the base". The turn starts at 0 and is raised by
`NextTurn`, when the party has finished giving orders. With the other order the
take-off would come out every turn and "It's not too late" every turn from
3.

## The character systems' ones

Everything still not running in `release`'s troops belongs to the systems of
switches 799 to 831, between 22 and 24 pages per troop in the world ones (108
onwards). Counted over the 69 troops, what blocks each page:

    ChangePartyMembers                              the 18 summons
    ChangeHP and ChangeMonsterHP                    Inscribe, LifeForStrength
    ChangeCondition and ChangeHP                    Sacrifice
    ChangeMonsterCondition                          ControlMachines
    ChangeEquipment, ChangeHP, ChangeMonsterHP and  Play Radio
    PlayBGM
    the above plus ChangeMonsterMP and FlashScreen  799

None fires in `release`: their switches are only turned on by each
system's skill —measured: no map in the cartridge or common event turns them on—, and
nobody in the party has any of those skills. They remain in the big one.

# What was done

**The three missing conditions**: turn, HP of an enemy and HP of an
actor (`eventos.disparo_de_tropa`, `ba_pag_cumple`). The numbers for each
don't go in per-page tables in bank 1 —ten bytes for each of the
five hundred didn't fit— but in a **ten-byte header in front of the
page's code**, in `tropa_codigo`, which is in RODATA; the ROM copies it to
`BA_COND` when the page looks at any of the three (`ba_pag_cabecera`). The
HP bracket is computed like `AreConditionsMet` —`100 * hp / máximo`, integer—
without dividing, comparing twenty-four-bit products (`ba_pag_hp`).

**The hidden enemies** (`BAF_OCULTO`, `tropa_ocultos`): a hidden one takes up its
place without `BAF_HAY`, so everything that looks at who's there —the target, the
actions, the victory— skips it without knowing about hidden ones, which is easyrpg's
`Exists()`. It has no line, isn't drawn, gives no experience or gold on winning
(`ba_sin_ocultos`: `GetExp` and `GetMoney` add up the dead) and drops no loot.
**`ShowHiddenMonster`** is OP_SHOW_ENEMY (0x33): it swaps one bit for the other
(`ba_mostrar_oculto`), and `escena_tick`, which already erased the one that dies, places
the one that appears by the same path: its cells from the clean background and those
visible on top, in drawing order.

**`PlaySound` and `ShakeScreen` in a troop page.** The shake is
`Game_Screen`'s and moves the scene (`ba_sacudir`); its wait, an OP_DELAY, is
counted by `ba_pag_paso` with `BA_PAG_ESPERA`.

**The thunder doesn't sound**, and it's a decision left to taro. The sound effect of a
page's `PlaySound` goes into the battle's audio package, which already limits
samples: measured against the previous `release`, `Thunder9` brings
`T_VGFighterMAX_Masako`'s six instruments down from 13.6-14.1 to 11.5-11.7 kHz and
BRASS64 from 16.3 to 10.8. taro's rule for sound effects is that no
instrument loses rate because of them, so the effect is compiled and requested but
doesn't go into the package; adding it to `SE_DE_TROPA_AL_PAQUETE` (snes_music.py) makes
it sound, with MSU-1 and without. With MSU-1 the battle theme plays through its
track and the drop wouldn't be heard; the effect doesn't sound there either without the line, because
the `.msu`'s quality effects are the package's. The four system
effects that happened to compile were also left out by the same rule,
costing nothing.

**The turn 0 page on opening the battle** runs in the same frame in which it's
built, and not in the next: all 69 troops carry it, and that way the battle opens
asking for orders as before.

**What turn 0 uncovered**: the `AfterBattleMint` of the maps with
encounters only calls common event 35, which doesn't compile, so the page compiled
to nothing and, with 498 on, ran forever: after the first battle
the hero couldn't take a step. An autorun that compiles to nothing is now not carried,
just like an empty one. In its own commit, and in
`divergences/a-skipped-call.md` what it costs.

**The model** (`batalla.PaginaDeTropa`, `Batalla.revisar_paginas`): knows when
a page's conditions are met and runs from it only what changes who's fighting
—`ShowHiddenMonster`, the switches and the branches by switch—, at the same
moments as the ROM. With that `test_eventos_de_tropa.py` predicts in which turn
each rat appears and the exact HP of the four.

What the ROM does differently, in `divergences/what-troop-pages-do-not-model.md`:
the HP of an actor who isn't fighting, the shake of the scene only, and the thunder.

# What was left out

- **The systems**: see above. What unblocks the most is still
  `ChangePartyMembers` in battle (the 918 summon pages of the 69
  troops), and then `ChangeHP` on the battle's HP.
- **Long messages are cut at 31 letters**: the take-off comes out "The Captain
  has taken off in th" and the king's second call loses the "s" of
  "sounds". It's `battle-texts.md`, which already had it with
  Absorb Aura.
- **Common event 35** doesn't run: see `divergences/a-skipped-call.md`.

# Numbers used

- Opcode: 0x33, OP_SHOW_ENEMY. 0x34 wasn't needed.
- Far RAM: `$7E7A10`-`$7E7A29` (`BA_TURNO` to `BA_COND`), in
  `rom/src/ram_lejana.s`.
- `test_*_golden.py` tuples: none.

# Tests

`pruebas/rpgmaker/test_eventos_de_tropa.py`, with four new cases:
`pelea-97` (AG7 against the Rat King), `pelea-97-sin-ratas` (with 1005 and
1006 already on), `pelea-102` (Kersh against the agents) and `pelea-86` (Kersh
and Talan against the Lazer Teeth).

* the Rat King turn by turn against the model: HP of the four, who stays
  hidden, what the scene draws —the `ESC_VIS` bit and, in the pixels, the
  composed buffer against the clean background—, the two messages from the LDB, and that the
  rats appear on different turns (4 and 8);
* without rats: the target cursor doesn't reach either, killing the king wins, and the
  victory gives 50 experience and 150 gold, the king's alone;
* the take-off: nothing on turn 0, the shake and then the message on
  turn 1 before the first action, and nothing on 2;
* that the take-off requests its effect: the `Thunder9`'s OP_SOUND in the
  page's code, read from the ROM;
* the condition with a multiple: the Lazer Teeth's page comes out on turns 1
  and 4 and not on 2, 3 or 5;
* the `CheckTurns` rule and what the tests assume about the LDB.

Red with the defect in place: base and multiple swapped (four of the
seven), `escena_tick` without placing the one that appears, and the composition drawing
the hidden ones —which is the mistake the first version had, and which only the
pixel comparison caught—.

# What taro has to test

- **The Rat King** (Rat Tracks, map 26): starts alone; with the king at about
  half, "The KINGRAT cries out for help!" and a rat appears; near the
  end, the second call and the other one. Both fight and can be hit.
- **The agents' battle** on the terrace (map 32): after giving the
  first turn's orders, the scene shakes for two seconds and "TALAN / The
  Captain has taken off in th" comes out (cut). No thunder: decide by listening whether it
  goes in (one line, see above).
- **That after a random battle** (Rat Tracks, the plant, the world) the
  hero keeps walking: that's what turn 0 broke.
