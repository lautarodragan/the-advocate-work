---
name: "A teleport to a map not carried is dropped, not the page"
description: "A Teleport to a map the cartridge does not carry leaves the whole page out today; drop the command with a warning instead, so the rest of the page runs"
type: feature
status: done
assignee: taro
agents: [Hurón]
---

taro, on 2026-10-15, about The Frozen World —whose combat maps 1 and 2 are
excluded, which leaves out 324 pages on 72 maps that teleport into them—:

> for now, can teleports to maps that don't exist not stop the page from
> compiling, but leave a warning and be excluded from the runtime?

Today the `TELEPORT` arm of `compile_command` (`rm2k-snes/events/src/compile.rs`)
returns `cannot()` when `ctx.map_index` has no index for the destination.

## Log

Hurón, 2026-10-15. Branches `huron-tp` in the-advocate (`8d6bc064`),
the-advocate-ports (`ad36f90`, `ec2cb90`) and the-advocate-docs (`fe8ebb5`).
Install on merge: `events` and `convert`.

* The `TELEPORT` arm returns, when `map_index` has no index, a `ShowMessage`
  of `Teleport to missing map N` (RM2k's id) through the same
  `Messages::add_waiting`; without a text block it still returns `cannot()`.
  Around it: `after_jump` is not applied to such a teleport (the page goes on
  on the same map) and the song pre-scan does not count it as an exit. The
  other uses of teleport destinations (`scan.rs`, `map_pictures.rs`) only
  read the id and are harmless. `MemorizeLocation` names no map and
  `ChangeVehicleLocation` is not compiled at all: neither is touched.
* The warning is in the converter, not in the compiler: the compiler has no
  channel for it (`Graphics::index_capped` has none either, its `dropped`
  is collected by the scan). It is one line per map, `N teleport(s) to a map
  that didn't make it into the ROM, each a message box instead: ids`.
* `python.json`: three hashes moved on purpose (the fixture has a teleport
  out of the cartridge); noted in the header of `python.rs`.
* Red/green: `a_teleport_to_a_map_not_carried_is_a_message_box` fails with
  the old arm and passes now. The ROM case `teleport-missing` has its own
  cartridge `test-teleport-missing` and `test_teleport_to_a_missing_map.py`
  (run green; not shown red against the old tools).
* **`abl.sfc` is byte for byte equal**: `6fd411779ff4...` before (main's
  build) and after (rebuilt with the local tools). ABL's suite: 1539 passed,
  2 skipped. `just test` 27, `just rust-test` green.
* **`test-special` moved**: its game maps teleport to maps it lacks, so it
  carries ~1.1 KB more text, and `text-crosses` fell off the bank edge;
  `push` lost 13 boxes (92 bytes each) to put it back. Not a golden change.
* **`just culprits` does not see this**: it compiles with every map
  carried, so before and after are both `3871 compile of 3891`. The number
  that moved is the converter's: Frozen World's 324 pages on 72 maps used
  to be left out; now they compile.
* **Finding, draft updated**: The Frozen World stops converting at map 3
  (the hero-flash stop of `flashing-hero-shares-a-palette-with-an-npc`),
  which the dropped pages were hiding, so its after-count was not measured
  and the port does not build until that is dealt with. Dooms2 (15 maps with
  the warning) and Vampires Dawn (132) do build.
