---
name: "Map 11 redesigned"
description: "The 52 light tiles become tiles: from 30 fps to smooth"
type: bug
status: done
---

# What

The Lazer Teeth HQ —map 11— **didn't fit in a frame where the stones minigame
is played**, and what pushed it over was its **52 light tiles**: 52 events
drawn with the same opaque ChipSet tile, the pool of light on the floor.

It was fixed **by redesigning the minigame**, not by optimizing the engine:
the light tiles stopped being events. The decision, and the two optimization
paths that were discarded on the way to it, are below.

# Status

**Done on 2026-09-21.** The 52 light tiles stopped being events: the pool is a
map tile, turning off a cone is a `TileSubstitution` and catching the hero is
a parallel that looks at the cell's terrain. The map lives forked in
`juego/mapas/Map0011.json`, with its own ChipSet.

Dropped frames walking 1200 frames, measured with
`/extras/scratch/mapa11-cierre/perdidos.py`:

    cell      diagnosis     the two paths     redesigned
    (50,50)       231             153              0
    (26,47)       625             475              2
    (18,50)      1200               9              0
    (19,46)      1196            1141             11
    ( 5,50)      1200              19              0

**The cell where the minigame is played went from 30 fps flat to eleven
dropped frames out of 1200**, below the ceiling the diagnosis had measured
—23—. The map's drawn events go from 69 to 17.

And it plays: `tests/abl/test_lights.py` measures that standing on a lit tile
opens the "they caught me" message, and that the stone on `Light5` turns off
its cone and leaves the broken lamp's switch set.

**What was discarded**, and it's the decision that opened all this: paths 3
and 4, which were engine optimizations. See "Why it isn't optimized" below.

# What was measured

Dropped frames walking 1200 frames, with the counter read and reset to zero
every 50 because **`lost_frames` saturates at 255**. It's the same method
that gave the 450 and the 228 in `opaque-events-into-the-map.md`, and that 228 was
reproduced exactly.

**The cell it's measured from changes the answer by a factor of five**, and
that's the first thing to know: the `in-11` case leaves the hero at (50,50),
which is an **empty area**, and there **no** light tile falls on screen. What
had been measured was the cost of rows that are never drawn.

    cell      on screen     as it is today   without the tiles  with nothing drawn
    (50,50)         0            231                75                 0
    (26,47)        17            625               108                73
    (18,50)        26           1200                 3                 3
    (19,46)        31           1196                23                10
    ( 5,50)        23           1200                 3                 3

"As it is today" is 50 drawn rows out of 69 —the 18 baked ones are already
hidden—; "without the tiles" is 16; "with nothing drawn", 0.

**1200 out of 1200 is 30 fps flat**: missing the vblank costs the whole frame,
not half. That is, in the minigame's area the map today **doesn't gain a
single frame** while walking, and without the tiles it drops three.

Standing still the margin is thin and enough: 176 iterations in 180 frames
with the tiles on screen, 179 without them. What brings it down is the scroll
redraw added to the sprites.

## An event parked outside the map **does cost today**

It's the cheap question, and the answer is that it costs, though less than one
on screen. Measured with a third variant that leaves the 52 tiles **drawn**
but parks them at (97,97), which is what the game does when turning off a
light:

    cell      as it is today   parked outside   without drawing them
    (50,50)        231               231                  75
    (19,46)       1196                75                  23

The row still costs its iteration of the loop, the comparison against the
hero's key and `place_npc`'s computation; the only thing saved is the body of
`emit_object`, which discards what falls off screen. **34 extra hidden rows are
worth 156 frames out of 1200 at (50,50) and 52 at (19,46).** Being on screen
costs much more than existing: 75 against 1196 on the same cell.

## The 84 events, by what they do

    group                        n   drawn     visible   relocated     tile
    light tile                  52      52        52          30        80
    no graphic                  15       0         0           4        —
    light source (Light1..6)     6       6         6           4        73 (and 53)
    character (Chara3)           6       6         6           6        CharSet
    the stone (Stone)            1       1         1           1        CharSet
    the idol (TheIdol)           1       1         1           1        65
    the ResetPuzzle console      1       1         1           0        33
    the LTComputer               1       1         1           0        49
    EV0017                       1       1         0           0        13

