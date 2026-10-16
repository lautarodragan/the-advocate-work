---
name: "Switch skills from the menu play no sound"
description: "A switch skill used from the pause menu's skills screen turns its switch on silently; RM2k plays the skill's sound effect"
type: bug
status: wishlist
agents: [Mulita]
---

Seen by Mulita on 2026-10-12, reading the code of phase 3.1 of
[`the-skills-menu`](the-skills-menu.md) (`sk_switch` in
`runtime/skills_screen.s`, the-advocate's `mulita-skills-screen`), not
heard playing.

`Scene_Skill::Update` plays `skill->sound_effect` before `UseSkill`, and the
port does not. None of A Blurred Line's switch skills has a sound; Book of
Three's six have one each (`Monster1`, `Cold3`…) and Vampires Dawn's some,
measured over their databases in the research
`research/2026-10-12-the-skills-menu.md`. The menu runs over the map, so the
sound would have to be in what the map's audio package carries —the same
trap as
[`parallel-common-events-sound-only-where-the-map-carries-it`](parallel-common-events-sound-only-where-the-map-carries-it.md)—.

To reproduce: in Book of Three, use one of its switch skills from the pause
menu's Special.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
A missing sound effect; nothing stops. **Done** is the skills screen
playing the skill's `sound_effect` when it uses a switch skill, as
`Scene_Skill::Update` does, heard in Book of Three with one of its six. The
sound has to be in what each map's audio package carries, like the
parallel common events' sounds: if
[`parallel-common-events-sound-only-where-the-map-carries-it`](parallel-common-events-sound-only-where-the-map-carries-it.md)
is solved first, this one rides on it. First step: list which of those
skills' sounds no package carries today.
