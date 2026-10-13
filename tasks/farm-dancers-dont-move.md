---
name: "The farm dancers don't move"
description: "In the dance on 127, 37 and 38 have a route and the spin animation, and in the ROM they stay still: the converter does not count them among the ones that walk"
type: bug
status: done
assignee: taro
---

Yaguareté saw it on 2026-10-03, while putting in the farm with the slot cache
(`tasks/sprite-slot-cache.md`). It predates the cache and was not followed
up.

Base: tools `fe0f90ee`, ABL `4cd8eb6`.

# The cause

`route::own` in `rm2k-snes-events` —what decides whether a page has its own
route, and from there whether its event walks as far as Wally is concerned
(`moves.rs`)— returned `None` for every page with the "spin" animation
(`AnimType_spin`, 5). Without its own route it is not one of the ones that
walk: it does not get the twelve poses, it does not ask for a route slot, and
it is drawn still, facing wherever its page says.

**It was on purpose, and it was a scope cut**: `git blame` gives the line in
`cc001fba` and its comment in `67a6e827` (the move to Rust, 2026-09-29), and
`git log -S spin` leads to `a80a37d7` (2026-09-05, "Los droides del mapa 2
caminan solos"), which left it out saying "the spin in place
(`AnimType_spin`, two pages) ... neither of the game's two pages that use it
is in the first maps". With 127 in the cartridge, one is.

# How many

Measured over the JSON of all of ABL's maps: **four pages** use "spin".

    map   event         route                        speed      in release?
    127   37 Farmer2    own, a square, repeats       3          yes
    127   38 Actress2   own, a square, repeats       3          yes
    64    3  AG7-17     none (still)                 1          yes
    227   3  AG7-17     none (still)                 1          no (>= 129)

The robot on 64 (switches 150 and 207, "Leaving Lashe City Scene") is the same
case without a route: it also stayed still.

# The fix

What RM2k does (`Game_Character::UpdateAnimation` and `UpdateFacing` in
EasyRPG): the count goes up every frame and on reaching 24, 16, 12, 8, 6 or 4
—by speed— it faces one quarter further clockwise; steps and `face_*` do not
turn it around; the column is the page's and nothing animates it.

* **Compiler** (`route::own`): a page that spins has its own route, with
  `"spin"` and `"pattern"` (the column). The one that spins without a route
  (`MoveType_stationary`) gets an empty one that repeats: the console only
  animates an event with a route slot.
* **Emission** (`rm2k-snes-mapdata`): the page's flags byte (+13) is full, so
  the spin goes in the speed one (+15): bit 7 spins, bits 4 and 5 the column.
* **Runtime**: `load_page_into_slot` masks the speed and sets bit 7 of +18 and
  the column in +10; `animate_ev_route` diverts to `spin_step` (in FAR,
  `far_npcs.s`, with its table); `move`, the jump's turn (`oam.s`) and `look`
  do not change which way one that spins faces; `remove_page_from_slot` clears
  the bit.

**Neither new RAM nor opcodes**: bit 7 of +18 of the route slot was used by
nobody.

# The cache and the route slots

In the dance two more start walking: 8 route slots out of 12, which the
celebration already released. With the cache, they ask for their own slot
(128 + event) instead of sharing a pose: the converter counts 17 still poses on
127 instead of 18, and the static peak stays at 33 against 30 slots (the same
warning as before; the celebration asks for 26). `test_farm.py`, which looks
at each event's VRAM frame by frame, stays green.

`just space release`, with main's tools and with these:

                 before     after
    banks        78 of 127  78 of 127
    bank 0       2,810 B    2,757 B
    bank 1       6,647 B    6,583 B
    BSS          125 B      125 B

# Tests (in ABL, branch `bailarines`)

* `rpgmaker/test_turn.py`, new: the two that dance spin clockwise every 12
  frames, without changing column, and they move; the robot on 64 (switches
  150 and 207) spins every 24 and does not move.
* `abl/test_playthrough_farm_golden.py`: in the dance, 37 and 38 have to move
  and show all four sides.
* **The red**, with main's tools: the walkthrough fails with "en el baile no
  se movieron [36, 37]", and `test_turn.py` with "dio 0 cuartos de vuelta" in
  both.

ABL's suite with these tools: all green, with the two new ones. **No golden
moved**: the suite's pass exactly, and the farm walkthrough's eleven come out
byte for byte identical to main's —in their shots the dancers are not on
screen, or the shot is taken before their first spin—. Captures of the dance
spinning in `/shared/captures/2026-10-04-bailarines/`.

**The suite does not cover**: a `face_*` or a jump on one that spins, a forced
route on it, and a page that spins with a column other than the middle one
(the game's four use the middle one). The robot on 64 is only checked through
its row: at that moment of the scene it is not seen on screen.

# When merging

Install `events`, `mapdata`, `convert` and `cartridge`: `just -f
tools/justfile install events mapdata convert cartridge` (`cartridge` builds
with the runtime).

# What taro has to test

* The farm dance: that 37 and 38 do their square spinning.
* Leaving Lashe (64) when the robot AG7-17 is there (switches 150 and 207):
  that it spins in place.
