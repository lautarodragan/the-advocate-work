---
name: "A Blurred Line: the chests change colour from map to map"
description: "The chests' palette changes between maps: open ones look flatter than closed ones, and in the Neon Vipers' base, with Arden, they look golden. Is there a distribution of the same number of colours that keeps them consistent without degrading anything else?"
type: research
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, 2026-10-16, playing A Blurred Line: the chests change palette from
map to map. Mostly it does not matter, but two or three cases stand out:

* open, they look flatter than closed —they must be losing a grey—;
* in the Neon Vipers' map, when Talan goes with Arden and finds that the
  agency (probably) took everyone, there are several chests, and they look
  golden.

**What taro wants, and what not**: consistent colour, but **no knob, no
hack, no palette reserved for them at the cost of other things, and no
other graphic degraded**. What is asked is whether the colour-fusing
algorithm (Adeleine, and how wally/rm2k-snes-screens use it) can change a
little so that, without treating chests as an exception, results come out
more consistent between maps with no loss of quality overall. taro's note:
that map already has a lot of grey; maybe there is a way to distribute the
colours that, with neither more nor fewer colours, makes the image more
consistent.

**First experiment, by hand, without touching the tools**: on that exact
map, from screenshots of the game running with Talan, Arden and a chest on
screen at once, look for an alternative distribution —changing what goes
into the ROM by hand, over the tools' current output, with a throwaway
script—. If one is found that improves that map, then look at what the
algorithm would need to approach it without worsening the other existing
distributions. If none is found, the algorithm is probably not worth
touching.

## Phase 1, by hand (Carpintero, 2026-10-16)

Measured on the-advocate `63b46ae9` and the ports `059ddcd`, global tools
from main.

**The map** is 38, `Sector 34 With Car`: the Vipers' HQ is its north-west
corner, reached through the pipe (events 20 and 21, only with Arden); the
scene of event 25 turns on 168 ("The Agency has been here"). Its three
chests are events 45–47, `BLObjs` character 2, closed pose 9 and open
pose 10 (page 2, switches 544–546).

**Why they look golden there and nowhere else**: map 38 has 22 characters
for 8 object palettes, and the split (`drawable_npcs`, wally) puts each
character in the first palette whose colours it fits **exactly**; when none
is left, the character is **lent** the palette it misses the fewest pixels
from, each missing colour going to its nearest by luma. The converter says
so: "map 38: 3 graphic(s) without a palette of their own, drawn with
someone else's: BLObjs:2, Chara2:2, People4:0". The chest is 13 greys
(and two orange pixels of the lock), and in luma —0.30/0.59/0.11— a
yellow-brown is near a grey, so the greys land on browns. Of ABL's maps,
38 is the only one where the chest is lent (31 maps lend something).

Two things make that choice worse than it has to be: the lending cost
counts the twelve poses of `BLObjs:2` (47 colours, other objects of the
sheet) when the map shows two, and it counts *how many* pixels miss, not
*how far* they go. And the chest is not the only victim: People4:0 (brown
hair instead of olive) and Chara2:2 (three black-haired kids drawn with
brown hair) are lent too, and show more.

**Open chests**: in the other fourteen maps with chests both poses are
**exact**; the open one is flatter in the drawing itself (eleven colours,
77 px of near-black interior, the light greys at 4 px each). On map 38 it
does lose a grey (16 and 19 both to `(18,18,1)`). Map 316 moves the
chest's greys too, but shows another object of that character (pose 7, a
turning event, so its colours are chosen over the twelve poses).

**By hand**: the leaders' four palettes fixed; the other seven characters
split into the four free palettes in all 350 ways, each group's palette
the union of its colours merged least visibly down to 15 (the timer's
colour kept). Error: mean CIE76 dE per pixel, against the sheet at 15 bits
(the background of 38 has no merged colour). Best candidate **M** (Chara4:1
alone; Chara2:4+People1:0+timer; Crown3:1+People4:0; Chara2:2+chest): chest
25.9 -> 1.4, Chara2:2 19.4 -> 3.8, People4:0 17.1 -> 5.8; worse: Crown3:1
3.6 -> 6.3, Chara2:4 4.0 -> 5.9, People1:0 2.6 -> 4.1. Worst character
25.9 -> 6.9 (a fixed one); sum 195 -> 70. **No split leaves everyone as
they are** (the least worsening is +1.8). Only switching the nearest to a
hue-aware distance, same split, gives 195 -> 152. Table, method and
hypothesis: `src/ports/abl/research/2026-10-16-the-chests-colours.md` in
the book (branch `carpintero-chests`). Captures and side by sides
(original | today | M | N): `/shared/captures/2026-10-16-chests/`.

**Answer**: yes, there is a better distribution of the same colours on
map 38, but it is a trade: three characters stop being drawn in the wrong
colours and three lose a shade. Hypothesis for the algorithm (not tried):
no character drawn with a palette not made with its colours in it —when
the events do not fit exactly, group similar characters and quantize each
group together instead of lending—; smaller steps first: lending cost over
the shown poses and by distance, nearest by a hue-aware distance. Cost to
measure: more characters with a per-map pose bank in the cartridge.

Not done: a capture of the original under Wine at that spot (getting the
original there means playing to it or editing a copy's start; the sheet at
15 bits over the exact background stands in), the other 30 maps that lend,
and the rain that does not fit on 38.

**taro, 2026-10-17**, on phase 1: "Excelente experimento y análisis!! Creo
que los puntos 1 y 2 deberían ser una mejora en general (sobre todo el 2).
Y coincido con que M se ve claramente mejor." Phase 2, Carpintero: steps 1
(the nearest colour by a distance that sees hue) and 2 (the borrowed
palette chosen over the poses the map shows, by distance), each on its
own, measured over the 31 maps that borrow and every game; then the cost
of step 3 (group and quantise together instead of borrowing) measured,
not implemented.