The **52 light tiles** are the group, and the name groups them without
identifying them: there are 19 events called `B3`. They're A 10, B 22, C 10,
D 4, E 6. All 52 are drawn with tile 80 and none walks. **33 have commands on
some page and 19 have none**: those do nothing but get drawn.

**Two mechanisms best not mixed**, because they coexist in the same minigame:

* the **sources** —the six `Light*`, and with them the PC and the idol— have a
  **second page conditioned on a switch** with **another tile**: it's the
  broken lamp. Their parallel page compares the stone's position with their
  own and, if they match, runs the `ChangeEventLocation`s;
* the cone's **light tiles** **don't change page: they move**. Turning off a
  cone means sending its tiles to (54,82), (97,97) or (98,97), and they don't
  come back except through `ResetPuzzle`, which relocates 42 events in one go.

The **15 without a graphic** are the ones that cost nothing to draw: the four
`Block*` of the shooting mode —which `ChangeEventLocation` places around the
hero—, the three grates, the two `EV008x` of the stairs, and the rest are scene
triggers and examine signs.

**The boxes that get examined and have nothing inside are real, and they're
the grates**: `EV0078` (3,51) and `EV0079` (6,38) answer "There's nothing in
the grate, except for a lot of dirt", and `Grate1` (26,51), once the stones
have been taken out, answers "There's nothing else within the grate". **None
of the three is drawn**, so they don't cost a single frame and removing them
gains nothing. They're the game's prose, not dead weight.

## Four still tiles are rejected by the rule for a single reason

