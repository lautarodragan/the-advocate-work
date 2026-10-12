---
name: "Cheaper windows"
description: "Build what 'The windows, made cheaper' measured: a background of the project's own by setting, its gradient through HDMA, the cursor in sprites, windows drawn by the runtime and the faces out of BG1, in seven small steps"
type: feature
status: todo
---

taro, on 2026-10-12: the implementation of the research, which had no task
of its own. The research is `research/2026-10-11-las-ventanas.md` in the
book ("The windows, made cheaper", Tijereta, from
`most-efficient-windows.md`); what each step saves, and for which game,
is there.

## The steps

Its order, each one verifiable with A Blurred Line's suite and `just
arrancan` in the ports:

1. **The setting, and a flat colour in the converter only**: `[windows]
   background` in `rm2k-snes-project`, a colour or a list of stops of a
   vertical gradient; `rm2k-snes-screens` draws the windows over one CGRAM
   entry. No runtime change. ABL without the setting, and the games
   already flat, byte for byte the same; ABL with `"#000000"`, its window
   goldens moving only by the near-black strokes, in their own commit.
2. **The message window's text area from one cell**: `prime_line` fills
   the line instead of copying `window_backdrop` when the background is
   flat. No golden moves.
3. **The gradient on the message window**: one entry of palette 0 and an
   HDMA channel, its table built for the window's position. A test
   cartridge of ABL with a gradient and its golden; The Frozen World and
   The Book of Three through `arrancan`, with captures for taro.
4. **The gradient on the screens**: items and equipment, then actor choice
   and shop, then battle; one screen per step, each with its capture.
5. **The cursor in sprites**, on the screens with their sprites off; then
   the pause menu; Dooms 2's actor choice is the check. The message
   window's cursor last, with the mask's window 2.
6. **Windows drawn by the runtime** from the frame's nine cells and the
   background's one, first on a screen that doesn't exist yet: the hero
   name screen, `hero-name-screen.md`.
7. **Faces**: in the message window, in the text area's cells with their
   palette by HDMA (Desert Nightmare, Dooms 2, Vampires Dawn); in the
   menu, in sprite palettes when a game runs out of BG2 palettes.

Steps 1 and 2 are worth doing even if nothing else is. Each step can be
its own task when it is taken; the value of the setting for each game is
in the research's "The setting for each game".

## Not measured, to keep in mind

Real hardware (CGRAM writes in the hblank are where emulators are least
trusted), how long `irq_music` takes, the battle windows' gradient groups,
and what a smooth gradient looks like next to RM2k's bands: see the
research's "What was not measured".
