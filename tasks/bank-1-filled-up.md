---
name: "Bank 1 filled up"
description: "After Picaflor's common events and Aguilucho's large pictures, bank 1 of release has 131 B left: move code to the far bank so the next features have room"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-10-02: "the refactor to free up those banks". Bank 1
of `release` was left with 131 B free (`just espacio`), between the autorun
common events and the shared `CallEvent` (Picaflor) and the large pictures
(Aguilucho). It's like what Pirincho did with bank 0's tables
(`item-and-theme-tables-out-of-bank-0.md`), but with code.

## What was measured before (2026-10-02, Pepitero, on `cb333da4`)

`just espacio`, bank 0 / bank 1:

    release                    1,063 B / 131 B
    test-special               1,081 B / 131 B
    test-encounter-every-step  1,077 B / 131 B

`abl.sfc` of `release`: `6643d2c1…`.

**`FAR` is bank 1**: the `.cfg` loads it into `BANK01`, `$01:8000`. There's no
separate "far bank" to move bank 1's stuff to: hand-written code had two
banks, `CODE` (0) and `FAR` (1), and both were full. So the
first thing was **opening a third**.

What takes up bank 1, per file, with the `.dbg` (each line with its span):
the battle is 15,589 B —`battle_scene.s` 5,261, `battle.s` 2,804,
`battle_skills.s` 2,253, `battle_troop.s` 1,548, `battle_run.s` 1,262,
`battle_victory.s` 1,123, `battle_loop.s` 953, `battle_items.s` 385—; then
`shop.s` 2,267, `msu_effects.s` 1,631, `level.s` 1,537,
`equipment_screen.s` 1,486, `big_picture.s` 1,346, `picture_far.s` 1,225,
`decompress.s` 1,189, and the rest under a KB.

## The third code bank: `FAR2`, in the lower half of `$C0`

It was the last data space in the fast 4 MB, and no cartridge used it
(`release` leaves the lower halves of `$C0` and `$C1` free). Being an
ExHiROM half it's always fast, with no mirror: what lives there is entered with `jsl` at
its address, and it doesn't need the copy in the second 4 MB that
banks 0 and 1 have. `banks::FAR2` in `rm2k-snes-cartridge`, and `just espacio`
shows it as "bank $C0".

The commit that opens it doesn't move the ROM: the three cartridges come out byte for byte
identical, because that half was zeros. `ld65` warns that the
`FAR2` segment doesn't exist until something uses it, in the next commit.

## What was moved

**The battle, from bank 1 to `FAR2`** (`222007f6`), with a commit before
(`ad142a2c`) that switches to `jsl` what it called outside. The eight `battle*.s` in
the list above are a closed group: among themselves they call with `jsr`, and
outside they only called four things with `jsr`, which became `jsl`:

    exp_add              level.s         rts -> rtl; battle_loop.s with jsl
    gold_add             shop.s          rts -> rtl; shop.s and battle_victory.s with jsl
    battle_fade_showing  battle_fade.s   rts -> rtl; battle_run.s with jsl
    msu_data_seek/valid  msu1.s          entries msu_data_seek_l and
                                         msu_data_valid_l; battle_scene.s
                                         uses them, msu_effects.s stays with jsr

The ones that enter the battle already used `jsl f:` without `+ FAST` —`battle_run`,
`ba_enemy_change`, `ba_show_hidden` (interpreter_shop_and_battle.s) and
`scene_cgram_restore` (enter_map.s)— and didn't change. The only `+ FAST` that
pointed inside was the `jsl` to `scn_double`, from battle_scene.s itself.
The battle's tables were already read with `f:`, because the data bank is
`$7E` while it lasts.

**What changes without being seen**: the battle ran from `$01`, the slow copy of
bank 1, and now it runs from the fast 4 MB. The goldens didn't move.

