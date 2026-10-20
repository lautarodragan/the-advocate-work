---
name: "Talan black with DummyHero as leader"
description: "an actor without a graphic uploaded fifteen zero colours to sprite palette 0; in the barrel on 14 and in Wick's hideout that palette was Talan's"
type: bug
status: done
assignee: taro
---

Reported by taro playing on the SNES on 2026-09-27. **It happened in `release`.**
Fixed in the commit that moves this task to `testing/`.

# The report

taro's report, in their words, translated:

> in Boss Wick's house, after watching the vidcasts, Talan turns
> completely black. Something similar already happened before: in the Lazer Teeth HQ,
> when Talan is hidden in the barrel [...] Talan appears without the barrel
> (up to here, all OK), but Talan turns completely black. In both cases
> a map change seems to restore him to normal.

# What was measured

**It is not the graphic change.** The suspicion was that a graphic change on
the same map uploaded the tiles and not the palette. In both scenes Talan **is not
the hero**: he is an event with `Future1:0` —event 4 of map 14 (NV Get Talan to
Work, the barrel scene) takes it with order 34 of a route; event 8 of
map 40, `TalanProxy`, brings it on its page— and the hero is `DummyHero`,
actor 10, which the game makes leader in those cutscenes: page 2 of the
hotplate removes Talan before going to 14, and the `Security Footage` (map 45)
sets 10 before going back to 40.

`DummyHero` does not have a single opaque pixel. The converter gives it in the
actor table palette 0 and fifteen colours at zero, with the comment "the ROM does not
upload them" (`5264eada`, 2026-09-07). **The ROM did upload them**:
`elegir_grafico_heroe` pointed `hero_cgram` at those colours for any
actor it found, and `aplicar_tinte` copied them to sprite palette 0
when loading the map. Palette 0 is that of the first graphic the
converter allocates, and on both maps it is that of `Future1:0`.

The dump of `cgram_sombra` at the moment of each scene, before the
fix —palette 0 all at zero, and Talan's sprite in the OAM with
palette 0—:

    map 14, Talan leaves the barrel  grupo=10 hero_pal=0  obj pal 0: 0000 x16
    map 40, the favour and surgeon   grupo=10 hero_pal=0  obj pal 0: 0000 x16

And "a map change fixes it" is because in both cases the next map
loads with Talan as leader: 14 puts him in the party before going to 16 and
41 rebuilds the party.

**It happened on every map of the game**: with `DummyHero` as leader, the 66
maps of `MAPAS_DEL_JUEGO` loaded palette 0 in black. It is measured by
`test_leader_without_graphic.py`: 66 reds with the old code, 0 with the
new. What looked black on each one depends on who uses palette 0.

Where the game gets with `DummyHero` leading —pages that set 10, and
the maps they jump to afterwards—, with a throwaway script over `data/`:

    set 10          4, 12, 18, 26, 33, 37, 38, 40, 45, 47, 48, 81, 84
    reached so      4, 5, 14, 20, 36, 40, 66, 82

# The fix

`elegir_grafico_heroe` turns off `hero_cgram` when the actor has no graphic,
recognised by the same sentinel `place_hero` looks at (the first pose at
`$FFFF`). It is what the converter's comment and that of `hero_cgram` in
`pagina_cero.s` already said happened.

# What is left, similar and different

**An event that order 34 changes to the graphic of a possible leader, without
that graphic being on any page of the map, shares the leader's slot**
—`npcs_dibujables` only gives its own palette to the leaders that appear as NPCs
on some page—. It is drawn with the colours of whoever leads. It does not turn
black (with the fix, with `DummyHero` leading the slot keeps the
cartridge's colours, which are those of the first leader), but with another leader who
is not the graphic's it would look with someone else's colours. In `release`:

    14  NV Get Talan to Work   ev4  -> Future1:0 (Talan)    6 palettes of 8
    76  Sorbe Mountain         ev5  -> AG717:4 (AG7-17)     7 palettes of 8
    81  Dr. Vago's House       ev2  -> Future1:0 (Talan)    Talan leads: fine
    83  Dalia at the Factory   ev13 -> Future1:5 (Kersh)    8 palettes of 8

It was not touched: fixing it means giving them their own palette in the converter, and 83 already
uses all eight, so there someone would end up drawn with a borrowed one. If
taro sees the Agency captain on 83 or AG7-17 on 76 with odd
colours, this is it.

# What taro has to test

1. The barrel scene: Talan comes out of the barrel with his colours.
2. Wick's hideout, after the vidcasts: Talan (the event) with his
   colours in Wick's room and in the surgeon's.
