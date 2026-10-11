---
name: "The fingerprint: the game's files, the .zip and --force"
description: "The game's resources go into the fingerprint by content; the game and the RTP can be a .zip, unpacked into the cache and into the fingerprint by content; the RTP as a directory and the SoundFont, by their path; and a --force"
type: feature
status: testing
assignee: taro
agents: [Cardón]
---

It follows from `dump-outside-the-cartridges-fingerprint.md`: with Sunset's ChipSet retouched, `just cartuchos` says "up to date" and the ROM stays stale.

taro's decision, on 2026-10-11: don't hash the RTP or the SoundFont; at most invalidate if the path changes, or a `--force` to use by hand if they are modified (it should never happen). He considered an RTP in `.zip` validated by path, date and size, without making up his mind. Hornero chose: the path of the RTP and the SoundFont in the fingerprint, a `--force`, and the game files the converter reads, by content —those do change if the game is retouched—. taro can adjust it.

## Change of brief, on 2026-10-11

taro, a while later: "If the zip thing wouldn't be very complicated, maybe I'd think about using .zip for the games too. That forces us a bit not to modify them, but always to use the patch system." So: first measure whether asset reading —game, then RTP— goes or can go through a single place; if so, `GAME_DIR` and `RTP_DIR` as `.zip`, with the fingerprint by the `.zip`'s content —or path, size and date, if hashing it is heavy—, the SoundFont by its path and `--force`; if not, the plan above and the measurement for taro to decide.

## The plan (Cardón, 2026-10-11)

Base: `the-advocate` `main` 6f933ff8 and ports `main` b499ab4, branches `cardon-huella-del-juego` in `~/scratch/cardon/`.

* **What it reads from the game.** The readers are three lookup functions in three crates —the converter's `resources::find`, `rm2k-render`'s `find_resource` (Wally, the screens) and `rm2k-snes-audio`'s— plus a couple of paths built by hand, and they run in different processes. Having each one record what it opens means touching five crates and a channel between processes, and a reader that forgets to record is the same road to a stale ROM. What goes in, then, is **what they can read**: the game's files with the extensions they accept —`.png`, `.bmp`, `.xyz`, `.mid`, `.wav`—, in any folder. Left out are the `.lmu`, `.ldb` and `.lmt` (they arrive through the dump), the `.lsd` saves —which change every time someone plays the original with Wine—, the executable, the `.ini`, the `.txt`, the `.mp3`/`.ogg` and the videos. A PNG the game carries and doesn't use goes in anyway: retouching it rebuilds unnecessarily, which is cheap and doesn't happen.
* **The names too**: each game file goes in with its path relative to the game, because renaming a resource changes which one is found.
* **RTP and SoundFont, by their path**, in the fingerprint. The MSU-1 tracks already hash the SoundFont by content (`midi_key`), so with them nothing is needed.
* **`--force`** in `rm2k-snes-cartridges`: it builds the named ones —or all— without looking at the seal. The `cartuchos` recipes already pass `{{args}}`, so `just cartuchos --force` comes out without touching them.
* **Who else reads the fingerprint**: `rm2k-snes-space` and the harness's `--list --json`. Both now receive the same machine flags as the one that builds: `rm2k-snes-space` accepts those of `rm2k-snes-cartridges`, and the `espacio` recipes and `cartuchos.py` pass them on.

Measured before the change, with the global ones: `--list --json` takes ~79 ms in ABL and ~22 ms in Sunset.

## Done, first part (the plan above)

`the-advocate` `bd6fc5a5` (cartridge), ports `cd3c891` (the `espacio` recipes, the `cartuchos` comment and `cartuchos.py`), book `887679c` (`internals/pipeline.md`, "When a cartridge is rebuilt"). The fingerprint test, red without the fix (`cartridges.rs:331` and `:349`), green with it. A Blurred Line's suite with the branch's `cartridge`: **1177 passed**, `abl.sfc` = `24dd24adb52f…`, `main`'s.

The cost, `--list --json` three times warm, before → after: ABL 79 → 90 ms (559 game files, 15 MB), Sunset 22 → 27 ms (298, 7.8 MB), Vampires Dawn 63 → 99 ms (1838, 39 MB). No cache is needed.

## The `.zip` (Hornero, at taro's request, 2026-10-11)

