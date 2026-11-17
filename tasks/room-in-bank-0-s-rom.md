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

## Carpintero, 2026-11-17

Branches `carpintero-bank0` in the-advocate (from `fe5529a3`) and in the
ports (from `428e7c3`).

### Measured before touching anything

`just space` in `abl/`, bank 0 and the two far banks cold code can go to
(`$C1` is `FAR3`):

| cartridge | bank 0 | bank 1 | `$C1` |
|---|---|---|---|
| release | 44 | 832 | 6275 |
| test-special | 70 | 855 | 6275 |
| test-encounter-every-step | 66 | 855 | 6275 |
| test-twins | 146 | 871 | 9753 |
| test-teleport-missing | 66 | 855 | 6275 |
| test-msu | 61 | 259 | 6245 |
| test-msu-rom | 65 | 855 | 6275 |
| test-change-system | 16 | 864 | 7165 |
| test-faces | 146 | 871 | 9290 |
| test-vblank | 49 | 871 | 7015 |
| test-title-4bpp | 127 | 871 | 9753 |

What is in `CODE`, from test-change-system's `.dbg` and ROM: each
top-level `.proc`, its size, and who calls it and with which opcode (a
throwaway script read the `ref=` of each symbol and the opcode at that
line's span). Then the call graph from two sets of roots: **hot**, what
`reset`'s loop calls, the NMI and `irq_music`, and anything referenced
from outside a `.proc` —dispatch tables, the bridges—; **cold**, the
screens (`title_screen`, `menu_screen`, `slots_screen`, `items_screen`,
`target_screen`), saving and loading, `battle_start` and what `reset`
calls before its loop. What only the cold ones reach is about 3.9 KB;
with the map's load (`load_requested`, `enter_map_no_events`) another
1.3 KB. The biggest, in bytes:

| routine | file | B | called from |
|---|---|---|---|
| reset (init + loop) | boot.s | 749 | vector, `jml` from three Game Overs |
| menu_screen | menu.s | 293 | move_hero `jsr` |
| items_screen | items.s | 229 | menu_screen |
| title_loop | title.s | 219 | title_screen |
| slots_screen | slots.s | 214 | menu_screen, op_save, title_loop |
| target_screen | menu.s | 195 | items_screen, the battle's bridge |
| slot_party_paint | slots.s | 181 | slot_paint |
| ppu_reset | boot.s | 140 | reset |
| slot_bank_upload, menu_upload | slots.s, menu.s | 135 each | the screens |
| battle_start | interpreter_shop_and_battle.s | 114 | move_hero, op_battle |
| menu_gold_write | menu.s | 114 | menu_upload |
| save_game | save_game.s | 97 | menu_screen, op_save |
| enter_map_no_events | enter_map.s | 409 | map load |

By file, what each has in `CODE`: save_game.s 341, slots.s 907, title.s
366, menu.s 1004 (of which ~250 hot: `request_menu`, `access_*`,
`key_value`, `actor_gfx_*`), items.s 560, boot.s 1013.

**How cold code calls bank 0**: wrap.s already had `CALL0`, which pushes
its own long return and a bank 0 return to a lone `rtl` and `jml`s in;
it keeps A, X, Y, flags and widths. It is now general (registers.s, its
`rtl` in boot.s): one bank 0 byte for every caller, instead of a
four-byte `_l` entry in bank 0 per routine called.

### The screens, out (commit 2)

save_game.s, title.s, slots.s and items.s whole, and menu.s from
`menu_enabled` on, to `FAR3`. Inside, they call each other with `jsr`
as before; what bank 0 calls is entered with `jsl` and leaves with
`rtl` (`title_screen`, `title_loop`, `menu_screen`, `slots_screen`,
`save_game`, `load_game`, `save_entry`, the new `save_menu`, which is
`op_save`'s body); what they call in bank 0 goes through `CALL0`; the
`scr_*` wrappers are skipped for the `tl_*` they wrap. `set_slot` was a
`sta slot`, and is that now. Two of the routines set the data bank with
`phk`/`plb`, which in `$C1` would point it at ROM: `pea $8080` and two
`plb`. The battle's bridges to these (`ba_t_ppu`, `ba_t_target`,
`ba_t_list`, `ba_t_build`) moved with them.

test-change-system: bank 0 15 -> 3011 B; `$C1` 7165 -> 3948.
`test_jumps_between_banks.py`, `test_linter.py`, `test_banks.py` and
`test_space.py` green on all eleven cartridges.
