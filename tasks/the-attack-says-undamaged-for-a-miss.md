---
name: "The attack says undamaged for a miss"
description: "A missed normal attack writes the target's undamaged line instead of RM2k's dodge one, and a hit of zero writes '0 health lost' instead of the undamaged one"
type: bug
status: draft
agents: [Cardón]
---

Seen by Cardón on 2026-10-20, **reading the code against easyrpg's**, with
the-advocate `3bc68ac4`, while doing
[`a-skill-in-battle-writes-no-result-line`](a-skill-in-battle-writes-no-result-line.md).
The original shows it: the 2015 RPG_RT under Wine, in the battle test of
troop 114, wrote "maneuvers out of the way!" under the Junkbot's missed
attack on Talan (the capture, in `/shared/captures/2026-10-20-skill-results/`).
Not run in the ROM.

**What RM2k does**, in easyrpg's `Scene_Battle_Rpg2k`: a normal attack
that misses goes to `ProcessBattleActionFailure`, which writes
`GetPhysicalFailureMessage` —`<target><dodge>`, A Blurred Line's
" maneuvers out of the way!"—; one that hits for 0 goes to
`ProcessBattleActionDamage`, which writes `GetUndamagedMessage`
—`<target><enemy_undamaged>`, " avoids taking damage."—.

**What the port does**: `ba_message`'s `attack:` branch, in
`runtime/battle.s`, writes the undamaged line for a miss (`BA_MDMG` at
$FFFF) and `<target> 0 health lost.` for a hit of zero. A skill's damage
line of zero goes through the same code since 2026-10-20 and is right
—undamaged—; the `dodge` term is in the cartridge since that day,
`BA_TXT_DODGE`.

**How to see it**: any battle where a party member's attack misses —the
droid of A Blurred Line's map 2 dodges sometimes—: the line under
"<who> attacks the enemy" says "Droid avoids taking damage."
