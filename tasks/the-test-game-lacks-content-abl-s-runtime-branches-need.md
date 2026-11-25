---
name: "The test game lacks the content some of the runtime's branches need"
description: "`just lint` runs Goombario over the test game's cartridges only, and the runtime assembles about 2,000 lines on what a game has —a parallel common event, a box without its window over the layer above, still events drawn into the background, a game-over picture, a ChangeSystem, a custom menu…— that ABL's cartridges assemble and the test game's do not; with ABL's `test_linter.py` gone, nothing lints them"
type: test
game: test-game
status: todo
author: chaja
links:
  found-in: [tests-without-the-stages-subcommands]
  relates: [abl-s-test-cartridges-become-test-game-cases]
  part-of: [abl-s-test-cartridges-become-test-game-cases]
---

Found by Chajá on 2026-11-25, on the-advocate `e267b6b3` and the ports
`7403613`, while making Goombario a lint over the test game
([`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md),
its log of that day).

**What was seen**: the test game's `lint` cartridge carries every build
flag the runtime assembles code on, and with `release` and `test-vblank`
`just lint` sees both sides of each flag. But most of the runtime's `.if`s
are not on a flag: the converter defines their symbol from what the
cartridge's game has. Read from the `.dbg` of each cartridge —each symbol's
value, or whether it is defined—, these are the branches A Blurred Line's
eleven cartridges assemble and none of the test game's does; the lines are
the instructions and labels inside each, counted by a throwaway script:

| Symbol, side | Where, lines | What the game would need |
|---|---|---|
| `layer_text_on` | `message_layer.s` (1127) and 20 more short ones | a `MessageOptions` without the window's background, on a map with a layer above |
| `posed_stills` | `posed.s` (472) and 6 more | a still event drawn with a ChipSet tile whose pages change its pose, on a map of `[graphics] baked_events` —the anvil's crate stopped being one on 2026-11-22, when an event a battle animation falls on became an object— |
| `WINDOW_SYSTEMS > 1` | `window_system.s` (~80), `vblank.s`, `messages.s`, `message_arrow.s`, `interpreter_message.s`, `load_graphics.s`, `boot.s` (~25) | a `ChangeSystemGraphics` to a second System |
| `GAME_OVER_TILES > 0` | `game_over.s` (80) | a game-over picture in the database |
| `COMPAR_N > 0` | `common_events.s` (38) | a parallel common event |
| `PICTURE_SETS > 0` | `picture_common.s` (29) | pictures the converter groups into a common set |
| `CM_MENUS > 0`, `CM_INKS_N > 0` | `custom_menu.s` (24) | a `[menus]` custom menu, the engine's own |
| `TEXT_INK_ENTRY = 0` | `message_layer.s` (85), `message_pace.s` (3) | a cartridge whose boxes type no colour: the test game's do, so this side needs a cartridge whose maps and common events type none |
| `WINDOW_BACKDROP_LINES = 1` | `messages.s` (8) | a window over one colour, `[windows.background]`; the test game's System is a gradient, so the other side needs another cartridge's System |
| `SLOT_MENU_TILES <> SLOT_TILES` | `menu.s`, `text_layer.s` (11) | a menu bank so full the slot screen's text goes last: only ABL's `release`, by space |

Three are one side of a pair that cannot be in one ROM —`TEXT_INK_ENTRY`,
`WINDOW_BACKDROP_LINES`, and `WINDOW_SYSTEMS` (`message_arrow.s:199`
assembles code on both sides)—, so the test game would need a cartridge
for each other side, with other maps; the rest only need the content
somewhere in the game.

And four that **no cartridge linted before either**, ABL's or the test
game's, because only other ports have them: `paint_table` (`painted.s`,
1021 lines; Desert Nightmare and Sunset over Imdahl), `sand_table`
(`sandstorm.s`, 699; Zounds), `SHOW_WINDOW_SLOTS` (`show_window.s`, 1825;
Desert Nightmare) and `WIDE_VARIABLES > 0` (`number_input.s`, 75; Desert
Nightmare).

**How to see it**: build the test game (`SOUNDFONT=… just -f
test-game/justfile cartridges`) and ABL's cartridges, and compare the
values of those symbols in each `.sfc.dbg` (`name="layer_text_on"`…).

**What is not in doubt**: each needs content written in the test game,
and much of it is what
[`abl-s-test-cartridges-become-test-game-cases`](abl-s-test-cartridges-become-test-game-cases.md)
moves anyway —`ChangeSystemGraphics`, the faces—. What is to decide is
whether ABL's `tests/tooling/test_linter.py` stays until it is done:
it was removed in the same change, as taro asked, and with it the lint
of these lines.

## Log

### 2026-11-25, Hornero: promoted to `todo`; ABL's linter test waits for it

Promoted by Hornero: measured from every cartridge's `.dbg`, and it is
the content [`abl-s-test-cartridges-become-test-game-cases`](abl-s-test-cartridges-become-test-game-cases.md)
asks the test game to have anyway. Until it is done, ABL's
`tests/tooling/test_linter.py` stays: Chajá's commit removing it (ports
`417e102`, branch `chaja-lint`) is held, so those ~2,000 lines keep being
linted. It is removed in the same change that makes the test game
assemble them.
