---
name: "Frozen World: the B menu's lit option loses its text"
description: "The three pictures of the menu share fifteen colours, and the lit option's white letters on its white-to-blue bar come out the bar's colour"
type: bug
status: draft
---

Seen by Mulita on 2026-10-17, with the-advocate `939a8bd7` (branch
`mulita-fw-b-menu`), in snes9x, on Frozen World's beach (map 11): press
B —with switch 213, the first plate— and the menu shows; the lit option
is a flat pale bar where the original has a white-to-blue gradient, and
its text is gone or in pieces. The other two options read well. Captures
in `/shared/captures/2026-10-17-frozen-world-b-menu/`.

What it is: `MenuEquipPlates`, `MenuItemManage` and `MenuPartyStats` are
109x64 with 256 colours each, reduced to fifteen by `images::picture` and
sharing one sprite palette (`share_palettes` in
`rm2k-snes/convert/src/pictures.rs`). The bar's light end and the white
letters fall on the same colour. Whatever fixes it is a choice of which
colours a picture keeps —a text the bar holds weighs few pixels—, not of
the copies of the common events.
