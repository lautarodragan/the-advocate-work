---
name: "The Book of Three against the original"
description: "An agent plays The Book of Three to its end in the original, under Wine, and in the port, compares them at each milestone and at each place the build says it degrades, and grows the walkthrough with them"
type: feature
status: testing
assignee: taro
agents: [Mulita]
---

taro, on 2026-10-15: they have never played The Book of Three and do not
want it spoiled, so they cannot tell what the port loses. An agent who
knows the original compares, and taro plays when the list is short.

**No spoilers for taro**: what is found goes to drafts and to "Known
issues"; reports to taro give counts, not story.

**Music**: taro focuses on the MSU-1 PCM, which should sound the same or
almost the same as the original; the SPC version is debugged by taro as
they play. So for music what is checked is that the same track plays at
the same place, with the same volume, tempo and fade.

## Mulita's notes (2026-10-15)

Started from the-advocate `fa9d1a14` and the ports `0ca371b`, in a worktree
of the ports on `mulita-bot-original`; the tools are the global ones (no
tool changed so far).

**How the two are put at the same place.** A milestone is a case: the
switches a player has by then —replaying in story order the switch and
party commands of the maps before it, without the random chests—, the
party, a level for the fights, and a teleport. The same JSON is a test page
of the port (`book-of-three/cases/milestone-*.json`) and, written over map 1
with `ditto write`, the start of a copy of the original run under Wine
(RPG_RT 2015, Xvfb; the copy in the scratch, `~/juegos` untouched). Scenes
are then played the same way on both sides: A every few ticks in the port,
Return every second in the original, with captures at intervals.

**Played, not jumped**: from the Book of Three to the heart of Yern's woods
(Coll's lotion, Hen Wen's escape, the lane, Caer Minule and its item shop,
the woods). The walkthrough stops there because of the first finding below.

**Findings** (each one a draft and a Known issues line in the book's page):

* `book-of-three-a-troop-of-nine` — the horsemen's battle (map 16) never
  ends: troop 83 has nine members, the cartridge carries eight. **Blocks
  the story.** Not in `degradations.json`.
* `characters-a-route-gives-a-graphic-are-not-drawn` — characters a scene
  places and dresses with a route, on an event with no graphic, never
  appear. Seen on maps 21, 22, 26, 32, 46, 63, 83; 43 routes on 14 maps in
  the data; ABL and four other games have the pattern too. Not in
  `degradations.json`.
* `book-of-three-story-battles-play-the-default-theme` — `ChangeSystemBGM`
  (declared debt), 40 commands.
* `tint-screen-snaps-instead-of-fading` — 128 `TintScreen` gradients.
* `book-of-three-inns-in-scenes-are-not-staged` — 12 `ShowInn`.
* `book-of-three-the-last-pictures-are-not-drawn` — maps 69 and 72.
* `book-of-three-the-map-item-shows-nothing` — common event 23.
* `book-of-three-the-intros-torches-stand-still` — map 3.
* `a-maps-own-music-ignores-its-volume-and-tempo` — 6 maps here, every
  game but one has some.
* Already drafted: the `PlayBGM` fade-in on map 21.

Not findings: a first false alarm on map 32 (the cell's scene did not start)
was the case's switches —a map the story visits twice—, fixed in the case;
the battle's missing party command window is a documented divergence.

**Music.** The port has no MSU-1 tracks for this game (`--without-tracks`),
so what was checked is the SPC's song: at the end of every milestone the
song in RAM (`song_current` by the converter's `music.json`) is the one the
original's event data plays there, and the test asserts it. Volume and tempo,
from `BGM_NOW`: a `PlayBGM`'s are honored, a map's own are not (draft
`a-maps-own-music-ignores-its-volume-and-tempo`, 6 maps here). The
original could not be heard —no audio under Xvfb—, only read.

**Done, and its limits** (2026-10-15):

* **Played to the end in both.** The original under Wine from 21 starting
  points (the intro, the walkthrough's stretch and the 20 milestone
  cases), every scene played through with Return; the port the same,
  from the same cases. The last milestone goes from the race to Caer
  Dathyl to the title screen in both.
* **Played and not jumped**: from the boot to Yern's woods (the
  walkthrough). **Jumped with cases**: everything after the horsemen —the
  port cannot pass them—, and inside it the walks between milestones: the
  overworld, the dungeons (South Mountains caves, Spiral Castle's tunnels,
  the lava tunnels, the hills), Spiral Castle's halls as Eilonwy, the Tylwyth
  Teg's maze. Optional places (Yern's tomb, Morda's cottage, the caves of
  maps 87 and 88) were not visited. Random battles only in Yern's woods.
* **Compared by eye**, not pixel by pixel: the original is 320x240 and
  the port 256x224, and the scenes' timing is not the same frame by frame;
  the films are contact sheets every few seconds, so a short difference
  mid-scene can be missed.
* **Music**: the port's song read from RAM against the original's event
  data; nothing was heard.
* **Not seen in the port at all**: the horsemen's fight (it never ends),
  the map item (only by the build's report).

**What is installed when merging**: nothing; no tool changed. The ports
branch is `mulita-bot-original` (cases, tests, 30 goldens); the book's,
`mulita-bot-original` (Known issues and "Its walkthrough"). `just boot`:
43 passed. Captures for Hornero (with spoilers):
`/shared/captures/2026-10-15-book-of-three-milestones/`.

**Drafts opened**: `book-of-three-a-troop-of-nine`,
`characters-a-route-gives-a-graphic-are-not-drawn`,
`book-of-three-story-battles-play-the-default-theme`,
`tint-screen-snaps-instead-of-fading`,
`book-of-three-inns-in-scenes-are-not-staged`,
`book-of-three-the-last-pictures-are-not-drawn`,
`book-of-three-the-map-item-shows-nothing`,
`book-of-three-the-intros-torches-stand-still`,
`a-maps-own-music-ignores-its-volume-and-tempo`. Two of them —the troop of
nine and the characters a route dresses— are not in `degradations.json`:
silent holes for its next round.
