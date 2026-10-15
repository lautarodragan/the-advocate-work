---
name: "Every degradation, said by the build"
description: "The converter writes, per cartridge, every place where it compiles a command undone or loses part of it —map, event, page, command, what is lost—, machine-readable, for any game"
type: feature
status: testing
assignee: taro
agents: [Hurón]
---

taro, on 2026-10-15: The Book of Three is a game taro has never played
and does not want spoiled, so they cannot tell when something is missing
—an animation not drawn, a fade ignored—. The plan: the build says every
place where it degrades, and an agent checks each one against the original
([`book-of-three-against-the-original`](book-of-three-against-the-original.md)).

Today some of those degradations are converter warnings, some are only in
the book's divergences and "what the compiler ignores silently", and some
are said nowhere. What it asks for: one list, written by the build in
`build/<cart>/`, complete by construction —at the place in the compiler
where each thing is lost, not a list kept by hand—.

## Hurón, 2026-10-15

Starting from the-advocate `fa9d1a14` and the ports `0ca371b`, branches
`huron-degradations` in both.

The plan: the event compiler carries a collector of losses in its `Ctx`,
with a stack of where it is —the map's page, or the common event or troop
page, and the bodies a `CallEvent` pastes inside—; each arm that compiles
a command with less than RM2k records there, with a `kind` slug. A page
that does not compile takes its losses back with it, as it takes its
texts back, so only what reaches the cartridge is listed. The answer
carries them, and the converter adds its own and those of its stages
(Wally's notes, the ChipSet animation that does not fit) and writes
`build/<cart>/degradations.json`, sorted.

### Done

the-advocate `huron-degradations`: `3a954b30` (the compiler) and
`5d5df69d` (the stages and the converter). The book's
`huron-degradations`: `c470d3d`, the file in `internals/pipeline.md`.
Nothing in the ports: the list is the tools' and lands in each game's
`build/<cart>/degradations.json`.

To install when merging: `events`, `wally`, `screens`, `mapdata` and
`convert`.

Where each kind is noted: the arms of `compile.rs` (and `pages.rs` for a
page's fields and own route, `troops.rs` for the troops' indices), Wally's
notes with a `loss`, `fit_all_by_map` in mapdata's emission, `lose` in the
screens' `convert.rs`, and the converter's own WARNINGs and its trim.
Pictures the project draws into their map are taken out by the converter,
by the `subject` the compiler gives them. The counts are what the build
prints and `counts` in the file says; they are not written here.

Run: `just test` and `just rust-test` in the-advocate; ABL's `just tests`
with these tools, green, and `abl.sfc` byte for byte the one built with
`fa9d1a14`'s tools; `just boot` at the ports' root, green.

**Not hooked, and why**:

* A blocked step of a route that is not skippable: whether it is blocked
  is the ROM's to know, when it runs.
* What `rm2k-snes-audio` leaves out —samples past the directory, effects
  that do not fit a package—: it is a stage of the cartridge's build that
  runs after the converter writes the file.
* The colours merged (Adeleine, the patches) and a sprite's colours
  dropped to make room for the timer; the shrunk battle animations: the
  patches are where those are written.
* The battle model's divergences —the enemies' AI, conditions, rank
  shifts— and the runtime's —collision, turning toward the hero, what the
  save keeps, the database's transitions—: they belong to no command or
  map, so they stay in the book's divergences.
* A `MovePicture` of a picture drawn into its map is still listed as not
  done: it is not, but the drawing is what was planned.
* A troop page the game copies into every troop is one entry per troop:
  that is where it is.
