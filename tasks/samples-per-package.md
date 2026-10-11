---
name: "Samples per package"
description: "Splitting the ARAM per map package and not per bank"
type: feature
status: done
---

# Done, on 2026-09-26

It is step 6 of `tasks/la-calidad-de-la-musica.md`, option A, with what was
measured and what came out: each sample with the budget of its worst package,
the sound effects subtracted, and the theme that may come in already playing
counted only as a theme
(`decisiones/el-tema-que-suena-gana-y-los-efectos-esperan.md`). The three
decisions below ended up like this: the unit is still the map; the stall is
paid in each map's fade and in the battle; and a program's sample is a single
one for the whole cartridge, at the rate of its worst package. What is below
is how it was written before.

# What

That the ARAM budget be split **per package and not per bank**: giving each
program what its worst package can pay, instead of a share of the whole bank.

Today the 40 KB of `ARAM_BUDGET` are split among **all** the cartridge's
programs, so adding themes lowers the rate of those that already sounded good:
with nineteen themes instead of eleven, the median goes from 12.5 to 8.4 kHz.
And the themes that do not manage to contribute programs sound incomplete —in
`abl` there are nine, with between 12% and 72% of their notes.

# Blockers

* **The transfer time.** Uploading a 32 KB bank through the IPL's protocol is
  on the order of half a second, that is, some thirty frames of stalled game.
  Today it is paid on each map change, inside the fade; in a `PlayBGM` in the
  middle of a scene it would show.
* **The sound effects share the ARAM** and have to survive the package change.

It is not a blocker, although it was written as one: **the mechanism already
exists**. `paquete_cargar` sends the SPC700 back to the IPL (`APU_CMD_IPL`)
and uploads the map's audio package.

# Decisions to make

* **What the package's unit is**: the map, as today, or the theme.
* **Where the stall is paid**, and whether there is a `PlayBGM` outside a fade
  that does not tolerate it.
* **What happens with a theme that plays in several packages**: its sample is
  duplicated or a common floor is shared.
