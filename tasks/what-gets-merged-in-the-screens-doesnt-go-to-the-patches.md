---
name: "What gets merged in the screens doesn't go to the patches"
description: "Of what the converter loses in the windows, only the message window's colours reach parches/auto/; the colours of the 8bpp screens, the merged cells and End Game's stay in a WARNING in the log"
type: chore
status: draft
---

Tijereta said it on 2026-10-05 in
`la-ventana-con-mas-colores.md`: the colours that get merged in the
8bpp windows (`borders.rs`: items, equipment, shop, actor choice)
"aren't written to the patches yet: that's what's missing from this task". And
`la-ventana-en-el-banco-de-tiles.md` (2026-10-11) added more of the
same kind: the cells Adeleine merges so they fit in their bank
(`fit.rs`, `merge_least_visible_tiles`), the message window's background
that shows through the frame (`group_cells`) and End Game's colours
(`merge_until`).

**It is still like that** in the-advocate `fc6f7456`: the request to
`rm2k-snes-patches` (`convert.rs`, the `windows` key) carries only the
message window's colour merges, and `WindowDecision` in
`rm2k-snes/patches/src/lib.rs` has no room for the rest. Built today
with those tools (ports `a85b7e3`), Book of Three, The Frozen World,
Dooms 2 and Desert Nightmare say in `conversor.log` "the actor choice's
windows take N tiles…", "the item and equipment windows…", "the shop's
windows…", "the message window's frame and arrow took N tiles…" and "End
Game's windows have more colours than its palette…", and in
`build/release/parches/auto/ventanas/` only the message window's remains.

What is lost with that: the question "what was lost" stops having a
single answer for those screens —it is the reason `parches/auto/`
exists—. Today only ABL versions its patches, and ABL fits without
merging anything, so there is still no diff that misses it: the first game
that versions them will miss it.

**How to see it**: `just cartuchos release` in `book-of-three/` of the ports and
`grep WARNING build/release/conversor.log`.
