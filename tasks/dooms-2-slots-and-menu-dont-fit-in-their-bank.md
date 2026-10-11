---
name: "Dooms 2's slots and menu don't fit in their bank"
description: "With Dooms 2's map 1 (choose a character) in the cartridge, the slot screen and the menu gather more tiles than the 448 of their bank; the map is left out and the game starts on map 2"
type: bug
status: draft
---

Measured by Calandria on 2026-10-11 (`exclusions-left-over-in-the-ports.md`):
with map 1 in, "the slot screen and the menu gather 524 tiles and
their bank fits 448" with ABL's System, and 482 with the game's own
(Tijereta, `window-in-the-tile-bank.md`, who left it as a
"separate task": "they are faces, not windows"). It is probably the same
thing Carpintero left undone on 2026-10-06 in
`degrade-instead-of-failing.md`, point 4: "the names that don't
fit in the menu's bank… try it in Dooms 2"; it wasn't checked that it is
the same stop.

**Checked today** (the-advocate `fc6f7456`, ports `a85b7e3`): with map 1
returned and `start_map = 1`, `just cartuchos release` stops at
"rm2k-snes-screens: the slot screen and the menu gather 482 tiles and
their bank fits 448". The error comes from `rm2k-snes/screens/src/slots.rs`
(`SLOT_TILES_MAX`), without degrading: it stops the whole cartridge. That is
why `dooms2/rm2k-snes.toml` excludes map 1 and starts on map 2.

**What you see while playing**: the game doesn't show the character choice
—it starts on map 2, "Jack"—, and any event that leads to map 1 loses
the whole page (a `Teleport` to a map that isn't in the cartridge doesn't
compile).

What is known of the cause: it is the faces (Tijereta). That map 1 adds them
because it is where the character is chosen —more candidates for leader, each
with their face— is the obvious suspicion, not checked.

**How to see it**: remove 1 from `excluded` in `dooms2/rm2k-snes.toml` and
`just cartuchos release` in `dooms2/`.
