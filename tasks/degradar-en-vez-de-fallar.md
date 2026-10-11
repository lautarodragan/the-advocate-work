---
name: "Degrade instead of failing"
description: "The limits that today stop the whole game or map lose only what doesn't fit, with a warning: EraseScreen/ShowScreen, more than 256 variables, more than 8 route graphics per map, the names that don't fit in the menu, the title that doesn't fit in VRAM"
type: feature
status: testing
agents: [Carpintero]
assignee: taro
---

From taro, on 2026-10-06: cheap shortcuts to unblock the other games, along
the same line as the surplus samples. From the survey
(`docs/research/2026-10-05-otros-juegos.md`) and from the brief analysis of the
four games.

## Done (Carpintero, 2026-10-06)

Each point in its own commit. None has an end-to-end test outside the
games (there is no test game with those limits): rebuilding covers them.
When merging, `events` and `convert` have to be reinstalled.

1. **EraseScreen / ShowScreen**: accepted doing nothing, in
   `ACCEPTED_UNDONE` (the runtime has no "screen to black" that doesn't
   overwrite a tint). Debt: the map stays visible where the original goes
   black; in Desert, the start menu comes out over a background of VRAM
   garbage. Unit test.
2. **More than 256 variables**: those left without a slot drop out of the list
   with a WARNING; the page that uses one was already left out; the *event* whose
   page condition uses one is left out with a WARNING (it was a fatal
   error); and a value that doesn't fit in a byte (`byte()`) leaves the
   page out instead of stopping the conversion (the 263 of a route). Vampires
   Dawn now gets past this (it names 600 variables).
3. **ROUTE_GFX_MAX**: the order 34 graphics that don't fit are ignored
   with a WARNING (`Graphics::index_capped`, with a unit test); the sprite
   associations past the ceiling are discarded the same way. El Dorado and
   Sunset build without exclusions.
5. **The title that doesn't fit**: the converter checks it against the limits
   that `title.s` asserts (544 picture tiles, 704 for the menu) and starts without
   a title with a WARNING. Desert and Frozen build without `--no-title`.

## Not done

4. **The names that don't fit in the menu's bank**: it costs more than the
   cheap stuff. The names are composed at runtime with tiles from the bank, so
   degrading means deciding what gets cut or omitted in `screens`, and
   trying it on Dooms 2, whose ROM is Mulita's. It stays as it was.
- **Vampires Dawn doesn't build yet**, because of limits that aren't these: maps
  with a panorama that doesn't fit, battle animations with no room in the
  sprite bank (twenty-five excluded and they keep appearing) and the message
  window, which asks for 262 tiles against 256. Each one is another "degrade
  instead of failing" per map.
- Desert Nightmare's exclusions stay: which ones depended on EraseScreen
  wasn't tried.
