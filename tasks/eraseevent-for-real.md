---
name: "EraseEvent for real"
description: "EraseEvent for real in map pages: the event that runs it disappears until the map is reloaded, and a parallel one is cut there; in a common event it does nothing"
type: feature
status: done
agents: [Aguará, Hurón]
assignee: taro
---

From Aguará's study, [`research/2026-10-05-the-missing-commands.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-05-the-missing-commands.html); `rm2k-snes-events culprits` measured it. taro, on 2026-10-05: leave them all, without launching yet. It is the first thing it recommends: a small one and a medium one.

2026-10-06, Hornero: in Desert Nightmare `EraseEvent` is what leaves the most
pages out on its own —127 of the 157 that use it, measured with `culprits
--every-map`—, and it is the suspect for its intro freezing: an
autostart page that erases itself, if it does not compile, does not let the scene
continue. El Dorado has 3. It is done whole: erase the event until the
map is reloaded, in maps and in ABL's quarry; the one in a common event still does nothing.
taro: "let's go with those two in parallel", with Sonnet.

## Hurón, 2026-10-06

**What there is**: `OP_ERASE_EVENT = 0x49` (one operand: the event, its index plus
one, like `OP_ROUTE`). It compiles in the page of a map's event; in a
common event —without a map, or pasted into the page that calls it— and after a jump to
another map it still does nothing, as in RM2k. A jump **to the same map** does not
count as a jump: it is the quarry's, and there it erases for real. A `MapEvents`
without an owner —a page belonging to nobody— is cut, like any "this event" without an
event.

**In the ROM**: `FLAG_ERASED` in `ev_flags`, with no new RAM. It is set by
`op_erase_event` (`interpreter_movement.s`), which asks for a refresh; it is looked at by
`conditions_ok` —no page of an erased event is met: it does not start,
it is not chosen, it is not on the list of parallels— and `apply_pages`, which hides
its row and releases its route even if the event has no pages that the draw
looks at. Only `clear_waits`, which runs on every map load, clears it: that is
why a jump to the same map does not undo it. **A parallel that runs it is
cut there** —`pair_ev`—, like `CommandEraseEvent` with `main_flag` false;
a foreground one continues until the end, as over there. What is not modelled, in
`divergences/what-erasing-an-event-does-not-model.md`.

**Measured** (`culprits --every-map`): Desert Nightmare, `EraseEvent` was the
first —157 pages, 127 alone— and it is no longer there; El Dorado, three alone, no longer
there; ABL, the one in 150 and the one in common event 36 compile. Desert's 157 are
parallels without a graphic.

**Desert Nightmare's intro: it was not this.** The intro ends the same
before and after: in black on the street (map 9), because its last page does
a `Teleport` to map 2, which the survey left out (`[maps] excluded`).
What does change is the WC scene (map 7): its event 4 is a parallel
that shows the picture `Lichteffekt_Tankstelle_WC` and erases itself, and before it did not
compile. Now the picture —a dark mask at 35% in RM2k— comes out opaque and
covers the room for ~480 frames: it looks like it hangs, but it continues. It is
the pictures' transparency, not the erasing; it is in
`/shared/capturas/2026-10-06-eraseevent/`.

**Tests**: three in the crate (`erasing_the_event_*`, one shown in red
before the fix) and `pruebas/rpgmaker/test_borrar_evento_de_verdad.py` in
ABL, with two new cases that go in `test-special` —in `release` the starting
map is the opening and does not let the page run—. **It does not cover** that the
event stops being drawn, that it stops blocking or that the parallel is cut:
the test event has no graphic and is not parallel. That was looked at playing
Desert Nightmare, no test enforces it.

**ABL's suite with the change's tools**: 1150 green (the 1147 from
before and the three new ones), no golden moved. `abl.sfc` changes
(`602b60e0…` to `8bb36b99…`) because of three things, all three expected: the runtime,
map 150 and common event 36, which now compile.

**At merge time**: reinstall `events cartridge convert rm2k-snes-audio` (the
new opcode changes what `bytecode` compiles), and in ABL bring in the branch
`huron/eraseevent`.
