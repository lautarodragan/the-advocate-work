---
name: "ABL: Forem left out at the factory"
description: "Map 83 leaves out Forem, event 13, whom a route dresses, because with him the rain's colours are lent: the converter says so, as it said of Northern Surl Camp's Paradise and Emily"
type: bug
status: testing
assignee: taro
agents: [cardon, tijereta]
author: tijereta
links:
  found-in: [abl-paradise-and-emily-left-out-at-the-northern-surl-camp]
  relates: [abl-the-factory-pump-s-light-is-grey, characters-a-route-dresses-left-out-where-they-cost-the-map]
  duplicated-by: [abl-the-factory-pump-s-light-is-grey]
  found: [share-data-on-the-rom-s-last-byte-does-not-link, rain-set-only-by-a-common-event-carries-no-drops]
---

Seen by Tijereta on 2026-11-22, grooming
[`abl-paradise-and-emily-left-out-at-the-northern-surl-camp`](abl-paradise-and-emily-left-out-at-the-northern-surl-camp.md),
in ABL's release build of the ports `89f77b4` with the-advocate
`0ae40e0a` and the global tools.

**What is seen**: on map 83, "Dalia at the Factory", event 13 (`Forem`)
draws nothing on any page and a route dresses him; the converter leaves
his row out because with it the map's rain loses its own colours, so the
scene goes on without him. It is the case that draft described for map
246, which no longer shows it, moved here. Forem was drawn from
2026-10-20 on
([`characters-a-route-dresses-left-out-where-they-cost-the-map`](characters-a-route-dresses-left-out-where-they-cost-the-map.md),
paying with the pump's red light,
[`abl-the-factory-pump-s-light-is-grey`](abl-the-factory-pump-s-light-is-grey.md));
when he went back out was not bisected. Not looked at on screen: no test
plays the scene that places him.

**How to see it**: `just cartridges release` in `abl/` and

    grep "map 83: WARNING" build/release/converter.log

says "events 13 draw nothing on any page and a route dresses them, and
they aren't drawn: with them the map loses rain-colors-lent".

## Comments

### 2026-11-24, Cardón: a question for taro

On map 83 one of three things has to go, and that is the game's own
choice: today Forem (event 13), whom a scene places there, is left out so
the rain keeps its colours (the converter says so in `converter.log`, ABL
release at ports `89f77b4`); from 2026-10-20 he was drawn and the pump's
light lost its red
([`abl-the-factory-pump-s-light-is-grey`](abl-the-factory-pump-s-light-is-grey.md),
closed as the other side of this).

**To decide**: (a) Forem out, as now; (b) Forem in, paying with the pump's
red, as from 2026-10-20 to whenever it went back; (c) Forem in, paying
with the rain's colours. **Recommendation**: (b): a character missing from
a scene loses more than a grey light; looked at on screen before choosing.
Both of ABL's Known issues lines about map 83 become one.

### 2026-11-27, taro: a question for Hornero

