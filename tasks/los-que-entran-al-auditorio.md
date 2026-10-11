---
name: "The ones who walk into the auditorium"
description: "On map 18 (Auditorium), WalkIn1 and WalkIn2 walk in in RM2k and not in the ROM"
type: bug
status: done
assignee: taro
---

From taro, on 2026-09-30, while playing: "in the auditorium there are two
NPCs who walk in; in the original game they walk in and in the ROM they
don't".

They are `WalkIn1` (event 16, at (13,10)) and `WalkIn2` (event 9, at (6,8))
of map 18. They're moved by page 1 of event 36, an autorun with switch 77:

    ChangeEventLocation 16 → (10,14)
    ControlSwitches 86 ON          ; WalkIn1 moves to its page 2
    MoveEvent 16 (frequency 8): 0,0,0,0,1,1,1,12
    Wait 5
    ChangeEventLocation 9 → (8,14)
    ControlSwitches 87 ON          ; WalkIn2 moves to its page 2
    MoveEvent 9: 0,0,0,0,0,0,3,3,12
    Wait 10
    …

Hornero's suspicion, unverified: the page change from the switch, right after
the `ChangeEventLocation` and before the `MoveEvent`, overwrites the position
or the route. See `decisiones/la-pagina-activa-se-congela-hasta-el-refresco.md`.

# What was seen in the ROM

With `grupo-11-en-18` and switch 77 turned on from outside, frame by frame
(RAM: `ev_pos_buf`, `npc_buf`, `route_ev` and the OAM):

* **the position and the route are fine**: 16 appears at (10,14), goes up to
  (10,10) and turns to (13,10), one step every 16 ticks; 9 appears at (8,14)
  some 30 ticks later and ends at (6,8). The forced route survives the page
  change —the slot keeps bit 0 off, and `remove_page_from_slot` doesn't touch
  a forced one—. Hornero's suspicion wasn't it.
* **what doesn't work is the drawing**: the row is visible, follows the event
  and its object is in the OAM, but the screen doesn't change a single pixel
  along the whole way. The object draws an empty graphic.

# What RM2k does

* easyrpg, `Game_Event::RefreshPage`: a page change doesn't touch the
  position nor the forced route; it changes the graphic (`SetSpriteGraphic`),
  the speed and the frequency.
* The 2015 RPG_RT with Wine, with a copy of the game that starts on 18 with
  the scene (page 1 of 36 without a condition and a `ControlSwitches 77` in
  front, written with `ditto write`): **both are seen going up the aisles**,
  with the green graphic of `Future2` index 6, without stopping.

# The cause

Page 1 of both draws `Future2` at **index 7, which is an empty slot of the
sheet** —a single color, the transparent one—, and page 2 index 6. An event
that walks and changes graphic keeps only one —"walking wins",
`divergencias/un-evento-que-camina-no-cambia-de-grafico.md`—, and that was
the one of its row: since no page is active on load, the one of the first
page that draws something, which is the empty slot.

There's no commit that broke it: "walking wins" is from `403eea38`
(2026-09-08) and since then the chosen one was the first. They were never
seen. It has nothing to do with the page frozen until the refresh: that
decision isn't touched.

# The fix

In `rm2k-snes-maps`, before counting poses and palettes: `pin_walkers`
(`tools/rm2k-snes/map-sprites/src/npc.rs`). For an event that walks and
changes graphic, **an empty slot of the sheet counts as "draws nothing"**,
which is what it is in RM2k: the row walks with the first graphic of its
pages that has pixels, and the pages with the empty slot hide it —they go
with the `outside` graphics, so the page doesn't carry a pose with bit 7—.

The test is `rom/pruebas/rpgmaker/test_rutas_auditorio.py`: that they pass
through the door and the middle of the aisle and end up seated, and that
where the ROM puts its object the screen differs from the empty aisle. With
the earlier ROM, the position ones were green and the drawing ones **red, 0
pixels in the 16 ticks** of each.

The ROM changes on two maps: 18 and 44 (Talan Stats), where Arden and Saldra
have the same pattern —page 1 with `BLPeople` index 3, empty; page 2 with
`Chara2`/`Chara3`—. I didn't look at 44 on screen.

No golden moved. Screenshots, before, after and the RPG_RT side by side, in
`/shared/capturas/2026-09-30-auditorio/`.

# The same pattern on other maps

`ChangeEventLocation`, a switch that changes the same event's page and a
`MoveEvent` of it, across all maps of the dump: **4 times on 2 maps**. The
two of 18, and Drago and Sern of 167, which have a single page —the switch
makes them appear, which the ROM already does— and besides, 167 isn't in the
cartridge. What the bug had in common wasn't the pattern but the sheet's
empty slot, and the fix covers that across the whole game: the build changes
only 18 and 44.

# Left aside

The frequency: easyrpg, in `RefreshPage`, gives the event the new page's
frequency (3) even if it has a forced route of frequency 8, and with that it
would stop 64 frames between steps. In the RPG_RT video they walk without
stopping, like the ROM, so it wasn't touched; I didn't measure it frame by
frame.

# When merging

Install `maps` in the global —`just -f tools/justfile install maps`—: the fix
is in `rm2k-snes-maps` and its library `rm2k-snes-map-sprites`. Run `just
pruebas` and `just -f tools/justfile test` on the merged tree.
