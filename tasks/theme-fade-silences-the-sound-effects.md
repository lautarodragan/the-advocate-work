---
name: "The theme's fade silences the sound effects"
description: "Without MSU-1, a FadeOutBGM leaves the DSP's master volume at zero and the sound effects stay mute until the next theme"
type: bug
status: done
---

Noted down as a divergence on 2026-09-26
(`workflow/divergencias/el-fundido-del-tema-calla-los-efectos.md`) by the
sound effects agent, without fixing it. Without MSU-1, `FadeOutBGM` lowers the
DSP's master volume (`MASTER`) instead of that of the music voices, so the
sound effects (which play on the same DSP voices with their own volume) stay
mute until another theme starts. Recording gave zero samples. It happens with the
thunder at the end of map 3 and with `Wind1`/`clap` on 18.

The likely fix: fade the volume of the music voices, not the
master one. Measure it with the music log or by recording, and enforce it with a
test.

## Done, on 2026-09-26

Without MSU-1, `bgm_fundido_tick` (`rom/src/musica.s`) no longer touches the master
volume: it lowers VOL_L and VOL_R of each music voice that played in the theme, and
`mus_escribir` scales the ones the stream writes in the middle of the fade. The
factor goes from 256 —the untouched volume— to 0, and each frame rewrites only
the volume that changed from the previous one. The arithmetic is done by the
PPU's multiplier (the mode 7 one), which now belongs to `irq_musica`: the
CPU's cannot be used in the interrupt. Voices with a sound effect are not
touched: the value goes to their shadow through `dsp_musica`. The master volume stays fixed
at the startup one, so the per-theme ceiling (`techos.toml`) and the sound effects'
ceiling keep measuring the same thing.

Two more things from the same bug:

* **The title screen silenced its theme with the master volume at zero**
  until the first `PlayBGM`, and the opening's sound effects before that
  `PlayBGM` stayed mute. Now it releases the voices with KOF.
* **A theme that looped in the middle of the fade cancelled it** and came back
  at full volume: `music_start_ya` —which is also the loop— set
  `bgm_fundido` to zero. That moved to `music_start`, which is the `PlayBGM`.

With MSU-1 the fade was right, and it stays the same: it lowers `MSU_VOLUMEN` and on
reaching zero stops the track.

It is enforced by `pruebas/rpgmaker/test_fundido_del_tema.py`, with the new case
`efecto-tras-el-fundido`: `Switch1` before the first theme, during the fade
of `evilrhys` and after. Peaks measured with snes9x:

    before the theme   0  →  9267
    during (15%)    1782  →  9470
    after              0  →  9267

And `test_con_msu_el_fundido_para_la_pista_y_los_efectos_siguen`
(`pruebas/abl/test_msu.py`) looks at the same thing with MSU-1; that one also passed
before. The divergence `divergencias/el-fundido-del-tema-calla-los-efectos.md`
was deleted: it stopped being one.

What taro has to listen to, without MSU-1: the thunder at the end of map 3
—the "Core...?" sequence—, which comes after a fade; the sound effects
of map 18 (`Wind1`, `clap`); and that the theme fades still sound
smooth and not in steps.
