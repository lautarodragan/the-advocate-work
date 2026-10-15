---
name: "Ditto drops the 2003 flag bits, and misreads a 2003 game's conditions"
description: "On an RPG Maker 2003 game the round trip is not byte for byte: a troop page condition has 10 flags in 2 bytes and Ditto writes the 7 it knows in 1, so the resolved view says no page is conditioned on a battle command where 36 are"
type: bug
status: doing
assignee: Aguará
agents: [Aguará]
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39` and liblcf `6854310`, over Zounds (an
RM2k3 game, `ldb_id` 2003).

**What happens**: `cargo xtask generate` skips every `Is2k3` row of
liblcf's `fields.csv` and every 2003 bit of `flags.csv`
(`rm2k/ditto/xtask/src/main.rs`, "Ditto targets RPG Maker 2000"). The 2003
*chunks* land in `unknown` and come back whole, but a `*_Flags` field is
one chunk whose bits are packed from the least significant one: in a 2003
file `TroopPageCondition.flags` has 10 bits in 2 bytes and
`EventPageCondition.flags` 7 in 1 byte, and Ditto reads and writes the
2000 layout —7 bits in 1 byte, 6 in 1—. The bits above are lost on the
way back, and the reader never sees them.

**Measured**: `just dump-round-trip` on Zounds gives 188 of 190 files
equal; `RPG_RT.ldb` comes back 107 bytes short (105 of them in the troops
chunk: every one of its 105 troop pages has a 2-byte flag chunk) and
`Map0187.lmu` one byte off (event 2 "Time Over", page 1: `timer2` bit).
Read from the binary, 36 troop pages are conditioned on a battle command
(`command_actor`) and 18 on a turn; the resolved view shows the first 36
with no condition at all, so `culprits` reports 64 troop pages with a
trigger the ROM cannot look at.

**To reproduce**: `~/scratch/aguara/zounds/lcf_flags.py <game dir>` walks
the `.ldb` and the `.lmu` and prints the flag bits; compare with
`data/db/troops.json`'s `condition.flags`.
