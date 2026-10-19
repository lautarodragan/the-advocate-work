---
name: "Zounds: a map animation leaves the map's colours wrong"
description: "In MiniCave (map 89), Tower (Ele)'s second page plays battle animation 89 three times, and after the second or third the map's background is left in wrong colours —yellow and magenta— that stay"
type: bug
status: doing
assignee: Chajá
agents: [Chajá]
---

taro, on 2026-10-19, playing Zounds (delivery of that day, the-advocate
`54ec3daf`, the ports `c2912ad`): in `MiniCave`, of `Oeste de la Grieta /
Secreto` —map 89, `… / Secreto / 5 - Rocks2`—, "the animation that `Tower
(Ele)` uses in its second page leaves the colours like this on its second
or third animation. I think the culprit is `ShowBattleAnimation`."

Two screenshots in `/shared/captures/2026-10-19-zounds-animation-colors/`:
`23.png`, a message of Kazar's with the background already wrong; `24.png`,
the map afterwards, still wrong. The characters and the face look right.

What Hornero saw: event 8, Tower (Ele), at (14,11); its page index 1 runs
`ShowBattleAnimation [89, 10005, 0, 0]` three times. The converter log:
"map 89: battle animations are drawn in 64 tiles from 192, palette 6".

## Log

**2026-10-19, Chajá.** Worktrees in `~/scratch/chaja/anim-colours/`
(the-advocate `54ec3daf`, the ports `c2912ad`), branch `chaja-anim-colours`
in both.

Reproduced, **in bsnes and not in snes9x**: the switch 126 on by hand, a
jump to map 89 at (13,11), right and A against Tower (Ele). After the
page, snes9x's screen is the map as it was, and bsnes' is the map with its
background in wrong colours, with `cgram_shadow` intact —only sprite
palette 6, the animation's, changed, which is right—. So what is wrong is
CGRAM, not what the ROM thinks it is.

Animation 89, "Bolt Magic S 1": a screen flash on frame 1 and three on the
target on frames 1, 5 and 10.

**The cause, measured** —a throwaway build with the V counter latched at
points of `flush_video`, in bsnes, and a capture every tick—: the garbage
appears on the tick the box after the second animation appears, and again
after the third. The second and third `ShowBattleAnimation` do not wait,
and the box right behind each one is composed and shown while the
animation still draws. On the vblank where the box's last line goes up and
the box appears, the animation's 2 KB frame went up too: the frame ended
at line 246, the line at 262, the HDMA tables at 268, and `HDMAEN` was
written at line 270 —eight lines into the next frame—. A channel turned on
after the top of the frame runs that frame from wherever its table was
left, and channel 5, the face's palette, writes CGRAM: the map's palettes
were left in garbage, and nothing writes them again until a tint or a
flash. The first animation is followed by a `MoveAll` that waits, so its
box comes after it ends: that is the "second or third". snes9x does not
run the stale channel, and its screen stays right.

Not the flashes, nor the animation's palette (sprite palette 6, entries
224-239, right in the shadow), nor the arrow: map 89's arrow objects take
palette 7 and tiles 256-257, above the box's 192-255, and no map of
Zounds' release has its arrow on its box's tiles or palette —checked over
`arrow_objs` against the converter's log—.

`git blame`: the face's HDMA channel came with `e65be23e` (2026-10-15), the
first channel that writes something that stays; until then a late `HDMAEN`
cost a frame of a misplaced window at most. The window's budget in
`flush_video` counts a window line against the poses, but the animation's
frame, which came later, went up regardless.

The fix, the-advocate `4ec5a45c` on `chaja-anim-colours`, in
`runtime/vblank.s`: the animation's frame waits for the next vblank when
the window takes this one —a line, which the box's appearance always comes
with, or a System's window—; and the box's appearance and the window's
`HDMAEN` are done only while `HVBJOY` says the vblank lasts, otherwise on
the next one. Measured again with the probes: the two vblanks that ran to
270 no longer pass 261. The test, the ports `0f75bc8` on
`chaja-anim-colours`: `test_zounds.py::test_the_towers_animations_leave_the_maps_colours`,
the page in bsnes, before and after compared; red before (10% of the
screen differs), green after (1%, the characters that moved).

What the probes also showed and is not fixed here: a draft,
[a face's cells step runs past the vblank](a-face-s-cells-step-runs-past-the-vblank.md).
