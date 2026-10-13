---
name: "Boss Wick turns into one of his girls"
description: "On returning from the vidcasts, Boss Wick changes his graphic to one of his girls'; taro thinks it worked at some point and then broke"
type: bug
status: done
agents: [Hurón, Tijereta]
assignee: taro
---

From taro, on 2026-10-05: "boss wick changes his graphic to one of his girls on
returning from the vidcasts. I think that worked at some point, and then
it broke". Of the same family as Dalia's tank and the missile
hatches: an event that ends up with another's graphic. If it's a
regression, it gets bisected: candidates from the last few days, the slot cache
(Yaguareté), the shared poses of 108, the ones that turn (Cotorra).

# What was measured (Tijereta, 2026-10-05)

Baseline: ABL `c988101`, tools `d0e2e16c`.

**It reproduces** in 40 with 156 and 160 on, without going through the
vidcasts: event 3 —`RightGirl/BossWick`, which with 160 switches to
`People7` 2, Wick— is drawn with `Chara3` 7, the girl of its page 1,
from arrival, and turns with her when the scene makes it turn.

**The cause.** Event 3 is turned by a route of the scene (event 7), so
it's one of the walkers: its row carries the twelve poses of **one** graphic,
that of the page active on load or of the first one that draws something, and
walking wins over the page's graphic
(`divergencias/un-evento-que-camina-no-cambia-de-grafico.md`, in the
tools). With 160 the page brings Wick and the row keeps the
girl. (Events 1 and 2 with 160 draw `BLPeople` 3, a gap in the
sheet: in RM2k they aren't seen, and in the ROM neither.)

# The bisection

It isn't one of these days' suspects: with the tools of
2026-10-02 (817037ee) and ABL `bdd0d83` it was already the same. With those of
2026-09-27 (062ea4fd), when 40 went into the cartridge, **Wick was visible,
but in the cell next to it**: it was event 1, Wick on his page 1, which with
160 draws the gap, and the ROM left it with its graphic. Since `f0e0dc2e`
(2026-09-30, the ones that enter the auditorium) a gap counts as "doesn't draw",
event 1 hides as in RM2k, and the girl of 3 was left in view. What
worked was one error covering another.

# The fix

In the tools, branch `worktree-agent-ac0c3db5dd60db962`: the page's +30
carries, also for the events that walk, the entry of its
graphic in the pose bank, and +31 its palette; on changing page the
row takes that bank and that palette and uploads the page's pose
(`walker_graphic`). Walking no longer wins: the divergence was deleted.

Compared with the original under Wine (a copy that starts in 40 with
160's page with no condition): Wick in cell 18, turning; the ROM now
the same. Captures in `/shared/captures/2026-10-05-compuertas-y-wick/`.

The test is `rpgmaker/test_page_graphic.py`: the silhouette of event 3
in VRAM against `People7` 2. Red with main's tools, green with
the branch's.

**What the suite doesn't cover**: the other events in the game that walk and
change graphic with the page, which the fix also changes and no
golden looks at —the companion in Sector 35 (37, event 17: Arden, Saldra or
AG7), 64, 105 and 114—; and returning from a battle or from a large picture
with one of those without a route slot (covered by a page refresh in
`npc_poses_forget`, which nothing runs).

**On merging**: install `cartridge`, `convert`, `mapdata` and `wally`.
