---
name: "The save carries its version"
description: "That a save from another build be rejected cleanly instead of loading corrupted"
type: bug
status: done
---

Since `release` and `test-main` are a single cartridge (2026-09-25), the
saved game changes size every time a case names a new variable or brings a
new troop: the cases travel in the ROM that gets played. Measured when
merging them: a save from the earlier `release`, loaded in the merged one,
**doesn't load** if what snes9x leaves in SRAM is left behind it, and
**loads corrupted** (inventory, HP, SP, equipment, actor graphics and skills
shifted) if there are zeros behind it, because the checksum still adds up.

That the save's header carry its size or a version derived from the format
(`partida_tabla`), and that one that doesn't match be treated as "there is no
save". See `tasks/merge-release-and-test-main.md`.

Not urgent: taro always tests from scratch and doesn't share saves between
builds. It matters the day an `.srm` travels to reproduce a bug, or for
whoever plays consecutive builds.

# What was done (2026-09-26)

Each slot's header goes from six bytes to ten:

    $0100  "ABLS"          the magic, as before
    $0104  suma            the sum of the save's bytes, as before
    $0106  PARTIDA_BYTES   the length, which the assembler takes from the same
                           constants as `partida_tabla`
    $0108  PARTIDA_FIRMA   16 bits of the CRC32 of which RM2k variable goes in
                           each slot, which actor each skill pair and each
                           experience slot belongs to, plus ITEMS_N, SWITCH_BYTES
                           and ACTORES_N: `firma_de_la_partida`, in the converter
    $010A  the data

Neither of the two words is bumped by hand. The signature covers what the
length doesn't see: two builds with the same number of variables and a
different variable in the same slot. What it does **not** cover: reordering
two lines of `partida_tabla` without changing the total, because the table is
hand-written source and the converter doesn't read it (commented above the
table).

`ranura_de_este_formato` (in `partida.s`) looks at magic, length and
signature, and the slots screen and `cargar_partida` use it: a save from
another build **shows as empty** ("- Empty -") and choosing it starts from
scratch, like an empty slot.

Empty and not "corrupted": EasyRPG puts "Savegame corrupted" in
`Window_SaveFile`, but that's its own English text written in the code, not
an LDB term, and the ROM takes everything it says from the LDB. And it's what
the ROM already did with a checksum that doesn't add up.

The test: `test_una_partida_de_otro_build_se_ve_vacia_y_no_carga`, in
`pruebas/rpgmaker/test_titulo_dibujo.py`, with three variants: the save of a
build from before this change (`sin-cabecera`), another length and another
signature. It saves for real through the menu, rebuilds the slot shifted two
bytes with zeros behind it —the case that used to load corrupted— and writes
it into SRAM (`retro.escribir_sram`, new). It compares the slots screen
against one with four empty slots pixel by pixel and then picks the slot.

Against the ROM of `b581d4e`, `sin-cabecera` goes red in 570 pixels —slot 2
shows Talan at level "L 0"— and, skipping the comparison, on the map: the
shifted save loads (map 5 and not 4). The other two don't exist without the
change (they ask for `PARTIDA_FIRMA`).

`release` and `test-special` today come out with different signatures, so a
save from one doesn't load in the other.
