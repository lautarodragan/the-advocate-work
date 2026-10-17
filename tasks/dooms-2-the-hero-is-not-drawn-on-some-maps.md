---
name: "Dooms 2: the hero is not drawn on some maps"
description: "On some maps the hero's graphic is not drawn, as the adult and as the child; the hero walks and interacts, so only the sprite is missing"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

taro, 2026-10-16, playing the delivery of that evening (the ports
`4b2d41e`, the-advocate `759aa0ba`), after Dooms 2 started on map 1
([`dooms-2-slots-and-menu-dont-fit-in-their-bank`](dooms-2-slots-and-menu-dont-fit-in-their-bank.md)):
"mejoró, pero ahora no se renderiza el gráfico del héroe en algunos mapas".
It happens with the adult hero and with the child. The hero can walk and
interact, so the game is alive and only the sprite is missing. taro did not
play it through, and did not say which maps.

## Measured (Calandria, 2026-10-16)

From the-advocate `759aa0ba` and the ports `4b2d41e`, playing in snes9x
with a throwaway script: teleport to each of the 93 maps with a given
actor leading, and compare the hero's 16x32 box with and without
`hero_hidden`.

* **With Will (5) leading, the hero is drawn on all 93 maps.** With Bob
  (2) it is drawn on none: `hero_poses` stays at zero and `place_hero`
  draws nothing. The map's actor table only has actors 5 and 7
  (`actor_table_0` and `_1` in `mapdata.inc`).
* So it is not the maps: it is **who leads**. Will narrates on map 1 and
  every choice takes him out; the story's hero joins on its own first map,
  or the choice puts them in (Jonathan, 7, the only one in the table).
  Every story but Jonathan's has its hero out of the table. Why taro saw
  it "on some maps" and not on all is not measured; the likely reason is
  `ChangeSpriteAssociation`: Bob, Bryan and others get another graphic
  on some maps (`dying`, `Crown7`…), and the runtime draws an association
  through the map's graphics table, not the actor table. The adult and the
  child are different actors of the database (Jack 1 and 6, Will 5 and 9,
  June 10 and 11), so both went undrawn.
* **Cause**: `possible_leaders` in the converter's `scan.rs` plays each
  map's `ChangePartyMembers` batches in file order on one party. Map 1's
  pages are alternatives: after the first page empties the party and
  Jonathan's page puts him in, every other candidate goes in *behind*
  Jonathan, and the ones whose page only removes Will join an empty party
  on another map, where the simulation (reset to `[5]` per map since
  `f804266b`, the Kersh fix) puts them behind Will. `git blame`: the
  per-map reset is f804266b's, which said itself it was "not more correct
  in general"; it held while Dooms 2 started on map 2 with Will always
  leading, and broke when map 1 came in.

## Done (Calandria, 2026-10-16)

Branches `calandria-dooms2-hero` in the-advocate (from `759aa0ba`), the
ports (from `4b2d41e`) and the book (from `34791a5`), each with `main`
merged at the end.

* **The converter** (`possible_leaders`, `rm2k-snes/convert/src/scan.rs`):
  `party_changes` keeps the pages now, and each map is played three ways:
  in file order on one party, as before; each page on its own from the
  cartridge's party; and each page on its own from an empty party, if some
  page ends with nobody in it. Dooms 2 goes from `[5, 7]` to all eleven
  actors. The test pages' parties keep the file-order play alone
  (`leaders_in_file_order`). Unit test
  `each_choice_of_a_map_and_a_party_emptied_elsewhere_bring_their_leader`,
  red first.
* **A first version went too far**, and it is in the history on purpose:
  batch by batch, with the empty start enabled by any batch that left
  nobody —ABL's car chase removes everyone and adds a car back in the same
  page— and also for the test parties. ABL got three more leaders (Gang
  Member, 16, among them), each with a palette of its own where they stand
  as events, and the golden `paradise-127-celebration` lost the colours of
  three villagers. With the final version ABL's `abl.sfc` is byte for byte
  the one of `759aa0ba`.
* **Wally** (`rm2k-snes/wally/src/sprites/split.rs`): with eleven leaders,
  map 1 —where the candidates stand as events— stopped the build ("is not
  in the palette split"): each leader that is also an event took a palette
  of its own and the other events had none. Now one that would need a new
  palette when only one is left shares a map palette like any event
  (`shared_leaders`), and its row of the actor table carries that palette's
  colours, so the upload when it leads repaints nothing. In Dooms 2, one:
  Graig (`Graignew:0`) on map 1; a plain note in the converter's log. The
  test `split_answers_with_the_palettes_it_is_given` changed with the rule.
* **Measured**: each of the eleven actors leading on each of the 93 maps,
  in snes9x, comparing the hero's box with and without `hero_hidden`
  (throwaway script): drawn everywhere, except actor 8 ("Player"), who has
  no graphic —RM2k draws nothing either—, and two captures taken with a
  message open, where the box does not refresh (maps 73 and 92; their
  captures show the hero).
* **The test**: `tests/test_dooms2.py`, at the ports' root, also checks
  Bob is drawn on map 3 after choosing him. Red with the global tools,
  green with the branch.
* **The book**: "The possible leaders are an approximation" says the three
  plays and what counting too many cost; the sprites page, that a leader
  shown as an event gets its own palette only while one is left.
* **Found and not fixed**: the draft
  [`dooms-2-three-autostart-pages-lost-to-sprite-associations`](dooms-2-three-autostart-pages-lost-to-sprite-associations.md).

**To install when merging**: `just install wally convert`.

**What the suite does not cover**: the hero of each story drawn on its own
maps by playing —only Bob on map 3 is in a test; the rest is the throwaway
measurement—, and the look an actor's `ChangeSpriteAssociation` gives it,
which goes through the map's graphics table and not the actor table.
