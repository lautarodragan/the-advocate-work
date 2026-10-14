---
name: "Unused items at the start of each game's database"
description: "Do the eight games leave RM2k's default items unused at the start of the item table? A measurement, for a quick fix to the 255-item limit"
type: research
status: testing
assignee: taro
agents: [Mulita]
---

taro, on 2026-10-14: "I think in ABL the first entries of each DB table
are the ones RPG Maker brings by default, and surely they are not used.
We could probably 'remove' the first 10–20 items as a quick fix. It is
costlier than ignoring the ones that don't fit, because it means moving
every reference, and the right fix is 2 bytes; but I'd like to know if the
other games also have N unused items, all together, at the start of the
table. Leaving the default entries and never using them was a common
practice."

Context: [`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md)
—ABL's whole `release` carries 264 items and the tables hold 255—.

## Log

### 2026-10-14, Mulita: the measurement

Method: one throwaway script over `data/` of each game (not committed).
An item id counts as referenced if it appears in: ChangeItems 10320 with
a constant item; ChangeEquipment 10450 with a constant (equip mode);
ConditionalBranch 12010 on an item (type 4); every id in OpenShop 10720's
list (parameters from index 4 on); an event page's item condition; actors'
initial equipment; enemies' `drop_id`. Scanned: every map's pages, common
events and troop pages. For skills (quick count): actors' learned lists,
enemy actions of kind skill, book/special items' `skill_id`, ChangeSkills
10440 with a constant, ConditionalBranch "actor knows skill".

| game | items | referenced | unreferenced | leading unreferenced run | ChangeItems / equip by variable |
|---|---|---|---|---|---|
| abl | 450 | 257 | 193 | **16** | 0 / 0 |
| book-of-three | 250 | 152 | 98 | **16** | 0 / 0 |
| el-dorado | 84 | 2 | 82 | **17** | 0 / 0 |
| frozen-world | 500 | 21 | 479 | **16** | 0 / 0 |
| vampires-dawn | 202 | 181 | 21 | 0 | 0 / 0 |
| dooms2 | 123 | 5 | 118 | 0 | 0 / 0 |
| desert-nightmare | 100 | 0 | 100 | (all: empty database, no names) | 0 / 0 |
| sunset-over-imdahl | 1 | 0 | 1 | (all: one placeholder item) | 0 / 0 |

First 20 names: abl, book-of-three, el-dorado and frozen-world share the
same ones, RM2k's defaults: Potion, Tear Drop, Magic Ether, Miracle Drop,
Phoenix Down, Antidote, OmniAntidote, Pocket Shelter, `----`, Apple, MP
Apple, Powr-Up, Defensive-Up, Mind-Up, Speed Up, `----`, then Club, Iron
sword, Spear, Bow (the weapons, from id 17, are where the run ends: 17 is
the first referenced id in abl, book-of-three and frozen-world; in
el-dorado 17 is also unreferenced and the run ends at 18). vampires-dawn
(Painkiller, Blood Phial...) and dooms2 (Clown dress...) have their own
tables from id 1, so there is nothing to drop.

Skills, leading unreferenced run: 0 in abl, book-of-three, el-dorado,
frozen-world, dooms2; 1 in vampires-dawn (all of desert-nightmare and
sunset: empty tables). Not worth anything there.

Reading: in ABL "drop the first 16" frees 16 ids (>= the 9 needed, since
the whole game is 264 against 255), and the same 16 are free in
book-of-three and frozen-world; el-dorado 17. Scattered unreferenced ids
beyond the run are many (193 in ABL) but dropping them means a remap, not
a shift.

What the scan cannot see: an item named by a variable (ChangeItems and
ChangeEquipment by variable: zero in all eight, so no uncertainty from
that); Maniac-patch item-by-variable branches; items reached only by the
battle engine through paths not listed above (items used as skill
requirements do not exist in RM2k); the dump's `desert-nightmare` and
`sunset-over-imdahl` databases, which look empty/placeholder, so their
numbers say nothing (desert-nightmare has 378 maps but 0 references).
The OpenShop parameter offset (4) was taken from the one sample in ABL
and EasyRPG; all referenced ids came out inside each table.