> > Say whether that is a rule for every map or this map's patch, and check that no other map's choice moves (the nine games' builds, byte for byte except map 83). ABL's Known issues lines about map 83 go in the same change.
>
> I can't remember what we talked about this, in the end, but this shouldn't be specific to this map. If it negatively affects other games/maps, I'd like to review it before deciding. (I do remember looking at the screenshots and choosing C, though).

### 2026-11-27, Hornero: a rule for every map

Agreed: a rule in Wally for every map, not a patch for map 83. The rule:
a lent rain colour (`rain-colors-lent`) costs nothing where no page of
the game can make it rain on that map, and weighs no more than its
measured distance where one can —here `(6,6,7)` drawn `(6,6,6)`—; so a
character a route dresses is not left out for it. Whoever implements it
builds the nine games and lists every map, of any game, whose choice
moves besides 83, with a capture of each before and after; if there is
one, it goes back to taro with those captures before landing. Still
`todo`.

## Log

### 2026-11-24, Hornero: taro asks to see b and c

> Could you ask Cardón to add a couple of screenshots, so I get an idea of
> how options B and C would look? I discard option A. I lean towards B,
> but I would like to see C too.

(taro, 2026-11-24)

Taken by Cardón only for the captures; it goes back to `draft` with
`assignee: taro` when they are in `/shared`.

### 2026-11-24, Cardón: the captures of a, b and c

In `/shared/captures/2026-11-24-forem-factory/`: `side-by-side.png` puts
the three ROMs and the original next to each other, and `README.txt`
says what each file is. ABL release, ports `4c23c9e`, the-advocate
`5572e9e8`. (b) and (c) were built with a wally changed only for this
experiment (branch `cardon-forem` in the-advocate, not to merge): (c)
keeps the dressed rows on map 83 whatever they cost; (b) does the same
and also lends `@tile:ChipSet1:138` a palette on map 83 only, without
trying to fit its own colours. The converter says the same as the
captures: (b) "drawn with someone else's: @tile:ChipSet1:138" and no rain
warning; (c) "the raindrops … are lent 6, drawn with its nearest colors:
[6, 6, 7] as [6, 6, 6]".

The scene is reached by teleporting Dalia (actor 21) to (68, 68), where
map 82's door leaves her, and letting event 9's autostart run with A
pressed on each box. The pump is seen from `test_delcentric_pump`'s cell,
(29, 61), with switch 276 on so the scene does not start. The rain is
written into `far_weather` by hand —strong, with its seed—: **as far as
the pages say, it does not rain on map 83 in the game**. No page of maps
82 or 83 sets the weather; the rain is set on maps 1, 20, 21, 108, 209,
223 and 309, and the weather survives a map change, so it would rain here
only if one of those left it on and nothing cleared it before Dalia's
scene —not checked by playing—. Every map carries the rain's colours
because some page of the game sets rain somewhere (`has_rain` in the
converter's `scan.rs`).

#### What is seen

* **Forem and the pump light are never on screen together.** Forem stands
  at x 55-58 for the whole scene; the pumps are at x 27-31, 24 cells away.
* **(a)**: the Agency Captain speaks from nowhere; the pump has its red
  light.
* **(b)**: the Captain is drawn, as in the original —with Kersh's sprite,
  `Future1` 5, which is what the route dresses him in—. The right pump's
  base loses its red light: nine pixels, red and two teal shades drawn
  grey, seen only by walking to the pumps. The rain, if it rained, would
  keep its colours.
* **(c)**: the Captain is drawn the same; the pump keeps its red light,
  identical to (a). What it pays is the raindrops' colour, `(6, 6, 7)` in
  15 bits drawn as `(6, 6, 6)`: a slightly bluish grey drawn neutral grey
  —186 pixels of a full-rain frame—, and only if it rained here, which it
  does not.

#### What each costs, as seen

(b) costs a small detail that is always visible near the pumps; (c)
costs nothing visible unless it rains here, and then one step of blue
in the drops. Seen this way, **(c) costs less than (b)**, against
Cardón's earlier recommendation, which did not know that the rain's cost
is that small and that the scene shows no rain. The fix for (c) would be the converter
counting `rain-colors-lent` as a cost only where a page can make it rain,
or not counting a lent rain colour this close; that is a change to
`loses_more` in wally, for whoever implements the choice.

Found on the way and left as a draft:
[`share-data-on-the-rom-s-last-byte-does-not-link`](share-data-on-the-rom-s-last-byte-does-not-link.md)
—a first try at (b), which lent the tile on map 17 too, packed
`share_data` at `$FFFFFF` and did not link—.

Back to `draft`, `assignee: taro`, for the choice.

### 2026-11-24, Hornero: Forem is Kersh

Event 13 is named `Forem` in the editor, and switches 276
(`ThreatenedForemDONE`) and 277 (`ForemScared`) use the name too, but the
route dresses him in Kersh's sprite (`Future1` 5) and Dalia calls him
"Sir!":

> I think so [that the captain in that scene is Kersh]. It would not make
> sense to me that the author reused Kersh's graphic, him being a main
> character and so striking, and especially not for someone in a similar
> role or title!

(taro, 2026-11-24)

So what (a) leaves out is Kersh, a main character, in a scene where he is
spoken to.

### 2026-11-24, Hornero: taro chose c

> Let's go with C.

(taro, 2026-11-24)

To `todo`: Kersh drawn on map 83, the raindrops paying —`(6,6,7)` drawn
`(6,6,6)`—, the pump keeping its red light. Cardón's note above says
where: `loses_more` in Wally must not count `rain-colors-lent` against a
character a route dresses here. Say whether that is a rule for every map
or this map's patch, and check that no other map's choice moves (the nine
games' builds, byte for byte except map 83). ABL's Known issues lines
about map 83 go in the same change.

### 2026-11-28, Tijereta: the rule, in Wally and the converter

Taken from the-advocate `b4654a3a` and the ports `aaa51a7c`, branch
`tijereta-forem` in both.

`git blame` on `loses_more`: `a2168be6` (2026-10-19) made any loss the
dressed rows add a veto, on purpose and for the menu pictures and tiles it
measured; `e5130fd7` (2026-10-20) took the lent tiles out of the veto and
said in its message that map 246's rain was not covered. The rain's note
is `f7028312` (2026-10-17). Nothing in them argues for the rain counting
where it never rains: every map of a game that sets rain anywhere carries
the drops (`has_rain`), so the note shows up on maps it never rains on.

The rule, as written:

* **Where it can rain** is a new question of the converter,
  `scan::rain_reach`: the sandstorm's walk (`sandstorm_reach`, now
  `weather_reach` for both) with the rain's type, and every map if a
  common event or a test page sets rain. The converter logs "it can rain
  in N of the M maps", and each map's request carries `rain_falls`. Where
  the drops go does not change: every map, as before.
* **`loses_more`** skips a `rain-colors-lent` on a map without
  `rain_falls`; on one with it, counts it only when its farthest drop is
  drawn more than `RAIN_SHADE` from its grey: CIE76 10, as
  `lab_distance` measures it (squared, in tenths). The factory's
  `(6,6,7)`→`(6,6,6)` is 5.5. **The 10 is my judgement**: Hornero's rule
  says "no more than its measured distance" without a scale to weigh it
  against a character; 10 is about where a difference stops reading as
  the same colour a shade off. The note now carries that distance.
* Unit tests: `losses` (the part of `loses_more` that reads the notes,
  taken out to test it) in `map.rs`, red without the two lines and green
  with them; `rain_reach` in `scan.rs`.

### 2026-11-28, Tijereta: only map 83 moves

The nine games built before (global tools, the-advocate `b4654a3a`) and
after (the branch), ports `aaa51a7c`: ABL's `release` and the root's
`cartridges`. Every other game's `.sfc`, `.msu` and `mapdata.inc` are
byte for byte the same; ABL's differ only by map 83, whose
`converter.log` now gives Forem's row and "the raindrops … are lent 6,
drawn with its nearest colors: [6, 6, 7] as [6, 6, 6]". Before, 83 was
also the only map of the nine whose dressed rows were left out for the
rain, so nothing else could move.

**The reach decides nothing here**: the walk carries the rain to 308 of
ABL's 313 maps, 83 among them —from Paradise a teleport reaches most of
the game—, and every map in Vampires Dawn, whose rain is a common event.
On 83 it is the distance, 5.5 under 10, that lets Forem in.

Captures in `/shared/captures/2026-11-28-rain-colour-rule/`, with
Cardón's harness script of 2026-11-24: the scene at tick 724, after with
the Agency Captain at the left edge; the same with rain written into RAM,
where the darkest drops also lose their step of blue; the pumps,
identical, the red light kept.

The book: the Known issues line about map 83 goes, and the converter's
stages page and the lossy colours page say the rule (`tijereta-forem` in
the-advocate-docs).

### 2026-11-28, Tijereta: verified, to testing

With the branch's tools (`just install-local .local-tools advocate wally
convert`): in the-advocate `just lint` (SOUNDFONT FluidR3_GM), `just
test`, `env -u SOUNDFONT just rust-test` and `just test-game` (231
passed, 6 skipped); in the ports, ABL's `just tests` (1621 passed, 2
skipped: no golden moved, `test_delcentric_pump_golden` among them) and
`just boot` at the root (209 passed). `abl.sfc` of the release:
`027b60e8a836d7e9` (sha256, first 16). After that, `main` merged into the
branches, which brought only `runtime/battle_message.s`; the suites were
not run again on it.

**What the suite does not cover**: no test plays map 83's scene, so
Forem drawn there is seen only in the captures; and none checks
`rain_reach` on a real game beyond the log line.

Branches `tijereta-forem` in the-advocate and the-advocate-docs; none in
the ports (no golden changed). When merging: `just install advocate wally
convert`.
