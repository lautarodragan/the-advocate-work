---
name: "Rescue the findings"
description: "Read the tasks in testing/ and move to tasks/draft/ the findings that were left loose —unfixed errors, uncovered paths, 'the next thing, measured'—, and to each port's 'Known issues' what is seen while playing"
type: docs
status: done
agents: [Calandria]
assignee: taro
---

taro, on 2026-10-11, created the `draft` status (see this repo's README and
"Un hallazgo que no se arregla" in `AGENTS.md`). The findings from before
stayed in the agents' tasks; this one rescues them. The example of the
format is `events-above-the-hero-over-the-painted-roofs.md`,
and the one for "Known issues", Sunset's page in the book.

## How it was done (Calandria, 2026-10-11)

The 60 tasks in `testing/` were read. Each finding was checked against today
—the-advocate `fc6f7456` (the global tools), ports `a85b7e3`,
book `f6e8d57`— with `git log`, the later tasks and the code. For
those of the other games, the release of Frozen World, Desert
Nightmare, Dooms 2, Book of Three, El Dorado and Vampires Dawn was built in a
worktree of the ports of its own (without commits), and where a map was
excluded it was returned to see today's stop (Dooms 2 map 1, Frozen
maps 1 and 2, VD without the `system` knob). The one-off scripts, in
`~/scratch/calandria/tmp/`.

## New drafts (17)

* `parallel-common-events-dont-run` — from `dashboard-against-the-whole-of-rm2k`.
* `n-0-and-renamed-actors-in-messages` — from `n-n-in-messages`.
* `what-gets-merged-in-the-screens-doesnt-go-to-the-patches` — from `window-with-more-than-15-colors` and `window-in-the-tile-bank`.
* `dooms-2-slots-and-menu-dont-fit-in-their-bank` — from `exclusions-left-over-in-the-ports`, `window-in-the-tile-bank` and point 4 of `degrade-instead-of-failing`.
* `flashing-hero-shares-a-palette-with-an-npc` — from `exclusions-left-over-in-the-ports` (Frozen 1).
* `map-streams-that-dont-fit-in-wram` — from `exclusions-left-over-in-the-ports` (Frozen 2) and `vampires-dawn-builds-from-its-toml` (VD 1).
* `vampires-dawn-maps-that-dont-fit-in-vram` — from `vampires-dawn-builds-from-its-toml`, `one-quantization-per-character-for-the-poses` and `merge-similar-tiles-when-the-background-doesnt-fit`.
* `vampires-dawn-now-builds-with-its-own-system` — from `window-in-the-tile-bank`: **it already builds with `VDBlutsys`**, measured today.
* `invisible-walls-lost-when-trimming-events` — from `events-that-dont-fit-in-the-map-ram`.
* `pictures-that-go-over-the-map-outside-sunset` — from `eraseevent-for-real` (Desert's WC).
* `title-that-doesnt-fit-in-vram` — from `degrade-instead-of-failing` (Desert, Frozen, VD).
* `variables-past-256` — from `degrade-instead-of-failing` (VD).
* `roof-edges-that-dont-fit-in-the-127` — from `sunset-in-mode-1-with-colour-math` and `other-games-build-and-boot`.
* `camera-turning-back-over-a-half-uploaded-row-loses-a-frame` — from `sunset-in-mode-1-with-colour-math`.
* `three-texts-that-went-stale` — from `book-the-tools-and-abl-docs-and-the-ports-section` and `justfiles-smaller`.
* `battle-with-the-party-empty` and `eraseevent-no-test-looks-at-what-is-seen` — coverage, from `empty-party-at-the-start` and `eraseevent-for-real`.

And a line in two tasks in `todo/`: `erasescreen-and-showscreen` (it no longer
leaves pages out, it is debt; what is seen in Desert and El Dorado) and
`changesystemgraphics` (also VD and Desert, which plays entirely with the
intro's System). The example draft now names the edges one.

## Known issues

In the book, branch `calandria-known-issues`: the section at the very top of
the eight port pages (in ABL, the presentation text moved to "The
port"). Each line names its draft or its task in `todo/`.

## Discarded: already fixed or covered

* Sunset black at 30 s (`ignore-changesystemgraphics-for-now`) and the opaque
  orange window (`sunset-the-map-22-scene-in-black`): they were fixed by the
  pictures inside the map and mode 1; the capture `modo1-22-01600` in
  `/shared/capturas/2026-10-11-sunset-modo-1/` shows the scene with the
  window without background.
* Desert's intro that ended in black because of the excluded map 2
  (`eraseevent-for-real`): Desert no longer excludes anything.
* Sunset takes hours (`sunset-over-imdahl-takes-hours-to-build`, `other-games-the-re-sweep`):
  it builds in 33 s (`other-games-build-and-boot`).
* The stripes in VD's intro (`boot-frames-per-cartridge`):
  `vampires-dawn-intro-broken`.
* Dooms 2's maps 40 to 93 (`faces-and-wait-escapes-in-messages`):
  `surplus-samples-dont-play`.
* The own System of Book of Three, Frozen, Desert and Dooms 2:
  `window-in-the-tile-bank`.
* The game's resources outside the fingerprint (`dump-outside-the-cartridges-fingerprint`):
  `fingerprint-the-game-files-the-zip-and-force`.
* `ChangeFaceGraphic` outside `ACCEPTED_UNDONE` (`dashboard-against-the-whole-of-rm2k`):
  `changefacegraphic-in-the-declared-debts`.
* The red of `the_layers_are_the_ones_the_python_made` and the screens
  test that changed: `window-colors-in-wally-request`
  and `00710e92`.
* VD's walls of music, troops, poses, boot and the
  errors without a map: their tasks in `testing/`.
* The hero's diagonals and turns in routes (`four-shortcuts-for-the-other-games`):
  `route-the-missing-moves.md`.
* `EraseScreen`/`ShowScreen`, `ChangeSystemGraphics`, the faces, the
  colours and the waits: their tasks in `todo/` (with the line above).

## Not rescued, by judgement

* `SUB_MAX` could be exceeded again (`four-shortcuts-for-the-other-games`):
  it wasn't seen being exceeded.
* ABL's routes that get cut at speed 3
  (`lookout-route-leaves-the-hero-facing-locked`): they do what RM2k does, and
  the model was without the tints' waits.
* The copies in `build/cache/zip/` that aren't deleted
  (`fingerprint-the-game-files-the-zip-and-force`), the 168 pose banks that remain
  (`one-quantization-per-character-for-the-poses`: VD fits now) and the painted maps with
  mandatory MSU-1 (`sunset-in-mode-1-with-colour-math`): nothing is broken.
* Desert's "light-blue garbage" panorama from 2026-10-05
  (`other-games-the-survey`): the panoramas were redone afterwards and
  nobody saw it again; not checked.
* The "it wasn't played" and "the suite doesn't cover" that don't name a concrete case.

## Seen in passing, without a draft

Today's Desert release says that on 157 maps it doesn't draw the pictures
`TextboxInnen` and `TextboxRahmen` —its messages' own frame—; it doesn't
come from any task in `testing/`, and Desert's page already says that
"136 maps don't draw some of their pictures". It is left for whoever looks at
Desert.

## When merging

Nothing to install. Merge the book's `calandria-known-issues`.
