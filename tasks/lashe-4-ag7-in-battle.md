---
name: "Lashe 4: AG7 in battle"
description: "The droid's skills according to its parts, the weapons' SP, and the enemies' ShortCircuit"
type: feature
status: done
---

# What

Milestone 4 of `lashe-city-with-the-car-up-to-the-race.md` —the context is there—. It has
two halves that don't step on each other:

- **the plant's enemies** (troops 108 to 114);
- **AG7-17** (actor 18), whom milestone 3 puts in the party without skills.

What taro answered on 2026-09-26 and governs here: AG7 **can't lose skills**
—that is, the multi-target ones go in— and the weapons charge SP because in
the original they do: **faithful to the original**.

# Status

2026-09-27, in `testing/`: done on the agent's branch, on `main` at a3140f1
and with `main` merged on top of milestone 5 (6c4949d); `just cartuchos` and
the whole suite green on the merged tree. What's left is taro's: play it (see
below). The goldens didn't change.

# What was done

**The space, first and separately.** Bank 1 had ~350 B left and the battle
code lives there. The troop pages' code and messages —almost eleven KB— moved
to RODATA in their own commit, with the suite green and without touching any
golden: they're read with a long pointer whose bank comes from
`^tropa_codigo`, so it's enough for each block to fit in a bank.

**The enemies choose what to do** (`batalla.accion_del_enemigo`,
`ba_accion_enemiga`): the LDB's list of actions with their `rating`, and the
weights of `SelectEnemyAiActionRpgRtCompat` —`max(0, rating - máximo + 10)`—.
With that **the only one in the plant that casts `ShortCircuit` is the
Tangle Wire** (troop 113), which has it at 50 like the attack; the Scrapped
Droid (10), the Trash Hauler and the Junkbot (30) are ten points or more below
and weigh zero, in RM2k too. A lone weighted action doesn't roll a die, so as
not to move the randomness of the battles that were already there. What isn't
modeled —conditions, the other basic actions, states— in
`divergences/what-the-enemies-ai-does-not-model.md`.

**The five scopes** (`batalla.blancos_de_la_habilidad`, `ba_hab_usar`):
`enemies` and `party` repeat the effect on each living one of that side, with
their rolls per target; `self` falls on the user. Only `enemy` and `ally` ask
for a target. With that AG7 loses none of its seventeen —the ones that touch
states (BioWarfare, HeadButt, RemoveStatus) do what can be done without
states— and along the way every actor's multi-target ones go in, Arden
included.

**The weapons' SP** (`batalla.sp_del_arma`, `ba_atacar`): the `sp_cost` of the
weapon in slot 0 is charged before the hit roll, with no graying out at zero
SP. The armors that carry `sp_cost` (NetLauncher, SpikedHelmet) don't
charge: `ForEachEquipment<true, false>` only looks at weapons.

**Common event 37: the tailored approach.** `eventos.COMUNES_DEL_EQUIPO`
recognizes the parallel common events, with a switch, that have nothing but
`ChangeSkills` and branches on the equipment. Their body is pasted after the
`ControlSwitches` that turns on their switch and the ROM runs it on closing
the menu (`comunes_del_equipo`). Why not the general approach, with the
numbers: `divergences/pure-parallel-common-events-run-only-when-what-they-read-changes.md`.
In short:

    general   ~0.13 frames of CPU per iteration of the body, on every frame of
              every map from the moment AG7 joins —measured with throwaway
              cases: 0/10/20/30 runs in a row, 63/64/66/67 frames—,
              and it also turns on 2 (DisableSaving, no switch), 3 and 8
    tailored  8 B of bank 0, 117 of bank 1, 0 of RAM, 0 cycles per frame;
              doesn't cover a page `ChangeEquipment` on 18 (the game
              has none)

**Animation 62 isn't drawn**, nor any skill's: it's a new subsystem inside the
battle (objects, OAM, a palette, the frames by DMA), and it stays with what was
looked at in `animations-in-battle.md`.

# Numbers used

- Opcode: none.
- Far RAM: `$7E7960`-`$7E797F`, in `rom/src/ram_lejana.s`: `BA_ARMA_SP`
  (4 bytes) and `BA_HAB_I` (1).
- Tuples of `test_*_golden.py`: none.

# What was measured

With `.res N, $00` and the symbol table, after the milestone and with 5
merged:

    release       bank 0: 211 free (219 before)    bank 1: ~10.2 KB
    test-special  bank 0: 981                      bank 1: ~11.3 KB

BSS and ZEROPAGE unchanged.

**A test page of more than ~12 KB hangs**: the one with 40 runs of 37
(12.3 KB) didn't reach the end and the one with 30 (9.2 KB) did. It isn't
from this milestone —no page of the game comes close— and it's noted in case
someone builds one.

# Tests

`pruebas/rpgmaker/test_ag7_y_la_planta.py`, with two new pages,
`ag7-componentes` and `pelea-113` (Talan and AG7 on floor 1):

* when 150 turns on AG7 knows ConcentratedSpray and nothing else;
* changing the weapon changes nothing with the menu open, and on closing it
  it knows ArmMissile and not ConcentratedSpray —red without the call from
  the menu—;
* with the switch off, closing the menu touches nothing;
* the battle against troop 113, turn by turn against the model: the HP of the
  four, AG7's SP (its weapon) and the Tangle Wire's (`ShortCircuit`),
  requiring that both have gone down;
* the "Components" list in battle;
* BombsAway, with the GrenadeLauncher: no target, at both enemies.

`test_cores.py` adds `test_la_pelea_de_la_planta`: two turns of 113 in snes9x
and bsnes.

# What taro has to look at while playing

What can be seen while playing is less than what was done: **in what reaches
up to the race AG7 doesn't get any other part** —no shop and no event of those
maps gives one, and the plant's enemies drop nothing—, so it has the ArmCannon
and nothing else. What there is:

* **"Components" in battle**, with ConcentratedSpray.
* **Taking off its ArmCannon** in the equip menu and leaving: in the next
  battle "Components" is grayed out. Putting it back on and leaving: it comes
  back.
* **The weapon's SP.** The battle doesn't show SP and neither does the pause
  menu, so it's seen through the gray: with 60 SP, nine ConcentratedSpray
  leave 6, which is still enough; one more attack (1 SP) and the skill goes
  gray. Without the weapon's cost it would stay available. SP carries over
  from one battle to the next.
* **The Tangle Wire** —the cable, in the troop with the rat— casting
  `ShortCircuit` roughly half the time; the others in the plant only hit, as
  in RM2k.
* **As a side effect, the Rat Tracks boss** (the KingRat) now sometimes bites
  with `RoyalRatBite` instead of hitting.

The multi-target ones (BombsAway, TillTheyGlow) and the parts that change the
skill can only be seen in the tests today.

# Tested

taro, on 2026-09-27, on the SNES with the FX Pak: everything worked, including
the path of selling the Idol, bribing the guard and taking AG7 along; the race
without lag or bugs (the companion at the wheel, too). Separate from this: the
black hero after changing graphic on the same map (Lazer Teeth HQ, Boss Wick).
