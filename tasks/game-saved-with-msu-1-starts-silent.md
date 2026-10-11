---
name: "The game saved with MSU-1 starts silent"
description: "Saving while an MSU-1 track plays saves music_apagada as 1, and on loading the game nothing plays"
type: bug
status: done
---

Seen reading the code on 2026-09-26, while fixing "the title track keeps
playing on starting"; it wasn't run. The saved game stores `music_apagada`
and `tema_actual` (`partida_tabla`, in `rom/src/banco1.s`), and with an
MSU-1 track playing `music_apagada` is 1 because the SPC700 is silent on
purpose. On loading, `music_boot_ya` (`rom/src/musica.s`) sees
`music_apagada` and takes the silent path: the game starts silent until the
next `PlayBGM` or a map's own theme. Before the fix of the title track, the
title track kept playing, which wasn't the right one either.

It is the same question that `mapa_tema_callar` and `op_battle` already
answer —"is it playing?" is `MSU_SUENA` or `music_apagada` at zero—, and it
can be answered on saving or on loading. Catch it with a test with
`msu=True` (`pruebas/abl/test_msu.py`), saving on a map with a track theme.

## Done, on 2026-09-27

**The intent**, by `git blame`: `music_apagada` and `tema_actual` went into
`partida_tabla` in `a51d2980` (2026-09-10), with the byte meaning "it was
saved without music". MSU-1 arrived the next day (`e6bb4bc`) and gave
`music_apagada` a second meaning —"the SPC700 is silent because the track is
playing"—, and the saved game kept storing it as is.

**The fix**, in `guardar_partida` (`rom/src/partida.s`): with `MSU_SUENA`
on, `music_apagada` is set to zero while the copy to SRAM lasts and
restored afterwards, with interrupts disabled —if `irq_musica` saw it at
zero it would run the SPC700 stream—. What is saved is once again "is it
playing?", without saying through what: on loading, `music_boot_ya` calls
`music_start`, which picks the track if there is MSU-1 and the SPC700 if not.

**The format doesn't change**: the same bytes in the same place, with the
meaning they already had without MSU-1. `PARTIDA_BYTES` and `PARTIDA_FIRMA`
come out the same, so nothing was bumped. A game saved with the track
playing **by an earlier build** still loads silent: it saved a 1, and on
loading there is no way to tell it apart from a real silence.

**The crossings**, measured with the test:

* with MSU-1 to with MSU-1: the track comes back. Before, silent.
* with MSU-1 to without MSU-1 (an `.srm` from the FX Pak in an emulator
  without tracks): the theme through the SPC700, with its samples in ARAM.
  Before, silent.
* without MSU-1 to with MSU-1: the track. It already worked —a 0 was
  saved—; now it is covered.

**The test**: `test_la_partida_guardada_vuelve_con_su_tema`, in
`pruebas/abl/test_msu.py`, with the three variants. It reaches map 26 —it
turns on `KSSMKEND`, which has a track—, saves through the menu, moves the
SRAM to another console if the combination asks for it, and loads with
"Resume the Story". Against the ROM without the fix, `msu-a-msu` and
`msu-a-spc700` give red (`music_apagada` at 1 and `MSU_SUENA` at 0 on
loading) and `spc700-a-msu` green.

## What taro has to look at

With the tracks alongside, in Mednafen (`-force_module snes_faust`) and on
the FX Pak: get to a place with a track theme, save, reset, "Resume the
Story", and hear the theme come back. And the crossing that matters in
practice: the `.srm` saved on the FX Pak, loaded in Mednafen **without** the
tracks, has to play through the SPC700. A game saved with an earlier build
while a track was playing will load silent all the same: it has to be saved
again.
