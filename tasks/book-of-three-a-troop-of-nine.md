---
name: "The Book of Three: the horsemen's battle never ends"
description: "Troop 83 has nine members and the cartridge carries eight; its first page leaves only the ninth standing, so the port's battle has no enemy and the story stops in Yern's woods"
type: bug
status: testing
assignee: taro
agents: [Mulita, Tijereta]
---

Seen by Mulita on 2026-10-15, comparing the port with the original under
Wine, with the-advocate `fa9d1a14` and the ports `0ca371b`, in The Book of
Three. **It blocks the story** a short way into the game.

**What is seen**: in Deep in Yern Forest (map 16), stepping on (12, 18)
starts the battle against troop 83. In the original its turn-0 page plays a
whole scene inside the battle —members appear with `ShowHiddenMonster` and
leave with `ChangeMonsterCondition`— and ends with one enemy standing, the
ninth member (place 8), which the player then fights. In the port the scene
plays, but no enemy is left on screen and the command menu comes back
forever: the battle never ends (6,000 frames of A taps, measured).

**Why it shows**: troop 83 has **nine** members, and the cartridge carries
eight (`ENEMIES_MAX` in `rm2k-snes/battle`, taken with `.take()`; the
hidden mask is a byte per troop). The converter says nothing: it is not in
`degradations.json` either. No other troop of the eight games has more
than eight members (counted over every `troops.json` of the ports).

**How to see it**: the ports' case `book-of-three/cases/milestone-*.json`
style —state up to map 16, teleport to (13, 18)— and a step left; or play
`tests/test_book_of_three.py` one milestone further than it goes. The
walkthrough stops before it on purpose and says so.

## Tijereta, 2026-10-15

From the-advocate `07fa9010` and the ports `dc01b28`, branches
`tijereta-troop9` in both and in the book.

**RM2k's limit**: none in the data. liblcf reads as many members as the
LDB holds and easyrpg-player's `Game_EnemyParty::ResetBattle` sets them
all up; `GetEnemy` answers null past the last one.

**Carry nine, or fit to eight**: fit. Carrying a ninth widens the battle
for every game for one troop of one: the combatants are forty bytes each
at fixed places of `FAR_BATTLE`, `ba_states` grows by `ST_BYTES`, the
drops by two, and the scene's masks (`scn_bits`, `SCN_VIS`), the troop's
`troop_hidden` and the drawing order are a byte per troop. FARBSS had
~13 B left in ABL: one combatant alone does not fit there.

What the troop's page does with its nine (counted from its data): the
first is visible and killed by the page, two more appear and are killed
one after the other, a procession of five appears and is killed, and the
ninth appears and stays —the only one fought—. At most five are on
screen together. So one of the procession can go without changing the
battle: `rm2k-snes-battle`'s new `fit` leaves out the hidden ones no page
shows first, then the hidden ones every page that shows them also kills,
highest place first, and only then the last places; one a page condition
or a battle branch asks about is never scenery. The pages are renumbered
and the commands about the one left out become `Comment`s at the same
index. Troop 83 loses member 8 (from 1), and keeps the ninth at place 8.
Every reader of troops calls it —the battle's `Db`, the event compiler's
`Game`, the converter's database—, and the converter notes it as
`troop-members-left-out` in `degradations.json`.

**Test**: `test_book_of_three.py` goes on past the deep woods: the touch,
the battle's first command —a golden, and one enemy standing at place
7—, and map 17, which is winning it (losing is the game over). Seen red
with the global tools, before the change: `play_script.Stuck: a battle of more than
60000 frames of A taps`. That cap is new in `play_script.tick`: before
it, the test hung instead of going red.

**Verified**, on the branches merged with main (the-advocate `91d55d39`,
the ports `8a9ab73`), with `battle events convert mapdata screens` from
the branch first in the PATH: `just test` and `just rust-test` green in
the-advocate; ABL's `just tests` green, and its `abl.sfc` byte for byte
the one of the same main without the change, `b5367669…` (before merging
main, `681b75cd…` against `07fa9010`); `just boot` at the ports' root
green. The troop is the only one of the eight games with more than eight
members (Mulita counted), and
Book of Three's `degradations.json` says it: one `troop-members-left-out`.

**What the suite does not cover**: `fit`'s third kind —cutting the last
places when there is not enough scenery— and the rewriting of
`ChangeMonsterHP`/`MP`, `ShowBattleAnimationB` and battle branches run
only in its unit tests: no troop of the eight games reaches them. The
procession with four figures instead of five was not compared with the
original under Wine; the battle's first command was, by Mulita.

**When merging**: reinstall `battle events convert mapdata screens`
(`events` and `convert` now depend on `rm2k-snes-battle`). Captures in
`/shared/captures/2026-10-15-troop-of-nine/`.
