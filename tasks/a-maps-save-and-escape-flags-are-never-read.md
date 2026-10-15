---
name: "A map's save and escape flags are never read"
description: "The tree's per-map can-save, can-escape and can-teleport tri-states are not read by anything: ABL forbids saving on 75 of its 308 maps"
type: bug
status: doing
assignee: Mulita
agents: [Mulita]
---

Seen by Cardón on 2026-10-14 (`what-the-compiler-ignores-silently.md`),
tools `14e200fc`, ports `f775b66`.

**What is seen**: not played. Each map of the tree has `save`, `escape` and
`teleport` set to inherit, allow or forbid, and `rm2k-rules`' tree resolves
only the music and the battle background by inheritance. Nothing reads these
three, so the pause menu's Save follows only `ChangeSaveAccess`, where RM2k
also greys it on a map that forbids it.

**How much ABL uses it**: resolved over the parents, 75 of the 308
cartridge maps forbid saving, all under "The Kingdom of Surl" (map 210:
Memnosyne's Adobe, the Surl roads and ruins), and map 105 forbids escaping.
Other games: Dooms 2 forbids saving on 88 of 92 maps; Vampires Dawn on 430
of 430, escaping on 377 and teleporting on 422.

**How to see it**: `maps.json` of the dump, `save` of node 210 is 2
(forbid) and its children inherit with 0; nothing in the Rust names the
field outside Ditto's schema. Not played: from the code, the pause menu's Save on one of those maps
follows only `ChangeSaveAccess`.

### Mulita, 2026-10-15

Started from the-advocate `99140946`, ports `94e794c`, book `33e9cfe`.

**What RM2k does** (easyrpg `Game_Map::Setup`, `game_map.cpp`): each of the
three climbs the parents while it says 0, a parent 0 ends the climb as
"allowed" —the root's own values are never read—, and only 2 forbids. The
result is written **over the same `Game_System` flags** that
`ChangeSaveAccess`/`ChangeEscapeAccess`/`ChangeTeleportAccess` set: there is
no separate "map flag" that combines with the command's, the last writer
wins. `Setup` runs on a change of map and on a new game; a jump to the same
map does not set up again, and loading a save goes through `SetupFromSave`,
which keeps the save's flags.

**Two things the assignment assumed that RM2k does not do:**

* **The map's escape is not the battle's Escape command.** easyrpg's only
  reader of `GetAllowEscape` is `IsSkillUsable` (and `Game_Party`'s copy):
  the Escape skill, which teleports to the escape point. The battle's
  Escape depends only on `EnemyEncounter`'s escape mode (`allow_escape`),
  and a random encounter always allows it. So a battle on map 105 keeps
  Escape enabled, as it does in RM2k; the comment in `compile.rs` that
  called `ChangeEscapeAccess` "the permission to escape from a battle" was
  wrong and is fixed.
* **On ABL the map's save cannot be seen.** Common event 2,
  `DisableSaving` (no switch: forbids while 236 is off), and 8,
  `EnableSaving` (switch 236: allows), write the permission whenever they
  run, which in RM2k is every frame: the map's forbid is overwritten one
  frame after entering. So the "menu on a Surl map with Save greyed"
  test cannot exist without being unfaithful; the save table is tested
  against the tree instead, and the same runtime path is tested through
  the escape bit, which nobody overwrites. It shows on Dooms 2 and
  Vampires Dawn, which have no such common events (not played).

**What was done:**

* `rm2k-rules`: `Tree::access(map) -> Access { save, escape, teleport }`,
  `Setup`'s climb, with a loop guard.
* converter: `emit::access_bits` turns it into `FAR_ACCESS`'s "forbidden"
  bits —save $01 and escape $04, the ones the commands already use, and
  teleport $08, new, which only a map sets— and each map's record carries
  it as `access`.
* `rm2k-snes-mapdata`: `map_access`, one byte per map in cartridge order,
  in RODATA (not bank 0).
* runtime: `map_access_enter`, in FAR2: replaces the $0D bits of
  `FAR_ACCESS` with the map's byte and owes the pure parallel common events
  a run, so 2 and 8 put theirs back on the next frame as RM2k's every-frame
  run does. Called from `load_requested`'s load branch (not the same-map
  one) and from the two new-game paths (`title.s` `leave`, `boot.s`
  `fresh`); not from the load-a-save paths. No far RAM.

**Tests** (ports, `tests/rpgmaker/test_map_permissions.py`, five new
cases): the table against `maps.json` climbed in Python; 105 forbids
escaping on entering; a page's `ChangeEscapeAccess` 0 is given back by a
`Teleport` to a map that allows; a jump to the same map keeps it; loading a
save made on 105 after allowing it keeps it allowed; on Surl (213) with 236
on, saving stays allowed. With main's tools the first three are red —the
table's symbol is missing, and the bit— and the other three green (they
guard the paths that must not set up); with the branch's, all six green.
Rust: `rm2k-rules`' `a_map_inherits_what_it_allows_from_its_parents`,
mapdata's `each_map_carries_what_it_forbids_in_its_order`, and the two
"as the Python wrote it" checks strip the new table.

Divergence: `divergences/what-a-maps-permissions-do-not-model.md` in the
book.
