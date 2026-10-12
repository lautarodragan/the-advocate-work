---
name: "World 9: the celebration at the farm"
description: "The farm (127) and the grove (128) in release: the celebration fits thanks to the VRAM slot cache, and the end of the demo moves to the night of the celebration"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-03, together with the tools' slot cache
(`workflow/tasks/*/la-cache-de-ranuras.md` over there, Yaguareté): "put 127
in release if it fits". It fits.

Base: ABL `57ef34d`, tools `60097b1a`.

# Which maps, and where the demo cuts

    108 "se me hizo tarde": the exit to the farm, event 20 (382)
    127 the celebration, the autostart of 31 (383): Pierson introduces
        Talan and asks him the Question twice; those of the profession he
        chooses jump in place. The scene turns 383 off, turns 389 on and
        jumps within the map
    127 the dance (389): Isabella, 46 (390), and the exit to the grove,
        27, where Emily waits
    128 the grove: the autostart of 2, the orchestra and Pierson; returns
        to 108 with 395
    108 Emily says good night, the autostart of 47 (395) —"What a
        day."—, which jumps to Talan's house with 396: there the next day
        begins, each profession's work

**The cut is the return from the grove**: the fork of 108 replaces event
47's `Teleport` to Talan's house with the sign ("END OF THE DEMO / The
next day in Paradise is / not in the cartridge yet. / Thanks for playing!")
and the return to the title, and the exit to the farm (events 20 and 21)
goes back to being the game's. **The rule**: `below = 129`.

From 127, the pages that jump to 152 and 158 (later batches) do not
compile, like the world's doors whose destination is not there.

# What it asked of the tools

* **The slot cache**: 127 did not fit in VRAM even with the idle ones
  taking turns. Now nobody has a fixed slot: whoever comes on screen asks
  for one. See the task over there.
* **Finished routes release their place**: 127 sends eighteen different
  events walking —Pierson and the four professions of the celebration, the
  six who stroll at the dance, Emily and Radin— and the ROM has twelve
  route places. Now the cap is twelve moving at once: see
  `divergences/finished-routes-give-up-their-slot.md` over there.

# Tests

* `abl/test_granja.py`: the celebration frame by frame, choosing farmer
  —seven jump—, and every five frames that each event on screen has in
  VRAM, in its cache slot, the bytes of its pose in the cartridge
  (`arnes/cache_de_ranuras.py`). With a golden at the start, with the
  farmers in the air and at the dance.
* `abl/test_recorrido_granja_golden.py`: from 108 to the end sign and the
  title, with eleven snapshots with golden. At the dance it also checks
  that the six who stroll move: they use the route places the celebration
  left.
* `abl/test_recorrido_paradise_dia_golden.py` now ends on reaching the
  farm: its two snapshots of the sign and the title went away, and the farm
  one is new.
* `rpgmaker/test_cores.py::test_la_cache_de_ranuras`: the celebration in
  snes9x and in bsnes.
* `parches/auto/mapas/`: two new patches, 127 and 128.
* `parches/auto/musica/techos.toml`: redone with `just techos`, because the
  new themes moved the distribution of the samples and
  `test_musica_techos.py` went red.

**The red**: without uploading the pose when taking a slot, the two farm
tests fail on the first frame looked at; without finished routes releasing
their place, the playthrough fails because two of those who stroll do not
move.

# What is not done, and what looks different

* **The dancers appear one or two frames late** after the jump within the
  map: the page refresh that shows them comes after building that frame,
  and they ask for a slot on the next one. It happens with the freshly
  uploaded screen.
* **The two who dance in place** —37 and 38, with their own route and the
  "spin" animation— do not move in the ROM: the converter does not count
  them among those who walk. It is not the cache's; I did not follow it.
* The defender and the actor branches are played by no test: the suite
  chooses farmer, which is the one that makes most people jump.
* The music of 127 and 128 was not listened to.

# When merging

Tools: install `wally`, `mapdata`, `convert` and `cartridge`.

# What taro has to test

* From the town exit to the farm: the whole celebration, choosing each
  profession (the three branches make different people jump); the dance,
  talking to Isabella, and the exit with Emily; the grove, and the good
  night with the end sign.
* That nobody in the celebration appears late or with someone else's pose,
  above all on the jump to the dance.
