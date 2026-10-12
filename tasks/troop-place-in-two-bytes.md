---
name: "The troop's place in two bytes"
description: "BA_TROOP_K is a byte: a cartridge with more than 255 used troops doesn't build (VD asks for 277); widen it to two bytes, for any game"
type: feature
status: done
agents: [Hurón]
assignee: taro
---

From `vampires-dawn-builds-from-its-toml.md` (Aguará, 2026-10-11):
"277 troops of 255, 554 members" stops VD's whole cartridge, not one
map. The check is `used.len() > 255` in mapdata's `emit.rs`; on
2026-10-10 (406fc5e0) only the start of the members was widened to a word.
Today VD leaves out 98, 182, 327 and 339 only because of this.

## What was done (Hurón, 2026-10-11)

Base: the-advocate `0bb1120a`, ports `c914245`; branches
`huron-tropas-dos-bytes` in both, worktrees in `~/scratch/huron/`.

**The byte's intention**: `git log -S 'troops of 255'` gives 406fc5e0
(Tijereta, 2026-10-10), which says "the troop's place stays a byte
—`BA_TROOP_K`, with $FF 'not carried'—: up to 255 troops per cartridge, and
the converter says so if it goes over". A declared limit, not a reason: the byte
was what there was at `FAR_BATTLE + 45`, and +46 and +47 are free (`BA_ACC`
starts at +48).

**The readers** (grep of `BA_TROOP_K` in `runtime/`, reviewed by hand):
the one that writes it, the search in `troop_id` in `battle.s` —which also
counted in `BA_S1` one byte at a time against `TROOPS_N`—; `ba_member_x`,
the setup's `troop_hidden`, `ba_page_build`, `ba_exp_allocate`, the background and
the battlers in `battle_scene.s`, and the two in `battle_victory.s`. ABL's
tests don't read `BA_TROOP_K` from RAM: they read the tables
(`troop_id`, `troop_hidden`, `troop_exp`), which don't change. The per-troop
tables (`troop_id`, `_exp`, `_gold`, `_init`, `troop_page_init` in
words; `troop_n`, `troop_hidden`, `troop_page_n`,
`scene_troop_backdrop` in bytes per troop) were already indexed with
sixteen-bit X: the only thing that was a byte was the place.

**The change** (the-advocate `5d7d5601`): `BA_TROOP_K` is a word at
+45/+46, $FFFF "not carried". Like `ENC_REG`, no place reaches $FF00
—the converter stops at 32768, so that the double indexes the word
tables in sixteen bits—, so the 8-bit checks read
`BA_TROOP_K + 1`. The search in `troop_id` counts in sixteen bits. The
check in `emit.rs` goes from 255 to 32768. New test in
`mapdata/tests/python.rs` (300 troops), seen red before ("300 troops
of 255, 611 members").

**Verified**:

* `just crate-test mapdata` and `just test` (27) green.
* ABL, in `abl/` of my ports with `PATH=<worktree>/.local-tools/bin`
  (project, mapdata, convert, cartridge): `just cartuchos` and `just
  pruebas`, **1202 passed**, no golden moved. `abl.sfc` goes from
  `24dd24ad…` to `4bb9b84e…`: `mapdata.inc` comes out identical to main's
  (`df57da5a…` both), so what changes is only the runtime's code
  —ABL carries fewer than 256 troops and the table doesn't move—.
* Vampires Dawn, taking the four troop ones out of `excluded`: it no longer
  stops at the troops but at the ROM ("a piece of 65536 bytes needs a new
  bank, and the 127 banks … are taken"). One at a time: 98 builds, 98+182 builds,
  and 327 or 339 on top no longer (the ROM). **Two come back**, 98 and 182; 327 and 339
  move to "poses" in the toml (ports `29d4c24`). The cartridge carries 266
  troops (`TROOPS_N`), `vampires-dawn.sfc` `c6b6fe5c…`.
* **A battle with the place above 255, run**: a throwaway case
  (not committed) that does `EnemyEncounter` of troop 332 —place 260;
  truncated it would be 4, troop 1, with four enemies— in snes9x and in
  bsnes: `BA_TROOP_K` = 260, one enemy, 400 HP (the Fireworm), its
  battler and its background; and winning it (HP and attack tweaked by hand), "590
  Experience Points gained", which comes from `troop_exp` at place 260.
  Captures in `/shared/capturas/2026-10-11-tropas-dos-bytes/`.

**What wasn't covered**: the victory gold with a high place (the
Fireworm gives 0), `troop_hidden` with a hidden member above 255, and the
troop pages (`ba_page_build`) above 255 weren't executed with a
case that looks at them; the code is the same pattern as the ones that were. No
test in the suite builds a cartridge with more than 255 troops: the coverage
of that path is the run above, which doesn't remain as a test. VD
wasn't played.

The book: a new snapshot at the top of `ports/vampires-dawn/README.md`
(docs `269aa1e`, branch `huron-tropas-dos-bytes`); no page in
`internals/` describes `FAR_BATTLE`.

When merging: reinstall `mapdata` and `convert` (the check), and the runtime
comes in through the checkout of `~/the-advocate`.
