---
name: "A victory song other than a changed battle song is uploaded when the battle is won"
description: "When ChangeSystemBGM gives the battle a song and the victory keeps another, winning uploads the victory's song with the picture still"
type: bug
status: draft
---

Seen by Carpintero on 2026-10-19, reading the runtime of the-advocate
`carpintero-music` (from `9592b88b`); **not measured on a ROM**.

A song a `ChangeSystemBGM` gives the battle goes up first in the battle's
package, with its sound effects and **without the database's songs**
—`battle_extra_l` in `runtime/audio_package.s`—. If the victory's song is
another —the database's, or a different `ChangeSystemBGM`'s—, it is not in
the ARAM when the battle is won, and `song_ensure` rebuilds the battle's
package with it first: the picture stays still while it uploads. ABL and
The Book of Three always give both slots the same song, so it does not
happen there; Dooms 2 gives the battle "BIG FIGHT" and "Everlasting battle
with Jack" and the victory "ESCAPE" or nothing, and Vampires Dawn's
database victory song is not its battle song (but it plays with MSU-1,
where songs with a track upload nothing).

**How to see it**: a Dooms 2 battle after a `ChangeSystemBGM` of slot 0
alone, without MSU-1: the frames between the last hit and the victory
message.

## Checked (2026-10-20, Tijereta)

Still so at the-advocate `8f290c39` by reading: `battle_extra_l`
(`runtime/audio_package.s`) puts one extra song in the battle's package,
the battle's, and nothing puts the victory's next to it. Still not
measured on a ROM, so whether the still picture is long enough to see is
not known; that is the first thing before deciding anything.