taro: "maybe I'd think about using .zip for the games too. That forces us a bit not to modify them, but always to use the patch system". Step 1: is there a single place that resolves an asset?

**Today there isn't one: there are three resolvers and several loose readers**, in different processes:

* the converter's `resources::find` (ChipSet, System, Title, GameOver, Backdrop, Monster, Picture, the animations), `rm2k-render`'s `find_resource` (Wally, the screens, `rm2k-render`), and `rm2k-snes-audio`'s (Music, Sound, plus a listing of names);
* paths built by hand: `maps.rs:241` (System loose at the root), `convert.rs:742`, `screens/game.rs:122`, `custom_menu.rs:954`, and the `read_dir` of `game_map_ids`;
* what is resolved is consumed as a **path**: each crate's `image`, the stages that run in another process with `--game-dir`/`--search-dir`, and external programs —`fluidsynth` and `ffmpeg` receive the MIDI and the WAV as a file—;
* outside Rust: `ditto unpack "$GAME_DIR"` and `datos-vuelta` in the recipes of the eight games, and ABL's harness —`resources.py` and `lcf` over the `.lmu`/`.ldb`—, all through `lugares.JUEGO`.

Reading **inside** the `.zip` in each of them means touching half the tree. But **a single place can be built** if the `.zip` is resolved to a directory before anyone reads: every binary that receives the machine's `--game-dir`/`--rtp-dir` reads it through `Environment` (`rm2k-project`), and the stages get it from the converter already resolved. If `Environment` swaps a `.zip` for its unpacked copy in the project's cache —once per `.zip`, keyed by the `.zip`—, none of the seventeen notices. What doesn't go through there —the Python harness and the `datos` recipes— asks `rm2k-snes-project` for the path, which is already who the harness asks for the rest.

**It was put together, and implemented** (Cardón, 2026-10-11):

* `rm2k-project` has `archive.rs` —a small `.zip` reader: stored and deflate with `flate2`, which was already in the lock; without ZIP64, with CRC, and refusing to write outside— and `Environment::unpack(&project)`: if `game_dir` or `rtp_dir` is a `.zip`, it unpacks it once into `zip/` in the project's cache, named `<zip>-<sha256 of the .zip>`, writing separately and renaming (the tests ask for it from several processes at once), and from there on the value is that directory, also in `as_flags`. **If a tool doesn't call `unpack` and gets a `.zip`, `game()`/`rtp()` give an error**: a lookup that finds nothing in the game falls back to the RTP without warning.
* It is called by the four that read the machine: `Cartridges::load` (and with that `rm2k-snes-cartridges` and `rm2k-snes-space`), the converter (`convert.rs` and `queries.rs`) and `rm2k-snes-msu`. The stages receive the directory from the converter; `rm2k-snes-volume-ceilings` only passes the flags on to the others.
* `rm2k-snes-project --game-dir X --unpacked game_dir` prints which directory to read from: it is used by the `datos` and `datos-vuelta` recipes of the eight games (Ditto reads a directory) and the harness's `lugares.py` (`JUEGO_LEIDO`, `RTP_LEIDO`, used by `resources.py` and `hoja.py`). The harness keeps passing the value as is to the tools, so that their fingerprint is the same as the builder's.
* **A `.zip`'s fingerprint is its content** —measured with `sha256sum`, warm: VD 64 MB in 48 ms, ABL 9 MB, the RTP 11 MB in 9 ms; path+size+date isn't needed—. A game in `.zip` goes in as the `.zip` alone; an RTP in `.zip`, also by content, and as a directory it still goes by its path. The SoundFont, by its path. `--force` stays.
* **The directory still works**, with the previous fingerprint (the resources by content). I keep it: the original with Wine needs the game unpacked, and measuring with a retouched copy —as Mulita did with the dump, or I did with Sunset's ChipSet— is easier with a directory. Requiring `.zip` wouldn't buy anything the fingerprint doesn't already cover. What enforces "don't touch the game" is pointing `maquina.just` at the `.zip` files.
* The nine `.zip` files are in `~/scratch/cardon/zips/` (`<port>.zip` and `rtp.zip`), with the files at the root and the folders as entries of their own —so an empty one comes back too, `Movie`—, built with `~/scratch/cardon/huella2/zipear.py`. **Without the `.git` that `~/juegos/abl-rm` has inside**: it isn't the game's.

