---
name: "The skills screen"
description: "Tech Skill in the pause menu opens the list: who, their skills, the description, the selector and the SP cost; nothing is used yet"
type: feature
status: testing
assignee: taro
agents: [Mulita]
---

Phase 2 of [`the-skills-menu`](the-skills-menu.md), as section 7 of the
research `research/2026-10-12-the-skills-menu.md` in the book plans it. taro
said go on 2026-10-12, with the switch skills
([`switch-skills-from-the-menu`](switch-skills-from-the-menu.md)) right
after.

## Log

### Mulita, 2026-10-12: the plan, as built

Starting from the-advocate `f760b107`, the ports `da1b27e`, the book
`f160fa7`; branches `mulita-skills-screen` in the three. The research's
section 7, with what reading the code changed:

* **The data banks are not the limit for Vampires Dawn**: it requires the
  MSU-1, and the packing sends to the `.msu` as many LZ2 pieces as it takes
  for the rest to fit (`pack_with_msu`). So a byte per carried skill goes in
  `RODATA` with the other `skill_*` tables, and what it costs Vampires Dawn
  is one more piece read from the `.msu`, if any.
* **The description's two lines are slices of the one text the battle
  already carries**: the screens stage answers, per skill, the first line's
  length and where and how long the second is, cut at a space as the item
  screen cuts —`description_spans`—; the map-usable flag goes in the same
  answer, with the rule in `rm2k-rules` (`skill::usable_on_the_map`,
  easyrpg's `Algo::IsSkillUsable` outside battle).
* **The windows are the screen's own**, one arrangement and its sixteen
  bars, as half-rows of BG1's tilemap; the VRAM is the custom menus'.

### Mulita, 2026-10-12: done, to testing

**Branches** `mulita-skills-screen` in the-advocate (`3086271b`, and
`switch-skills-from-the-menu` on top), the ports and the book. **To
install when merging**: `screens` and `mapdata` (both compile `rules`,
which gained `skill.rs`; nothing else changed in it). The runtime changes
too, so `cartridge` needs no reinstall: it assembles the checkout's.

What it is: Tech Skill asks whose on the menu itself, refuses an actor at
0 HP, and opens a full screen —the description in two lines, the status
line, two columns of eight rows that scroll a row at a time, grey what the
map cannot use or the SP do not cover—. B goes back to the menu on the
command. The divergence is in the book,
`divergences/the-skills-screen.md`.

**What it costs**, `rm2k-snes-space` on every game's `release` and ABL's
test cartridges: bank `$C0` about 1.36 KB, bank 1 about 50 B, bank 0
four bytes fewer, far RAM 5 B (Vampires Dawn is left with 48). With phase
3.1 on top, `$C0` some 150 B more.

**Verified**: ABL's suite with the branch's tools, 1279 passed with the
new `test_menu_skills_drawing.py` (six cases, pixel for pixel against
`rm2k-snes-screens render`) and `test_menu_skills_golden.py` (eight
new goldens); `just boot`, 9 passed; `just test`, 27; `just
rust-test`. Ten goldens moved, each by 111 pixels on the second command's
two cell rows, "Tech Skill" from grey to white: their own commit. The
captures, side by side with the original's under Wine, are in
`~/scratch/mulita/capturas/2026-10-12-skills-screen/`.

**Not covered by the suite**: the weapon requirement of skills with
physical attributes (not modelled; no game was checked for one), teleport
and escape skills (always grey; no game teaches one), and the screen in
the other seven games beyond `just boot` reaching their first map —no
test opens their Tech Skill—.

**Found and not fixed**, as drafts:
[`a-test-case-that-adds-a-skill-pair-shifts-test-lista-larga`](a-test-case-that-adds-a-skill-pair-shifts-test-lista-larga.md).
Seen under Wine and not noted elsewhere: the original paints SP at zero in
the System's "low" colour; the port, white.
