---
name: "Sound effects without cuts"
description: "The sound effects whole and at a higher rate where it costs no instrument anything; the rest, for taro to decide by listening"
type: feature
status: done
assignee: taro
---

# What

Improve how the sound effects sound. The limits they had —see
`sound-effects.md`— were intentional, all because of ARAM: they go in
each map's audio package, at 6 kHz and at most three quarters of a second
(a longer one repeats its last 0.4 s until it lasts as long as in RM2k).

**The condition is taro's**, from 2026-09-26, in their words, translated:

> I don't find it acceptable for instruments to lose quality because of a
> single map, but I don't want to lose quality in the sound effects
> either.

Since the per-package budget, the
sound effects are subtracted before allotting, so enlarging one lowers the rate of
its package's samples **if that package is the one that limits them**. The idea
he approved: choose the quality effect by effect, as with the thunder.

# Status

2026-09-26, in `testing/`: **done, what costs no instrument
anything** —25 effects whole, almost all at 22 kHz—, and **what would cost
an instrument, measured and recorded for taro to decide by listening**, below in
"What taro decides". What's left for him: listen to
`/shared/audio/2026-09-26-efectos/` (it has its `LEEME.txt`) and choose.

Later the same day taro chose —all whole, at half as a minimum—, and
with the numbers for that in view he changed: **whole yes, but half only
where it's free for the music**. It's in the branch
`worktree-agent-afa6d748ca7a9d5ab`, unmerged: see "The candidates,
whole" below. **Whole at 6 kHz still costs the music**; of the
proposals there taro chose the thunder one, which leaves the rain whole for free.
What the battle and map 3 still cost waits for freeing up entries in the
directory, in another task.

Done the same day, in `effects-directory.md`: of the 175 pairs
that went down, 117 remain, and none goes down compared with before. **To the themes of
the packages that pay for the sound effects it gives nothing back** —the battle one,
`evilrhys`, `TF3_1_awe`, `3D-Galax` and `Gaden`—: they're limited by their own
package, and no copy takes them out of there. What comes back is the knock-on effect.

# What was stale on 2026-09-26

The task was written on the 24th, and since then:

* **A single voice: stale.** There are two, 6 and 7, since 8c9c182 (see
  `rom/src/efectos_de_sonido.s`).
* **6 kHz, 0.75 s and the 0.4 s loop: still true** for all but the
  opening's thunder, which goes whole at 22 kHz
  (`ports/abl/decisions/the-thunder-plays-whole-and-pays-for-the-rain.md`). The thunder **was already on
  `main`**, not only in the experiment's branch as that decision said.
* **The ARAM budget** is no longer "each effect whatever fits": it's per
  package and each package fills ARAM, so there was no spare room to
  use without looking package by package. See `decisions/a-single-sample-bank.md`.
* **`SE_ARAM` is still dead**: `build_varios` passes `1 << 30` to `build_efectos`.

**The test case —the opening's thunderclaps cut off— was already
solved.** Recording `release`'s idle opening (955b186, without MSU-1)
for 3000 frames and noting per frame which effect plays on each voice: the three
thunderclaps (frames 408, 1600 and 2638) play their 144 frames whole on voice
6, with the rain on 7, and the recording drops 9 dB from the peak down to the
rain's floor instead of staying flat until the `KOF`.

# The sound effects heard the most

"Uses" are the `PlaySound`s of the pages of the maps `release` carries
(a script over `data/maps/`); those of the battle animations and of the
battle aren't counted. "22 kHz" is what it would weigh whole at the WAV's rate.

