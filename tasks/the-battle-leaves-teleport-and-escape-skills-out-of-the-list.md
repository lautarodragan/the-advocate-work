---
name: "The battle leaves teleport and escape skills out of the list"
description: "RM2k 2000 lists every skill an actor knows in battle, a teleport or escape one grey; this battle leaves them out, so Zounds' Teleport is not in its party's battle list"
type: bug
status: draft
agents: [Cardón]
---

Seen by Cardón on 2026-10-20, **reading the code and the data**, with
the-advocate `8f290c39` and the ports `68bf55b`, while fixing
[`battle-offers-skills-that-are-only-for-the-map`](battle-offers-skills-that-are-only-for-the-map.md).
Not run in the ROM nor in the original.

**What RM2k does**, in easyrpg: RM2k 2000's `Window_Skill::CheckInclude`
lists in battle every skill the actor knows, and `Algo::IsSkillUsable`
answers no for a `teleport` or `escape` skill in battle, so it is there,
grey, and A on it buzzes.

**What the port does**: `skill_usable` in `rm2k-snes-battle`'s `rules.rs`
carries only `normal` and `switch` skills, so the converter gives a
teleport or escape one `$FF` in `skill_pair_k` and the battle's list skips
it. Since that task the list greys by `usable_in_battle` —the converter's
`skill_in_battle`, read by `ba_skill_reaches`—, which already answers no
for both types: carrying them would be enough to draw them grey.

**Where it shows**: Zounds' party learns Teleport (skill 30, type
`teleport`) with a `ChangeSkills` on the whole party; once learned, it is
in the original's battle list, grey, and not in the port's. No actor of ABL,
Book of Three or Vampires Dawn knows one, by their learning lists and fixed
`ChangeSkills`.

**What it costs**: the small game of `rm2k-snes-battle`'s tests has a
teleport skill (7) and an escape one (12), so carrying them changes the
stage's answer for that game, whose hashes are the deleted Python's
(`tests/model.rs`): they would be another place where the Python was
wrong, said there like the critical and like `usable_in_battle`.
