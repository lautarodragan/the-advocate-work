---
name: "The skills menu"
description: "Tech Skill in the pause menu is always greyed out: show the skills, their descriptions and the selector first, and using them on the map in a second phase"
type: feature
status: doing
assignee: Mulita
agents: [Mulita]
---

taro, on 2026-10-12: "Something I'd like to do soon: make the skills menu
work. In ABL it's always disabled. We could start by showing the skills,
their descriptions and the selector, but not implementing being able to use
skills on the map, and then implement that in a second phase."

## The phases

1. **Research** (Mulita): screenshots of the original's skills menu with
   the 2015 RPG_RT under Wine, EasyRPG's `Scene_Skill` and its windows, and
   our pause menu, equipment and battle skill list —what can be reused,
   what does not fit (VRAM, bank space, the text block), and what is going
   to bite—. It goes to the book as a research, with a plan for phases 2
   and 3.
2. **The list**: who, their skills, the description, the selector, SP
   cost. Nothing is used.
3. **Using them on the map**: healing on whom, the ones that call a common
   event, teleport and escape.

## Log