| Effect | Maps | Uses | Length | 22 kHz | Today |
|---|---|---:|---:|---:|---|
| Sword3 | 26, 255 | 61 | 0.79 s | 9.8 KB | **whole at 22 kHz** |
| Bow2 | 2, 17, 20, 21, 26, 32, 133, 255, 261, 269 | 46 | 0.67 s | 8.4 KB | 6 kHz; waiting: 2 |
| Darkness | 2, 3, 32 | 16 | 1.38 s | 17.1 KB | 6 kHz with loop; waiting: 2 and 3 |
| Blow2 | 8, 11, 13, 19 | 12 | 0.28 s | 3.4 KB | 6 kHz; waiting: 19 |
| Holy5 | 2 and eight more | 10 | 0.83 s | 10.3 KB | 6 kHz with loop; waiting: 2 |
| Holy3 | 2, 11 | 9 | 0.54 s | 6.7 KB | 6 kHz; waiting: 2 |
| Switch1 | 3 | 9 | 0.40 s | 4.9 KB | 6 kHz; waiting: 3 |
| Decision1 | 2, 7, 17 | 8 | 0.25 s | 3.1 KB | 6 kHz; waiting: 2 |
| Earth2 | 2, 3, 74 | 8 | 1.22 s | 15.2 KB | 6 kHz with loop; waiting: 2 and 3 |
| Failure2 | 9 | 7 | 0.60 s | 7.4 KB | 6 kHz; 9 has no room (inheritance) |
| Earth8 | 14, 261 | 7 | 0.51 s | 6.4 KB | **whole at 22 kHz** |
| clap | 18 | 7 | 2.79 s | 17.3 KB (WAV at 11 kHz) | 6 kHz with loop; 18 has no room |
| Rain1 | 1 | 6, looping | 5.00 s | 62 KB | 6 kHz with loop; waiting: 1 |
| Recovery4 | 23, 26 | 6 | 1.08 s | 13.4 KB | **whole at 22 kHz** |
| Success2 | 9, 10, 12, 16 | 6 | 1.30 s | 16.1 KB | 6 kHz with loop; 9 has no room |
| Item1 | 11, 13, 17, 20, 133 | 6 | 0.71 s | 8.8 KB | 6 kHz; 20 has no room |
| Monster2 | 21, 26 | 5 | 1.52 s | 18.8 KB | **whole at 22 kHz** |
| Glass, Explosion4 | 3, 11, 19 | 5–6 | 1.5–1.9 s | 18–24 KB | 6 kHz with loop; waiting: 3 and 19 |
| Thunder9 | 3, 20, 32 | 4 | 1.92 s | 23.8 KB | 6 kHz with loop; waiting: 3 |
| The battle: Attack2, Damage1, Evasion1, Escape, Item2, Bite, Monster1 | battle | every battle | 0.4–3 s | 4.7–37 KB | 6 kHz; waiting: the battle |

"Waiting: N" means package N limits samples and raising it lowers the rate of
some instrument: it's in "What taro decides". "No room
(inheritance)" means its package has room on its own, but with some theme that
may already be playing its sound effects **already** don't fit alongside, and enlarging them would
make the `PlayBGM` wait longer: see below.

# What was done

**What a whole effect takes up extra no longer goes into the music's
budget**: the bank is allotted counting each effect in `SE_ENTEROS` at its
usual size, and the extra has to fit in what the music leaves
free in each package where it is; otherwise, the converter stops saying which one
(`_enteros_entran` in `tools/audio/snes_music.py`). That way no instrument pays for
it **by construction**, and if tomorrow the music grows in a package, the
converter warns instead of lowering someone's rate. The opening's thunder
is the exception, `SE_ENTEROS_PAGADOS`: taro chose it before this rule, and
in `test-special` its package does limit samples.

**What went in**: the effects that are only in packages that don't limit any
sample, the most heard first, at the highest rate that fits —22,050
Hz, the WAVs', or otherwise 16,000 or 11,025—, and without a package whose
effects today fit alongside a theme that may already be playing ceasing to fit.
First the loop was removed from all that had it, and then the
rate was raised. That's 24 plus the thunder:

| Rate | Effects |
|---|---|
| 22 kHz | Sword3, Monster2, Recovery4, Flame5, Explosion5, Dark5, Cold2, Thunder6, Thunder4, Decision2, Earth8, Fall2, Buzzer1, Blow7, Failure1 |
| 16 kHz | Holy6, Kill3 |
| 11 kHz | Sword2, Dark1, Sword1 |
| 6 kHz, no loop | Numbness3, Refer Book, Earth1, Thunder5 |

**What it cost**, measured on `release` against 955b186:

* **To the instruments, nothing**: the allotment, the copies, the rate and the size of
  each sample come out identical, in `release` and in `test-special` (a script that
  compares what `build_varios` returns in both commits).
* **To the fade-in**, a few more frames of black in the maps that
  grew —hardware frames from the jump request until the fade
  ends, in the order 7, 26, 261, 13, 269, 30, 33, 52, 11—: 7 from 93 to
  136, 261 from 131 to 165, 269 from 106 to 133, 33 from 99 to 117, 52 from 128 to 144,
  13 from 88 to 103, 30 from 92 to 103, 11 from 134 to 144; 26 the same (163). No
  package can exceed ARAM, so the worst doesn't get worse: what changes
  is that more maps come close to it.
* **Cartridge**: the sound effects go from 211,509 B to 398,007 B.

What's heard, against the original WAV (the energy above 3 kHz, in dB against
the total): before, between −22 and −55 dB, 20 to 40 dB below the WAV; the
22 kHz ones end up 1–6 dB from it, the 16 ones 2–3, and the 11 ones further (Dark1,
−26 against −8). Those still at 6 kHz sound as they were, but whole and
without the repeated plateau.

