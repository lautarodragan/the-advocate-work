---
name: "ABL: map 11 back to the original"
description: "The stones and lights minigame plays well with the game's own map 11 now: drop the redesign's fork, its ChipSet if nobody else uses it, and what tests and docs say about it"
type: tooling
status: doing
assignee: Mulita
agents: [Mulita]
---

taro, on 2026-10-20, after playing a build of A Blurred Line without the
redesign of map 11 (ports `4749a8c`, the-advocate `796b4dc9`, map 11's
override removed; delivered apart in
`/shared/captures/2026-10-20-abl-original-stones/`): "now it runs
perfectly without the patch! We can remove it". The redesign was
[`map-11-redesigned`](map-11-redesigned.md): the original lagged, so its
light events became tiles of a custom ChipSet with terrains marking the
areas. The engine's optimisations since —among them baking still events
into the map: 22 of map 11's are baked today— made it unnecessary.

**Done**: `abl/patches/manual/maps/Map0011.*` gone; the ChipSet record
it used, if no other patch uses it; the tests and goldens that covered
the redesign either moved to the original map —the minigame still
played and won by the suite, if it was— or removed with a reason;
patches README, `rm2k-snes.toml` comments and the book updated; ABL's
suite green.

# Log

**2026-10-20, Mulita.** Started from the-advocate `8715b90e`, ports
`c333ab6` and docs `5959e14`, on branches `mulita-map-11-original`.

What the fork carried, and what goes with it: `Map0011.json` and
`.tiles` in `abl/patches/manual/maps/`, and `ChipSet/0053.json`
(`lasheint11`), which only map 11's fork names —18 uses 54, 32 uses 55,
the debug map 1000 uses 10—. The ChipSets are a `BTreeMap` by id in
`fork.rs`, so a gap at 53 is allowed and 54/55 keep their ids.

What relied on the redesign, found by grep over the ports, the-advocate
and the book:

* `tests/abl/test_lights.py`: written for the redesign —`sub_n`, the
  upper tile 10080 of cone B—. Rewritten over the original's events.
* `tests/harness/stones.py`: its docstring says the map read is the fork.
* `tests/tooling/test_pages.py`: the four variable slots above 204 were
  the redesign's parallel; without it they go.
* `tests/UNTESTED.md`: "the day the fork of map 11 brings its own
  ChipSet…".
* `patches/manual/README.md`: "Map 11…" and the contact-vs-parallel note.
* The book has nothing on the redesign outside research snapshots, which
  are not edited.
* the-advocate: comments on map 11 talk about the original's lights and
  the stones engine, which are back; nothing to change.
