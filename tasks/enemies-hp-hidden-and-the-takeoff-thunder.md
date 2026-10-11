---
name: "The enemies' HP hidden, and the takeoff's thunder"
description: "Hide the enemies' HP like RM2k (with a flag for debugging) and record the battle theme with and without Thunder9 so taro can decide"
type: feature
status: done
assignee: Ombú
---

Two small battle things, from 2026-09-28.

**The enemies' HP.** RM2k never shows it and ABL has no way to see it (Tero
measured it: `menu-like-rm2k.md`). taro accepted the proposal: hide it by
default with a build flag, `CON_HP_DE_ENEMIGOS = False` in `cartuchos.py`,
like `CON_MAPA_DE_DEBUG`. Today `ba_renglon` in `rom/src/batalla.s` draws it;
in `pantallas.py` it's noted as our own decision.

**The takeoff's thunder.** The turn-1 page of troops 102 and 104 asks for
Thunder9, and it doesn't play because putting it in the battle package lowers
six instruments of the battle theme from ~14 to ~11.5 kHz and BRASS64 from
16.3 to 10.8 (Ceibo measured it: `release-troop-events.md`). It's
decided by listening.

2026-09-28, in `testing/`: done by Ombú on his branch, on `main` at 8da66c4,
in e15fd72; `just cartuchos` and `just pruebas` green. What's left is
taro's: look at the goldens and listen to the thunder (see below).

# The enemies' HP — done

As Tero proposed: `CON_HP_DE_ENEMIGOS = False` in
`tools/ensamblado/cartuchos.py`, next to `CON_MAPA_DE_DEBUG`, which passes
`--hp-de-enemigos` to the converter **in both cartridges**; the converter
emits `BA_HP_ENEMIGOS` next to `BA_HP_NUM_DX`, and `ba_renglon`
(`rom/src/batalla.s`) cuts after the name if the row isn't the party's. In
`pantallas.py` there's no reference that draws the battle, only the geometry
and the decision written above `BA_ENEMIGO_FILA0`: it was rewritten.

A `ca65` trap that cost a build: inside a `.proc`, `.if BA_HP_ENEMIGOS = 0`
gives "Constant expression expected" even though the constant is defined
earlier; with `::BA_HP_ENEMIGOS` it works. It's commented there.

**With the flag on the ROM is the one from before, byte for byte**: building
a separate `release` with `--hp-de-enemigos` and assembling 8da66c4's
`rom/src/` against its same `mapdata.inc`, both `.sfc` come out identical
(`cmp`). `just pruebas` doesn't run that path: the suite runs with the flag
off.

**Nine goldens change**, and in all of them the only difference is the
rectangle x 145-191 of the enemy rows: `batalla`, `batalla-blanco`,
`batalla-droide`, `batalla-textos-lejos`, `encuentro`, `msu-datos-rom`,
`msu-datos-msu`, `msu-mundo-rom` and `msu-mundo-msu`. Before and after, side
by side, in `/shared/capturas/2026-09-28-hp-de-enemigos/`.

**No test read an enemy's HP on the screen** except those goldens, and none of
them shows a hit: all are the battle just opened or picking a target, with
the HP full. The ones that look at how much an enemy has left already read it
from RAM (`Pelea.hp_del_combatiente`), so there was nothing to move from the
screen to RAM.

# The thunder — recorded, so taro can decide

Nothing in `main`. Built separately, with a converter wrapper that adds
`Thunder9` to `SE_DE_TROPA_AL_PAQUETE` without touching the source; the
control (the same wrapper without adding it) comes out byte for byte
identical to `release`. The wavs and what to listen for in each one, in
`/shared/audio/2026-09-28-trueno/` (`LEEME.txt`).

What was measured, comparing the allocation lines of `conversor.log`:

- **at 6000 Hz**, the rate Thunder9 already has in maps 3, 20 and 32:
  BRASS64 from 16.3 to 10.8 kHz —only the battle theme uses it— and thirteen
  more of `T_VGFighterMAX_Masako` from 13.6-14.1 to 11.5-11.7: five programs
  (DSTGT48, NYLON48A, FANTA81, STLGT57B, STRNG71B) and **eight from the drum
  kit**, which Ceibo's count didn't include.
- **with MSU-1** the theme loses nothing, but the quality sound effects of
  the battle package in the `.msu` go down from 14000 to 12000 Hz: the seven
  that were already there, plus the thunder.
- **without lowering anything it doesn't fit**: the battle package has 896 B
  free and the thunder takes 6462 B at 6000 Hz, 5382 at 5000, 4302 at 4000
  and 3231 at 3000. At all four rates BRASS64 drops to 10.8 just the same,
  and the other thirteen drop less the lower the rate (at 3000:
  12.6-13.0). Fitting in 896 B would require about 800 Hz. Sharing: no
  battle sound effect uses that sample.
- **in passing**: Thunder9 at 3000 Hz everywhere raises nine instruments of
  `evilrhys`, on map 3, from 4.5-5.2 to 6.5-6.8 kHz, because map 3 today pays
  for the thunder at 6000.

What's left is taro's: listen and say whether it goes in, and at what rate.
If it does, it's adding `"Thunder9"` to `SE_DE_TROPA_AL_PAQUETE` (and, for a
different rate only in the battle, an alias like `Thunder9@entero`), redoing
`just techos`, and `test_el_despegue_pide_su_efecto` stops saying "no
suena".

# Numbers used

None: neither opcode 0x34 nor far RAM `$7E7A30`-`$7E7A3F`.

# What taro decided

On 2026-09-28, after listening to the eight recordings: the thunder goes in
at 6000 Hz (`SE_DE_TROPA_AL_PAQUETE`), with what it costs the battle theme
and the battle's quality sound effects.