**The audio package, from bank 0 to `FAR2`** (`d09c4232`): `audio_package.s`
is the biggest thing in bank 0 that doesn't run every frame —it's called when loading
a map, at boot and when starting a theme—, and it runs at the same speed,
because bank 0 runs from `$80`. Four `_l` entries at the end of the
file, and their callers switch to `jsl`: `aram_clear_l` and `package_load_l`
(boot.s), `package_load_l` (enter_map.s), `package_load_done_l`
(battle_bridges.s) and `song_ensure_l` (music.s). Inside it called `dsp_pair`
with `jsr`, and it switched to `dsp_pair_l`, which already existed.

**How the callers were found**: besides the `grep` of each routine, a
throwaway script that walks the `.dbg` —each line of `tools/runtime/` with
its address— and flags every absolute `jsr`/`jmp` whose destination is in another
bank, and every absolute read of a ROM label outside bank 0. It gave
0 on the baseline, and 0 after each move.

## What was left unmoved

* **The rest of bank 1** wasn't needed: it was left with 14 KB free. The
  biggest things still there —`shop.s`, `msu_effects.s`, `level.s`,
  `equipment_screen.s`, the pictures— are cold and could be moved just the same: the
  shop and the equipment form one group (`shop.s` calls `equipment_screen.s`
  with `jsr`), and the pictures another (`picture_far.s` and `big_picture.s`).
* **From bank 0, the hot stuff**: `event_pages.s`, `music.s` (`irq_music`),
  `oam.s`, `vblank.s`, `event_routes.s`, `tint.s`, `hero.s`, `cells.s`. They run
  every frame or in the interrupt, and call everything with `jsr`.
* **From bank 0, the cold stuff that doesn't pay off**: the menu screens (`menu.s`,
  `slots.s`, `items.s`, `title.s`) are cold, but they call many bank 0
  routines —`title.s` fourteen—, and each one requires a four-byte bridge:
  `title.s` would free some 240 B out of 313. `save_game.s` (365 B) does pay off
  —it calls a single routine outside—, but it's called from six files.

## The rule

In the header of `tools/runtime/main.s` (`598376c9`), which is where whoever
adds a file sees it: what goes in `CODE`, in `FAR` and in `FAR2`; that a
subsystem goes whole in one bank; that between banks it's `jsl`/`rtl` with an
`_l` entry; that `FAR2` is entered **without** `+ FAST`; and that none of that is
checked by the assembler. The project's README adds a line in the
ExHiROM section that points there.

**Proposal, not done**: the `.dbg` script as a test in
`rom/pruebas/herramientas/`, so that "nothing checks it" stops being true. It reads
the operand from the source with a regular expression, so it's heuristic.

## The numbers

`just espacio`, before and after:

    bank 0    release 1,063 -> 2,868 B; test-special 1,081 -> 2,886;
              test-encounter-every-step 1,077 -> 2,882
    bank 1    131 -> 14,204 B in all three
    $C0       (didn't exist) -> 16,852 B free of 32,768, in all three

The commits:

    f026d255  the third bank: the three cartridges identical byte for byte
    ad142a2c  what the battle calls outside, with jsl
    222007f6  the battle to FAR2
    d09c4232  the audio package to FAR2
    598376c9  the rule in main.s and the old prose: only comments, same ROM
    d5013576  `bank_far2` in rm2k-snes-space's JSON and in test_espacio.py

Each commit that moves the ROM, with `just pruebas` green —1000, and 1001 with
the new space test— and the goldens identical. Final `abl.sfc`:
`35c76500…`. `NO_CACHE=1 just cartuchos` gives the same. `just -f tools/justfile
test`: 39. `cargo test -p rm2k-snes-cartridge`: green.
`test_musica_techos.py` and `test_cores.py` pass inside `just pruebas`.

**On merging**: `just -f tools/justfile install cartridge` —
`banks.rs` (the `.cfg`) and `rm2k-snes-space` changed—. Without that, the global assembler
doesn't declare `FAR2` and the build fails.
