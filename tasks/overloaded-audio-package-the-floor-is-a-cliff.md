---
name: "An overloaded audio package gets its music at 6 kHz; one that barely fits gets it at the minimum"
description: "The relief of a package that does not fit in the ARAM leaves its music at the sound effects' rate and drops effects; a package that fits by a few bytes is not relieved and its music is squeezed to the minimum instead. Where the trigger goes is taro's to decide by ear"
type: bug
status: testing
assignee: taro
agents: [Aguará, Cardón]
---

Seen by Aguará on 2026-10-15, on the branch `aguara-aram` of the-advocate
(`f0b15d74`, on main `362d3765`), while making The Frozen World's map 1
build.

**What it is**: `relief.rs` in `rm2k-snes-audio` relieves a package only
when it does not fit even with every sample at the minimum —what used to
stop the build—, and then aims the music at the effects' rate, 6 kHz,
dropping effects from the end of the list. A package whose effects leave
its music a few bytes above the minimum is not relieved, and the
allocation squeezes its music down to the minimum —`FLOOR`, 256 B per
sample— to fit every effect. So two packages a few bytes apart come out
very differently: one with its music at ~6 kHz and fewer effects, the
other with all its effects and music at its worst.

**Why it was left so**: the trigger at "does not fit at all" keeps every
package that builds today exactly as it is —A Blurred Line's map 3 keeps
`evilrhys` at 4.5 kHz so that its 55 KB of effects fit, which taro chose
by ear (`paid_by_music`)—, and its ROM comes out byte for byte the same.
Moving the trigger to "the music would go below 6 kHz" would relieve
ABL's map 3 too, which is taro's call, not the tool's.

**How to see it**: any game whose package has effects for ~60 KB (not
relieved, music at the minimum) next to one with ~64 KB (relieved). In the
build's `converter.log`, the per-sample lines say the kHz and which
package limited each.

**taro, 2026-10-16**, before deciding, wants to hear ABL's map 3 both
ways: as it is, and with the relief triggered when the music would go
below 6 kHz. Taken by Cardón to render the two and list which other
packages of the nine games would change.

## The two renders and the survey (Cardón, 2026-10-16)

The variant is on the branch `cardon-relief-6khz` of the-advocate: the
trigger in `relieve` asks whether the package's music fits **at the floor
rate** —6 kHz, or a sample's native rate if lower— next to every sound
effect in `free`, instead of at the minimum. Once relieved, the relief is
the same as before: songs separate first, then effects from the end of the
list, aiming at `room`.

Both renders of ABL are built with the same tools from main, installed
locally from one checkout; the variant's only differs in
`rm2k-snes-audio`. Map 3's sound effects all play in the Emitter Room scene
—event 5's page 2, which the suite's case `talan` starts—, so that is what
is recorded, SPC700 only.
Map 3's last effect, Fog2, plays only at the end of Core's farewell (event
42, after maps 4, 5 and 6), which is recorded apart.

The renders are in `/shared/audio/2026-10-16-map-3-relief/`, with their
README: tools at main `40117ca0`, the variant an experiment commit
(`db9f8d40`, no longer on any branch: the real commit, below, replaced it
with the same trigger); the ports at `ad003b1`.

**ABL's map 3** (converter.log, samples limited by package 3):

| sample | as it is | relief at 6 kHz |
|---|---|---|
| CELST77 | 18.2 | 18.2 |
| SLPMT52A | 5.2 | 5.9 |
| HARP_70A | 4.8 | 6.1 |
| TMPNI47 | 4.6 | 6.3 |
| STRNG71B | 4.5 | 6.2 |
| SURDO60 | 4.6 | 6.2 |
| KICK264 | 9.7 | 9.7 |
| SOLKK60A, FATSD60A, T_SNR60A, OHH__60B, CHINA60A | 4.5 | 6.1 |
| CHH__60A (two) | 7.5 | 7.5 |

`evilrhys` goes separate (the map does not start it on entering: event 5's
`PlayBGM` does), so it starts 0.1 s later in the scene; Fog2, the last of
the 20 effects, is left out. Elsewhere in ABL, three samples move 0.1 kHz
(SEA__60, HBNGO60, RDCYM60B) from the shared bank's new split.

