---
name: "The variables past 256"
description: "Vampires Dawn names 600 variables and far RAM has room for 256: the pages that use one of the other 344 are left out"
type: feature
status: draft
---

Carpintero declared it on 2026-10-06 as a degradation
(`degradar-en-vez-de-fallar.md`, point 2): the variables that don't have
room drop out of the list with a WARNING, the page that uses one is left
out, and so is an event whose page condition uses one. Before, it stopped
the build; now it is a loss that no task follows.

**Checked today** (the-advocate `fc6f7456`, ports `a85b7e3`): the
`conversor.log` of Vampires Dawn's release says "the game names 600
variables and 256 fit in far RAM: the pages that use one of the 344 past
it are left out". None of the other eight games goes past 256.

**Not measured**: how many VD pages drop because of this. `rm2k-snes-events
culprits --every-map`, on the build's `compile` request, says so.

**How to see it**: `just cartuchos release` in `vampires-dawn/` and
`grep "variables and" build/release/conversor.log`.
