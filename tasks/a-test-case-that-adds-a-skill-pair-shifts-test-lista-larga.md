---
name: "A test case that adds a skill pair shifts test_long_list"
description: "With a test page that teaches Kersh a skill the game never teaches him, ABL's test_long_list.py stops seeing the first skill of Talan's battle list"
type: bug
status: draft
agents: [Mulita]
---

Seen by Mulita on 2026-10-12, at the-advocate `3086271b` and the ports'
branch `mulita-skills-screen`, while writing the test page
`tests/cases/skills.json` of A Blurred Line.

With one more command in that page —`ChangeSkills [1, 11, 0, 0, 294]`,
Memory of Sorrow to Kersh, a pair of actor and skill the game itself never
names— the four goldens of `tests/rpgmaker/test_long_list.py` go red:
Talan's battle list starts at SingleCure1, and Absorb Aura, its first, is
gone. Without that command, or with skills the game does teach, they are
green. Kersh is actor 11 and Talan 14: a new pair before Talan's moves the
bit of every pair after it.

The test sets Talan's bits in `FAR_SKILL` with the slots that
`datos.skill_slots()` asks the converter for, scanning the
cartridge's cases. It was not measured whether that map and the one the
cartridge was compiled with disagree —which would be the harness's—, or
whether the cartridge itself numbers the pairs of a case's `ChangeSkills`
in another order —which would be the ROM's, and a game could hit it—.

To reproduce: add that command to `tests/cases/skills.json`, `just
cartuchos`, and `just tests tests/rpgmaker/test_long_list.py`.