### Across the nine games

Each game's `release`, built with main's tools and with the variant's
`rm2k-snes-audio`, the two `converter.log`s compared:

* **The Book of Three, Desert Nightmare, Dooms 2, The Frozen World,
  Sunset over Imdahl, Zounds**: nothing changes, not a sample line. The
  Frozen World's map 1 was already relieved, and is relieved the same.
* **A Blurred Line**: map 3, above.
* **El Dorado**: three packages, which share their drum kit and
  instruments, all with `Recado`:
  * map 12 (`Recado`, `Sombrero`, 22 effects): `Sombrero` goes separate,
    no effect is lost; what limited the music of all three maps was this
    package, so its samples go from ~4.4 kHz to 10.1–10.5 kHz (PIANO64
    4.5 → 10.5, VIBE_64A 3.9 → 10.5, ACOBS43A 4.7 → 10.1, VIOLN76 5.3 →
    10.5, TRMBN62A 4.6 → 9.2, the congas, timbales, bell and guiro 4.4 →
    10.4);
  * map 11 (`Recado`, 25 effects): loses **Schlange** —the snake at
    (13,7)— and **schritte-metall-schwer** —the knife palm at (13,13),
    page 2—; its music now limits the shared samples, at 6.3–7.0 kHz
    (from ~4.4);
  * map 4 (`Recado`, 26 effects): loses **Blow6** and **Knarren2** —both
    the rope at (8,11), pages 1 and 4—; music at the same 6.3–7.0 kHz.
* **Vampires Dawn**: map 4 (`Vampire1`, `Inn1`, `Game22`, 12 effects):
  `Game22` goes separate, no effect is lost, and its music goes from
  ~5.8 to ~7.4 kHz (OVDRV60 6.2 → 8.3, SYBS133 6.1 → 7.0). **But 36
  samples of other maps go down**, 9 go up: the worst, VIOLN68 23.3 →
  16.7 kHz on map 221, TRMBN62A 13.8 → 9.2 on 240, and map 360's kit
  (RDBEL64B, VBSLP64, SWHSL60A, WODBK60) 17.3 → 14.3; the best, POLY_48A
  and BS_LD48 on 236, 12.5 → 14.6. The bank goes from 202 versions to
  200. Why the split of the shared bank moves that much was not measured;
  the likely cause is the directory's copies, which a separate song's
  package competes for.

## Decided (taro, 2026-10-16)

*"vamos por el 6k. Coincido en que el salto entre 4 y 6k no tiene
sentido, y 4k es demasiado poco"*. The experiment became the real change:
`relief.rs` triggers at the floor, ABL's `paid_by_music` comment says the
music pays only down to 6 kHz, and the book's internals and lossy pages
say what triggers the relief now.

Branches, all named `cardon-relief-6khz`, with main merged (the-advocate
`63b46ae9`, the ports `059ddcd`):

* **the-advocate**: `12ca6c69`, the trigger, with the test that pinned the
  old one rewritten and a new one for a package that fits only below the
  floor (red with the old trigger).
* **the-advocate-ports**: `ddec8b8`, ABL's `paid_by_music` comment;
  `0462e4d`, ABL's volume ceilings measured again —`test_music_ceilings`
  went red: `evilrhys` goes from headroom 0.299 to 0.354, the rest move by
  0.01 at most—. No golden moved.
* **the-advocate-docs**: `331e0d2`, `internals/audio.md` and the lossy
  entry, renamed, with its link in `lossy.md`.

**Verified** on the merged tree, with the tools installed locally from it:
`just rust-test`, `just test`, `just test-game` (with FluidR3_GM), ABL's
`just tests` and the ports' `just boot`, all green. What the suite does not
cover: that Fog2 is silent at Core's farewell, and that `evilrhys` starts
on its `PlayBGM` —both heard only in the renders, which were made with the
experiment's identical trigger—; and El Dorado's and Vampires Dawn's
changed packages, which no test plays.

**To install when merging**: `just install rm2k-snes-audio`. Then `just
deliver` of ABL and of the other games, for the packages above to reach
the builds.
