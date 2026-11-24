---
name: "ChangeEventLocation shifts the NPC table once per event"
description: "Each ChangeEventLocation of an event with a graphic re-sorts its row with an mvp of the rows it passes: a page that sends eleven events away costs ~600 of the frame's 262 lines, two frames lost"
type: refactor
status: todo
agents: [cardon]
author: aguara
links:
  found-in: [abl-lazer-teeth-s-rock-lags]
---

Seen by Aguará on 2026-11-17, measuring
[`abl-lazer-teeth-s-rock-lags`](abl-lazer-teeth-s-rock-lags.md), with
the-advocate `865163eb` plus that task's branch, in snes9x with a line
profiler.

**What was seen**: in ABL's map 11, the page of `Light4` that a stone
breaks sends the ten events of its cone and itself to (54,82) with eleven
`ChangeEventLocation`s and turns a switch on. That tick costs 380-600
lines —one stone at `Light4` from (15,48) loses two frames there, one at
`Light5` one—. Each `op_place` of an event with no route slot goes through
`plant_event`: a linear `event_npc`, and `fit_far`, which moves the row to
its sorted place with an `mvp` of every row in between —sixteen bytes per
row, seven cycles a byte—. The cones go from y 41-48 to 82, past twenty to
forty rows each, ~50 lines per event.

**To reproduce**: `tests/abl/test_stones.py`'s `frames_lost_throwing` from
(15,48) up, and look at the tick switch 47 turns on.

What might do: one shift for a run of `ChangeEventLocation`s, or a sorted
index instead of moving whole rows. Neither is small: route slots and the
OAM walk read the rows by offset.

## Log

### 2026-11-24, Cardón: to todo

Measured (380-600 lines on the tick that breaks `Light4`), and
`fit_far`/`plant_event` are untouched since (no commit in `runtime/` since
2026-11-17 mentions `fit_far`). It is the rest of the lag taro played in
[`abl-lazer-teeth-s-rock-lags`](abl-lazer-teeth-s-rock-lags.md), done;
nothing seen changes but frames not lost. Which of the two ways (one shift
per run, or a sorted index) is a technical choice the task makes and
measures.