### What was measured with the `.zip` files

* **The ROMs, byte for byte.** In the six ports that build on `main` —Sunset, El Dorado, Book of Three, Frozen World, Dooms 2, Desert Nightmare— the same ROM fingerprint with the global tools and the directory, with the branch's tools and the directory, and with the branch's and the two `.zip` files; the second time, "up to date", and `just espacio` works with the `.zip`. **Vampires Dawn doesn't build on `main`** (map 15 can't carry the message window, with the global tools as well): with the directory and with the `.zip` it stops in the same place with the same `conversor.log`, 256 lines. ABL: the suite with the two `.zip` files, **1177 passed** and `abl.sfc` = `24dd24adb52f…`; with the directory, too. Script: `~/scratch/cardon/huella2/zip-vs-dir.sh`; log, `zip-vs-dir2.log`.
* **`just datos` with the `.zip`** gives the committed `data/` in all eight, and in ABL `datos-vuelta` gives 330 of 330 equal. Each unpacked copy is equal to its original with `diff -r` (without `abl-rm`'s `.git`), the RTP included.
* **The cost.** The fingerprint, `--list --json` warm: ABL 85 ms with the `.zip` and 95 with the directory; VD 108 ms with the `.zip` and 99 with the directory; Sunset 27 in both. With the `.zip` it is read once: the fingerprint uses the hash `unpack` already took (before that, VD gave 156 ms). Unpacking VD the first time, 249 ms; afterwards, 48.
* **By hand in Sunset**, with a copy of the game (`~/scratch/cardon/huella2/a-mano.sh`, log `a-mano.log`): rewriting a `.lsd` save doesn't rebuild; retouching the ChipSet rebuilds —the middle pixel falls on a tile that isn't used, and the ROM comes out the same, `2175c7f9…`—; the RTP via another path rebuilds, and going back too; `--force` rebuilds without touching anything; the `.zip` of the retouched copy rebuilds, the second time "up to date", and the `.zip` rebuilt from the original rebuilds and gives the usual ROM. The check alone, with nothing to build: 31 ms with the directory, 38 with the `.zip`.
* **What the suite wasn't seeing**: with the `.zip` files, the first run gave 7 reds and an error. The music and MSU ones run `rm2k-snes-audio` on its own with `banderas("juego")`, which passed it the `.zip`, and `test_hover_tram.py` opened the PNG from `os.environ["GAME_DIR"]`. Fixed: `banderas` gives the unpacked directories, and only `cartuchos.py` passes the values as is.

## Result

Branches `cardon-huella-del-juego`:

* `the-advocate` (`bd6fc5a5`, `e1946ac1`, `921bf73b`): the fingerprint with the game's resources, the RTP and the SoundFont by path, `--force`; `rm2k-project` with `archive.rs` and `Environment::unpack`, `--unpacked`; the converter, `rm2k-snes-msu` and the cartridges call `unpack`.
* ports (`cd3c891`, `050c3a3`, with `main` merged): the `espacio`, `datos` and `datos-vuelta` recipes of the eight, and ABL's harness.
* book (`887679c`, `74c0e05`, with `main` merged): "When a cartridge is rebuilt" and "A game or an RTP as a `.zip`" in `internals/pipeline.md`; a line in `ports/README.md` and in ABL's.

**When merging, reinstall** `just install cartridge convert patches project rm2k-snes-audio`: `project` changes all the binaries that compile it in, and the others don't use it.

**To move to the `.zip` files**: move `~/scratch/cardon/zips/` where it belongs and point `maquina.just` (`juegos`, `RTP_DIR`) and each `justfile`'s `GAME_DIR` at `<port>.zip` and `rtp.zip`. Wine keeps the directory in `~/juegos`.

**What the suite doesn't cover**: the suite runs with whatever `maquina.just` says, so until it points at the `.zip` files the `.zip` path is exercised only by `rm2k-project`'s tests and the hand runs above. The rebuild because of a change in the game, in the RTP or with `--force` was measured by hand in Sunset; the suite builds from a game that doesn't change. ABL's run with the directory was before the last change to `cartridge` (reading the `.zip` only once), which only touches the `.zip` path; the `.zip` one, after. The old copies in `build/cache/zip/` aren't deleted by themselves: each distinct `.zip` leaves its own.
