---
name: "The getaway car isn't visible"
description: "With an autorun running, the full refresh only looks at autoruns"
type: bug
status: done
---

**After choosing the car on the rooftop, map 4's cutscene runs with a black
screen**: the texts are visible and the car isn't. In RM2k the background is
black too, but the car is there, animated. taro saw it on 2026-09-23 playing
the build of `3e028a0`
—`pruebas-manuales/2026-09-23-3e028a0-snes/talan-arden-car-escape.png`—,
and it isn't new.

The car is `EV0002` or `EV0003` of map 4: `BLVehicles/2`, with the page
conditioned on 130 (red) or 131 (blue) **and** 132, which map 33 turns on
before the choice. The cutscene is page 4 of `EV0001`, an autorun that also
asks for 132.

# The cause, measured

Starting the test cartridge on map 4 with 130 and 132 on —`in-4`—, both cars
end up with `npc_buf + 14` at zero and `eleg_por_ev` at `$FFFF` for events
1 and 2: **no refresh pass looked at their pages**, neither the one from
loading the map nor a forced one afterwards.

It's `elegir_con_filtro`: to decide between the short filter (`$80`, only
autoruns) and the full one (`$E0`) it does `ldx solo_auto` with X in 16 bits,
and that also reads `auto_n`, the byte next to it. With some autorun active
`auto_n` isn't zero, neither is X, and the full pass filters like the short
one: events that only have their own route or a per-page graphic never pick
a page while the autorun lasts.

It was born in `348cf58` (2026-09-06). Two lines above, the same function
reads `solo_auto` with `lda`, in 8 bits, so the `ldx` isn't there on purpose.

**It isn't specific to this map**: it happens to any refresh with an autorun
running, which in a cutscene is the norm.

# The fix

`solo_auto` is read with `lda`, before the page. With that, in the same
`in-4` start with 130 and 132, event 1 picks its page (`$A0`) and event 2
stays hidden (`$FFFD`): **the red car appears, and animates** —it changes
pose every ten frames—. The blue one doesn't, which is as it should be.

And since every case of the suite's test page **is an autorun**, every
refresh in the suite ran with the bug in place: the fix may move goldens
that have nothing to do with cars. The first one that showed up is
`flash-shared-2`: the hero no longer flashes together with event 4.

**It moved no golden**: `just tests` green with the fix. The
`flash-shared-2` thing mentioned above wasn't this but the case of the
other task, which flashed the hero and changed the converter's palette
allocation for map 6: see `two-flashes-at-once`.

It is guarded by `tests/rpgmaker/test_refresh_with_autostart.py`, which
starts in `in-4` with 130 and 132 and checks that the red one is drawn and
the blue one isn't. It was seen red against the `main.s` from before the
fix: both rows at zero.

What was **not** run: the getaway played in full, from the rooftop. The test
reaches map 4 with the switches set by hand.

**Confirmed by taro playing on 2026-09-26: works perfectly.**
