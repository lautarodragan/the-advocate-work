---
name: "ChangeSystemGraphics"
description: "Sunset Over Imdahl changes the System in its startup event (map 11), which therefore does not run: white map and the menu with the wrong colors. Medium: the window with the System changed on the fly; cheap: ignore it"
type: feature
status: todo
agents: [Aguará]
---

From Aguará's brief analysis (Sonnet), on 2026-10-05, of what taro saw playing the ROMs of the other games.

Today it is ignored: `ChangeSystemGraphics` is accepted doing nothing, as a debt (`ACCEPTED_UNDONE` in the events compiler), so that the page that uses it does not stay out; see `ignore-changesystemgraphics-for-now.md`. When this task is done, it has to be taken off that list.

It is not only Sunset: built on 2026-10-11 (the-advocate `fc6f7456`, ports `a85b7e3`), Vampires Dawn warns about it in maps 3 (the intro) and 27, and Sunset in 11 (to `SaveMeny`). Desert Nightmare does it in its common event 1, `Init`, from `Systemset_Intro` —the database's— to `Systemset_Spiel`, so today it plays entirely with the intro's; common events do not warn about it in the log. (Calandria, 2026-10-11.)

## The windows' background, by System (Cardón, 2026-10-12)

`[windows.background]` in `rm2k-snes.toml` is keyed by the System's name
(`windows-background-setting-and-flat-text-area.md`), so this command can
pick the entry of the System it switches to. What is done: the project
reads and checks every entry (`rm2k-snes-project`, `windows.rs`), and the
converter refuses a key that names no System of the game or the RTP. What
is left for this task:

* the converter asks `rm2k-snes-screens` for one set of windows today, the
  starting System's (`game_flags` in `convert/src/screens.rs` passes
  `--window-background` for `starting_system()`); with this command it has
  to ask once per System the game switches to, each with its own entry, and
  emit one window palette and set of tiles per System;
* the runtime has to swap them when the command runs.

The Systems the games switch to have no entry yet, because nothing draws
them: Desert Nightmare's `Systemset_Spiel` has one (black, like the
intro's); Sunset's `SaveMeny` and Vampires Dawn's `VDBlutsys2`,
`redblue-sys`, `Stone` and `Wood` do not. Their values are measured the
way "The setting for each game" in the research measured the others.
