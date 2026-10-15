---
name: "Page conditions on switches past 1023 read other RAM"
description: "A page that asks for a switch past the ROM's 1024 is emitted with that number as is, and the console tests a bit beyond the switch bitmap: Vampires Dawn has 735 such pages on 253 maps, Frozen World 45 on 27"
type: bug
status: doing
assignee: Tijereta
agents: [Tijereta]
---

Seen by Hurón on 2026-10-14, with the-advocate `51b4b1b2` and the ports
`d91049e`, while writing the ports' `tests/test_walkers.py` for
[`events-that-walk-by-a-movement-type-stand-still`](events-that-walk-by-a-movement-type-stand-still.md).
**Seen in the ROM, not playing**.

**What happens**: the ROM keeps 1024 switches —`SWITCH_BYTES` is 128 in
`rm2k-snes-mapdata`— and the compiler refuses commands that touch a switch
past 1023 (`SWITCH_MAX` in `compile.rs`), but a page's **condition** goes
into the page table (`+4`, `+6`) with the number as is, and the console
tests that bit beyond `switches`, in whatever RAM follows. In Vampires
Dawn, map 433 ("Level"): the eight figures' page 3, the dead one, asks
for switch 1521, which reads as on from the start, so the page that wins
is the dead one and the figures that should flee lie there.

Counted over the dumps, pages that ask for a switch ≥ 1024: Vampires
Dawn 735 on 253 maps (up to 1643), Frozen World 45 on 27 (up to 1077),
the other games none.

**To reproduce**: the ports' `tests/`, a `Session` of Vampires Dawn past
its opening, `go_to_map(433, 14, 16)`, and read bit 1521 of `switches`:
it is 1; `pick_by_ev` picks offset `$40`, page 3, for events 0 to 7.

Two ways out: widen the bitmap where the game needs it, or have the
converter refuse —or treat as off— a condition past what the ROM holds.

**Correction** (Calandria, 2026-10-14): the compiler refuses a *branch* on a
switch past 1,023, not every "command that touches" one. `ControlSwitches` is
not checked and compiles with the number as is, writing past the table: see
[`branches-and-switch-commands-past-switch-1023`](branches-and-switch-commands-past-switch-1023.md).
