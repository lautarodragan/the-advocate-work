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
