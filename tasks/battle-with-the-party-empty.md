---
name: "A battle with the party empty"
description: "RM2k immediately loses a battle with nobody in the party; what the ROM does wasn't looked at, and the eight ports start with the database's party, which in several of them is nobody"
type: test
status: todo
---

Mulita left it on 2026-10-10 in "Lo que no cubre" of
`empty-party-at-the-start.md`: "A battle with the party empty.
RM2k loses it immediately (`Game_Battle::CheckLose` with nobody who can
act); the runtime wasn't looked at or tested." The rest of the empty party
—not drawing itself, walking, the menu, saving and loading— is covered by
ABL's `test_empty_party.py`, in `test-special`.

Why it deserves a test and not just playing it: since that task no port
carries the `party = [1]` crutch (all eight `rm2k-snes.toml` say `party =
[]`, ports `a85b7e3`), and RM2k lets the invisible hero walk, touch
events and run into random encounters. A battle with zero actors is a
runtime path (the walks over `party_n` in `battle.s` and
`battle_troop.s`) that nothing executes today.

**How to see it**: ABL's empty party case (map 5, at (39,34), the one from
`battle-82-party-11-12`) with an `EnterBattle` or an encounter before anyone
joins, compared with what the original does in Wine.

## Defined

Todo, on 2026-10-16, by Cardón: a runtime path no test executes, which the eight ports can
reach since they all start with `party = []`.

**Done** means a case in ABL's `test-special` —the empty-party one, map 5,
with an `EnterBattle` before anyone joins— that ends the way the original
does under Wine (lost at once, Game Over or the page's defeat branch),
with its golden, and the runtime fixed if it does not. **First step**: the
original under Wine with that case, to know what to expect.

## Checked (2026-10-20, Chajá)

Still open: no test of ABL's or of the test game's enters a battle with
nobody in the party (`test_empty_party.py` covers the hero, the menu,
items, equipment and saving). The ports are nine since Zounds, and each
one's project file is `advocate.toml` since 2026-10-20 (the ports'
`71c4143`): eight `release`s say `party = []`, and ABL's says `[10]`,
DummyHero, so that map 1's opening runs —see its comment—. ABL's
`test-special` and several of its test cartridges still start empty.
