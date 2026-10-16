---
name: "The converter still caps experience slots and variables by the hand-written far RAM map"
description: "rm2k-snes-battle refuses more than 126 experience slots because FAR_EXP had 504 B, and rm2k-snes-mapdata explains its 256-variable cap with 'FAR_ITEMS is 512 bytes from FAR_VARIABLES'; since far RAM is placed by the linker neither is the reason"
type: bug
status: draft
---

Seen by Hurón on 2026-10-16, while letting the linker place the far RAM map
([task](let-the-linker-place-the-far-ram-map.md)), with the-advocate
`762f7f92`.

**What happens**: since that change, `FAR_EXP`, `FAR_VARIABLES` and
`FAR_SKILL` are a `.res` sized by the game in `runtime/far_ram_game.s`.
Three checks of the converter were written against the old fixed regions
and still stand:

* `rm2k-snes/battle/src/experience.rs` refuses more than
  `SAVE_BYTES / 4` = 126 experience slots, "don't fit in the 504 bytes of
  FAR_EXP". Nothing in far RAM limits it now but the pool; what else limits
  the slot count (a byte index?) was not looked at.
* `rm2k-snes/mapdata/src/emit.rs` refuses more than 256 variables with
  "FAR_ITEMS is 512 bytes from FAR_VARIABLES". The cap is still real —the
  slot is a byte in the bytecode, see
  [`variables-are-capped-at-256-slots`](variables-are-capped-at-256-slots.md)—
  but the message gives the wrong reason.
* `rm2k-snes/events/src/indices.rs` caps skill pairs at `SKILL_SLOTS_MAX`,
  "`FAR_SKILL` holds"; the runtime comment says the converter stops past
  256 bytes. Whether something besides the old region needs that cap was
  not looked at.

**How to reproduce**: read the three messages; none of the nine games hits
them today.
