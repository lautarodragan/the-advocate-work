---
name: "Zounds: no way back from map 81 to where you came from"
description: "Map 81 (\"4\", under the cave's Arriba) is entered from map 79 at (46,43) and only lets you out to the left, to 189: nothing takes you back to 79, the crack's side, so the shortcut it makes leads nowhere from there"
type: bug
status: testing
assignee: taro
agents: [Carpintero]
---

taro, on 2026-10-20, in their words, translated:

> There's a bug in the original Zounds, I think in Map0081.json: the
> teleport events that let you go back the way you came —from the crack—
> are missing. It lets you leave on the left, which is fine and makes a
> shortcut, but the shortcut makes no sense if you can't get to the
> crack that way. Can you put those teleports on the stairs, more or
> less halfway?

**Read in the dump** (Hornero): map 81 has one teleport out, EV0006 at
(1,22) to map 189 (16,8); it is entered from 189's EV0001 at (2,22) and
from map 79 ("2") —its EV0010 and EV0013 at (18,2) and (19,2)— at
(46,43). Nothing in 81 goes back to 79.

**The fix**, approved by taro: teleports to map 79 on 81's stairs, about
halfway, in the game's own data, landing in 79 just inside the doorway
the party came out of, facing away from it, like the game's other
doorway pairs.

## Log

**2026-10-20, Carpintero — the cells.** Map 79's crack is two cells wide,
(18,0) to (19,3), and its teleports up to 81 are row 2 (EV0010 and EV0013,
below the hero, touch: FadeOutBGM, EraseScreen, the desert's tint, Teleport
to 81 (46,43), ShowScreen, PlayBGM `Zounds_Desierto_01`). On 81, (46,43)
is above a flight of stairs two cells wide, x 45 and 46, drawn from row 45
to the bottom edge, row 59 —walls on both sides—: halfway is row 52.

So **two touch events below the hero, EV0007 at (45,52) and EV0008 at
(46,52)**, the next free ids of map 81, back to **79 (18,3) and (19,3)**,
column for column, facing down. Row 3 is the crack's bottom cell, passable,
and 79's teleports run only when the hero steps onto row 2, so the landing
does not send the party back up. The page mirrors 79's the other way:
FadeOutBGM 2000, EraseScreen, TintScreen 60/70/80 —the cave's, set by map
58's fall on the way in; nothing else between 58 and 79 tints—, Teleport,
ShowScreen, PlayBGM `Zounds_Dungeon_01` (which 79 also inherits from map
68 since the cave's song fix; said anyway, as 79's exit says its song).

Captures with the cells marked, and a README:
`/shared/captures/2026-10-20-zounds-map-81/`.

**The game**: `b0e6b1f` on branch `carpintero-map81` of `~/juegos/zounds`
(over `master` `7ca8690`), `Map0081.lmu` only, written with `ditto
read`/`write`: the untouched file's round trip was byte for byte equal,
and the written one reads back to the edited JSON and writes back equal.
**The ports**: `just dump` with `GAMES` on the worktree: the difference in
`zounds/data/` is `Map0081.json` alone, the two events.

**The test**: `test_down_map_81s_stairs_back_to_the_crack` in the ports'
`tests/test_zounds.py`, from the debug map: `go_to_map` 81 at (45,43) and
(46,43) —the second is where the crack lands— and walk down until map 79,
at (18,3) and (19,3). Red with the ports' old dump (the hero walks to the
bottom edge, (45,59), and stays on 81), green with the new one.

**Verified**: `just boot -k zounds` at the ports' root: 30 passed on the
branch (over `a75f83c`), and 35 passed after merging the ports' `main`
(`0031803`). **Not with the global tools**: the ports' `main` already
carries Zounds' `[battle.terms]` `dodge`, which the global
`rm2k-snes-mapdata` (from the-advocate `main` `3bc68ac4`) refuses, so the
converter fails. The tools went in from Hornero's integration branch of
the-advocate, untouched, installed into a detached worktree's
`.local-tools`: `090b0037` for the branch (the pair of `a75f83c`), and
`5971f850` after the merge —with `090b0037` the merged tree had the
skill screen's three tests and the record player's bar red, which come
with runtime changes after it—. Neither ABL's suite nor `just test` was run: no
tool changed. What the suite does not cover: the tint and the song after
the jump (not asserted), and the fixed game under RPG Maker 2003 was not
played.

**When merging**: nothing to install. Branches, all `carpintero-map81`:
the game's in `~/juegos/zounds` (`b0e6b1f`, merged with `master`
`ae3c66c`), which has to be merged there so the next `just dump` does not
undo the ports' `data/`; the ports'; and the book's, a bullet in Zounds'
"What is fixed in the game itself".
