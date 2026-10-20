---
name: "The invisible walls lost when trimming events"
description: "When a map goes past 120 events, the trim also leaves out invisible walls: on eight maps of Desert Nightmare the hero can pass where the original stops them"
type: bug
status: doing
assignee: Aguará
agents: [Aguará]
---

Measured by Carpintero on 2026-10-10 (`events-that-dont-fit-in-the-map-ram.md`):
when a map goes past the 120 events of RAM, `Game::trim`
(`rm2k-snes/convert/src/trim.rs`) leaves out what loses the least, and the
third class is "an invisible wall". Desert: "9 lose decoration and 8
of those invisible walls". He himself left noted what remains: "the
invisible walls could go into the map's passability, and the decoration
be baked (`decorative_events`) instead of lost: the trim runs before
Wally, so today what goes away isn't baked".

**Checked today** (the-advocate `fc6f7456`, ports `a85b7e3`): the
`converter.log` of Desert Nightmare's release gives the same lists as on
2026-10-10. These lose invisible walls (wall only, or drawing and wall):

| map | events with a wall that go away |
|---|---|
| 2 Dusty Creek | 5 |
| 4 Werkstatt | 23 + 27 |
| 5 Wohngegend | 11 |
| 14 Polizeirevier | 20 + 27 |
| 61 Werkstatt-Nacht | 23 + 28 |
| 62 Wohngegend-Nacht | 13 |
| 66 Polizeirevier-Nacht | 20 + 26 |
| 172 Alte Minensiedlung | 12 |

In Vampires Dawn, map 164 (Thessa) loses two with drawing and wall,
events 253 and 254 (also checked today, in a VD build with its
own System: the trim doesn't depend on that).

**What you see while playing**: on those maps the hero walks through cells that
are blocked in the original. Which ones they are, and whether they let you reach
somewhere you shouldn't, wasn't looked at in an emulator.

**How to see it**: `just cartridges release` in `desert-nightmare/` and
`grep "lose an invisible wall\|looks and a wall" build/release/converter.log`;
the event numbers are on each line.

## Defined (2026-10-16, Carpintero)

A wall that goes away can open a way the original closes, which can
break a game. **Done**: an invisible wall the trim leaves out becomes
blocked passability of its cell when the event is still and its pages
never change that —else it stays a candidate to keep—; Desert
Nightmare's eight maps and Vampires Dawn's 164 no longer list walls lost
in `converter.log`, and a converter test holds it. **First step**: for
each wall listed, whether any page of it moves, erases itself or changes
its layer.

## Measured again (2026-10-20, Aguará)

At the-advocate `8f290c39`, ports `68bf55b`, `just cartridges release`:
the twins (`trim::twins`, 2026-10-17, `5b3c2a9f` —walls on the hero's
layer can share a row—) saved four of Desert Nightmare's eight maps: 2,
5, 62 and 172 no longer lose a wall. Four still do, and VD's 164 too:

| map | invisible walls | looks and a wall |
|---|---|---|
| DN 4 Werkstatt | 23 | 27 |
| DN 14 Polizeirevier | 20 | 26 |
| DN 61 Werkstatt-Nacht | 23 | 28 |
| DN 66 Polizeirevier-Nacht | 20 | 25 |
| VD 164 Thessa | 0 | 2 (253 254) |

So the fix is still needed.

## First step: what each lost wall is (2026-10-20, Aguará)

Read from the dump: of DN map 4's 50 and map 14's 46, and VD 164's two,
every one has no commands, nobody names it, no move type and no route.
All are one page on the hero's layer without conditions, except four of
map 14 that have two pages: one below the hero and one on his layer,
one of them under a switch —a wall that comes and goes—. Those four are
not still; the other 94 (and the night maps' copies) are.

## What was done

`trim::still_wall` (the-advocate, `rm2k-snes/convert/src/trim.rs`): an
event that runs nothing and nobody names, with every page on the hero's
layer, none that walks or has a route, and one page without conditions
—so a page is always active; conditions are not read, any page may be
the active one—. Such a wall is `Loss::StillWall` (or
`LooksAndStillWall` if drawn), ranked right after the ones that do
nothing (resp. right after the drawings): it loses nothing (resp. only its
looks). Its cell goes in the Wally request's new `walls`, and Wally
closes it in the passability (`rm2k-snes/wally/src/layers.rs`), as it
already did for a decorative event on that layer. A wall that can stop
being one keeps its old classes, after the drawings.

Touch triggers: a wall with a page that runs is not a wall but `Pages`,
never baked. The doors filter is not involved: the codes are the
schema's fields, nothing is written by eye.

Broader option, not done: bake every still wall before the trim, in every
map. It frees rows and costs nothing at run time, but changes every
cartridge with one —ABL's too— for maps that fit, and moves the divergence
(an event on another layer that walks into it is stopped; in RM2k it is
not) to maps that have no reason to pay it. Recommended only if some map
needs the rows.
