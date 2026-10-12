---
name: "Monster conditions and FlashScreen in battle"
description: "ChangeMonsterCondition leaves out 164 troop pages —140 with FlashScreen—: Inscribe (799) and ControlMachines (803), at least 66 of them from release encounters. FlashScreen in the scene is cheap; real conditions are big, and taro decides whether they get done or are accepted as debt"
type: feature
status: testing
agents: [Aguará, Chajá]
assignee: taro
---

From Aguará's study, [`research/2026-10-05-the-missing-commands.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-05-the-missing-commands.html); measured by `rm2k-snes-events culprits`. taro, on 2026-10-05: leave them in todo, without launching yet. taro's decision on conditions is still pending.

## taro's decision, 2026-10-12

**First as debt, then for real.** `ChangeMonsterCondition` is accepted
without doing it, as a declared debt, and `FlashScreen` —with `TintScreen`
and `TerminateBattle`, small— is done for real in the battle scene: that
unblocks the 164 pages of `Inscribe` and `ControlMachines`, knowing that
`Control` and `BarkWall` don't happen yet. The real condition system is a
task of its own, in todo: `battle-conditions-for-real.md`.


# Status

2026-10-12, Chajá, from the-advocate 2c7b10ce and the ports b3063e2,
on the branches `chaja-destello` of both.

The plan, after reading the runtime:

* **`FlashScreen` needs no opcode**: a troop page runs `OP_FLASH_SCREEN`
  with the map's interpreter, which only leaves the flash's state
  —`flash_level`, `flash_remain`, `flash_rgb`—; it is `flash_tick`, in the
  map's loop, that draws it on the map's palettes. The battle runs its own
  loop, so it gets its own tick over the scene's palette: the background's
  colours and the battlers', BG1 from entry `SCENE_CGRAM` to the windows'.
  The windows and the text do not flash, as in RM2k, where the windows are
  above `Priority_Screen`.
* **`TintScreen` the same**: `OP_TINT` leaves the tint and `tint_pending`,
  and the battle's tick tints the scene. And the scene starts with the
  map's tint, which is what RM2k does —`Spriteset_Battle` takes
  `Game_Screen`'s tone—: the agency captain's battle (troop 240) is fought
  with the map tinted and its turn 0 page puts it back to neutral.
* **`TerminateBattle`** is the one opcode, `OP_BATTLE_ABORT`, 0x4C: the
  battle ends with no victory, as EasyRPG's `BattleResult::Abort`, and the
  map's page carries on past the handlers. That needs a fourth destination
  in `OP_BATTLE`.
* **`ChangeMonsterCondition`** compiles to nothing, in `ACCEPTED_UNDONE`, and
  the converter warns about it in troop pages too, which until now only
  maps' automatic pages did.

# What was done (2026-10-12, Chajá)

Branches `chaja-destello`: the-advocate `5238c200`, the ports `38befdb`
(test and cases) and `3952062` (goldens), the book `eeb3d08`. `main` had
not moved in any of the four when delivering.

* **The flash and the tint on the scene**: `runtime/battle_tone.s`, the
  battle's tick, at the end of each frame of `battle_run` as `flash_tick`
  goes after `events_tick`. The scene's palette —the background's colours
  in use and each battler palette— through the tint's tables composed with
  the flash's, into `pal_buf`, uploaded in the next vblank; the windows and
  the text are left alone. The scene starts with the map's tint, and a flash
  left going is cut at both ends of the battle.
* **`TerminateBattle`**: `OP_BATTLE_ABORT` (0x4C), and a fourth destination
  in `OP_BATTLE`, past the handlers; `BA_ABORT_R` is the fourth result and
  `BA_M_ABORT` the mode that closes the battle with no end screen.
* **`ChangeMonsterCondition`** in `ACCEPTED_UNDONE`; `TroopPages` lists the
  debts of the troop pages that got in and the converter warns one line per
  command with its troops. `Wait` came into the troop pages with them.
* **`TROOP_PAGES_MAX` 32 → 64**: the agency captain's 33 pages all compile
  now, and the converter stopped.
* RAM: `ba_abort`, `ba_bg_src` (the background's 96 colours, read back from
  CGRAM), `ba_tone_ready` and `ba_tone_tint`, all in `FARBSS`; `pal_buf`,
  which the battle did not use, as the output.

**`rm2k-snes-events culprits --every-map`**, with the request of each
`release`, before (main's tools) and after —the numbers are the command's,
and went in the report—: in ABL no troop page is left out by a command any
more, only the ones with a trigger the ROM cannot look at; Book of Three
gains the pages that `ChangeMonsterCondition`, `TerminateBattle`,
`TintScreen` and `Wait` stopped, and keeps the ones of `ControlVars`,
`ChangeItems`, `ShowBattleAnimationB` and `ChangeMonsterHP`. The other six
do not move: their troop pages stop at the trigger. Maps and commons do not
move in any.

**Verified**: `just test` and `just rust-test`; ABL's suite whole with
these tools, green; the new
`pruebas/rpgmaker/test_destello_de_pelea_golden.py` red with main's tools
(five of six) and green with these; `just arrancan` of the ports, green
for the other seven, in snes9x and bsnes. Run by hand and not in the suite: the flash over a background
from the `.msu` (MSU-1 on, same case: one step per frame, none lost).
Compared with the original under Wine, with a copy of the LDB where
`Inscribe`'s page runs on turn 0 of a battle test against troop 128: the
same look.

**On merging, install** `cartridge events convert mapdata`. No golden
moved but the two new ones.

**What the suite does not cover**: a `TerminateBattle` in a battle with
handlers (the game's only one has none; the compiler's test covers where
it goes); a flash or a tint when the battle starts on the plain
background; a flash left going when a battle ends; `Wait` in a troop page
on the console (only Book of Three uses it, and its pages are not played).

**What taro should play**: Inscribe after one of Talan's walls, in any
random encounter of `release` —the flash comes out in the wall's colour,
over the scene and not the window—, and ControlMachines, whose message
comes out and whose machine goes on attacking. And the agency captain's
battle (map 207): it opens with its colours although the map was black, and
on turn 10 it goes black and ends with no victory screen.

**Draft**: `battle-message-box-empties-two-frames-late.md`.
Captures: `~/scratch/chaja/capturas/2026-10-12-destello/`, with its
`LEEME.txt`.
