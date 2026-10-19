---
name: "A battle song with many instruments squeezes the samples it shares"
description: "Since ChangeSystemBGM is done, each song it names has to fit in the battle's package next to the battle's sound effects; in ABL one of them pulls thirteen shared samples down to ~9.5 kHz for the whole cartridge"
type: bug
status: draft
---

Seen by Carpintero on 2026-10-19, with the-advocate `carpintero-music`
(from `9592b88b`) and the ports `carpintero-music` (from `c420032`), in A
Blurred Line's `release` without MSU-1.

**What changes**: `ChangeSystemBGM` of the battle is done since that
branch, and the songs it names are separate songs of the battle's audio
package: each one has to fit in the ARAM with the battle's sound effects.
The battle's package leaves 32,432 B for music in ABL, and
`T_AVGFighter_KyaraSelect` —one `ChangeSystemBGM` on map 311— has 28
samples. Since the sample bank is one for the whole cartridge, each sample
at the budget of its worst package, thirteen samples it shares with other
songs go down from 12–22 kHz to ~9.5 kHz **in every song that uses them**,
mostly drums (`g:56`, `g:40`, `g:41`, `g:53`, `g:33`, `g:36`, `g:46`) and
five melodic ones. The Book of Three's bank does not move.

**How to see it**: `audio.json` of ABL's `release`, `bank.limited_by`: the
keys limited by `pelea>T_AVGFighter_KyaraSelect`. Comparing each key's
rate against a build from `main` before the branch gives the list; the
script that did it compared `bank.keys` against `bank.voices[].rate`.

With MSU-1 —how ABL is played— none of it is heard: the songs with a track
do not upload samples.
