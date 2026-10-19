---
name: "The Book of Three: a night's rest in a scene has no fade or music"
description: "The game uses ShowInn as the night passing in several scenes; the port heals on the spot, without the inn's fade to black and its jingle"
type: bug
status: testing
assignee: taro
agents: [Tijereta]
---

Seen by Mulita on 2026-10-15, comparing the port with the original under
Wine, with the-advocate `fa9d1a14` (and `362d3765` for
`degradations.json`) and the ports `0ca371b`, in The Book of Three.

**What is seen**: besides the village inn (map 15), the game calls
`ShowInn` at price 0 as "the night passes" or a free rest: inside scenes
—Gwydion's camp (map 17), the cell in Spiral Castle (32), Medwyn's house
(80), map 63—, at the free resting places of maps 20, 24 (two abandoned
buildings), 41, 53 and 62, and in common event 10. In the original
the screen fades to black with the inn's music and comes back; in the port
the party is healed at once and the scene goes on.

**What the build says**: `degradations.json` lists the twelve as
`inn-not-staged`, "the inn heals on the spot, without the fade to black or
its music".

**How to see it**: the ports' case `milestone-campfire` —its scene ends
with one—, or `milestone-guard`.

## Defined

Wishlist, on 2026-10-16, by Cardón: at the-advocate `f4709d0b` `compile_inn` heals on the
spot for every inn, of every game, and says so as `inn-not-staged`; the
scenes go on, only without their fade.

**Done** means `ShowInn` fades to black with the System's inn music and
comes back, at price 0 too, as RM2k's `Scene_Map::CallInn`, and the loss
goes for both prices or only the free one; a golden of
`milestone-campfire`'s end. **First step**: how the runtime does a fade
and a song from a page today (`TintScreen`, `PlayBGM`), to stage it with
them.

## Work

Tijereta, from 2026-10-19, at the-advocate `9592b88b` and the ports
`c420032`; branches `tijereta-inns` in the-advocate, the ports and the
book.

**How the runtime fades and plays from a page today**: `OP_ERASE_SCREEN`
and `OP_SHOW_SCREEN` are the teleport's brightness fade cut in half, with
the world frozen while they go (`fade_tick` returns nonzero); `OP_FADE_BGM`
lowers the song without blocking; `OP_BGM` plays a `Songs` index at a
level. What is missing for `CallInn` is two things the bytecode cannot
say: **the song that was playing before**, which `CallInn` keeps apart
(`music_before_inn`, not the memorized one), and **waiting for the jingle
to play once** —`BGM_PlayedOnce`, or ten seconds— with the world frozen.

