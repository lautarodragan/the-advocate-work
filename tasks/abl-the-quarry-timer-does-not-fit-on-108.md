---
name: "ABL: the quarry's timer does not fit on 108"
description: "With the quarry (150) in the cartridge, the converter gives the timer digits to 108 by walking reach and stops there: its eight sprite palettes are full"
type: bug
status: doing
assignee: Chajá
agents: [Chajá]
---

Seen by Cardón on 2026-10-14, with the-advocate `a7f278e6` and the ports
`6a9d53c`, in ABL, building a cartridge with every map of the game: see
[`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md).

**What is seen**: the converter stops with "map 108: the timer doesn't
fit: the map already uses the 8 sprite palettes it gets and none has room
for its 2 colors". The defender's job at the quarry (150, event 4) starts a
five-minute timer, common event 36 stops it, and the converter gives the
digits to every map it reaches walking from there —see `timer_reach` in
`scan.rs` of `rm2k-snes-convert`—; 150's exits lead to 108. In RM2k the
job can be left, so the timer does run on 108.

With 108 added to `[graphics] timer_never_runs_in` the reach stops at the
town and the build goes on: the digits go to 63 maps, 150 and 151 among
them. What that loses is the timer on screen while Talan walks through 108
in the middle of the job.

**How to see it**: a cartridge with 150 and 108, and the converter's log.
