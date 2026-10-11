---
name: "Choose another System from the project"
description: "A knob in rm2k-snes.toml that says which System to use instead of the one the database names: one from the game, from the RTP or from the project"
type: feature
status: testing
agents: [Calandria]
assignee: taro
---

From taro, on 2026-10-05: the four games that don't build because of the window
build and run with ABL's System put in by hand in a copy. "let's launch it
now! … a cheap and atomic step forward, without introducing hacks or
complexity". It is path 2: choose another System, not a recipe over the
game's own.

## What was done

`[graphics] system`, **optional**: a name, which is looked up like the
database's —the game, its folder, the RTP—, or the path to an image
of its own, relative to `rm2k-snes.toml` and ending in `.png` or `.bmp`. It
is read by `system_choice` in the converter's `game.rs`, which makes it absolute
if it is a path; from there it goes down two paths, the only ones that looked
up the System:

* `rm2k-snes-screens --system`, in every call with a game
  (`window`, `convert`, `render`): `Game::use_system` changes the name
  that `Game::skin` looks up, or gives it the file. The window, the menu, the
  battle and the title come out of that `skin`.
* `system_path` in `maps.rs`, the timer digits that `wally`
  draws.

Test: `tools/rm2k-snes/screens/tests/system_choice.rs`, red with
`use_system` empty (two of three).

Checked with ROMs: ABL without the knob comes out the same, `abl.sfc`
`27e94e67039533a2…`, and the suite gives 1136. Frozen World, Book of Three and
Desert Nightmare, built with the original game and
`system = "ablskin.png"`, start: captures in
`/shared/capturas/2026-10-05-otros-juegos/system-elegido*.png`, ROMs in
`/shared/builds/otros-juegos/<juego>.sfc`, and the knob committed in
each repo. Dooms2 doesn't build for another reason: its CharSets are BMP.

What nothing in the suite covers: no ABL case sets the knob.

When merging: reinstall `convert` and `screens`.