**Plan**: `ShowInn` stages as RM2k's `Scene_Map::CallInn`, built from the
opcodes above plus `OP_INN` (0x3B, the one handed out), with a phase
operand: 0 notes the song playing and its level, 1 freezes the world until
the song playing has come round once (or ten seconds) and stops it, 2 puts
the noted song back from the top. The page emits:

    OP_INN 0, OP_FADE_BGM (800 ms), OP_ERASE_SCREEN (the fade),
    [OP_BGM the System's inn music, OP_INN 1], OP_HEAL,
    OP_INN 2, OP_SHOW_SCREEN (the fade)

with the bracket left out when the inn music is `(OFF)` —ABL's, Desert
Nightmare's and Sunset's—, which is `StartInn` going straight to
`FinishInn`.

**Done as planned**, with three things learned on the way:

* the wait hangs off `fade_tick`: with no fade of its own it asks
  `inn_tick`, so the frozen frames are a fade's —the world stops, the
  ticks and the music go on—. Bank 0 pays the opcode's entry (14 bytes) and
  two in `fade_tick`; the rest is in `FAR3`, `inn.s`;
* "played once" is a count, `SONG_LAPS`, that `music_frame` adds one to
  each time a song starts over. The nine bytes did not fit where the restart
  was —two branches of the opcode chain went out of range— and the restart
  moved out of the way, next to `boot`, reached with a `jmp`;
* an MSU-1 track repeats from its loop point and never ends, so `OP_INN 1`
  writes `$2007` without the repeat bit and the wait looks at the playing
  bit. **No test runs that path**: the suite plays no inn music through the
  MSU-1.

"Playing" before the inn is what the battle asks —a song cut by a fade,
or a map with none, leaves silence after the night—, not `MemorizeBGM`'s
last song.

**Measured** on The Book of Three's camp, snes9x and bsnes alike: 25 ticks
down, 361 ticks of `Inn1` in the black —it ends on the lap, not on the ten
seconds—, 23 ticks up.

**Coordination with Carpintero** (`playbgm-fade-in-is-dropped`): the inn's
music goes through `op_bgm`, the same writer as `PlayBGM`'s, so if
`OP_BGM` gains the fade-in operand the inn gets it there; the inn wants it
at 0. And if a page's bytes do not walk by the declared sizes the
conversion stops, so a mismatch cannot pass quietly.

**Verified**, with the tools of the branch (`.local-tools` with `events`,
`convert` and `cartridge`): `just crate-test events` (155 + 5 + 8 green;
the Python parity hash of the compilation's `maps` moved on purpose, see
`python.rs`), `just test`, `just lint`; ABL's `just cartridges` and
`just tests`, with no golden moved; and `just boot` from the ports root.
The two new ROM tests were red with the global tools: the bum healed at
full brightness.

Measured with the branch's tools: `just crate-test events` (155 + 5 + 8),
`just test` (29), `just lint`; ABL's suite 1582 passed, 2 skipped, no
golden moved, `abl.sfc` `84bfa9a11fe05e21`; `just boot` 74 passed, with
one new golden, `book-of-three-m-campfire-night` —the scene going on after
the night: the camp is tinted black before it, so the night is black over
black and is heard, not seen—. `milestone-campfire`'s end golden did not
move. **Bank 0**, `just space` in ABL: `test-change-system` is the
tightest, at 14 bytes left; `release` 69.

**What no test covers**: the MSU-1 path of the wait —the track told to
stop repeating, and its playing bit—; an inn whose music the cartridge
does not carry, or the same song as the map's; a night started over a
screen an event already erased; and the paid inn with an inn music,
which no game has (ABL's paid inns play `(OFF)`).

**When merging**: reinstall `events`, `convert` and `cartridge` —the
opcode and the runtime change—. `SAVE_BYTES` does not change: nothing of
the inn travels in the save. Carpintero's `PlayBGM` work had not landed in
`main` when this was handed back; the inn goes through `op_bgm`, see
above. Captures in `/shared/captures/2026-10-19-inns/`, the camp's night
heard in `/shared/audio/2026-10-19-inns/`. Branches `tijereta-inns` in the
three repos; draft: `an-inn-has-no-gold-window`.

## On Carpintero's music (2026-10-19, after the hand-back)

Hornero merged `hornero-integ` (`main` plus Carpintero's, Calandria's
and Chajá's branches) into `tijereta-inns` in the three repos. `op_bgm` is
still the one `OP_BGM` writer, now from `Level`: `PlayBGM` passes
`music_level`, the inn its System entry's level **with its own fade-in**,
which `Game_System::BgmPlay` honours (0 in every game today). With
`bgm_fade` at 2 meaning a fade-in, the inn's wait reads only 1 as "the song
before is fading out". The runtime's convention did not change for the
inn: it notes `song_current` and `BGM_NOW` and puts them back through
`BGM_ASK` and `music_play`; `BGM_ASK_FADE` is not written, so no fade-in.
The camp's test now checks the level too: `TLITCA` at `80800001` before
and after, in both cores.

A golden photo moved in time, not in pixels: the guard milestone's
`-scene` photo is taken by ticks, and the cell's night adds 409; at 1619
it is the same frame. The parity hash moved for both changes; with
`inn_staging` answering the heal alone it is Carpintero's.

Verified on the merged tree with `.local-tools` of `events`, `convert`,
`cartridge`, `mapdata`, `rm2k-snes-audio` and `wally`: `just crate-test
events` (159 + 5 + 8), `just test` (29), `just lint`; ABL 1570 passed, 2
skipped, `abl.sfc` `0a3cce588992ccea`; `just boot` 77 passed and the
guard red until the photo moved, then the guard and the inn's test again,
green. `just space`: `test-change-system` 49 B of bank 0, `release` 104.
**When merging**: reinstall `events`, `convert`, `cartridge`.
