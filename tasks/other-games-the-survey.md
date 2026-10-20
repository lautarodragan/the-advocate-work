---
name: "Other games: the survey"
description: "Seven RM2k games besides ABL —El Dorado, Sunset Over Imdahl, The Book of Three, Dooms 2, The Frozen World, Desert Nightmare, Vampires Dawn—: a project for each one, what compiles, what breaks and a first cartridge without MSU-1, to find what they share before fixing anything"
type: research
status: done
agents: [Aguará]
assignee: taro
---

From taro, on 2026-10-05, in their words, translated:

> I left you some games in /shared/otros-juegos/. They all have
> different challenges. I'd try them without MSU first, to simplify
> everything.

Copied to local disk in `/extras/otros-juegos/`. The
seven are RM2k (none has `ldb_id` 2003). The Way Episode 1 came
as an unextracted .exe and is left for later.

## While working (Aguará, 2026-10-05)

The projects go in `/extras/otros-juegos-snes/<juego>/`, each one its own
repo; the temporaries in `/extras/scratch/aguara/`.

* **Ditto**: all seven round-trip byte for byte, after looking up
  `RPG_RT.LDB` case-insensitively (Sunset). Its own commit.
* **Setting up a project**: the first time, against "missing key", sixteen
  sections of ABL's `rm2k-snes.toml` had to be filled with neutral
  values, a `nothing.json` case and a `[cases] debug_map_entry` that doesn't
  exist. The other six came from a throwaway script that copies El Dorado's
  (`nuevo.py`): it is what a `rm2k-snes-project new` would do.
* **ABL assumptions fixed in the branch**: the mandatory debug map
  (1), the single-map cartridge (3), the System and the faces only from the
  game (5), each in its own commit.
* **The sweep**: one cartridge per map, each map alone, to see where each one
  stops. `BOOT_FRAMES` raised to 255 **only in the tree, without
  committing**, so that each map's boot doesn't hide what's behind it.
* **What blocks a whole game**: the window with more than 15 colours (Dooms2,
  Frozen World, Book of Three, Vampires Dawn), the empty party at the start
  (Sunset, Desert), BMP (Dooms2). To look behind it: a copy of the game made of
  links with the System reduced to 12 colours and the BMPs converted to PNG
  (`juegos/granja.py`), and `party = [1]`.
* **Careful with partial installs**: each binary reads the runtime from the checkout
  it was installed from (`suite::runtime`). With local `cartridge` and
  global `rm2k-snes-audio`, `BOOT_FRAMES` came from two different trees.

## Result

The study, with the table and the recommendation:
[`research/2026-10-05-other-games.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-05-other-games.html). Six of the seven build a
cartridge that starts; Vampires Dawn doesn't (the variables).

**Where each thing is** (on this machine, that's why here and not in the
study):

* the projects, each its own repo with one commit: `/extras/otros-juegos-snes/<juego>/`;
* the ROMs: `/shared/builds/other-games/<juego>.sfc`;
* the sheets, original above and cartridge below:
  `/shared/captures/2026-10-05-other-games/<juego>.png`;
* the link copies with the reduced System and the BMPs as PNG, which the
  cartridges of Book of Three, Dooms 2, Frozen World and Desert need to
  build: `/extras/scratch/aguara/juegos/<juego>/`, made with the `granja.py`
  next to them. They are built with `GAME_DIR=<copia> just cartridges`.

**What to look at**: that the beginning of Book of Three, Frozen World and Dooms 2
resembles the original, and **Desert Nightmare's background**, a mode 3
panorama that comes out as light-blue garbage: it's from the newly merged panoramas.

**Verified**: the tests of each touched crate —`ditto`, `cartridge`,
`screens`, `convert`, `wally`, `events`—, each new test seen red;
`just -f tools/justfile test`; and A Blurred Line's suite (`b28864d`→`bfe49bf`,
own clone) with these tools: 1136 green, `abl.sfc`
`27e94e67039533a2…`, same as before. The suite doesn't run any of the
seven games: what is said about them comes from the sweep and the captures.

**When merging, reinstall**: `ditto cartridge screens convert wally events`.
It doesn't touch the runtime or the RAM.
