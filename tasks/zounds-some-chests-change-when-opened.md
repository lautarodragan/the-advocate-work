---
name: "Zounds: some chests change when opened"
description: "Opening some chests in Zounds draws a different chest than the closed one"
type: bug
status: doing
assignee: Cardón
agents: [Cardón]
game: zounds
---

taro, on 2026-11-17, translated:

> And another, from today: some chests in Zounds change when opened (just
> what you told me to watch for after baking the moved chests and the
> 12/4 poses).

Screenshots in `/shared/bug-reports-etc/zounds-chests/`
(`zounds_000.png`-`zounds_012.png`): e.g. in the desert, a red chest next
to the hero becomes a brown one when opened ("Has Encontrado: Poción Roja
x1"). Build of 2026-11-17 (ports `428e7c3`, the-advocate `fe5529a3` or
`95863f36`).

Suspects, from the day's changes: the baked still events (a chest drawn
into BG1 whose next page's graphic is a sprite from another CharSet cell),
and poses-only (four facings instead of twelve for NPCs that only turn).

Done means: which chests and maps, the cause, fixed, with a ROM test.

taro, later the same day, translated:

> ABL's chests that I tested (almost all of Lashe City, the Arden path)
> were all fine, and about half of Zounds' were fine (dungeon, desert, the
> crack, the maze north of the crack).

## Log

**Cardón, 2026-11-17**, from the-advocate `95863f36` and the ports
`7ea4469`, in `cardon-chests` of both.

**The screenshots are the game's own data.** Each chest is two pages, the
second on the switch the first turns on, and in three of the pairs taro
sent the second page names another cell than the first:

* `zounds_000`/`001`, map 34 event 63 at (11, 49): closed is
  `Zounds_Chest_04` character 4, facing down —the red one—; open is
  character **0** facing left, and every opened chest of that sheet is
  brown. So it opens brown.
* `zounds_003`/`004`, map 34 event 2 at (40, 8): `Zounds_Chest_03`
  character 0, red closed and red open. Unchanged, as the ROM drew it.
* `zounds_006`/`007`/`008`, map 84 event 4 at (5, 4): closed is
  `Zounds_Chest_04` character 0 —the orange one—; open is
  **`Zounds_Chest_03`** character 0 facing left, the red open one.

And the sheet itself: `Zounds_Chest_04` has its closed chests in eight
colours (the facing-down row of its characters) and only brown ones open
(the facing-left row, but for two grey ones), so any of its chests that is
not brown closed changes colour when opened, in RM2k too —map 34's event 1,
red to brown; event 9 and map 88's five, orange to brown—. The PNGs in the
game's `snes-port` branch are its XYZs pixel for pixel (checked: decoded
the XYZ of `5fa54e6`).

**EasyRPG agrees**: started at map 34 (10, 49) with `--start-map-id`, the
hero turned right and opened event 63: red closed, brown open, as on the
console. `Game_Event::RefreshPage` sets the new page's graphic and, when
the facing or pattern differs, its facing.

**EasyRPG, map 84 too**: started at (5, 5), the hero turned up and opened
event 4: orange closed, red open, as on the console (`zounds_006`-`008`).

**A sweep over the console**: every chest-like event of two pages —the
second on the switch the first turns on— that the release cartridge
carries, 29 of them, reached from the debug room with `go_to_map`, its
switch written off and on, and its cell compared with RM2k's pose for each
page. Every one draws its own page's cell and colours, the baked ones too
(map 17's stands the 2 px lower its cell asks for, as decided). Contact
sheet in `/shared/captures/2026-11-17-zounds-chests/`. The one exception
is not about opening: **map 134's chest at (2, 30) is a dark square**,
closed and opened, because on that map its graphic, `object1:6`, is lent
another's palette ("10 graphic(s) without a palette of their own" in
`converter.log`). It is the only chest lent one. Draft:
[`zounds-map-134-s-chest-is-a-dark-square`](zounds-map-134-s-chest-is-a-dark-square.md),
and a line in the book's Known issues.

So the chests taro saw change are the game's own pages, and the port is
faithful. Those whose colour changes in RM2k, by the dump: map 34's events
1 and 63 (red to brown) and 9 (orange to brown), map 84's 4 (orange to
red), map 88's five (orange to brown), all `Zounds_Chest_04` closed; the
rest keep their colour. That lines up with taro's "about half". Not fixed
here: making them open in their own colour is a change to the game's
art —`Zounds_Chest_04` has no coloured open chests to point at; red could
borrow `Zounds_Chest_03`'s, orange has no match— and that is taro's call
on their own game, done in its repository and dumped, as
[`zounds-two-chests-share-a-switch`](zounds-two-chests-share-a-switch.md)
was.

**Same class in ABL**: none. Its 62 two-page `BLObjs` chests all open in
the same character they close in.

**The test**: `tests/test_zounds_chests_open.py` in the ports opens three
chests as the player does —beside it, facing it, A— and holds each cell
closed and opened against its goldens, checked against RM2k's poses: map
34's (an object whose open page names another character), map 84's (an
object whose open page names another sheet) and map 17's (baked into the
background, turning to another facing). It was not shown red: there was
no fix; it guards what the console already did.

**Verified**, on the ports' `cardon-chests` and the global tools
(the-advocate `95863f36`; nothing of the tools changed): ABL's `just
tests`, 1679 passed and 2 skipped, no golden moved (`abl.sfc` sha256
`3cfb09a7648de945`), its `test_cores.py` 24 passed; `just boot` at the
ports' root, 158 passed, the new test's three among them; after merging
the ports' main (`1d0a6b6`), `just boot -k zounds` again. `just space`:
the tightest is `abl`'s release, 0 whole banks free and 11 halves; bank
0's least is 3,752 bytes.

**What the suite does not cover**: of the 29 swept chests only three are
held by a test; the rest were looked at once, by the sweep. The `object1`
chests (the RTP's) and the baked chests of maps 19, 33, 60 and the others
have no golden of their opening.

**Branches**: the ports' `cardon-chests` (the test and its goldens), the
book's `cardon-chests` (the Known issues line), and this one (the task and
the draft). **To install when merging**: nothing.

## Reopened (2026-11-17, Hornero)

taro, translated, after seeing that RM2k does the same:

> Oh! It must be a bug in Zounds, then. Maybe they use this CharSet.

with a picture of a chest CharSet (kept in
`~/scratch/hornero/zounds-chest-sheet-from-taro.png`): closed chests in
many colours, opened ones only brown and grey. So it is fixed in the game
itself, like
[`zounds-two-chests-share-a-switch`](zounds-two-chests-share-a-switch.md):
each coloured chest opens in its own colour.
