---
name: "The race in release"
description: "The car chase, which today does not go into any ROM"
type: feature
status: done
---

# What

Put the car chase —maps 49 to 54— into `release`, when it is taken on. (Until
2026-09-25 it said "and into `test-main`": they were merged.)

# Status

**It went in on 2026-09-27**, with milestone 1 of
`race-and-what-comes-next.md`: see `race-1-it-goes-in-and-it-runs-at-30-frames.md`. What is
below is what was known before.

Until 2026-09-24 it had its own ROM, `just build carrera` —formerly
`demo-carrera`—, built separately. taro removed it that day: it was an
experiment to try that case, and it makes no sense to get so far ahead. It is
picked up again when it goes into `release`.

What follows is the comment the recipe had, which is what took effort to find
out. The recipe is not kept: it started on map 49 placing the hero with
`--inicio 1 26`, and that converter flag was removed on 2026-09-25. The race
is going to be tested **by reaching the map normally**, through the game's
`Teleport`, not by starting on a cell chosen from outside.

# What was known

The seven maps are the scene's: 49, 52 and 54 are the three laps, 50 is the
crash room with the "let's go again", 51 the raised bridge, and 53 the ending.

**With `--grupo 14`, Talan, who is the one the game gets here with.** On
entering 49, `RaceController1` removes from the party the actors that may be
there and adds `CarRED` or `CarBLUE` depending on the switch it turns on
itself, so the hero **is the car**. With the test party set, Kersh would stay
inside —he is not on that list— and the graphic would come out wrong; with the
database's initial party, the hero is drawn **without a graphic** until
`RaceController1`'s `PanScreen` finishes and only then does the car come in,
which is a symptom taro reported while playing.

**The cell through which the game enters is (1, 26)**, and it is not
cosmetic. Without it the converter places the hero on the open tile nearest to
the centre, which on this map lands on a row where **there is not a single
obstacle** nor any of the events that jump to the next map: the car could
cross the map's 500 cells without hitting anything and without getting
anywhere. The cell comes from the `Teleport [49, 1, 26]` of event 3 on map 36,
which is where the game enters, so reaching the map normally lands there
without doing anything.

**Switch 171 is what makes it start** —the test page
`tests/cases/switch-171.json` turns it on—, and one has to know why. Event 1
on map 49 has two autostart pages, one per switch, and the one that sets up the
car asks for 171. With both off **neither is the active one** and the event
does nothing, so the hero stays as `DummyHero`, whose sprite is an empty cell
on purpose: screen without a car. What turns it on in the game is
`RaceControllerZERO`, Talan's intro with the controls sign; that page compiles,
and the switch is still set by hand only because nobody looked at that scene
again since then: removing it is a manual test of the whole intro.

**And the race does not run on its own**, which is the first thing one notices
playing: the hero walks freely and at the speed `RaceController1` left him.
What runs it is `RaceController2`, the only parallel page of 49 that does not
compile, and what stops it is the `KeyInputProc` **without wait**; the reason
that command is still not accepted is in `KEY_INPUT_PROC` in eventos.py.
