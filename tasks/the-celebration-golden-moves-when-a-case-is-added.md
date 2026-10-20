---
name: "The celebration's golden moves when a case is added"
description: "Adding one test case to ABL's test cartridge turns paradise-127-celebration red: two People4 farmers of map 127 come out with other sleeve colours, a palette that depends on the cartridge's layout"
type: bug
status: draft
agents: [Cardón]
---

Seen by Cardón on 2026-10-20, with the-advocate `8f290c39` —the global
tools, without any change— and the ports `68bf55b`, while writing the
golden of
[`battle-offers-skills-that-are-only-for-the-map`](battle-offers-skills-that-are-only-for-the-map.md).

**What was seen**: with one more file in ABL's `tests/cases/` —a battle
page, `battle-114-map-only-skills.json`, Emily and Radin against troop 114:
a `Teleport` to (60, 4, 11), `ChangePartyMembers` 10 out, 25 and 27 in,
`Wait` 10 and `EnemyEncounter` 114—, `tests/abl/test_farm.py::
test_the_celebration_with_the_slot_cache` goes red: `paradise-127-celebration`
differs from its golden in 338 pixels. Without the file it is green, with
the same tools. The case touches nothing of map 127.

The 338 pixels are two people of the celebration on map 127, both
`People4` index 2: event 30 (LawyerCouncil, at (20, 8)) and event 23
(Lawyer, at (24, 12)). Same pose, same shape, **other colours**: the
golden has their sleeves white, the capture blue. The RTP's `People4` index
2 has sleeves blue above and white below, so it is not clear which of the
two is right; that it changes with the layout of the cartridge is the bug
either way. The slot cache's own check —`slot_cache.on_screen`, that each
slot's VRAM has its pose— passes on both: it does not look at palettes.

**How to reproduce**: put the case above back in `tests/cases/` of the
ports and run `just tests tests/abl/test_farm.py` in `abl/`. The two
captures, side by side with their difference, are in
`/shared/captures/2026-10-20-map-only-skills/farm/`.

What to look at first: what decides the OAM palette of a slot-cache event,
and whether it can be read before it is written —a page refresh, the
upload queue— in a frame that moves with the layout (the celebration's
frames have moved before: see the comment of `_walking_pose` in
`tests/harness/slot_cache.py`).
