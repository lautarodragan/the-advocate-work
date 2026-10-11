---
name: "Lashe 3: the recycling plant and the droid"
description: "Stash, the floors that break, and AG7-17 joining the party: 57, 59 to 63 and 164"
type: feature
status: done
assignee: taro
---

# What

Milestone 3 of `lashe-city-with-the-car-up-to-the-race.md` —the context and what was measured are
there—. It comes after 1 and in parallel with 2.

The droid's path from Sector 32 (48): Stash's door, the scene with the
"bald man" who robbed you on the Hover-Tram (or with the bribed guard), the recycling
plant with the floors that break, the Motivator Chip, the tunnel back, and
**AG7-17 joining the party**, with its tutorial. It turns on 150, which is what the
branch without a companion needs to leave.

Maps: **57** (Stash's Emporium), **59** (Outside Recycling Plant), **60**,
**61** and **62** (the three floors), **63** (the tunnel) and **164** (the
droid's tutorial, outside Lashe City's subtree).

# Status

2026-09-27, in `testing/`: done on the agent's branch, with `main` merged
on top of milestone 2. What's left is taro's: playing it and looking at the photos without a
golden in `pruebas/snapshots/playthrough/lashe-planta*/`.

# What was done

**The seven maps in `MAPAS_DEL_JUEGO`**, and **all** their triggerable pages
compile, including the two of Stash's door on 48.

**`RecallToLocation` and `MemorizeLocation` are a single opcode, `OP_LOCATION`**:
the same place read or written in three variables, with a mode bit. **In the
variables the map is the RM2k id** —any other page reads and
writes them: the floors load 61 with a `ControlVars`—, so the ROM
translates it with `mapa_rm2k`, a table of ids by index that the converter emits in
RODATA (it costs no bank 0). Jumping is a `Teleport` with the destination read at
run time, and the page continues on the new map; to a map the cartridge doesn't carry
**it doesn't jump and carries on**. When recalling, the refresh of each of the three
writes goes in a bit of the mode.

**The memorized theme is `OP_MEMORIZED_BGM`**, with the index in `TEMA_RECORDADO`
($7E7940, far RAM; reset sets it to $FF). Playing the one already playing doesn't
restart it, like `BgmPlay` with the same name. It doesn't travel in the save: the two
commands always go in the same autostart page.

The bodies live in bank 1 (`rom/src/lugar_y_tema_recordados.s`) and in
0 only the entry remains, like `op_heal`: bank 0 had 342 bytes left and the two
asked for almost 200. They read and write the variables directly in far RAM.

**The variable slot went to eight bits.** The game names 127 variables and
these two commands add nine (127-129, 158-160, 169-171): the slot, which
carried the `VAR_REFRESCO` bit on top, didn't fit in seven. The bit moved to the
flags byte of each opcode that writes (OP_VAR's operation, OP_KEY's
flags, the mode of OP_TERRAIN and of OP_LOCATION). Separate commit, with
the suite green before the new variables. **A game saved with an
earlier build doesn't load** (the save's signature changes with the slots).

The converter records as the audio destination the map of a `RecallToLocation`
when the page set it with a constant (the floors); the return from the tutorial
jumps to what another page memorized and isn't recorded.

**AG7-17 joins the party without skills**: common event 37 (`UpdateAG7
Skills`) is parallel and the ROM doesn't run parallel common events. That's for milestone 4, which
has to give it its own without it being able to lose them.

# What was measured

All on `release`. **Bank 0**: 342 free before the milestone, 244 with the milestone
alone, **219 with milestone 2 merged**. **Bank 1**: the last symbol went from
$01:F874 (~1.9 KB free) to $01:FEA4 (**~350 B free**, with both milestones); most
of it is the troop pages and the plant's encounter tables, not the code. **Cartridge**: 2,964,854 B used, 70.7% of 4 MB (last
bank $61). BSS and ZEROPAGE unchanged.

**Pages**: with the plan's `medir.py`, 176 of 176 triggerable ones of 48, 57, 59-63 and
164 compile (120 before).

**Dropped frames**, walking 1200 frames 50 at a time back and forth (the method of
`map-11-redesigned.md`), with encounters turned off: 0 on 57, 59,
60, 61, 62 and 63. The only 10 came from accidentally stepping on the hole at (15,7)
of 62 and falling to 60: a teleport.

**Audio.** `fm2bar_gs` (Stash) goes in with all its notes and its MSU-1 track
came out by itself. Against `main` with milestone 2, pair by pair (program, theme) of the
shared bank: two go down, 0.1 kHz (SPACE79 in `TF3_1_awe` and
`T_ProjectJustice_DiscLoad`). `just techos` redone: no theme clips.

# Tests

`pruebas/rpgmaker/test_lugar_recordado.py`, with five new cases:
`lugar-caer` (the whole floor of 60: it falls to 61 at the variables' cell and
the page carries on there), `lugar-ida-y-vuelta`, `lugar-ausente` (map 999: it doesn't
jump), `tema-recordado` and `tema-recordado-el-mismo` (doesn't restart).
`test_cores.py` adds `lugar-ida-y-vuelta`.

`pruebas/abl/test_recorrido_lashe_planta_golden.py`, on `release`:

* `test_stash_la_planta_y_ag7_en_el_grupo`: no companion and with the idol
  stolen (71). From 48 to Stash's, the scene, the plant, **four falls**
  —from the entrance of 60 you can't go up without falling—, the chip, the tunnel, page 5
  of Stash, what was memorized (48, 3, 39), the tutorial and the return: party
  [Talan, AG7], 150, without the chip, the previous theme playing.
* `test_la_escena_de_stash_con_el_soborno`: page 4 (29), up to the plant.
* `test_con_arden_la_puerta_de_stash_esta_cerrada`.

The plant's random encounters **are turned off** in the test (`ENC_BASE` at
zero on reaching each map): no walkthrough test walks through an area
with encounters, and the plant's battles are milestone 4's.

Photos without a golden:

    lashe-planta          Stash's scene, outside the plant, floor 1,
                          fallen onto floor 0, the chip's room, the tunnel, the
                          tutorial, AG7 in the party
    lashe-planta-soborno  Stash's scene with the bribe
    lashe-planta-arden    "Looks like they're closed"

What they do **not** cover: Stash's pages 1 and 3 (credits and nothing), the other
holes of 62 and 60 —the one at (12,10) of 62 chains two falls through an autostart
page of 60—, and the plant's battles.

# What taro has to look at while playing

Stash's scene depending on how the tram went, the floors that break and the
fall (the hero has to come down from above passing through, not appear), the
chip, the tunnel, the tutorial —the droid on the black screen and the theme that
keeps going without cutting— and AG7 in the party from the pause menu. Fighting in the
plant with AG7: without skills, and the enemies without theirs. And that a save
from an earlier build doesn't load.

# Tested

taro, on 2026-09-27, on the SNES with the FX Pak: everything worked, including the path
of selling the Idol, bribing the guard and taking AG7; the race with no lag nor
bugs (the companion at the wheel, too). Set aside is the black hero after
changing graphic on the same map (Lazer Teeth's HQ, Boss Wick).
