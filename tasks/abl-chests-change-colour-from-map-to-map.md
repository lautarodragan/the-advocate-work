---
name: "A Blurred Line: the chests change colour from map to map"
description: "The chests' palette changes between maps: open ones look flatter than closed ones, and in the Neon Vipers' base, with Arden, they look golden. Is there a distribution of the same number of colours that keeps them consistent without degrading anything else?"
type: research
status: done
assignee: taro
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

**taro, 2026-10-17**, on phase 1, in their words, translated:

> Excellent experiment and analysis!! I think points 1 and 2 should be an
> improvement in general (especially 2). And I agree that M looks clearly
> better.

Phase 2, Carpintero: steps 1
(the nearest colour by a distance that sees hue) and 2 (the borrowed
palette chosen over the poses the map shows, by distance), each on its
own, measured over the 31 maps that borrow and every game; then the cost
of step 3 (group and quantise together instead of borrowing) measured,
not implemented.


## Phase 2 (Carpintero, 2026-10-17)

Started from the-advocate `48362b6b` and the ports `9ce88ef`; main moved
during it (Calandria's still pages, `b15c9408` / `bd92975`), was merged,
and everything below was measured again on it. Branches
`carpintero-lending` in the-advocate, the ports and the book. Two commits
in wally, one per step:

* **Step 2** (`bf056f24`): `fits` only marks a character lent; `lend`,
  once every palette is whole, gives it the palette with the least *pixels
  × distance* over the poses the map shows (each colour as the bank draws
  it). The distance, not its square: the square was measured and lost.
* **Step 1** (`18b67bc6`): `nearest` is the nearest in CIE Lab (Adeleine's
  new `lab_distance`, CIE76 in integer tenths), not by luma; the lending
  cost and the timer's use it too. Oklab was measured as well and lost.

How: every game's `cartridges` built once through a shim that keeps
wally's requests; each variant of wally replayed over them with a
throwaway report: per character drawn with a palette of the map's, the
mean colour difference per pixel against the sheet at 15 bits over the
poses the map shows, in CIE76 and CIEDE2000 (CIEDE2000 is the judge: Lab
would judge itself). Per map the worst character and the sum.

**197 instances of 196 maps lend** (ABL 30, BoT 3, Desert Nightmare 42,
Dooms 2 3, El Dorado 10, Frozen World 14, Sunset 11, Vampires Dawn 70,
Zounds 13). No map that does not lend moves, in any variant.

| CIEDE2000 | better / worse / same | sum of totals | sum of worst | chars worse > 1 |
|---|---|---|---|---|
| step 2 | 135 / 22 / 40 | −18% | −23% | 56 on 38 maps |
| step 1 | 149 / 35 / 13 | −4% | −3% | 74 on 36 maps |
| both | 176 / 15 / 6 | −23% | −30% | 35 on 22 maps |

In CIE76: step 2 143/14/40 (−21%, −24%), step 1 187/1/9 (−11%, −13%), both
190/1/6 (−31%, −38%), nobody worse by more than 2.3. No map's CIEDE2000 sum
gets worse by more than 1.7 with both; the worst character, +3.3, is
Vampires Dawn's 221 `sozai00:1`, which on screen gets its blue dress and
blond hair back. Map 38: chest 25.9 → 9.1 (M had 1.4), People4:0 17.1 →
14.6, Chara2:2 19.0 → 13.7, nobody else moves.

Lost variants (on the earlier main, CIEDE2000, with step 2): squared cost
with Oklab 143/50/12 and 134 chars worse; linear with Oklab 157/33/15 and
88; linear with Lab, the chosen one, 182/17/6 and 41.

**Step 3, cost only** (model: each palette hosting a guest re-quantised
with all its characters; a member whose colours move gets its own pose
bank; ROM counted per pose, since the cartridge stores each once): 448–522
more pose banks over all games, 1–3 per lending map on average (max 31,
Vampires Dawn's 95), 1.4–1.6 MB. ABL 31–37 banks, 156–174 KB, and ABL's
`release` has about 229 KB free with steps 1 and 2: it fits, 55–70 KB
left. Vampires Dawn (508–598 KB) has no free bank: it would go to the
`.msu`. The rest have two dozen banks free or more. A real grouping would
move more characters than the model, so it costs more.

Verified: `just rust-test`, `just test`, `just test-game` on the merged
tree; ABL's `just tests` green after five rounds, 35 goldens moved, looked
at, committed in the ports (`01d3217`); `just boot`: Sunset's four square
goldens moved (`80f0aba`), the rest green; once Zounds' cores arrived 16
ticks apart under load and passed right after (draft
`zounds-the-two-cores-once-arrived-sixteen-ticks-apart`). Captures and
side by sides: `/shared/captures/2026-10-17-palette-lending/`. Book:
`research/2026-10-17-the-palette-a-character-is-lent.md`, and the colours
page, "Every event is drawn" and Adeleine's entry updated.

**When merging**: `just install wally adeleine` (events came from main).
`rm2k-snes/wally/src/sprites/extras.rs` is touched (one line: the timer's
lending cost uses `lab_distance`), and Calandria works there: look at that
merge by hand.
