---
name: "The Book of Three: the intro's torches stand still"
description: "Map 3, the opening's hall, has six still events that animate in RM2k; the console animates four at most, and here none"
type: bug
status: done
assignee: taro
agents: [Mulita, Calandria]
---

Seen by Mulita on 2026-10-15 in the port's opening, next to the
original under Wine, with the-advocate `fa9d1a14` (and `362d3765` for
`degradations.json`) and the ports `0ca371b`, in The Book of Three.

**What is seen**: the hall shown behind the opening text (map 3) has six
flames whose pages animate standing still; in the port they are drawn
still (seen). In the original they were not watched closely: the data says
they flicker.

**What the build says**: `still-animation-dropped`, "map 3: 6 still events
animate in RM2k and the console animates 4 at most: none does" —see
[More than four still events that animate](https://github.com/lautarodragan/the-advocate-docs/blob/main/src/divergences/more-than-four-still-events-that-animate.md)
in the book—.

**How to see it**: boot the release and watch the opening.

taro, on 2026-10-15: they saw them still every time they played and could not tell whether it was on purpose. Take it on.

## Calandria, 2026-10-15

Started from the-advocate `97b51db6` and the ports `d9006cc`, on
branches `calandria-still-animations` in each and in the book.

**What map 3 has**: events 3 to 8, all `Crown7` index 3, pose 7,
continuous animation, layer "same as hero", no commands — and **speeds 6,
5, 6, 2, 6 and 4**: the author made them flicker out of step on purpose.

**Before** (`still-animation-dropped` in each `release`'s
`degradations.json`, maps / events): ABL 14 / 345, Bo3 1 / 6, DN 0, Dooms2
0, ElD 7 / 57, FW 1 / 8, SoI 16 / 297, VD 93 / 1525.

**The budget, with poses on the fly** (since 2026-09-05, before the cap of
2026-09-09): a still event that animates costs **one VRAM slot** —a 32x32
block, 16 object tiles— and its character's twelve poses in the
cartridge, not twelve resident poses; the cap's comment said "twelve
tiles". The phase of the still animation is global (`ticks`), so two of
them with the same (CharSet, index, pose) **and the same speed** show the
same column on every frame: they can share the slot, with one of them
uploading. That was not possible: each had `Slot::Event` of its own.

**The plan**:

* group them by (CharSet, index, pose, speed): one uploads —bit 7 of +13,
  as today— and the rest point their tile at its slot without animating;
  one that turns, changes graphic or is sent walking by a test page keeps
  a slot of its own;
* the one that uploads does it **even hidden** (a new bit 6), so erasing it
  does not freeze the rest;
* no fixed cap: animate everything, and if the map does not fit, drop
  whole *looks* —(CharSet, index, pose), all speeds— from the last, until
  it fits without losing anything else; only then the old chain.

**Done** (the-advocate `ef8a6ae4`): as planned. Map 3 takes four slots
for its six torches (the three at speed 6 share one) and all six
animate. The new ROM test, `tests/test_book_of_three_torches.py` in the
ports, looks at the four torches the text does not cover over 180 ticks
once the text is open: red with the tools of `97b51db6` (a single drawing
each), green with these. It had to wait for the text: during the fade
in from black the cells change too, and the first version passed red.

`just test` 29 passed; `just rust-test` 906 passed, 0 failed.

**A first version made events wait** (Vampires Dawn's 236 and 240 went
to a cache with waits, and 201 and 222 one more): in a cache every one
that animates wants its own slot while in view. Fixed in `7aa66900`: a
cache with waits does not count as fitting, fewer looks go first, and if
events wait even with none animating, none animate when that leaves
fewer waiting.

**After** (the-advocate `7aa66900`, ports `66a83f3`, maps / events): ABL 1
/ 61 (map 148: 61 `Crown7` torches at two speeds, a map whose ground is
fused to fit; the animation goes before more fusion), Bo3 0, DN 0,
Dooms2 0, ElD 0, FW 0, SoI 8 / 153, VD 5 / 126 (102 animates one of its
three looks; 201, 222, 236 and 240 are cache maps). No other kind of
`degradations.json` moved but `events-wait-for-a-slot`: SoI 12 → 11, VD 9
→ 8 (map 77 no longer waits).

**Poses on the fly** does not change the math: it was already one slot
per animating event when the cap was measured (2026-09-09, poses on the
fly since 2026-09-05). What it adds is vblank: each group's leader
uploads a pose when its column changes, through the same queue as the
walkers; sharing means one upload per group instead of one per event.

Book (`calandria-still-animations`, `69e147c`): the divergence is now
"Still events that animate past the sprite bank", with a redirect; the
lossy entry and the phase's page updated; Bo3's Known issues line gone.

**The race paid for it** (ABL, `test_the_whole_race`): the 29 cars
parked along map 49 animate now (four groups), and the lap went from 45
extra frames in 976 ticks to 68 with the limit at 48 (5 per hundred).
Measured, each with the lap of map 49:

    animate_still returning at once                45
    walking the rows every frame, no row animating 53
    as first written (rows and division each frame) 68
    one upload per frame, the rest later           68 (cap), 56 (with gating)
    walking only on the tick of a change (gate)    49
      same, without the uploads                    46
    remembering where the rows were (hints)        49, left out

The race is at the cliff —21 when its limit was set—, and frames tip by
tens of cycles. `animate_still` now walks only on the tick of the soonest
column change (`still_next`) or when someone else touched such a row's
pose (`still_touched`: full queue, bank reload, turn, page graphic,
route, cache slot), and stops after the map's count of animating rows
(the padding of `anim_table`, now a count). The last frame went into the
test: `EXTRA_FRAMES` 5 → 6, in its own ports commit, a judgement for
taro to confirm.

Merging `main` (FAR3, Chajá) was needed: before it Sunset and Vampires
Dawn did not link, on main's own bank 1 and FAR2.

**Drafts**:
[`abl-the-sixty-one-torches-of-map-148-stand-still`](abl-the-sixty-one-torches-of-map-148-stand-still.md)
(Paradise Burning's fires; in ABL's Known issues) and
[`a-forced-route-on-a-still-event-that-animates-reads-its-flags-as-speed`](a-forced-route-on-a-still-event-that-animates-reads-its-flags-as-speed.md).

**What no test covers**: the bit-6 path —the uploading twin erased or
hidden while the rest stay—; `still_touched` from the turn, a page's
graphic, a route and a cache slot on a still event that animates (none
of the eight ports has one turning, and the cache maps animate none
today); the hidden twin is reasoned, not seen.

**Verified on the merged tree** (the-advocate `da83ab02`, ports
`2ae6d06`, with `main` merged in all three; tools from the worktree:
wally, mapdata, convert, cartridge, and screens and events because
`main` changed them): `just test` 29 passed; `just rust-test` 911 passed,
0 failed; ABL's `just tests` 1,555 passed, 2 skipped, and no golden
moved; `just boot` at the ports' root 44 passed, the new torches test
among them. The race's lap of map 49: 49 extra frames in 976 ticks.

**To install when merging**: `just install wally mapdata convert
cartridge` from `~/the-advocate` —the runtime changes too, so the
cartridges rebuild—.

Branches `calandria-still-animations` in the-advocate, the ports and the
book.
