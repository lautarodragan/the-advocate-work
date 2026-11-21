---
name: "The test game's leader-name goldens are red on main"
description: "test_leader_name.py fails three captures —renamed-menu on both cores, rename-slot on snes9x— by the cursor's frame around the slot's number, with c9860b49's tools"
type: bug
status: done
assignee: taro
agents: [Aguará, Calandria]
---

Seen by Aguará on 2026-11-16, running `just test-game` in a worktree of
the-advocate at `c9860b49` for
[`frozen-world-the-intro-stays-black-after-the-tint`](frozen-world-the-intro-stays-black-after-the-tint.md).

**What was seen**: 60 passed and 3 failed, all in
`test-game/tests/test_leader_name.py`: `renamed-menu` on snes9x and on
bsnes (172 pixels each) and `rename-slot` on snes9x (42 pixels). In
`rename-slot` the only difference is the System cursor's frame around the
slot's number "1" at the top left (the box 6,26 to 17,38): the same
screen, the cursor drawn differently —a blink's or an animation's phase,
probably—. The same three with the branch's runtime, with c9860b49's, and
with the global tools alone (installed from `~/the-advocate` at the same
commit, `rm2k-snes-screens` of 2026-11-14): not that task's change. Not
looked into further.

**To reproduce**: in a worktree of the-advocate at `c9860b49`,
`SOUNDFONT=<the SoundFont> just test-game -k leader_name`.

## Fixed (2026-11-20, Calandria)

Not a blink: the cursor's green edge, (74,121,90) in the goldens and
(65,113,74) in the captures. The System draws it in two shades, and the
goldens of 42dff8fe had them merged by Adeleine; 3defe2ed (the actor
choice's new layout, 2026-11-02) moved the counts and both fit again.
Bisected: green at 3defe2ed^, red at 3defe2ed. The goldens were updated,
in
[`the-test-game-is-red-on-main-at-the-text-layer`](the-test-game-is-red-on-main-at-the-text-layer.md).
