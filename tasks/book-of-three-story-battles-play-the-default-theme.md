---
name: "The Book of Three: the story's battles play the default battle theme"
description: "Each scripted fight sets its own battle and victory music with ChangeSystemBGM, which the port does not do: they all play the database's battle theme"
type: bug
status: doing
assignee: Carpintero
agents: [Carpintero]
---

Seen by Mulita on 2026-10-15, comparing the port with the original's event
data, with the-advocate `fa9d1a14` (and `362d3765` for
`degradations.json`) and the ports `0ca371b`, in The Book of Three.

**What is heard**: before almost every story fight the game changes the
system's battle music —and the battle-end music— with `ChangeSystemBGM`,
and sets it back after. In the port the battle always plays the
database's theme, "intothefireedit". Measured in the port's RAM on map 16:
the original asks for "talisn" there, the port plays "intothefireedit".

**Where**: 40 commands on maps 16, 21, 22, 26, 31, 32, 44, 46, 64, 78, 88
and 89, in `degradations.json` as `system-bgm-not-changed`.
`ChangeSystemBGM` is a declared debt since the survey —"the missing
commands" research, 2026-10-05—; there was no task for this game, where
every story fight relies on it.

**How to see it**: the ports' case `milestone-cauldron` and the song in
RAM (`games.Session.song`) during the first battle.

## Defined (2026-10-16, Carpintero)

Still open: `compile.rs` drops `ChangeSystemBGM` with
`system-bgm-not-changed` at the-advocate `f4709d0b`. It is a missing
command, heard in every story fight. **Done**: `ChangeSystemBGM` for the
battle and the victory slots at least —a slot the battle reads instead of
the database's theme, kept in the save—, the songs it names carried by
the audio packages, the degradation gone for those slots, and the
ports' `milestone-cauldron` asserting "talisn" in the first battle.
**First step**: count, over the nine dumps, which slots the command
changes (battle, victory, inn, vehicles, game over), to decide which go in
the first version.

## Doing (2026-10-19, Carpintero)

Branches `carpintero-music` in the-advocate (from `9592b88b`) and the
ports (from `c420032`), shared with the two other music tasks —
`a-maps-own-music-ignores-its-volume-and-tempo.md` and
`playbgm-fade-in-is-dropped.md`—, since all three are how a song starts.

**The count, over the nine dumps** (maps, common events and troops):
`ChangeSystemBGM` changes the battle's song 487 times —ABL 65, The Book of
Three 20, Dooms 2 7, Vampires Dawn 380, Zounds 15— and the victory's 89
—ABL 65, The Book of Three 20, Dooms 2 4—; the Game Over's once (Dooms 2)
and a vehicle's once (Zounds); **the inn's never**. So the first version
is slots 0 and 1, and the rest stays `system-bgm-not-changed`. ABL and
The Book of Three set both to the same song almost always, so the victory
goes on with the battle's song.

**How**: `OP_SYSTEM_BGM` (0x39: slot, song, the six bytes of a level)
writes `SYS_SONGS` in far RAM, which a new game fills with the database's
—with the database's level, `BA_SONG_GAINS` and the like from the
converter— and which travels in the save. The battle reads it on entering
and on winning. The song goes into the battle's audio package as a
**separate** song, like a troop page's: uploaded first with the battle's
sound effects and without the database's songs —`battle_extra_l` in
`audio_package.s`—, so it does not lower the battle song's rate.

Found on the way: `song_ensure`, the upload of a song that is not in ARAM,
always rebuilt `map_current`'s package, also in a battle. A troop page's
`PlayBGM` —ABL's radio— left the battle without its sound effects. It now
rebuilds the package loaded last (`PKG_LOADED`), the battle's in a battle.
