---
name: "Lashe 5: the car's tail end"
description: "The closing of 36 through the three branches, up to the Teleport to 49 exclusive"
type: feature
status: done
assignee: taro
---

# What

The last milestone of `lashe-city-hasta-la-carrera.md`. It goes when 1, 2
and 3 are in —and 4 if you want to play the droid branch fighting it—.

Make the three branches reach the end: page 2 of event 3 of 36, with 161
and the branch's condition met, notices the Agency car (turns on 238),
asks "Should we stay in Lashe City or get out?", and with "We've got to get out
of here" turns on 182 and reaches the limit —whatever was decided in milestone 1
for the `Teleport [49, 1, 26]`—.

    Arden   161 + 169   (the Vipers' HQ, in 38)
    Saldra  161 + 181   (Sector 33, 47)
    alone   161 + 150   (the droid)

"Stay in the city a little longer" closes nothing: the next time you go back
to the car, the upper branch of the same page asks it again.

It shouldn't need new code: everything the page uses already compiles in milestone 1.
What it needs is **playing it end to end**, because it's the only place where
the three paths and the switches they left come together.

# Tests

- **Three walkthroughs**, one per branch, from the talk in the car (map 4,
  page 5) to the limit, on `release`. They're long: it's best that each one
  starts with the switches of the stretches that aren't its branch's already set
  —Wick's stretch is covered by milestone 2's walkthrough— and plays its own plus the
  closing.
- "Stay" once and "get out" afterwards.
- Check that **no** branch reaches the closing without its condition: the branch with no
  companion and no droid has to stay in the city, as in the original.

# Status

2026-09-27, in `testing/`: done on `a3140f1` (milestones 1, 2 and 3), in the
agent's branch, with `main` merged before delivering. **It didn't need new
code**: the three branches close with the ROM as it was. What's left is
taro's: play it and look at the photos without golden.

# What was done

`pruebas/abl/test_recorrido_lashe_cierre_golden.py`, on `release`, one
walkthrough per branch. Each one starts at the car talk in map 4 (132),
goes through the cutscene in 34, and reaches 36 with Wick's stretch done (
161 turned on by hand: `test_recorrido_lashe_wick_golden.py` plays it). Then:

1. its sector and back to the car **without doing its own thing**: 36 doesn't turn on 238
   and the first choice it opens is the sectors one (four options, not two);
2. its own thing, played from 36 and not with `ir_al_mapa`, and walking back to the
   car;
3. "Stay": 238 on, 182 not; another trip to a sector and to the car;
4. "We've got to get out of here": 182, the end sign and the title.

So that "without its condition" isn't just "without anything", each one starts with the
switch of **another** branch that you can have without it being your own:

    Arden   with 181 (the guards work in all three branches); plays the pipe,
            the HQ and the whisper (169) in 38
    Saldra  with 150 and AG7 in the party (with her the droid is optional); plays
            the shop in 56 and the guards (181) in 47. The branch of the
            page that looks at 150 requires 56 to be off: it isn't enough
    alone   with 181; plays Stash, the plant, the chip, the tunnel, AG7 and its
            tutorial in 48. Without 150 it stays in the city, as in the
            original

The stretches milestones 1 and 3 already played are reused: in a separate commit, the
body of their tests became functions (`el_hq_por_el_cano`,
`la_tienda_y_los_guardias`, `irse_termina_la_demo`, `de_stash_a_ag7`), without
changing what they play.

That step 1 catches what it says was checked by hand once: with 169 on
from the start, Arden's branch stops there ("tiene 2 opciones").

**No mandatory battle** in the three branches: the only area with encounters
is the plant (59 to 62), and there Talan goes alone —AG7 joins later—; the walkthrough
turns them off, like milestone 3's. So the droid branch doesn't depend on
milestone 4.

The photos are left in `pruebas/snapshots/playthrough/lashe-cierre-*/` **without
golden** (`arden`, `saldra`, `solo`). What they **don't** cover: the blue car (130
off), Wick's stretch played in the same run, and the plant's
battles.

# What taro has to look at while playing

The game from the talk in the car to the limit, along the branch of his choice, with
the build that comes out of merged `main`. And that the limit does what was decided.

Per branch, with the build of merged `main`: with Arden, the pipe and the whisper;
with Saldra, the guards in 33; with no companion, Stash, the plant and AG7. Before
meeting the condition, going back to the car shouldn't ask anything; afterwards,
"Stay" once (it's asked again the next time) and "get out": the demo's end sign
and the title.

# Tested

taro, on 2026-09-27, on the SNES with the FX Pak: everything worked, including the path
of selling the Idol, bribing the guard and taking AG7; the race with no lag or
bugs (the companion at the wheel, too). Separate from this is the black hero after
changing graphic in the same map (Lazer Teeth's HQ, Boss Wick).
