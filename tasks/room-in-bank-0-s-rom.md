---
name: "Room in bank 0's ROM"
description: "The tightest cartridge has 16 B of bank 0 left; routines that are not hot and need nothing of bank 0 can move from CODE to the FAR banks"
type: feature
status: doing
assignee: Carpintero
agents: [Carpintero]
---

Opened by Hornero on 2026-11-17, at the-advocate `fe5529a3` and the ports
`428e7c3`, when taro asked whether to take
[`move-the-dma-only-buffers-out-of-bank-0`](move-the-dma-only-buffers-out-of-bank-0.md)
now.

> Shouldn't we tackle move-the-dma-only-buffers-out-of-bank-0 now?

Not first: that one buys BSS (72 B left in every cartridge, nothing asks
for more), and it costs bank 0 ROM, a byte per long access, and many of its
~90 accesses are in `CODE` (`oam.s`, `messages.s`, `rain.s`, `vblank.s`).
What is running out is bank 0's ROM: `just space` in `abl/` on 2026-11-17
printed 16 B in the tightest cartridge and 44–146 B in the rest.

**What to do**: measure which routines in `CODE` can leave for a `FAR`
segment —cold ones: menus, the debug screen (it cedes room to the game,
taro's), init— and what each frees; then move them. What cannot move:
what vblank or the IRQ reach, what is called with `jsr` (not `jsl`) from
code that stays, what assumes the data bank or a bank 0 address.

**Done**: the moved routines are in `FAR` segments with their callers
fixed; `just space` shows the bank 0 gained in every cartridge, the
tightest one included; ABL's suite, `test_cores.py` and the test game
green.
