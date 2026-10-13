---
name: "Three divergences, against RM2k"
description: "Verify with RPG_RT under Wine three divergences that were measured against the Python reference and not against RM2k"
type: test
status: done
assignee: taro
---

Guayabo flagged them on 2026-09-29, when classifying the divergences by repo
(`decisions-and-divergences-by-repo.md`): they were measured against the
Python reference that existed until 2026-09-16, not against RM2k, so it is
not known whether the ROM differs from RM2k.

- `workflow/divergencias/fase-de-los-tiles-animados.md` (it says so itself)
- `workflow/divergencias/cronometro-llegando-a-cero.md` (its 252 pixels are
  from `27c828de`, against the reference)
- `workflow/divergencias/move-event-tras-teleport-interno.md`

For each one: either it is confirmed against RPG_RT under Wine —and the
divergence says what was measured—, or it is discarded and deleted, saying
so in the commit.

## How it was measured (Caranday, 2026-09-29)

**The original**: the 2015 RPG_RT under Wine, on a copy of the game where
page 1 of EV0001 of map 4 —the autostart the game begins with— is replaced
by the case's page: the one from `rom/pruebas/casos/timer-cero.json` as is,
or a `Teleport` to the place to look at. "Begin the Story" is chosen and the
Wine desktop is recorded with `ffmpeg -f x11grab -framerate 60`, lossless;
then it is read frame by frame at 320x240. **Wine does not let one count
absolute frames** —the recording runs on wall-clock time and sometimes
duplicates or drops one—, so everything is measured **between marks of the
same video**: when something appears, when a fade starts to darken, when
the camera moves. Every number below came out the same in at least two
recordings.

**The ROM**: `release`, with `tanda.partida` and one capture per tick, and
the same marks.

**easyrpg** agrees on what was looked at: the timer goes off when it has
less than sixty frames left (`Game_Party::UpdateTimers`), and the ChipSet
animation comes from a counter that does not advance during transitions
(`Player::Update(false)`).

## What it gave

**The timer — deleted.** With the `timer-zero` page, measured from the
frame in which the timer appears, in both: the colon goes off at +30, the
digits are visible until +59 and at +60 the timer is gone. **It never shows
00:00, in neither one.** The 252 pixels of frame 60 were the reference being
wrong. The only difference is the tint after the `Wait 2`: +12 in the
original, +13 in the ROM; it goes to the new task below.

**The `MoveEvent` after the internal teleport — deleted.** In both, the
hero takes the first step two frames after the fade ends, in the four
rounds of the map 16 scene, and in the fourth —the one the file pointed
at— walks the same 88 frames and the camera scrolls the same 176 pixels as
in the others. Nothing starts four ticks early and no screen is shifted
eight pixels. What does differ is the length of each round: 161 ticks in
the ROM and 158 in the original. It is a new task:
`teleport-takes-three-frames-too-many.md`.

**The phase of the animated tiles — deleted.** The ten pixels are the water
of map 6's ChipSet, visible after the `graphic-hero` route lowers the
camera: today it changes step at tick 47 of that case, same as on
2026-09-12. Against the original, the rule was measured, not the absolute
phase —that depends on everything played since "Begin the Story", and the
ROM's boot does not last the same; `tools/rpgmaker/rm2k.py` says so—:

* **every 24 frames**, in both;
* **still during the teleport fade**, and exactly during it: in the
  original the water changes 24 frames after the last frame of the fade,
  with the last step before it on the frame previous to the first of the
  fade. In the ROM, with a real `Teleport` (those of the map 16 scene),
  `vueltas_congeladas` goes up during the same 69 ticks the visible fade
  lasts.

The one-frame difference the file measured was between two clocks —the
reference's counted the fade ticks and the ROM's did not— and stopped
existing on 2026-09-18 (`4b2c6fe5`), when the ROM began freezing the
animation like easyrpg.

Two things seen in passing, which do not change the above:

* `Partida.go_to_map` freezes **one tick more** than the visible fade (70
  against 69): the animation comes out of it one frame late. It is the
  harness's, which asks for the fade from outside; with a page's
  `Teleport` it does not happen.
* In the original, opening and closing the menu also leaves the water
  still: in a menu that was open 103 frames counting both transitions, the
  water lost 100. The ROM does not count `vueltas` in the menu either; it
  was not measured frame by frame.

## Where the captures ended up

`/shared/captures/2026-09-29-divergencias/`, the original and the ROM with
the same name and the number relative to the mark used:

* `cronometro-{rpgrt,rom}-*`: before, on appearing, the tint, the colon, the
  last frame with digits and the first without timer. The number is the
  frame since arriving at map 6.
* `mapa16-{rpgrt,rom}-tramo3-*` and `tramo4-*`: the end of the third round,
  and the fourth from start to finish.
* `agua-{rpgrt,rom}-*`: the last water step before the fade, the first and
  the last frame of the fade, and the step after. The ROM ones come from
  `go_to_map`, so they carry the harness's extra tick.

In the ROM captures of map 16 the hero is not visible: the save starts from
`in-5` and reaches 16 through `go_to_map`, without the party the game
enters there with. The camera follows him anyway, which is what was
measured.

What `just tests` does not cover: none of this. These are measurements
with throwaway scripts; no code or goldens were touched, only two test
comments that cited the deleted files.
