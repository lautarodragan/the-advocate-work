---
name: "The slot screen shows no HP"
description: "Every save's row shows the level and not the leader's hit points, which RPG_RT writes after it: \"L 1\" where the original says \"L 1  HP 40\""
type: bug
status: draft
agents: [Hurón]
---

Seen by Hurón on 2026-10-20, with the-advocate `07b002f5` (branch
`huron-slot-names`) and the ports' `d9caad2`, in ABL's `release`, and in
every game: it is the engine's slot screen.

**What is seen**: a slot with a save shows "File 1", the leader's name and
"L 1". The original under Wine writes "L  1   HP 40" on that third line
—`Window_SaveFile::Refresh` in easyrpg: the `hp_short` term at x 46 of the
window's contents, in system colour 1, and the hit points in three
places—. The port's layout says so in `rm2k-snes/screens/src/layout.rs`
("three lines of text on the left"), without saying why the HP is not
among them. Since this branch the text starts at x 8 like the original's,
so the row has the room the original gives it.

**How to see it**: the golden `title-slots-long-names` against
`slots-original.png` (Chajá's, of 2026-10-14), side by side in
`sheet-long-names.png` of the captures of 2026-10-20, `slot-names`.
