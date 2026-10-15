---
name: "Elemental attributes are not applied in battle"
description: "An enemy's weakness or resistance to an attribute never changes the damage: 74 of the 100 enemies ABL can fight have one the party carries"
type: bug
status: doing
assignee: Chajá
agents: [Chajá]
---

Seen by Cardón on 2026-10-14 (`what-the-compiler-ignores-silently.md`),
tools `14e200fc`, ports `f775b66`.

**What is seen**: not played. The battle model reads none of the enemies'
`attribute_ranks`, the skills' `attribute_effects` or the weapons'
`attribute_set`, so a Flame skill against a Flame-weak enemy, or a Sword
against one that resists swords, does the neutral damage. The only
mention is a comment in `rm2k-snes/battle/src/simulate.rs` ("what is
missing: attributes, rows and the double attack"); no page of the book
says it.

**How much ABL uses it**: of the 100 enemies the cartridge can fight, 74
have a rank other than neutral on an attribute the party's gear or skills
carry; 39 of the 134 skills the party learns and 153 weapons carry an
attribute; 11 of the 44 skills the enemies use do too. The other games with
the data: The Book of Three (66 of 80 enemies), El Dorado and Frozen World
(38 of 45 each), Vampires Dawn (141 of 163).

**How to see it**: no cartridge row to point at; count over the dump with
`enemies.json` (`attribute_ranks`, not all 2), `skills.json`
(`attribute_effects`) and `items.json` (`attribute_set`); the research has
the method.
[What the compiler ignores silently](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-14-what-the-compiler-ignores-silently.html).
