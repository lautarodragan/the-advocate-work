---
name: "What gets merged in the screens doesn't go to the patches"
description: "Of what the converter loses in the windows, only the message window's colours reach patches/auto/; the colours of the 8bpp screens, the merged cells and End Game's stay in a WARNING in the log"
type: chore
status: wishlist
---

Tijereta said it on 2026-10-05 in
`window-with-more-than-15-colors.md`: the colours that get merged in the
8bpp windows (`borders.rs`: items, equipment, shop, actor choice)
"aren't written to the patches yet: that's what's missing from this task". And
`window-in-the-tile-bank.md` (2026-10-11) added more of the
same kind: the cells Adeleine merges so they fit in their bank
(`fit.rs`, `merge_least_visible_tiles`), the message window's background
that shows through the frame (`group_cells`) and End Game's colours
(`merge_until`).

**It is still like that** in the-advocate `fc6f7456`: the request to
`rm2k-snes-patches` (`convert.rs`, the `windows` key) carries only the
message window's colour merges, and `WindowDecision` in
`rm2k-snes/patches/src/lib.rs` has no room for the rest. Built today
with those tools (ports `a85b7e3`), Book of Three, The Frozen World,
Dooms 2 and Desert Nightmare say in `converter.log` "the actor choice's
windows take N tiles…", "the item and equipment windows…", "the shop's
windows…", "the message window's frame and arrow took N tiles…" and "End
Game's windows have more colours than its palette…", and in
`build/release/patches/auto/ventanas/` only the message window's remains.

What is lost with that: the question "what was lost" stops having a
single answer for those screens —it is the reason `patches/auto/`
exists—. Today only ABL versions its patches, and ABL fits without
merging anything, so there is still no diff that misses it: the first game
that versions them will miss it.

**How to see it**: `just cartridges release` in `book-of-three/` of the ports and
`grep WARNING build/release/converter.log`.

**Checked on 2026-10-16 (Mulita)**, at the-advocate 759aa0ba: still so —`WindowDecision` in `rm2k-snes/patches/src/lib.rs` holds
only the message window's merges—. The folder is
`build/release/patches/auto/windows/` since `5d78ada7`, which put the
names the tools write into a build in English.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
Only ABL versions its patches, and it merges nothing in those screens, so
nobody misses it yet. **Done** is `WindowDecision` holding the 8bpp
screens' colour merges, the merged cells and End Game's colours, and the
converter writing them into `patches/auto/windows/` as it does the message
window's, with a `rm2k-snes-patches` test per kind. First step: the shape
of each kind in `borders.rs`, `fit.rs` and `merge_until`.
