---
name: "Plan: the whole game without MSU-1, the count"
description: "What Lechuza's count left out (the battle animations, their sound effects) and what shrinks it (animations only in the .msu, map backgrounds quantised per ChipSet, LZ2 where it goes raw, smaller music): does it fit in 4 MB, or in 8?"
type: research
status: done
assignee: taro
---

From taro, on 2026-10-01, after reading
[`docs/research/2026-10-01-los-mapas-por-el-msu-1.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-01-los-mapas-por-el-msu-1.html). The new decision:
`decisiones/el-juego-se-juega-sin-msu-1.md`. What he wants to know is whether,
moving to 8 MB if needed, compressing what can be compressed and lowering the
quality of something in the ROM without MSU-1, the whole game fits.

# What came out (Tucu-tucu)

The study is [`docs/research/2026-10-01-el-juego-entero-sin-msu-1.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-01-el-juego-entero-sin-msu-1.html).
The short version:

* **In 4 MB it doesn't fit with any cut**; in **8 MB (ExHiROM) it fits without
  lowering the quality of anything**, with ~850 KB of margin, using only LZ2 where
  it goes raw, DTE in the messages and jumps in the sequences.
* **Lechuza's count counted the samples too many times**: compiling the audio
  of the whole game at once, it's 1,052 KB and not 2,120. The whole game
  as it is today is ~7,450 KB.
* **What was missing**: ~630 KB (`ShowPicture` images ~430 estimated,
  the five maps ~105, the sound effects of the battle animations 92). The
  84 animations only the battle uses are 462 KB and go to the `.msu`. The
  panoramas stay out.
* **Backgrounds per ChipSet**: −840 KB, 94 maps lose colours and it's barely
  noticeable. Kept in reserve for when 8 MB gets tight.
* It recommends **revisiting `decisiones/el-cartucho-se-queda-en-4-mb.md`**.

For taro:

* The captures of the backgrounds are in
  `/shared/capturas/2026-10-01-fondos-por-chipset/`: today's on the left,
  per ChipSet on the right, the ten maps that lose the most colours.
* Decide whether to move to 8 MB, and whether the battle without MSU-1 carries the sounds of
  its animations (92 KB).

It doesn't touch the game: `just pruebas`, 923 green. **On merging there's nothing
to install.** The throwaway scripts were left in the scratchpad, in
`tucu-tucu/`, and reuse the runs from `lechuza/`.
