---
name: "Let the linker place the far RAM map"
description: "Move the 24 KB of $7E2000-$7E7FFF written by hand into segments the linker places, sized by the game: 3.5 KB (ABL) to 5.6 KB (Sunset) of slack and holes become one pool, and just space says what is left in total"
type: feature
status: testing
assignee: taro
agents: [Hurón]
---

Suggested by Hurón on 2026-10-15, in the study
[`the-wram-and-sram-map-measured`](the-wram-and-sram-map-measured.md),
with the-advocate `6fa69781` and the ports at `f015801`. It is the plan
the book's decision "RAM is placed by the linker" already names as the way
`FARBSS` grows, done once for everything.

**What was measured**: the map of `$7E2000`–`$7E7FFF` holds, in ABL's
release, 21,049 B in regions written by hand, with 3,218 B of slack inside
regions whose cap was chosen for any game (`FAR_EXP` 504 B for 92 used,
`FAR_SKILL` 256 for 32, `FAR_ENCOUNTER` 256 for 9…) and 309 B of holes
between them —the same ten holes in every game—. In Vampires Dawn the
slack is 3,720 B, in Sunset 5,293. `FARBSS`, the 832 B the linker hands
out today, has 12 B left in ABL.

**What it costs**: 198 constants with the bank in front, 88 sixteen-bit
ones read with the data bank at `$7E`, and 238 derived from them, in
eleven files of the runtime; the blocks that are walked as a range
—`clear_variables` wipes from `FAR_MSG_OPTIONS` to the inventory's end in
one pass through the `WMADD` window; each line of `save_table` is a DMA—
have to stay contiguous and in order, as one segment each or one `.res`
with offsets. The ROM changes everywhere and the behaviour nowhere: the
goldens are the net, with `test_wram_reservations.py`, which has to learn
the new segments, and `test_decompressed_load.py`.

**What to decide**: whether to do it whole or subsystem by subsystem, and
in which order the segments go so that what is saved as a block and what
reset clears stay contiguous.

## Progress (Hurón, 2026-10-16)

Taken from the-advocate `7b0bdcb3` and the ports `b5da6ce`, branches
`huron-linker-far-ram` in both. Decided: whole, in two commits —the
relocation alone, with every region keeping the size it had, and then the
sizes by the game—, and the switches' table loading into the same area, so
`just space` gives one number for the 24 KB.

**The relocation** (the-advocate `fb156a3e`, the ports `649bf19`): every
region of the hand-written map is a `.res` in `FARBSS`, the long names as
labels and the sixteen-bit ones as `.loword` of a lowercase label
(`far_battle`, `FAR_BATTLE`), with their internal offsets as they were. The
`FARRAM` area is `$7E2000`, 24 KB. Measured on ABL's release: **no code or
data label moved** —no instruction changed size or addressing mode— and
573 far symbols did; what kept its value is registers, VRAM and SRAM
addresses, seeds and caps, and the two first regions, which land where
they were. The one thing ca65 refused is a link-time address in an 8-bit
immediate (`LVL_LINES_MAX`), which went back to a constant.

The guard in ABL's `test_wram_reservations.py` changed: in the symbol
table a `.loword` of a label and a hand-written number look the same, so
it looks for far addresses written by hand in the runtime's source.

**Sized by the game** (the-advocate `d121156e`): the regions the game sizes
—the pairs, the variables, the inventory, the actors' tables, the skills,
the experience, the troop pages, the slot cache, the sound effect places,
the samples, the rain— get their `.res` in `runtime/far_ram_game.s`, right
after the cartridge's `.inc`, and the fixed ones take what their layout
reaches. The text layer's size is a number, `TL_BYTES`, asserted equal to
what text_layer.s lays out. It moved the battle's state to `$42xx`, where
its sixteen-bit names fell on the registers' numbers and ABL's
`test_jumps_between_banks.py` took them for registers: it now looks at an
`=` as a register only if it is defined as a number (the ports `d595985`).
The actors' cap is the next commit, `762f7f92`: see
[`nothing-caps-the-actor-count-against-far-hp`](nothing-caps-the-actor-count-against-far-hp.md).

**What `just space` says of far RAM**, before (FARBSS's pool and the
switches' 256 B, apart) and after (the whole 24 KB, switches included),
each game's `release` and ABL's test cartridges:

| cartridge | before: FARBSS | before: switches | after |
|---|---|---|---|
| abl release | 15 | 128 | 3,459 |
| abl test-special | 231 | 128 | 3,978 |
| abl test-encounter-every-step | 231 | 128 | 4,237 |
| abl test-twins | 267 | 128 | 4,138 |
| abl test-teleport-missing | 267 | 128 | 4,285 |
| abl test-msu / test-msu-rom | 207 | 129 | 3,921 |
| abl test-change-system | 229 | 128 | 4,284 |
| abl test-title-4bpp | 279 | 129 | 4,387 |
| book-of-three | 219 | 128 | 4,975 |
| desert-nightmare | 277 | 128 | 5,196 |
| dooms2 | 195 | 128 | 4,731 |
| el-dorado | 315 | 128 | 5,351 |
| frozen-world | 279 | 121 | 4,381 |
| sunset-over-imdahl | 282 | 128 | 5,495 |
| vampires-dawn | 67 | 50 | 3,955 |
| zounds | 195 | 128 | 4,586 |

**The save does not change**: its layout in SRAM is `save_table`'s order
and lengths, untouched, so saves from before load.

**Verified**, with the branch's tools (`just install-local .local-tools
cartridge`): ABL's whole suite, 1,563 passed and 2 skipped, goldens
unchanged —`test_wram_reservations.py` and `test_cores.py` included—, and
green on the relocation alone too (1,555); `just rust-test`, `just test`
and `just test-game` in the-advocate; `just boot` at the ports' root,
whole, 46 passed —Book of Three's playthrough, milestones, endings,
reraise and torches, and the eight games' boot—. Book: the decision's
"How it applies", branch `huron-linker-far-ram` of the docs.

What the suite does not cover: a game whose sizes differ from the nine's
(more actors, more samples) is only checked by the asserts and the link.
The converter's caps written against the old regions are left as they
were: draft
[`the-converter-caps-what-far-ram-no-longer-limits`](the-converter-caps-what-far-ram-no-longer-limits.md).

To install when merging: `cartridge` (`just install cartridge`).
