---
name: "A map with one encounter step breaks the assembly"
description: "encounter_steps = 1 gives enc_base 65536, which does not fit in a .word: --test-encounters 1 does not build"
type: bug
status: done
assignee: taro
---

Surubí found it on 2026-09-29 while moving the battle tables to Rust
(`rust-the-converter-pilot-the-battle-tables.md`): a map with `encounter_steps` 1 gives
`enc_base` 65536, which does not fit in a `.word`. The Python emitted it
anyway and the Rust reproduces it on purpose, because its test pins the
Python's output. No ABL map has 1, but `--test-encounters 1` would break the
assembly. Fixing it changes the output in that case, so it goes separately:
decide what RM2k does with one step (one encounter per step?) and emit
something that fits.

## Taken on 2026-09-29

Hornero looked at easyrpg (`Game_Player::UpdateEncounterSteps`): the chance
per step is `1/encounter_steps` times a factor that grows with what has been
walked, so with 1 it gives 100% or more: a battle on every step. There is
nothing to decide: the chance has to saturate at the maximum instead of
overflowing. No ABL map uses 1, so ABL's ROM does not change; the test case is
`--test-encounters 1`.

## How the ROM uses it, and where it is fixed (Calandria, 2026-09-29)

`enc_base` is `65536 // pasos`, one word per encounter record.
`encounter_map` copies it to `ENC_BASE` on entering the map, and
`encounter_steps` —the body of `OP_ENCOUNTER_STEPS`— overwrites it with the
operand's. On each step, `encounter_step` goes up a row with `ENC_N` against
the thresholds, and shifts the base according to the row's `pmod`: to the
right 4 to 1 times in rows 0 to 3, to the left 1 to 4 in rows 4 to 7. **If the
shift to the left carries, it is "always"**, without rolling the die —the
`PercentChance` with chance >= 1—; if not, a battle happens if the xorshift
gives less than that.

The arithmetic with 1 step: the thresholds are `ceil(fila / 100)` = 1, 1, 1,
1, 2, 2, 2, so on the first step —`ENC_N` = 1— it is already in row 4, `pmod`
2. In easyrpg: `ratio` = 100 / 1 = 100, the same row, `p = 1 * 2 * 1` = 2,
always. In the ROM: `$FFFF << 1` carries, always. And since `ENC_N` goes back
to 0 with each encounter and the next step sets it to 1, **rows 0 to 3 are
never rolled with one step**; if they were, `$FFFF >> k` is `$10000 >> k`
minus one part in 65536. So **saturating at `$FFFF` in what is emitted is
enough**, and the runtime is not touched. With 2 steps the base is `$8000`,
which already fits.

There are three copies, and all three saturate the same way: `base` in
`rm2k-snes-battle` (the map's tables), `enc_base` in `rm2k-snes-events` (the
operand of `ChangeEncounterSteps`, which with 1 **did not compile**: `word`
refused) and `enc_base` in `tools/port/events.py` (the model). The `battle`
test that pins the Python's text, `the_encounters_of_the_game_are_the_pythons`,
changed on purpose: its game has map 5 with 1 step. The new hash is that of
the Python's text with that `.word` going from 65536 to 65535 and nothing
else —verified against the pilot's saved text—.

The ROM test is a new cartridge, `test-encounter-every-step`: map 21 and the
encounter party of `test-special`, with `--test-encounters 1`. Its case,
`encounter-every-step`, is a copy of `party-11-12-13` and not the same one: a
case in two cartridges has to be in the one that carries them all
(`test_a_case_in_two_runs_in_the_one_with_all`), and that one is
not in `release`. So it goes in `excluded_cases`. Before the fix it did not
assemble (`Range error (65536 not in [0..65535])`); after it,
`test_encounter_every_step.py` walks up and the battle comes on the first step.
With the cartridge changed to `test-special` the same test goes red with
"8 pasos", which is the control.

## When merging

Reinstall `battle` and `events` in the global one: `just -f tools/justfile
install battle events`. The new cartridge is built by `just cartridges` on its
own. In `abl.sfc` there is nothing to play, because it comes out the same. The
only thing left for taro, if he wants, is to look at
`rom/build/tests/encounter-every-step/prueba.sfc`, where every step on map 21
is a battle.
