---
name: "The variables past 256"
description: "Vampires Dawn names 600 variables and the cartridge holds 256 (duplicate of variables-are-capped-at-256-slots): the pages that use one of the other 344 are left out"
type: feature
status: draft
---

Carpintero declared it on 2026-10-06 as a degradation
(`degrade-instead-of-failing.md`, point 2): the variables that don't have
room drop out of the list with a WARNING, the page that uses one is left
out, and so is an event whose page condition uses one. Before, it stopped
the build; now it is a loss that no task follows.

**Checked today** (the-advocate `fc6f7456`, ports `a85b7e3`): the
`converter.log` of Vampires Dawn's release says "the game names 600
variables and 256 fit in far RAM: the pages that use one of the 344 past
it are left out". None of the other eight games goes past 256.

**Not measured**: how many VD pages drop because of this. `rm2k-snes-events
culprits --every-map`, on the build's `compile` request, says so.

**How to see it**: `just cartridges release` in `vampires-dawn/` and
`grep "variables and" build/release/converter.log`.

**Duplicate, noted on 2026-10-16 (Mulita)**: the same cap is followed in
[`variables-are-capped-at-256-slots`](variables-are-capped-at-256-slots.md)
(Hurón, 2026-10-15), which says where it lives —a byte slot in the
bytecode and the converter's check— and counts what Vampires Dawn loses
(224 events for 145 variables). The 256 is no longer far RAM's: since
the-advocate `d121156e` the variables' region is sized by the game and
placed by the linker. This one stays because the book's Vampires Dawn
page links it.
