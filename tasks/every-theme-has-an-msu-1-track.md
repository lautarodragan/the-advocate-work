---
name: "Every theme has an MSU-1 track"
description: "Today only some themes have a track (PISTAS_MSU); taro wants all of them, always"
type: feature
status: done
---

taro, on 2026-09-26: **every theme should always have its MSU-1 version**.
Today those in `PISTAS_MSU` (`tools/audio/snes_music.py`) have it, and the
audio reports of these days talked about "the themes that have a track" as if
it were normal for some not to.

What it implies:

* Rendering the track of each theme that does not have one
  (`tools/audio/msu.py`, with fluidsynth and the SoundFont, or the audio
  replacement if there is one), and the list no longer being written by hand:
  **every theme that goes into the cartridge has a track**, and a test (or an
  assertion in the converter) that fails if any does not have one.
* Each theme's track number is decided today by `PISTAS_MSU`; with all of
  them, the numbering can come from the theme's index.
* Consequences in the ROM: with MSU-1 **no** music sample is uploaded
  (`done/` or `with-msu-1-the-theme-samples-arent-uploaded.md`), so the whole
  ARAM is left for the sound effects; it is better done **after** the task of
  the sound effects with MSU-1, or coordinated with it.
* The tracks go to `/shared/msu/` with `just entregar --actualizar-msu` (the
  fingerprint changes).
* Touching `msu.py` redoes all the tracks: it is done once.

# Status

**Done on 2026-09-26, taro still has to listen to it.** Every theme in the
cartridge has a track: in `release` there are 32, the 22 from before and ten
new ones.

**The numbering comes from the game's `Music/`**, not from the cartridge: a
theme's number is its place in the sorted list —case-insensitive, from 1— of
the `.mid` and `.wav` files in `Music/` (`pista_msu` in `snes_music.py`). The
theme's index in the cartridge is decided by the order in which the `PlayBGM`s
appear when compiling, so a new map would have shifted the numbers of the ones
that come after, and each shift is hundreds of megabytes to redo and to copy
to the card again. `Music/` belongs to the original game and does not change:
a new theme is a new file, and the others stay where they were. The numbers
come out with gaps (2, 4, 15 … 224), and the MSU-1 does not care.

What it cost: **renumbering the 22 from before once**. The tracks in
`/shared/msu/` have to be replaced entirely with `just entregar
--actualizar-msu` —the fingerprint changes—: with this ROM, the `abl-1` to
`abl-22` from before play the wrong themes.

How it is built now:

* The converter gives each theme its `pista` (`build_varios`), writes it into
  the ROM's `tema_msu` and into the `musica.json` next to it.
* `msu.py` builds **those in `musica.json`** and deletes the `<rom>-N.pcm`
  that no longer belong to any theme, because `just entregar` copies every
  one it finds. A theme that is a WAV in the game has a track too, via ffmpeg
  (today there is none in the cartridge).
* `cartuchos.py` builds the tracks **after** the `release` conversion, and
  not alongside it: it needs them from `musica.json`.

**The test** is `test_todo_tema_tiene_su_pista` (`pruebas/abl/test_msu.py`):
every theme with music in `Music/` has a number in `musica.json`, the same one
in the ROM's `tema_msu`, and its `.pcm` next to it; and no `.pcm` is left
over. It was seen failing by removing `abl-148.pcm` by hand, adding an extra
`abl-5.pcm` and setting `prepara`'s track to `null` in `musica.json`.

**The new ones** —`11h035`, `bubstix`, `Deflector1`, `Fire_Mustang…`,
`MML2_MotherZone`, `pn28year`, `prepara`, `T_ProjectJustice_DiscLoad`,
`Tnt07`, `wb3town`— weigh 177 MB together. The volume, by peak like the
others (see `msu.py`); the median level, measured as the RMS of 1 s windows at
the 90th percentile, gives the same in the new ones as in the ones from
before, and all of them fall within the range of the 22. The 22 re-rendered
ones come out byte for byte identical to the ones from before, with another
name.

**What changed in the quality of the sound effects with MSU-1**, against
`main` (`ee55226`), in the converter's output:

    paquete 121: 5000 Hz: 1                       -> 22050 Hz: 1
    paquete 261: 22050 Hz: 3, 6000 Hz: 3, 5500: 1 -> 22050 Hz: 3, 18000 Hz: 4
    paquete  52: 22050 Hz: 1, 20000 Hz: 2         -> 22050 Hz: 3

Without MSU-1 nothing changes: against `main`'s, the ROM differs in 134
bytes, and all of them fall in `tema_msu`, in the tables of the `.msu`'s
sound effects (`se_msu_filas`, `se_msu_altura`) and in its signature
(`msu_datos_firma`).
