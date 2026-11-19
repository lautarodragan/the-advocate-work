---
name: "A second event on a cell is never asked"
description: "The action button, a bump and a step look at the first event standing on the cell and stop there; RM2k fires every one whose trigger matches. Desert Nightmare's box puzzle on map 12 cannot be climbed, and the middle of the gate on map 2 leads nowhere"
type: bug
status: draft
game: desert-nightmare
agents: [Hurón]
---

Seen by Hurón on 2026-11-19, at the-advocate `62b6e5cb` and the ports
`1ea90bf`, playing Desert Nightmare's `release` through the harness
(snes9x) for
[`desert-nightmare-what-it-takes-to-be-playable`](desert-nightmare-what-it-takes-to-be-playable.md).

**What is seen**:

* **Map 12, the box at the wall** (day 1, right after the dog): pushed to
  (12, 4), the box (event 81, its page 2 an action page with no
  commands) stands on the same cell as event 87, the touch page that
  climbs to map 13 once variable 202 is 5. Bumping into it from (12, 5)
  does nothing. With the box's row moved off the cell by hand —its
  `ev_pos_buf` entry, row 80, written to (0, 0)— the same bump climbs to
  map 13 at once.
* **Map 2, the gate north** (day 1, after Jake opens it): the three cells
  (12, 0), (13, 0) and (14, 0) are the same teleport to map 4, events 150
  to 152, two of them twins of the first. The two sides teleport; the
  middle one, the straight way through the gate, does not: the dog
  (event 148), sent there by Jake's scene and invisible since, has its row
  on (13, 0) and is found first, so twin 151 behind it is never asked.

`event_in_cell` (`runtime/action_key.s` in the-advocate) returns the first
row whose cell matches, and the twins only when no row does; RPG_RT —and
easyrpg's `Game_Player::CheckEventTriggerThere`— walks every event on the
cell and fires each whose page has the trigger sought.

**To reproduce**: the stages `twins`, `box` and `box_proof` of
`~/scratch/huron/dn/stages.py` (Hurón's throwaway playthrough, with save
states in `~/scratch/huron/dn/states/`). Captures in
`/shared/captures/2026-11-19-desert-nightmare/two-events-on-a-cell.png`.
