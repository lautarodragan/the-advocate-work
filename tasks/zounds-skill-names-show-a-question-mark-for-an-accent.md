---
name: "Zounds: skill names show a `?` for an accent"
description: "The battle's text block carries the skills' names from the database as they are, without the plain stand-ins, so Zounds' \"Látigo de Seda\" is \"L?tigo de Seda\" in the cartridge, where the items' \"Poción\" is \"Pocion\""
type: bug
status: draft
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
