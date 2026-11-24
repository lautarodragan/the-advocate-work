---
name: "Zounds: skill names show a `?` for an accent"
description: "The battle's text block carries the skills' names from the database as they are, without the plain stand-ins, so Zounds' \"Látigo de Seda\" is \"L?tigo de Seda\" in the cartridge, where the items' \"Poción\" is \"Pocion\""
type: bug
status: done
assignee: taro
agents: [Aguará, Hurón]
author: aguara
links:
  found-in: [zounds-the-item-target-picker-does-not-fit]
  found: [zounds-condition-messages-are-japanese-defaults]
---

Seen by Aguará on 2026-11-02, while doing
[`zounds-the-item-target-picker-does-not-fit`](zounds-the-item-target-picker-does-not-fit.md),
on the-advocate `aguara-item-target` (from `23b413cd`). Not looked at on
the screen.

**What it is**: the battle model hands the skills' names to the emission
as the database has them (`skill_texts` in `rm2k-snes/battle/src/model.rs`,
`json!({"name": s.name, …})`), and `Texts::add` in `emit.rs` writes a `?`
for every letter outside the console's font. Its own comment says that
what comes from the database goes through `plain` first, which is what the
items' names get (`item_text` in the screens stage), but the skills' names
do not. So the text block carries `L?tigo` twice —`skill_txt` and the
taught skill's whole name— and `P?talo` once, next to `Pocion` for the
items.

**To reproduce**: build Zounds' `release` and look for the bytes of
`L?tigo` in `item_texts` of `build/release/mapdata.inc`
(`~/scratch/aguara/item-target/texts_scan.py` counted them). On the
console, any of Zounds' accented skills —"Látigo de Seda", "Pétalo
Violeta", "Muerte Espontánea"— in the battle's skill list.

The actor choice does not show it since that task: it has its own copy of
a skill's name, `skill_target_names`, made with `item_text`.

## Log

### 2026-11-22, Carpintero: still so, to todo

Checked against the-advocate `0ae40e0a` and the ports `89f77b4`, on
Zounds' `build/release/mapdata.inc` of that day: Aguará's
`texts_scan.py` counts `L?tigo` 2, `Latigo` 1, `P?talo` 1, `Petalo` 1,
`Pocion` 3 and `Poci?n` 0 in `item_texts`. The `?` ones are the two
paths the draft names, unchanged: `skill_texts` in
`rm2k-snes/battle/src/model.rs` still hands `s.name` as it is, and
`emit.rs` adds it with `texts.add` both for `skill_txt` and for the
taught skill's whole name (`whole_skill_text`), without `plain`. Moved
to `todo` by taro's request.

### 2026-11-22, Hornero: taken by Aguará

taro, translated, on whether it can be done without new problems:

> Go ahead!

Hornero's read before launching: both paths are in `emit.rs` of the
mapdata stage, which already has `plain`; the skill's description and its
two using messages (`using_message1`, `using_message2`) are added without
it too, and go in the same change.

### 2026-11-22, Aguará: the battle's database texts go plain, with their icons

On the-advocate `aguara-skill-accents` (from `6a8f4162`) and the ports
`aguara-skill-accents` (from `001cfb7`).

#### What `git blame` says

The skill lines of the battle's text block are from the port of the
emission to Rust (`ac8b075b`, 2026-10-01); `plain` came on 2026-10-16
(`f6c884c1`) and covered the actors' names and the commands, not these.
An oversight, not a choice: `Texts::add`'s own comment says the
database's texts go through `plain` first.

#### Why not `plain` itself

`plain` drops the ExFont icons —it is for the actors' names, which the
menu's bank and a box's names do not draw—, and every one of Zounds'
skills starts with one (`$LLátigo de Seda`), which the battle's list
draws today. So a sibling, `db_text`: the same stand-ins with the icons
kept, as `item_text` does in the screens stage
(`plain_text_but(text, exfont::is_half)`). It goes on every database text
the stage added raw: a skill's name, description, whole name and its two
using messages, the enemies' names, the dead state's name and its
revival message, the victory's second line, the conditions' five
messages and the level term.

#### The suspicion about descriptions and messages, measured

