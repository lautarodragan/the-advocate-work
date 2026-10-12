---
name: "Skills that cost 100 SP or more are left out"
description: "Vampires Dawn's Apocalypse (100) and Vampire Healing (120) are not in the cartridge: the battle's list writes two digits, so the stage leaves out any skill over 99"
type: bug
status: draft
---

Seen by Mulita on 2026-10-12, **reading the data and the code**, with the-advocate
`28e66b35` and the ports `c97a0dd`, while studying the skills menu
(`the-skills-menu.md`). Not run in the ROM.

**What the code does**: `skill_usable` in `rm2k-snes-battle`'s `rules.rs`
keeps a skill only with `sp_cost <= 99`, "which is what the list writes";
one that costs more gets `$FF` in `skill_pair_k`, so the battle's list skips
it even when the actor knows it.

**Where it shows**: of the eight games, only Vampires Dawn teaches such
skills: **Apocalypse** (11, 100 SP) and **Vampire Healing** (121, 120 SP),
both by `ChangeSkills`. In the original they are in the actor's battle list,
with a three-digit cost —easyrpg's `Window_Skill` writes it `{:3d}`—; in
the port they are missing. The skills menu would miss them too, since it
reads the same tables.

**How to see it**: in Vampires Dawn, an actor that has learned either, in
battle, with the skill list open.
