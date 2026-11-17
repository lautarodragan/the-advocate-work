---
name: "ABL: the Linkage Block's screen stays dark"
description: "On map 2 the computer screen at (39,69)-(40,70) is four events that cover the panorama; when Core gets in, a MoveEvent raises their transparency five times and RM2k shows the starry panorama through them; the port ignores the transparency moves and the screen stays dark"
type: bug
status: done
assignee: taro
agents: [Chajá]
---

taro, on 2026-11-16, with captures from RPG_RT, Mesen and EasyRPG's
editor in the shared folder, `captures/2026-11-16-taro-abl-computer-screen/`:

> The computer screen in Linkage Block (39,69)-(40,70) doesn't show the
> panorama when it turns on. I never reported this because I thought it
> was by design —that the hardware didn't let us show the panorama on
> this map—, but I just found out that we're already rendering it, hiding
> BG1 in Mesen. LBScreenTopLeft (etc.) normally cover the panorama until
> Core manages to "hack" the computer. I think what happens is that we
> don't honour these commands, the `MoveEvent`s that do
> `IncreaseTransparency`, which eventually hide those events completely,
> letting the panorama be seen. In the original game, I suppose that
> looks like a fade-in, but we could make it on/off and that's it,
> tracking the transparency and hiding them if opacity = 0 /
> transparency = 100% / whatever.

What the data says (Hornero): map 2's events 11-14 (`LBScreenLeft`,
`LBScreenRight`, `LBScreenTopLeft`, `LBScreenTopRight`) draw ChipSet
tiles (indices 16 and 22), no CharSet, below the hero, one page with no
condition. Events 15 and 16 (`SeeCompPanelTop`) move each of them with
five `IncreaseTransparency` (move command 40) after "Got it! I'm in.", and
elsewhere five `DecreaseTransparency` (41).

Done means: RM2k's transparency steps on an event are tracked —what RM2k
does with each step, from EasyRPG's `Game_Character`, and what the
console can show: hidden at full transparency, as taro proposes, and
whatever is honest in between (half-transparency of an object is colour
math the port may or may not have)—; map 2's screen shows the panorama
after Core gets in, measured in a ROM test; the decrease brings them back.

## Log

**2026-11-16, Chajá.** At the-advocate 3f3eede3, the-advocate-ports 4e3bfac.

The cause. `compile_route` (`rm2k-snes/events/src/compile.rs`) accepts 40
and 41 and drops them, noting `route-transparency-dropped`: `git blame`
gives cc77d4e1 for the comment, which moved there with the rest of the
Python's whys on 2026-09-29 (the Python, `tools/port/events.py`, had done
the same since the scene first compiled). On purpose: "the SNES does not
fade a sprite in steps without color math", and dropping them is what let
map 2's 78-command scene compile. A route left with nothing is not even
emitted, so the four screens never got a route. The wishlist task
[route-transparency](route-transparency.md) said the same.

What RM2k does (EasyRPG `Game_Character::UpdateMoveRoute`,
`Game_Event::RefreshPage`, `GetOpacity`): a level 0 to 7, clamped; 40
raises it, 41 lowers it, neither costs a frame (the branch that does not
touch the stop counter); a new page sets it to 3 if the page is
translucent and 0 if not; inside a jump they are not run. Opacity is
`(8 - level) * 32 - 1`: 255, 223, 191, 159, 127, 95, 63, 31. **It is never
invisible**: five 40s leave the screens at 95/255, which is why RPG_RT
shows the stars with the screen's grid faint on top.

The survey of the eight ports (MoveEvent routes decoded with
`route::decode`'s operands; a raw count of 40s gave false hits from the
letters `(` and `)` of graphic names): ABL only map 2's eight routes (events
15/16 on 11-14, five 40s and five 41s); El Dorado 350 routes, mostly
one 40 per call on cars and obstacles; Vampires Dawn 37 (lights that fade
themselves, map 95's, the hero 7 up and 7 down on maps 16 and 58); Sunset
over Imdahl 6 (map 10 the hero 7 up/7 down, map 15 events 3 and 4 10 up,
8 down); Zounds 3 (map 4's intro, the hero 5 up and 7 down; map 13
`Viejo Loco` 1 and 1). No page's own route has a 40 or a 41 in any of
them. Several targets are on translucent pages (El Dorado map 5, Vampires
Dawn's lights): their level starts at 3, so one 40 hides them.

The fix, all or nothing as taro proposed, with RM2k's level kept:

* the compiler emits 40 and 41 into a `MoveEvent`'s route (dropped only
  inside a jump, as RM2k does), noting `route-transparency-all-or-nothing`;
  a page's own route still drops them (none of the eight games has one);
* the ROM keeps an event's level in its row's +14, which was 0/1 "drawn"
  and is now 0 or one plus twice the level, so every reader that only asks
  "drawn?" is untouched; `build_oam` hides the row from level 4 on
  (`TRANSP_HIDDEN`), `ev_transparency` (far, `jsl`) moves it, clamped;
  the hero's is `hero_transp` beside `hero_hidden`, saved with it;
* a page whose graphic follows the page sets the level again —3 if
  translucent (bit 6 of the page's pose byte), else 0—, and the converter
  starts a row at 3 when its page at load is translucent (wally's `Npc`
  and the page records carry `translucent`);
* half drawn is colour math, tried for translucent events and left out
  (the book's "Colour math for translucent events"): not done.

Cardón's concern (posed_events): with the 40s emitted, `route_turns` no
longer counts a fading event as "only turned", so `posed::select` keeps it
an object ("a route moves it"); before, the route was not even emitted, and
a fade-only event was eligible. Guarded by
`a_route_that_fades_an_event_does_not_only_turn_it` in `pages.rs`.

Tests: `a_route_raises_and_lowers_the_transparency` (events crate, red with
the `path.push` taken out); `rpgmaker/test_route_transparency_golden.py` in
ABL, with the case `screen-fades` —map 2, four screens five 40s, the hero
four, then all back—: red before on the old tools (levels stay `[1, 1, 1,
1]`), green after; its golden `screen-fades-270` shows the stars in the
screen and no hero. The events crate's `python.json` hashes of both `maps`
moved: the test game's map 1 event 1 has a 40; with the push out, the
answer was the old one.

Verified, on the branches with main merged (the-advocate `chaja-lb-screen`
d9837b8e, the-advocate-ports `chaja-lb-screen`, the book
`chaja-lb-screen`): ABL's `just tests` with these tools, 1661 passed and 2
skipped; `just boot` of the eight ports, 153 passed (before the merge);
the-advocate's `just test` (29) and `just rust-test`, green;
`just test-game` red only on `test_leader_name`'s three captures, the same
three on 3f3eede3 with the global tools: the draft
[the-test-games-leader-name-goldens-are-red-on-main](the-test-games-leader-name-goldens-are-red-on-main.md).
The save grew a byte (`hero_transp`): saves from before do not load.

Install on merge: `just install events wally mapdata convert`, from
the-advocate (`screens` compiles Wally in but only gained a field, it
need not be reinstalled). The runtime change rides on the checkout.

Not covered by any test: the hero's level travelling in a save; a
translucent page starting at 3 (no ABL scene fades one; El Dorado's map 5
and Vampires Dawn's lights do); the level kept when the same page is set up
again after a battle. Side by side with RPG_RT:
`captures/2026-11-16-lb-screen/` in the shared folder.

**2026-11-17, taro**: declared done.
