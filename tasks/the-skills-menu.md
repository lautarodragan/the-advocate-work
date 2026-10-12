---
name: "The skills menu"
description: "Tech Skill in the pause menu is always greyed out: show the skills, their descriptions and the selector first, and using them on the map in a second phase"
type: feature
status: testing
assignee: taro
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

### Mulita, 2026-10-12: phase 1, the research

From the-advocate `28e66b35`, the ports `c97a0dd`, the book `c3e40f4`.

* **Why Tech Skill is grey**: not the game. In the original the option is
  enabled from the first moment the player walks —the intro rooftop, with
  Kersh, whose Healing Syringe already heals from the menu—. It is grey in
  the port because the runtime does not do it: the pause menu greys every
  command the converter's `MENU_DONE` does not list (`menu_enabled` in
  `runtime/menu.s`, `menu_done` in `mapdata/src/emit.rs`).
* **The original under Wine**: a copy of ABL whose map 4 builds a party
  with Kersh, Talan (given 27 skills, to scroll), Radin without SP and
  Emily, and takes it to map 7. Captured: the list, the description line,
  the costs, grey skills (battle-only, not enough SP), the scroll with its
  arrows, a heal with the target window, a full-HP target that does
  nothing, Change Tape and Mix Formula —switch skills whose common event
  runs on the map after the menu closes—, and an actor with no skills.
* **Delivered**: the research,
  [`research/2026-10-12-the-skills-menu.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-12-the-skills-menu.html)
  in the book —branch `mulita-skills-menu` of the-advocate-docs—, with the
  plan for phases 2 and 3 split into steps, the risks and the measured
  numbers; and a line in "Known issues" of the six ports that teach skills.
  The captures and their `LEEME.txt` were left in Mulita's scratch, under
  `capturas/`. No code: no branch in the-advocate or in the ports, nothing
  to install.
* **What it found**: the data is already in the cartridge for the battle;
  the screen needs the custom menus' full VRAM (ABL's widest page asks some
  336 pairs, the items screen leaves 184); the description needs two lines
  for 82 of ABL's 231 skills; Vampires Dawn has 170 B left in its data banks
  and 53 B of far RAM. And that **four of ABL's systems —Radin's Mix
  Formula and Field/Battery Repair, Sern's Weapon Forging, Emily's Change
  Tape— are reached only from Tech Skill**: no event turns on their
  switches.
* **Drafts**, both read in the code and not run in the ROM:
  `battle-offers-skills-that-are-only-for-the-map.md` and
  `skills-that-cost-100-or-more-are-left-out.md`.
* **Proposed follow-ups**, not created: the list (phase 2), switch skills
  from the menu (3.1, what ABL needs first), healing skills from the menu
  (3.2), items that cast a skill outside battle (3.3). See section 9 of the
  research.
