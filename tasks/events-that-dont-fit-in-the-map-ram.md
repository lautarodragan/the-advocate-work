---
name: "The events that don't fit in the map's RAM"
description: "EV_MAX: a map with more than 120 events cuts the build; make the ones that matter fit, and warn"
type: feature
status: done
assignee: taro
agents: [Carpintero]
---

From the report of `npcs-that-dont-fit-in-oam.md`: `EV_MAX`, 120 events per map, RAM of bank 0. 38 maps of Vampires Dawn and 11 of Desert Nightmare exceed it.

## What was measured (2026-10-10, the-advocate 27010065, ports bd64aed)

Each event is a row of `ev_pos_buf` (4 bytes), `ev_flags` (1) and
`pick_by_ev` (2) in bank 0, and in several places the index is a byte
("EV_MAX is 128"). The maps that go over reach 328 events (VD 28), so
raising the cap is no way out.

What the leftover ones are, per map (script in
`~/scratch/carpintero/eventos/medir.py`): in Vampires Dawn, 24 of the 38
have more than 120 events **with commands**; almost all are strips of
invisible events, below the hero, on touch, with `ControlSwitches` +
`Teleport` to the same destination —the map's edge, 70 cells that lead to the
same place of map 1— or with a `ControlVariables`. In Desert Nightmare
what is left over is mostly events that are only seen (graphic, no commands).

## What was done

Two steps, both in the converter (`convert/src/trim.rs`, `Game::trim`),
before any stage reads the map:

1. **Twins, without losing anything.** Events with the same pages, invisible,
   still, outside the hero's layer, unnamed, without autostart
   or parallel pages, which are not erased and do not name "this event":
   the one with the lowest id keeps the row and the others are a cell in a
   ROM table behind the map's positions (a word with how many
   and 6 bytes each). `twin_in_cell` (`runtime/action_key.s`) looks at it
   when no row is on the cell. New RAM: none (it uses `npc_ptr`).
2. **If that is not enough, what loses the least is left out**: nothing, only how
   it looks, invisible wall, looks and blocks, pages that run, named;
   within each class the highest id. The event stops existing: the
   compiler and Wally receive `dropped_events` and read the map without it.

Measured: with the twins no map of VD or of Desert loses a page
(without them, 22 of VD lost exits). VD: 24 of 38 fit whole, 14
lose decoration. Desert: 2 of 11 fit, 9 lose decoration and 8 of
those invisible walls. `~/scratch/carpintero/eventos/recorte-*.txt`.

`--test-events-max` lowers the cap for the tests: ABL's `test-twins`
cartridge (map 255) and `test_gemelos.py` cover the ROM's
path.

Branches: `carpintero-eventos` in the-advocate, in the ports and in the book
(`src/divergences/events-that-do-not-fit-in-the-ram.md`). At merge time,
reinstall `convert events wally mapdata`, and not `cartridge` (it did not change:
the runtime comes from the checkout). `abl.sfc` changes on purpose; the whole
suite green without moving goldens.

What remains: the invisible walls could go into the map's
passability, and the decoration be baked (`decorative_events`) instead of lost:
the trimming runs before Wally, so today what goes is not baked.

## The decision

It is lost, and what is chosen. The converter decides it when reading the game
(`convert/src/trim.rs`, `Game::trim`), and the map is read without them in the
three stages that read it —the converter, the compiler and Wally—: the
compiler and Wally receive it in their requests, `dropped_events`, and so the
indices are the same everywhere. An event that goes stops existing:
a page that names it does not compile.

Order, from what loses the least to what loses the most; within each class, the highest
id first:

1. nothing: no commands, nobody names it, it does not draw, it does not block;
2. only how it looks;
3. an invisible wall (in the hero's layer);
4. how it looks and a wall;
5. pages that run;
6. named by someone (its pages and the ones that name it).

"Naming": `MoveEvent`, `ChangeEventLocation`, `TradeEventLocations`,
`FlashSprite`, `ShowBattleAnimation`, the branch on an event's direction,
`ControlVariables` with a character as operand and `CallEvent` of an event
of the map; in the map's pages, the common events and the test ones.

## The lossless way out (done: the twins)

Measured before doing it with `~/scratch/carpintero/eventos/fusion.py`. What
it cost: a word per map in the `ev_pos` block (the record was
full in its 128 bytes, so there was no new field), 6 bytes per twin,
some 70 bytes of `CODE` in bank 0, and one more test cartridge.