**What `just tests` doesn't cover**: none of this sounds in the suite. A
separate script looked at it, jumping to the map, silencing the music and recording each effect coming out
of the ROM, before and after.

# What taro decides

Each candidate, with what the instruments would pay. The calculation rebuilds
`release`'s allotment with the bigger effect (copies included) and compares the
rate of each (theme, instrument) pair; "N go down" are the pairs that lose more
than 0.5 kHz, and the ones that lose the most are named. The copies are rearranged with
each change, so a small effect can move many pairs.

| Candidate | Extra weight | What it pays |
|---|---:|---|
| **Rain1** at 11 kHz, with its loop (map 1) | 2.1 KB | 15 go down: the taiko of `escape_newyork` and `vswar` 22.0 → 16.3, the polysynth 21.1 → 16.9, the piano (5 themes) 17.9 → 16.3 |
| Rain1 at 22 kHz, with its loop | 6.8 KB | 18 go down: `escape_newyork`'s polysynth 21.1 → 12.6, the taiko 22.0 → 14.0, the piano 17.9 → 14.0 |
| Rain1 whole at 6 kHz, no loop | 14.3 KB | `escape_newyork`'s polysynth 21.1 → 8.4, the taiko → 10.4, the piano → 10.5 |
| **The battle**: Attack2, Damage1, Evasion1 and Escape at 16 kHz | 12.1 KB | 40 go down: the battle theme's brass 21.7 → 10.8, and cymbals of other themes 22 → 13.9 |
| Attack2 alone, at 22 kHz | 6.3 KB | 42 go down: the battle's brass 21.7 → 16.3, the guitars 19.9 → 15.2 |
| Damage1 alone, at 22 kHz | 5.5 KB | 25 go down: the same ones, similarly |
| Monster1 whole at 6 kHz | 7.6 KB | 43 go down: the battle's brass → 16.3, the guitars → 14.7 |
| Bite, Item2 and Monster1 whole at 11 kHz | 24.2 KB | the battle's guitars 19.9 → 8.2 |
| **Thunder9** whole at 6 kHz (maps 3, 20, 32) | 3.9 KB | 13 go down, all from `evilrhys` in 3: harp 12.2 → 9.5, strings 12.5 → 10.0 |
| Thunder9 whole at 11 kHz | 9.4 KB | `evilrhys` at 6.1–6.6 kHz |
| **Darkness** whole at 6 kHz (2, 3, 32) | 2.1 KB | 25 go down: `TF3_1_awe`'s polysynth 16.9 → 12.6, `evilrhys` 12.5 → 11.1 |
| Darkness whole at 16 kHz | 9.9 KB | `TF3_1_awe` at 8.4, `evilrhys` at 5.9 |
| **Switch1** at 22 kHz (3) | 3.6 KB | 13 go down, `evilrhys`: 12.5 → 10.2 |
| **Bow2** at 11 kHz | 1.9 KB | 12 go down, `TF3_1_awe`: polysynth 16.9 → 12.6 |
| Bow2 at 22 kHz | 6.1 KB | `TF3_1_awe`: bass 16.4 → 11.7, polysynth → 12.6 |
| Holy5 at 16 kHz | 4.9 KB | `TF3_1_awe`: polysynth → 12.6, bass → 12.9 |
| Blow2 at 22 kHz (19) | 2.5 KB | 41 go down: a bass of `hzbreach` and `vswar` 22.9 → 16.7, the polysynth → 16.9 |
| Explosion4 or Glass at 11 kHz | 6.5 / 9.4 KB | 50 go down: cymbals 22 → 13.9, `evilrhys` at 6.6 |

**Bow2 and Holy5 have a catch**: besides 2 they're in 26 and 261, to
which what was done left ~1 KB free. Raising them also requires lowering some of what
was done there (Monster2, Recovery4, Sword3 in 26; Thunder4, Buzzer1 in 261).

**A cheaper path for those that share a package**, like the thunder: an
alias —another directory entry for the same WAV— whole only in the
packages that have room, and the usual one in the one that limits. But the
directory is full (255 entries, the SRCN cap), so each alias
costs the last copy of `snes_music.copias`: **the first, the `SPACE79` of
`T_ProjectJustice_DiscLoad` and `dcbest`, 17.9 → 16.0 kHz**; the second, the
copy before it, and so on. Freeing up entries is "giving the sound effects their own
place in the directory" (see "Sin el techo del mapa 3" in
`quality-of-the-music.md`), which means redoing `paquete_de_audio.s`.

