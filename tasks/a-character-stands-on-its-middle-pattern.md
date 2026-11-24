---
name: "A character stands on its middle pattern"
description: "RM2k draws an event on its page's pattern only with a fixed graphic or spinning; any other stands on the middle one, and the ROM draws the page's pattern: a step where RM2k shows feet together"
type: bug
status: draft
author: cardon
links:
  relates: [abl-the-hover-tram-s-crowd-is-cut]
---

Seen by Cardón on 2026-11-18, in
[`abl-the-hover-tram-s-crowd-is-cut`](abl-the-hover-tram-s-crowd-is-cut.md),
with the-advocate at `44e25d4f` and the ports at `45ed2bf`.

**What happens**: on ABL's Hover-Tram (map 13) five people of the standing
row —`EV0016` to `EV0020`, `Future3` 6— have pattern 2 on their page and
animation type 0. RPG_RT 2015 under Wine draws them on pattern 1, feet
together; the ROM draws pattern 2, mid-step (the golden `tram-trip-10`
before the Hover-Tram's fork). EasyRPG says the same as RPG_RT:
`Game_Event::SetupFromPage` sets the page's pattern only for
`AnimType_fixed_graphic` and `AnimType_spin`, and every other character
starts on `Frame_middle`.

**Where**: `page_graphic` in `rm2k-snes/convert/src/maps.rs` takes
`page.pattern` whatever the animation type; `git blame` gives the move of
the Python converter to Rust, not a decision.

**How much**: 78 pages of ABL, on 46 maps, have a pattern other than 1
with an animation type that is neither 4 nor 5 (counted over `data/maps/`).
Map 13's no longer count: its fork bakes those five on the middle pattern,
as RPG_RT draws them.

**How to see it**: map 13 at the start of the trip, in RPG_RT and in a ROM
built before the fork —the five backs at (3,9), (5,9), (11,9), (12,9) and
(15,9) step in the ROM—. Captures side by side in
`/shared/captures/2026-11-18-hover-tram-patch/`.