`scripts/db_scan.py` over every port's `data/db` (in
`~/scratch/aguara/skill-accents/`): Zounds' skill descriptions do carry
accents (`daño`, `Técnica`, `Científico`, `Deformación`), its using
messages do not. Vampires Dawn has five skill names (`Schwäche`, `Große
Heilung`…) and a description. ABL, The Book of Three, El Dorado and
Frozen World carry RM2k's untranslated Japanese defaults in skills 71
and 72's first using message, read as Windows-1252 —mojibake—, and
Zounds the same in states 1 to 9's messages; no port has a non-ASCII
enemy name. The mojibake is garbage either way: before, a `?` for each
letter outside ASCII; now each Latin-1 letter as its plain neighbour.

#### The letter cap

`WHOLE` (`model.rs`): the cartridge keeps every letter of a skill's
name, and only the pixels cut, so there is no letter cap for the stand-in
to cross. A Spanish or German accent stands in one for one; only `ß`,
`Æ`, `…` and the like grow (`ss`, `AE`, `...`). The battle model's
"names the battle cuts" report measures the name as the database has it,
with the font's Latin-1 advance for `á`, not the `a` drawn: a pixel of
difference at most in a report, not in the cartridge, whose `scr_cap`
measures what it draws.

#### Measured on Zounds' release

`scripts/texts_scan.py` (in `~/scratch/aguara/skill-accents/`, the
item-target one with the descriptions too) over
`build/release/mapdata.inc`, before (the global tools, `6a8f4162`) and
after (`aguara-skill-accents`): `L?tigo` 2 → 0 and `Latigo` 1 → 3,
`P?talo` 1 → 0, `Pu?al` 1 → 0, `da?o` 3 → 0, `T?cnica` 2 → 0,
`Cient?fico` 1 → 0, `Deformaci?n` 1 → 0; `Pocion` 3 both times. The `?`
in the whole block, 558 → 94: what is left is the real ones (the shops'
`¿` stood in) and the state messages' bytes with no stand-in —see the
draft
[`zounds-condition-messages-are-japanese-defaults`](zounds-condition-messages-are-japanese-defaults.md)—.

On the screen, with the `battle-commands` case and Unamë's skill list,
the cursor on her third skill: "Pu?al Punzante" and "T?cnica de combate."
before, "Punal Punzante" and "Tecnica de combate." after, with the icon.
Nobody in the case knows "Látigo de Seda", the same path. Before, after
and difference in `/shared/captures/2026-11-22-zounds-skill-accents/`.

#### Verified

All with the worktree's `.local-tools` (mapdata) first in the PATH:

* `just test` in the-advocate: 29 passed; `just crate-test mapdata`: 101
  passed, among them the new
  `a_database_text_stands_its_accents_in_and_keeps_its_icons`, shown red
  first with `db_text` returning the text as is (`L?tigo de Seda`).
* `just boot -k zounds` in the ports: 76 passed. `just boot`, every game:
  199 passed. ABL's `just tests`: 1686 passed, 2 skipped. **No golden
  moved**, so the ports branch has no commit: no golden covers the
  battle's skill list or the help line over it, in Zounds or in Vampires
  Dawn, whose five skill names with `ä` and `ß` go plain too.

When merging: reinstall `mapdata`.

### 2026-11-22, Hurón: what to look at

![Unamë's skills in battle, the cursor on "Punal Punzante", its help "Tecnica de combate.": plain stand-ins with the icon, no `?`](images/zounds-skill-names-show-a-question-mark-for-an-accent/skill-list.png)

Shot from the ports' main (`22c7559`, global tools at the-advocate
`1b8825d8`) with the case `battle-commands` (Unamë and Kazar against the
Pez Shark): Unamë's "Tecnica", Down once. Before this task it read
"Pu?al Punzante" and "T?cnica de combate." (Aguará's before, after and
difference are in `/shared/captures/2026-11-22-zounds-skill-accents/`).
**Once Calandria's Latin-1 change lands, the same screen should show the
accented letters themselves**, "Puñal Punzante" and "Técnica de combate.",
instead of the plain `n` and `e`.

**How to get there in play**: any battle with Unamë. "Tecnica", and the
cursor on an accented skill: "Puñal Punzante", "Látigo de Seda", "Pétalo
Violeta", "Muerte Espontánea". The help line above shows its description.

### 2026-11-24, Hornero: done

Closed by taro, from `testing`.