**The ones that cost no instrument but do cost the sound effects**: in
packages 9, 18, 20, 28 and 32, with some theme that may already be playing, the
map's sound effects **already** don't fit alongside and wait for the `PlayBGM`. There's room
to enlarge them —Cold7 at 22 kHz in 32, Wind8 at 11 in 28, Kill2 and Kill4
in 20—, and what's paid is that they wait longer: more mute effects between
arrival and the `PlayBGM`, and that `PlayBGM` frozen for longer. It wasn't done.

# The candidates, whole (2026-09-26, in the branch, unmerged)

taro, listening, in their words, translated:

> I have zero doubts that they have to have their full length (all of
> them)

First he asked for half (11 kHz) as a minimum; with the
numbers for that —the battle theme and `evilrhys` at a quarter, 196 pairs
going down— he said that affecting the music so much doesn't please him, and it ended up like this:
**all whole, at half only where it's free, and otherwise at the usual 6 kHz**.

**None was free at half**: each candidate is in some package
that limits samples (1, 2, 3, 19 or the battle), and in those
any extra byte lowers someone's rate. So:

* **Whole at 6 kHz** the ones that were longer than 0.75 s: Rain1, Bite,
  Item2, Monster1, Thunder9 (the one in 3, 20 and 32), Darkness, Explosion4,
  Glass and Holy5 (`SE_ENTEROS_PAGADOS` in `tools/audio/snes_music.py`).
* **Same as on `main`** the ones that already played whole: Attack2, Damage1,
  Evasion1, Escape, Switch1, Bow2 and Blow2.
* **No aliases**: with all at a single rate they're not needed, and each one costs
  a copy. `SE_DEL_MAPA` stays with map 1's thunder, which was already there.

The first version —at half, with aliases in map 3— is in 68c6818, and
its recordings in `/shared/audio/2026-09-26-efectos-completos/`.

## Full length alone already costs the music

**And it can't be avoided at 6 kHz**: the packages that limit are full up to
the margin, and a whole effect at 6 kHz weighs about 3,400 bytes per second,
against the 2,529 of the 0.75 s cap with loop. For full length to
be free, Rain1 would have to go at less than 1 kHz.

Each one alone, against `main` (rebuilding the allotment with that effect whole and
nothing else changed):

| Effect | Packages | Extra | What the music pays, alone |
|---|---|---:|---|
| **Rain1** (5 s) | 1 | 14.3 KB | `escape_newyork`: polysynth 21.1 → 8.4, taiko 22 → 10.4, piano 17.9 → 10.5, and seven more from ~16 to ~10. **With the thunder at 8.8 kHz, nothing**: see below |
| Monster1 (3 s) | battle | 7.6 KB | `T_VGFighterMAX_Masako`: brass 21.7 → 16.3, guitars 19.9 → 14.7 |
| Bite (1 s) | battle, 8 | 0.8 KB | brass 21.7 → 16.3 (because of a copy), the rest ~1 kHz |
| Item2 (1.1 s) | battle | 1.3 KB | brass 21.7 → 16.3, toms 19.9 → 18.5 |
| **The battle's three** | battle | 9.7 KB | guitars 19.9 → 13.6, toms → 14.1, brass → 16.3; twenty instruments |
| Thunder9 (1.9 s) | 3, 20, 32 | 3.9 KB | `evilrhys`: harp 12.2 → 9.5, strings 12.5 → 10.0 |
| Darkness (1.4 s) | 2, 3, 32 | 2.1 KB | `TF3_1_awe`: polysynth 16.9 → 12.6; `evilrhys` → 11.1 |
| Explosion4 (1.5 s) | 3, 19 | 2.4 KB | 54 pairs because of copies that get rearranged: bass of `hzbreach` and `vswar` 22.9 → 16.7, `Gaden`'s tuba 17.2 → 14.7 |
| Glass (1.9 s) | 3, 11, 19 | 4.0 KB | 55 pairs, the same ones, and `evilrhys` → 9.5 |
| **Map 3's four** | 3 | 12.4 KB | **`evilrhys` from 12.5 to 4.6**, and as a knock-on cymbals of `Deflector1` and `Lunar_Pyramid` 22 → 13.9 |
| Holy5 (0.8 s) | 2, 8 more | 0.3 KB | one sample of `TF3_1_awe` 16.4 → 15.7 |

**All together, as it is in the branch** —with the thunder at 8.8 kHz—: 175
pairs go down, and **none because of map 1's package**. What remains is from the battle,
map 3, 2 and 19, and knock-on effects:

