---
name: "Lashe 2: Boss Wick and the vidcasts"
description: "From Talan's neighbour to Boss Wick's favour: maps 40 to 45 and the transitions"
type: feature
status: done
assignee: taro
---

# What

Milestone 2 of `lashe-city-with-the-car-up-to-the-race.md` —the context and what was measured are
there—. It goes after 1 and in parallel with 3.

The mandatory stretch of the three branches: the neighbour's door in Sector 35
(event 13 of 37, requires 151 from Talan's pad) leads to **Boss
Wick**'s den, the vidcasts, the security video with the director's scene, and **the
favour**: Wick heals your ankle if you agree to owe him one. It turns on 161
(`DoneWithVidcast`), which the three branches require to leave.

Maps: **40** (Boss Wick's Den), **41** (ScreenToneAdjuster, black), **42**
(The Vidcasts), **43** (Vidcasts Office: 34's tiles), **44** (Talan Stats,
black) and **45** (Security Footage: all of 19, tiles and events). 46 and 98
nobody reaches. The order in which they're gone through is in the plan,
"Tramo por tramo".

**The mafia boss isn't a battle.** It's event 7 of 40: two nested
`ShowChoice`s; accepting turns on 164 and runs page 5 (the surgeon,
`ChangeHeroTitle` to 'Fugitive', 267); refusing turns on 162. Both
end in 41 and from there go to 37, where the companion comments (event 17, switch
163).

# Status

2026-09-27, in `testing/`: done on `bd5b6a6`, in the agent's branch. What's
left is taro's: play it (below, "What taro has to look at while playing") and
look at the photos without golden in `tests/snapshots/playthrough/lashe-wick-*/`.
What follows from here down to "What was done" is the plan as it was.

# What was missing

With the six maps in the cartridge all pages compile except four, and
the four fall for the same reason:

**`ChangeScreenTransitions`** (10690): page 1 of 40 (Wick's scene
1), 4 (the favour), page 1 of 42 and page 1 of 45. It asks for `[0, 16]`/`[1, 16]`
—zoom for erasing and for showing in the teleport—, `[0, 17]`/`[1, 17]`
—mosaic— and `[0, 0]`/`[1, 0]` —back to the fade—. It's `SetTransition` in
EasyRPG (`game_system.cpp`, the `fades` table). In the whole game it blocks 15
pages and unblocks 14 on its own.

What can be done and what can't (question 4 of the plan):

- **the mosaic is the console's**: the `MOSAIC` register makes the blocks, and
  growing them during the fade is cheap;
- **zoom doesn't exist in mode 3**; the reasonable thing is a fade and declaring it in
  `divergencias/`;
- the chosen transition is state that crosses the teleport: it goes to far
  RAM (BSS has ~100 bytes free), and it's saved in the game if the
  original saves it.

And the debt in `other-transitions.md` shrinks: the
mosaic stops being there.

**Two new themes without samples in the bank**: `Kfmus5` (the den, plays
with 8% of its notes through the SPC700) and `tsmedit` (the surgeon, 53%). They
have the MSU-1 track on their own —since 2026-09-26 every theme has its own,
with the number `pista_msu` gives—, and how they sound without MSU-1 gets checked.

**The "REC" in 45** (`ShowPicture 'ABLrec'`, a parallel that makes it
blink): the ROM carries a single sign and it's the "One year previously" one, so
it's accepted without being done (question 5).

# Numbers to hand out

One opcode (the transition) and two MSU-1 tracks. One far RAM address.

# Tests

- **Suite cases** for the transition: a `Teleport` with mosaic and one with
  zoom, with goldens midway through the effect —outside the first twenty frames of
  a message—.
- **The walkthrough**: from 37 with 151 set —or entering 39 and touching
  the computer—, until returning to 37 with 161 on, **through both
  branches** of the favour (needs milestone 0 for "Refuse"). Check 162 or 164 and
  267, and photos in scene 1, the video, and the surgeon.
- The two-core test (`test_cores.py`) on the new transition: the
  state lives in RAM that has to be initialised.

# What taro has to look at while playing

Wick's whole scene and both branches of the favour; the mosaic on entering the
vidcasts; the zoom as a fade; the security video without the "REC"; and how
the two themes sound with and without MSU-1.

# What was done

**The six maps in `MAPAS_DEL_JUEGO`** (`tools/ensamblado/cartuchos.py`), and
with that in `release`. All their pages compile, and also the one milestone 1
had left dead: the neighbour's door, page 3 of event 13 of 37.
No page of these maps is left uncompiled. What compiles and doesn't do what
the original does: the "REC" in 45 (`ShowPicture 'ABLrec'`, decided debt) and
`ChangeHeroTitle` to 'Fugitive' (there's no screen that shows it).

**`ChangeScreenTransitions`**, with a new opcode, `OP_TRANSITION` (**0x2E**),
and two bytes of far RAM, `TRANSICION_BORRAR` and `TRANSICION_MOSTRAR`
(**$7E7920** and **$7E7921**, from the $7E7920-$7E793F range). The converter decides:
17 is the mosaic, the rest is the fade (zoom included, as taro
decided); the cut (19), "none" (20) and the battle ones don't compile, and there are
none in `release`. The mosaic is written in the vblank from
`fundido_mosaico` (`rom/src/transicion_del_teletransporte.s`), tied to the brightness
like the battle's; `fundido_tick` wasn't touched. It doesn't travel in the save: between
the page that sets it to mosaic and the one that sets it back there's no moment when
you can save (see the comment in `ram_lejana.s`). The divergence
—the mosaic darkens, the sprites don't pixelate, the zoom is a fade— is in
`divergences/the-teleport-transitions.md`.

**The cap of chained teleports, from 8 to 32** (`SALTOS_MAX` in
`rom/src/pagina_cero.s`). From the neighbour's door until returning to 37 there are twelve
jumps between maps without the player taking control, and with 8 the ROM
panicked on the second pass through 43: the screen froze with
Talan's message.

**The possible leaders are checked at the end of each run of consecutive
`ChangePartyMembers`**, not after each command
(`_cambios_del_mapa` in `tools/port/snes_convert.py`). 41 removes everyone
before putting Talan back in, in two consecutive pages, and the simulation
let Arden, Saldra and AG7 pass as leaders: three more characters in every
map of the cartridge and two goldens of the suite (`tram`, `mecanico`) with the
colours shifted. With the new rule 12 and
13 (Core and Manta) also stop being leaders in `release`, which they only were for the same reason —an
intermediate step of the test parties in map 4—; the suite didn't move any
golden.

# What was measured

**Bank 0** (`TABLAS`, the method in `AGENTS.md`): `release` from 342 B free to
**317**; `test-special` has 1041. **Bank 1**: the last symbol goes from
$01:F874 to $01:F8C1 (~1.85 KB free). **BSS** and **ZEROPAGE** unchanged.
**Cartridge**: from 2,747,611 B (65.5%) to 2,857,944 (68.1%), +110 KB, adding up
the segments of the `.dbg`.

**Lost frames**, outside the fades, in the whole scene along the
accept branch (the player never walks through these maps): 40, 34 in 3390 ticks
(the worst stretch of 10 ticks, 5); 42, 8 in 680, all at once; 43, 44 and 45, zero;
41 is always inside a fade.

**Audio.** `Kfmus5` and `tsmedit` go in with their samples and with an MSU-1 track
(100 and 204). Comparing the rates in `converter.log` against `main`,
almost nothing changes: `PCKBS50A` in `TF3_1_awe` loses its copy (15.2 -> 14.0 kHz),
`EORG268` in `Deflector1` gains one (16.4 -> 22.9), and the rest moves one or two
tenths —`evilrhys`'s cymbals from 4.6 to 4.5—. The converter doesn't know that
`Kfmus5` keeps playing from 41 to 45 —it comes from 37's page and the rule in
`temas_heredados` cuts at 41, which has its own `PlayBGM`s— so those
packages don't reserve room for it. Nobody listened to it without MSU-1: it goes with the
audio pass (`audio-after-lashe-city.md`). `just ceilings` redone: no
theme clips.

# Tests

* `tests/abl/test_playthrough_lashe_wick_golden.py`: from 37 with 151,
  the door, scene 1, the vidcasts, the video, and the favour through both
  branches: **accept** with Saldra (164, the surgeon, 267, and 41 doesn't make him
  limp) and **refuse** with Arden (162, without 164 or 267, and one point less of
  speed). It checks through RAM the transition each page leaves, the party on
  returning and the companion's comment, which turns off 163.
* `test_transition` in `tests/rpgmaker/test_commands_golden.py`: the cases
  `transition-mosaic` and `transition-zoom`, with new goldens midway through each
  ramp, and the same ones in `test_cores.py`.

The photos, without golden:

    lashe-wick-acepta   the den, the vidcasts' mosaic, the video,
                        the favour, the surgeon, back in 37
    lashe-wick-rechaza  the same without the surgeon

What they **don't** cover: the second confirmation with "No" (which also turns on
162), the branch with no companion, and the Bum in 37 with 164 (page 4).

# What taro has to look at while playing

Wick's whole scene and both branches of the favour; the mosaic when jumping
inside the vidcasts (with the hero sharp on top); the entrance to the vidcasts
with a fade where the original zooms; the security video without the "REC"; and
how `Kfmus5` and `tsmedit` sound with and without MSU-1.

# Tested

taro, on 2026-09-27, on the SNES with the FX Pak: everything worked, including the path
of selling the Idol, bribing the guard and taking AG7; the race with no lag or
bugs (the companion at the wheel, too). Separate from this is the black hero after
changing graphic in the same map (Lazer Teeth's HQ, Boss Wick).
