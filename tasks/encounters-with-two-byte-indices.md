---
name: "Encounters with two-byte indices"
description: "The encounter tables use one byte per index and Vampires Dawn has 779 troops and 136 zones: make them fit, instead of stopping the build"
type: feature
status: done
agents: [Tijereta]
assignee: taro
---

Cardón found it on 2026-10-06 measuring Vampires Dawn: with the maps that
didn't fit left out, `rm2k-snes-battle` fails because the encounters don't
fit in one-byte tables (121 records, 136 zones, 779 troops).

taro, on 2026-10-06: "Go ahead!", with Sonnet.

## Done, on 2026-10-06 (Tijereta)

`enc_map` (with `$FFFF` for "no encounters"), `enc_zone_init` and
`enc_troop_init` are word tables; `ENC_REG` is a word, in the
ninth byte of `$3900` that was already free: **there is no new RAM**, no
opcode was touched. `enc_zone_n` and `enc_troop_n` stay as bytes, the counts
*inside* a record or a zone, and the converter stops if any goes past
255. Ceilings: 8191 records (`record * 8` in a 16-bit offset) and 32767
troops. Fixed width and not variable per game: it costs a few hundred bytes.

The one-byte ceiling was from when there were 53 records, 56 zones and 322 troops
(its comment says so): there was no decision to respect. Of the three only
the troops went past 255 in Vampires Dawn; the other two fitted, but
I widened them anyway as the brief asked.

Another table with the same ceiling didn't turn up: `BA_TROOP` and `enc_troop` were already
words. **A hidden consumer did turn up**: the converter's `scene.rs`
read the JSON's `per_map` and compared with `0xFF`; with `$FFFF` every
map seemed to have encounters and the cartridge loaded extra backgrounds
(`test_scene_a_battle_whose_backdrop_is_missing_uses_the_fallback` showed it
red). Now it compares with `NO_RECORD`, written twice because `convert`
doesn't link `battle`.

### Measured on Vampires Dawn
With Cardón's clone (maps excluded) the battle **gets through**: 102 maps with
encounters, 117 zones and 646 troops (with 23 more maps out). What stops it
next, and it is of the "doesn't fit" kind that we already degrade and I didn't touch: first the
maps with more than 104 NPCs in OAM (6, 130, 164, 201, 205, 208, 210, 216, 218,
239, 240, 323, 332, 333, 341, 347, 379, 381, 383, 390, 393, 409, 412, 429,
which I excluded in my clone), and with those out, map 1: "a stream of anim_tiles
is 27264 bytes and 8192 fit in WRAM". What comes after that I didn't see.

### Verified
- New crate test red before (300 maps, `the encounters don't fit
  in one-byte tables`) and green after; the two hashes of the tables' text
  changed on purpose, stated in the test. Tests of `battle` and of
  `convert` green.
- A Blurred Line's suite with my tools: 1150 green, including
  `test-encounter-every-step` (the same troops). No golden changes.
  `abl.sfc` went from `8bb36b99…` to `aaae70c2…`: the tables are wider and
  the runtime reads them differently, as expected. ABL's test that read
  `ENC_REG` as a byte I switched to a word (branch `tijereta-encuentros-dos-bytes`
  of the clone `/extras/scratch/tijereta/abl2`).
- Not covered: the battle with more than 255 troops **running in the ROM**: no
  test executes an encounter with the troop index past 255 (the test
  game doesn't have that many). The new path, `enc_troop_init` as a word,
  is executed by ABL's encounters with small indices.

When merging, reinstall: `battle cartridge convert`.