| Theme | What it loses most | Limited by | Instruments that go down |
|---|---|---|---:|
| `evilrhys` | almost everything, 12.5 → ~4.5 | 3 | 13 |
| `T_VGFighterMAX_Masako` | guitars 19.9 → 13.6, toms → 14.1, brass 21.7 → 16.3 | battle | 20 |
| `TF3_1_awe` | polysynth 16.9 → 12.6 | 2 | 12 |
| `escape_newyork`, `vswar` | polysynth 21.1 → 12.6 (sample shared with `TF3_1_awe`) | 2 | 7 and 9 |
| `hzbreach` | bass 22.9 → 14.6 | 2 | 4 |
| `3D-Galax`, `Gaden` | bass 16.7 → 13.3, tuba 17.2 → 14.7 | 19 | 13 and 6 |
| `cd2`, `Lunar_Pyramid`, `Deflector1`, `11h035` | ocarina 24.1 → 16.1, cymbals 22 → 13.9 | 18+hzstream (copies that get rearranged) | 4 to 11 |
| the other 18 | ~16–20 → ~13–14, mostly samples the battle limits | battle | 1 to 9 |

The ones that lose the most have an MSU-1 track, so with MSU-1 it isn't heard.

## The thunder pays for the rain (done)

**Map 1's thunder goes whole at 8.8 kHz instead of 22**, and with that the
whole rain is free: Rain1 whole at 6 kHz plus `Thunder9@entero` at 8,800
Hz take up 63 bytes more than today, within the margin. Checked with the
converter: with those two alone, the bank, the copies and the rate and size of
each sample come out **identical to `main`**. It's taro's, from 2026-09-26: he'd
already listened to the thunder at lower quality and found it quite acceptable.
See `ports/abl/decisions/the-thunder-plays-whole-and-pays-for-the-rain.md`.

## Proposals that remain, measured (not implemented)

* **Less than 6 kHz for the long ones of map 3 and the battle.** At 4 kHz whole,
  map 3's four cost 4.9 KB instead of 12.4 (`evilrhys` at ~9.4 instead of
  4.6), and the battle's three 3.9 instead of 9.7 (brass and guitars at
  ~16.3 instead of ~14). It isn't free even then.
* **The underlying fix**: free up directory entries so the copies
  separate the themes from the package that limits them (almost all the knock-on), or
  the long effects by streaming, or quality versions with MSU-1 (another agent
  is doing it).

## Loading and waits

The packages that limit don't grow: what the sound effects gain the
music loses. Measured jumping from the title in the order 1, 2, 3, 8, 11, 19, 20,
23, 26, 32, 261, 17, 255, 13 (frames from the jump request to the end
of the fade), against `main`: 20 +13, 32 +10, 19 +9, 11 +5; 1
−10 and 2 −11 (the thunder at 8.8 kHz weighs 14 KB less, and 2's music
went down); the rest the same or one less. Loading a save in map 1 fits within the
cap of `test_entering_the_game_brings_back_the_map_songs_samples`, which
went back to how it was.

**Extra waits for the `PlayBGM`**: 11's sound effects with `hzstream` or
`C3classi` playing, which fit before, because of Glass whole (1.9 and 3.6
KB short; whole it can't weigh less), and 20's with `3D-Galax` and 32's
with `Lunar_Pyramid`, more than before. 28 with `wb3shop` improves.

**What `just tests` doesn't cover**: that the sound effects play whole; a
separate script recorded it, effect by effect, coming out of the ROM, in
`/shared/audio/2026-09-26-efectos-enteros/`.

# To listen

`/shared/audio/2026-09-26-efectos/`, with its `LEEME.txt`: the 24 of what was done,
before and after, and the candidates in two or three qualities, all coming out of
the ROM without MSU-1, with the music silenced, at volume 100, tempo 100 and
centred. The candidates come from a ROM built separately that puts them in maps
without a theme; in the game they'd pay what's in the table.

# Found in passing

**Without MSU-1, `FadeOutBGM` also silences the sound effects** until another
theme starts. The thunder at the end of map 3 is one of those that fall there.
Fixed on 2026-09-26: `tasks/theme-fade-silences-the-sound-effects.md`.

# The earlier work: 2026-09-24

That day's investigation (on 7303f2b) found the two causes of the
cut-off thunder: the rain stole its only voice —it cut off at 73 of its
144 frames, and once at 7— and the cap with loop repeated its loudest
stretch until a dry `KOF`. taro heard it stutter even without rain. Both
were fixed: two voices (8c9c182) and the thunder whole at 22 kHz, with the
numbers in the decision. The rest of that plan —longer effects in all
maps, the baked fade as plan B, the rate for all— is what this
task replaces: **effect by effect, and only where nobody pays**.
