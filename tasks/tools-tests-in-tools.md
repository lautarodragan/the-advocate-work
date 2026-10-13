---
name: "The tools' tests, in tools/"
description: "The tests that do not need the game move to tools/pruebas/; Ditto's stop falling back on ABL's game, and ABL checks its round trip with the ditto in the PATH"
type: refactor
status: done
assignee: taro
---

It comes from what `tools-justfile.md` left open
(Espinillo). taro asked on 2026-09-29 for Hornero to decide what was open and make
a first version without waiting for him. What was decided:

- **The tests that need neither the game nor a ROM go to `tools/pruebas/`**,
  with a `tools/pytest.ini` of its own and a recipe `pruebas` in `tools/justfile`.
  They are in Spanish, like the Python of `tools/`: they get translated all together.
- **`ditto-pruebas` and `ditto-vuelta-entera` require `DITTO_CORPUS`** and do not
  fall back on `ABL_GAME_DIR`: the tools know about no game. Without the
  variable, the ones that need a corpus are skipped, as they already are.
- **ABL checks that its game does the round trip** with a recipe of its own
  that uses the `ditto` executable in the PATH (`unpack` and `pack`), without compiling
  anything.

## What was done (Chañar)

The criterion, applied test by test while reading them: what moves is what does not read
`GAME_DIR` or the RTP, nor `data/`, nor `patches/`, nor a built cartridge, nor the
suite. Reading the engine (`rom/src/`) does not count, because it travels with the
tools; nor does the SoundFont, which is converter material.

### What moved to `tools/pruebas/`

**Whole, with `git mv` and without touching their insides:** `test_escapes`,
`test_temas_heredados`, `test_sustituciones`, `test_musica_stream` and
`test_repartos`. The last two still build their `sys.path` by hand: it is superfluous,
but harmless, and touching it complicated the merge.

**Split**, with `git mv` of the file to `tools/` —the biggest part— and what
needs the game to a new file in `tests/tooling/`:

* `test_protocolo`: the two that read the cartridges and `GAME_DIR` stay in
  `test_protocol_against_the_game.py`.
* `test_textos`: the two that read `data/` stay in `test_game_texts.py`.
* `test_ensamblar`: the `cartridges.py` part —the fingerprint, the `.dbg` of each
  cartridge, which one each case goes to, the list of `release`— stays in
  `test_cartridges.py`. `cartridges.py` has ABL's data and its destination
  is open, so its tests stay with the game.
* `test_banks`: the one that reads the cartridge's symbol table stays with the
  same name, because `rom/src/banco1.s` cites it by that name.

**For whoever merges with Lapacho:** the files that moved and the new ones
import `port.eventos`, `port.ventana`, `port.textos`, `port.snes_convert`,
`port.event_opcodes`, `rpgmaker.lcf`, `render.render_map.GAME_DIR`,
`ensamblado.*` and `audio.*`. Git follows the rename of the ones that moved
whole and of `test_protocolo`, `test_textos` and `test_ensamblar` (the latter
it sees as a rename to `test_cartridges.py`, by similarity); the four new files
in `tests/tooling/` nobody follows: if Lapacho changed
imports there, they have to be carried over by hand. With a grep of the modules he moved
over `tools/pruebas/` and `tests/tooling/`.

### What did not move, and why

* `test_lz2`, `test_space`, `test_wram_reservations`, `test_patches`:
  they read built cartridges.
* `test_encounters`, `test_pages`, `test_baked`, `test_flash_palette`,
  `test_timer_palette`: they read the game (`GAME_DIR`).
* `test_leaders`: uses `datos.DEMO`, from the harness, and the converter over those maps.
* `test_fork_maps`: reads `data/` and `patches/manual/`.
* `test_index`, `test_abl_side`: they belong to ABL.
* From `tests/rpgmaker/`, none: they all run the ROM (`partida`) or read the
  game. The closest one was `test_music_allocation`, which does not run a ROM
  but builds `escape_newyork`, a theme from the game. `test_items` has a case
  without a ROM that reads the game's LDB.

### What came out extra

* **The cartridges' fingerprint read `tools/*/*.py`**, so the tests in
  `tools/pruebas/` made all the cartridges stale when edited. They are
  taken out of the fingerprint, in their own commit.
* **`tools/pruebas/` has its index and its index test.** Extending the one in
  the root would make it name `tools/` from ABL's side, which is what
  `test_abl_side` forbids.
* **`ABL_SOUNDFONT`**: `test_musica_stream` reads the SoundFont from that
  variable, which has ABL's name even though it is converter material. It was not
  touched.

### Ditto and `datos-vuelta`

* `ditto-pruebas` uses only `DITTO_CORPUS`; without the variable, the ones that
  need it are skipped (read in `tools/ditto/tests/common/mod.rs`, without
  compiling). `ditto-vuelta-entera` refuses without it.
* `just dump-round-trip`, in the root: with the `ditto` in the PATH, `unpack` and
  `pack`, and `cmp` of each `.lmu`/`.ldb`/`.lmt`. Run once: **330
  byte-for-byte identical, 0 different, in 2 s.** The "different" or
  "missing" path was not exercised.

### Verified

On `main` at `6072e21e`, which did not move while this lasted:

* **Before:** `just tests`, 973 cases.
* **After:** `just tests`, 866 pass, in one minute; `just -f
  tools/justfile pruebas`, 109 pass, in half a second. 866 + 109 = 975: the
  973 from before, since the splits do not change the count because each case
  goes whole to one side or the other, plus the two of the new index test.
* `abl.sfc` rebuilt with the same sha256 as before (`7a3c6483…`): the fingerprint
  changed, the ROM did not.
* `test_abl_side`: the list of exceptions went down by five
  (`test_musica_stream`, `test_repartos`, `test_temas_heredados`,
  `test_protocolo`, `test_ensamblar`).

**What was not run:** `ditto-pruebas`, `ditto-vuelta-entera` and no
`cargo test` (only `--dry-run`, and `ditto-vuelta-entera` without the variable, which
refuses before reaching cargo). Nor the host.
