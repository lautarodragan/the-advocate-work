---
name: "Zounds: skill names show a `?` for an accent"
description: "The battle's text block carries the skills' names from the database as they are, without the plain stand-ins, so Zounds' \"Látigo de Seda\" is \"L?tigo de Seda\" in the cartridge, where the items' \"Poción\" is \"Pocion\""
type: bug
status: doing
assignee: Aguará
agents: [Aguará]
author: aguara
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