Of the 52, **22 aren't relocated by anyone** and the baking rule bakes **18**.
The four left over are events **31 (`B1`), 32 (`B2`), 33 (`B3`) and 46
(`B2`)**, and the reason is a single one: **they have two or three pages**, and
the rule asks for one. But **all their pages draw the same tile 80, on the same
layer, and the first one has no condition**, so their drawing is as fixed as
the other 18's. What changes between their pages is the script, not the
graphic —in fact `collect_npcs` already knows it: it gives them `cambia`
false—. (That's path 1, which is already done: today the rule bakes them and
they're 22.)

# The paths, with what each one costs

## 1. Loosening the baking rule — DONE

The condition is the first page without a condition and **all** the pages with
the same graphic, the same layer and no continuous animation. It's in
`eventos_horneables`, with the why of each thing.

What was expected was **26 → 31** with map 2 joining in. What came out is
**26 → 29 on 7 maps**, with map 11 from 18 to 22, because map 2 **moved a
golden** and that forced a sixth condition: **baking can't open the cell**.

Map 2's `MovinDoor` is in a corner, outside any camera, and baking it moved
`door-left-950` by 113 pixels —a door sixty cells away, with the same
switches set—. What was measured before deciding: the map's CGRAM comes out
identical, the background draws the same except for the baked cell, the NPC
table changes **a single byte** —that row's "is visible"— and the compiled
pages don't change. The only thing left is that **its cell is closed in the
map's table and its tile gets overwritten**, so baking it opened it;
`pasa_con_evento` checks the row, but more than one reads the table. **The
whole mechanism wasn't taken apart**: if someone wants to pull on that thread,
the comparison is in the commit.

Closing too much is still allowed, which is the normal case. Map 141's
`EV0004` also comes out, which was in the same situation and no test runs.

**What it doesn't fix**, as expected: nothing of the lag where the game is
played. Those four tiles are inside group B, which is already almost entirely
baked. At (26,47) it goes from 625 to 527 and at (19,46) from 1196 to 1150.

## 2. Not processing the row of an event that falls off screen — DONE

It didn't end up as a `cmp` in `build_oam` before `place_npc` but **inside
`place_npc`**, split in two: the X as soon as it's computed and the Y right
after the jump. It comes out cheaper than the outer `cmp` —half the discards
read nothing else from the row, and the one that does get drawn pays no extra
computation— and there's no margin to choose: it's the same comparison as
`emit_object`'s, with the same offset of 32 and the same cut at 224 at the
bottom, so it discards object by object the same and the OAM comes out
identical.

**It gains far more than expected.** The estimate was "part of the 156 frames
at (50,50) and of the 52 at (19,46)"; what was measured is 231 → 153 at
(50,50), and **1200 → 9 at (18,50) and 1200 → 19 at (5,50)**: two cells that
were at 30 fps flat and now fit in the frame. They were just on the other side
of the edge.

It costs 21 bytes of bank 0 and **gains on every map**, not only on 11.

**It doesn't fix the case that matters**, as expected: with the cone on the
tiles are on screen and keep costing. At (19,46) it goes from 1150 to 1141.

# Why it isn't optimized

## 3. Baking each known position and turning the tilemap on/off — DISCARDED

It was the only path that attacked the 1141 frames: a tile that moves
**between two known cells** gets baked into its own, and when the cone turns
off the map's tile changes instead of moving an OAM row. Measured ceiling,
**1196 → 23 dropped frames out of 1200**.

The rule is general —it's today's baking one with "never moves" swapped for
"moves only to constant cells"— and **knows nothing about ABL**. What
discarded it is how much it yields, measured on 2026-09-21 over the 328 maps
with `/extras/scratch/horneado-movil/contar.py`:

    map    events   positions per event
      11      30       3
       3      24       2
      28       2       2
       2       1       2
      17       1       3
      83       1       3

**59 events on 6 maps**, out of 123 with a fixed ChipSet drawing in the whole
game, and that's the upper bound: the script doesn't look at opacity or at
whether baking would open the cell. That is, **54 of the 59 are on two maps**,
and the second one —3, the Emitter Room's wrecked hall, with some twenty
events on screen at once— **isn't a problem while playing**: taro never
noticed lag there.

taro's decision: a table of overwritten cells in RAM, plus checking it in
`stream_map`, isn't paid for one map. **Averaged over other games, it yields
less than one map.**

## 4. A converter special case for the light tiles — DISCARDED

It's discarded by the same thing as 3, and it was already discarded before
because **it recognizes this minigame from the inside**, which is what the
port does nowhere.

Emitting the 52 as their own structure —a bitmap of "this cell is lit"—
instead of 52 events. It gains the same as 3 and also saves 52 rows of the NPC
table and 52 entries of `pasa_con_evento`'s walk.

What it breaks: it's **recognizing this minigame from the inside**, which is
exactly what the port does nowhere. The rest of the engine knows nothing about
ABL, and this would. If path 3 is enough, this one isn't needed.

## 5. Freeing the sprite palette and the VRAM slot of the baked ones

It's noted in `opaque-events-into-the-map.md` and still holds: today a baked event
still goes into `npcs_dibujables`'s allocation as if it were drawn. Removing
it frees a palette and **changes what's seen** —map 11 has a graphic drawn
with someone else's palette, `@tile:lasheint:49`—, so it **moves goldens** and
is a separate decision. It doesn't gain frames: it gains colors.

# The redesign

Decided on 2026-09-21. **The 52 light tiles stop being events**: the pool of
light becomes a map tile, and turning a cone on or off is changing that tile.
With that there's nothing left to optimize, and what the engine gains is **two
RM2k commands it doesn't implement today**, useful for any game that gets
ported.

It gains the same as path 3 did —from 1141 dropped frames down to the floor—
and also removes 52 rows of the NPC table, which `pasa_con_evento` walks on
every step.

## The two commands, verified against liblcf and EasyRPG's interpreter

* **`TileSubstitution` (11750)**, parameters `[capa alta?, tile viejo, tile
  nuevo]`. It substitutes **all** the cells with that tile, on that layer, in
  the whole map. It's by **tile number and not by cell**, so in the ROM it's a
  small table in RAM that `stream_map` checks when writing each tile —quite a
  bit cheaper than the table of overwritten cells path 3 required—.

  Being global per tile is what forces **duplicating the tile**: one number per
  cone, or turning off one would turn them all off. And duplicating **comes
  for free**: Voodoo deduplicates at the 8x8 level and reuses the mirrored
  ones, so a repeated ChipSet tile is four cells that were already there.

* **`StoreTerrainID` (10910)**, parameters `[modo, x, y, variable]`. The
  terrain comes from the **lower layer**'s tile —"RPG_RT always uses the
  terrain of the first lower tile"—, not from the upper layer's. That is, the
  terrain **can't say "I'm lit"**, because that layer doesn't change when the
  cone turns off: it says **"this cell belongs to cone C"**, and whether C is on
  is already known by a switch the game has.

  From that it follows that a few duplicated floors are needed and not 52: one
  per cone. The parallel boils down to reading the terrain under the hero, and
  if it's a cone's, checking its switch.

  **They're three and not six**, measured when doing it: only three groups of
  cells catch. The three terrains are 27, 28 and 29, which no ChipSet of the
  game uses and which carry the same values as 1 —the one the map has today on
  all its cells—, so using them for the first time changes nothing but what
  `StoreTerrainID` answers.

The port also has to emit the **terrain table per ChipSet**, which `lcf.py`
already reads (`terrain_data`) and nobody uses. It goes to bank 1, which has
about 21 KB free.

## What was measured of the ChipSet

Map 11 uses **ChipSet 10**, which seven maps share. Together they take 55 of
the upper layer's 144 tiles: **89 are left free**. The lower layer has 162
slots, and ChipSet 10's `terrain_data` is **all 1** — ABL doesn't use terrains
anywhere.

Even so, the redesign goes with **a ChipSet of its own for map 11**, taro's
decision: it shares with no one, so duplicating floors with their terrain
doesn't touch a pixel of the other six maps, and deduplication means that a
ChipSet almost the same as 10 costs no tiles.

## What the reset requires

`ResetPuzzle` today relocates 42 events **without reloading the map**.
Reloading it isn't equivalent —it would also move the hero and the stone—, so
**the turned-off light tile is also a tile of its own**: turning on is
`80 → 80A` and turning off is `80A → 80`, the substitution is symmetric and the
reset is substituting again.

**That `TileSubstitution` doesn't persist is canon and is left that way**: in
the interpreter it's applied to the scene's spriteset, that is, it's lost when
the map reloads. In ABL this map is never returned to, so there's nothing to
reapply.

The only case where the redesign could differ from the original is **returning
from a battle**: in canon the substitutions would be lost, but today's events
survive. It doesn't happen, and it's verified: `Lazer Teeth HQ` has
`encounters: []`, that is, no troop assigned. It's noted because it's what gets
reintroduced by accident the day someone puts troops on a map.

From that comes an implementation decision best taken on purpose: **the
substitutions table lives as long as the loaded map lives, not as long as the
tilemap window**. Clearing it when loading a map and not when refilling the
window leaves it canonical and also correct if some day you come back from a
battle.

## The 33 light tiles with commands

They were assumed to be copy-paste and **they aren't**, though almost: looking
at them one by one —on 2026-09-21, before deleting them— five different
scripts and four cells with their own pages came out.

The five scripts are the same "they caught me, the minigame restarts" with the
guard who's watching and the text changed: on cone C it's `LTSentry2` who
catches you and not `LTSentry1`, `A1` says "avoid the light" where the B ones
say "avoid the light, or not be seen", and there's an "avoid being seen"
variant for when the guard is walking. They're copied as is into a five-page
event and the parallel calls the right one, which is the shape the map already
used.

The four cells with their own pages are from group B and look at two switches:
46 —the guard went to check the noise— and 51 —he's walking—. One lets you
through, two answer "Something behind me?!" and three change the text. The
parallel tells them apart by cell, and that comparison **only runs when the
hero is already standing on one of group B**, that is once per playthrough and
not once per frame.

## The map's fork, not the patch

The redesigned map 11 is a **whole replacement of the file**, not a
description of changes, and the pipeline ignores the original if it exists.
Three things support it:

* **It doesn't go in `patches/`**, which today is **generated output** —the
  color merges the allocator decided—. This is hand-written input that
  overrides everything else: two opposite directions in one directory is what
  someone regenerates without looking.
* **The original stays versioned in `data/`**, so the diff isn't lost: it's
  computed when needed. And nothing gets overwritten, because `unpack` writes
  into `data/` and never into the fork.
* **It's all or nothing.** The layers live outside the JSON, so a `.json`
  without its `.tiles` would leave the build with the old layers and the new
  events, and that **looks fine** until it doesn't. If a piece is missing, the
  build refuses.

The tests it requires, from taro and from here: that the **id inside match the
file's name** —otherwise the teleports break—, and that **the teleports that
enter that map from the rest of the game still land on walkable cells**,
which is the one that really breaks the game and the id doesn't cover. Map 11
is in `abl`, so its golden covers the rest.

The whole fork is data and **Ditto can write it**: it reads and writes `.ldb`,
`.lmu` and `.lmt`, with a round-trip over the 330 files. It's four things: the
new ChipSet in the database with its passability and its terrains, the map's
`chipset_id`, the `upper_layer` with the baked pools, and the 52 events
replaced by a single parallel one.

**Done on 2026-09-21**, with three things decided while doing it that this
document didn't foresee —the why of each one, in `juego/README.md`—:

* the map's fork carries inside it an `id` field that Ditto's dump doesn't
  have. It's the only thing that makes the test taro asked for real: the
  pipeline picks the map by the **file's name** and the teleports name it by
  its **id**, and without that field there's no "id inside" to compare;
* **the new ChipSet doesn't replace the database's section: it's added**, in a
  file of its own. A fork that overwrote `db/chipsets.json` would go stale
  without warning the day `just dump` changes it;
* **its image isn't versioned: it's built.** The game's art isn't ours to
  redistribute —it lives in `/extras`—, so what's committed is the recipe
  —which block and which tile get copied where— and the PNG goes to
  `rom/build/juego/`.

## The trap that showed up when building it: the destination block

`TileSubstitution` swaps one tile for another, but the ROM draws **16x16
blocks with both layers together**. If the map already draws, on some cell,
the combination the substitution is going to leave, the block exists and
there's nothing to build; if not, the converter builds it, and **it can't when
either of the two tiles gets baked into the background** —an upper tile
without the `Above` bit doesn't go to BG2, and there the block's two halves
stop being independent—.

The pools of light are exactly that case: they go **under** the hero, so they
don't carry `Above`. Giving them the bit so the block can be built would put
them on top, and the pool is opaque: **the player would vanish when standing in
the light**.

The way out doesn't touch how it looks: **the missing combinations get drawn
onto the map**, one cell each, in the last row. The map is 100x100 and all its
content fits in x 1..28, and 35..58, so neither the hero nor the camera gets
there —it's where the game itself parks the events it turns off—. They're
fifteen, and they aren't a hand-written list: they're deduced by
`/extras/scratch/mapa11-cierre/faltantes.py` from the map and its own
substitutions, and after applying them it answers zero.

**It'll happen to any fork that substitutes a tile that doesn't carry
`Above`.**

## What remains different from the original, and taro has to judge it

* **The cone takes a while to turn off.** The tilemap is redone one column per
  frame, so the substitution isn't seen instantly as in RM2k: standing still it
  can take up to `WINDOW_COLS` = 64 frames. Walking, it's less noticeable.
  Uploading two columns per frame doesn't fit: `push_strips` uploads only one.
* **When the "they caught me" triggers**: before it was touch —it fires on the
  step—, now it's a parallel that looks at the cell. One frame of difference.

## The split

**The engine's, and general**: `TileSubstitution`, `StoreTerrainID`, the
terrain table, and the fork mechanism with its tests. **Done**; what didn't
turn out as assumed is above, in "Status", and it's that the substitution takes
a while to show.

And two things the engine requires that this document didn't foresee —both
are what's holding back map 11 today, see "Status"—: **the tile being
substituted to has to be drawn on some cell of the map**, on its layer, because
the 8x8s that go into VRAM are those of the map's cells; and **if it's an upper
tile, with the `Above` bit set**, because without it it gets baked into the
background and the block's two layers stop being independent.

**ABL's**: its own ChipSet, the duplicated tiles, the terrains per cone and the
redesigned map. **Done.**

# How to reproduce it

The throwaway scripts were left in `/extras/scratch/mapa11/`: `grupos.py`
classifies the 84, `porque_no.py` says why the rule rejects each still tile,
`perdidos_zona.py` measures the dropped frames per cell and `capturar.py` takes
the screenshots. The screenshots and their `LEEME.txt` are in
`/extras/capturas/mapa11/`.

`perdidos_zona.py` has the worktree's root written inside it: it has to be
changed before running it, and the cartridges have to be built first. It's the
one that gives the table above, and it takes five seconds.
