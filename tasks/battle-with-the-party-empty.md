---
name: "A battle with the party empty"
description: "RM2k immediately loses a battle with nobody in the party; what the ROM does wasn't looked at, and the eight ports start with the database's party, which in several of them is nobody"
type: test
status: draft
---

Mulita left it on 2026-10-10 in "Lo que no cubre" of
`el-grupo-vacio-al-empezar.md`: "A battle with the party empty.
RM2k loses it immediately (`Game_Battle::CheckLose` with nobody who can
act); the runtime wasn't looked at or tested." The rest of the empty party
—not drawing itself, walking, the menu, saving and loading— is covered by
ABL's `test_grupo_vacio.py`, in `test-special`.

Why it deserves a test and not just playing it: since that task no port
carries the `party = [1]` crutch (all eight `rm2k-snes.toml` say `party =
[]`, ports `a85b7e3`), and RM2k lets the invisible hero walk, touch
events and run into random encounters. A battle with zero actors is a
runtime path (the walks over `party_n` in `battle.s` and
`battle_troop.s`) that nothing executes today.

**How to see it**: ABL's empty party case (map 5, at (39,34), the one from
`pelea-82-grupo-11-12`) with an `EnterBattle` or an encounter before anyone
joins, compared with what the original does in Wine.
