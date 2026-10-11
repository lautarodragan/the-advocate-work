---
name: "The dump, outside the cartridges' fingerprint"
description: "just cartuchos said 'up to date' with Sunset's data/maps/Map0022.json edited by hand: the dump isn't in the fingerprint, on purpose; it remains to confirm that a change in the original game does rebuild"
type: chore
status: testing
assignee: taro
agents: [Hornero, Cardón]
---

Seen by Mulita on 2026-10-11 (`sunset-el-mapa-22-en-negro.md`): for the cartridge to notice an edited `Map0022.json` she had to delete its directory.

It's intentional: `fingerprint_files`, in `rm2k-snes/cartridge/src/cartridges.rs` of `the-advocate`, says "The game's dump does not: it is regenerated from the game". What hasn't been looked at is the other half: whether a change in `GAME_DIR` —a new `.lmu` from the game— regenerates the dump and rebuilds, or whether it also goes stale without warning. If it's the latter, it's a path to a stale ROM that no test sees. And if editing the dump by hand is a legitimate way to measure —Mulita used it to isolate a cause—, the recipe should say so or see it.

## What was measured (Cardón, 2026-10-11)

Nobody regenerates the dump on their own: `data/` is committed and rewritten by each game's `datos` recipe, by hand. So the answer is "it goes stale", in two steps. Measured in Sunset, in a worktree of the ports, with a copy of the game in `~/scratch/cardon/huella/juego` as `GAME_DIR` and `release` built with the global tools of 70d4348a (scripts `medir.sh` and `activos.sh` in that folder; the logs, `antes.log` and `despues.log`):

| step | `just cartuchos release` | ROM |
|---|---|---|
| built from scratch | built | `54ceac6f9556b0a8` |
| Map0039.lmu with one tile changed (5092 -> 5001) | up to date | `54ceac6f…` |
| `just datos` with that game: `data/maps/Map0039.tiles` changes | **up to date** | `54ceac6f…` (stale) |
| from scratch, with that `data/` | built | `c6f43b98638ad200` |
| the game's whole ChipSet retouched, `data/` the same | **up to date** | `c6f43b98…` (stale) |
| from scratch, with that ChipSet | built | `41b52b748ba44dcd` |

* The `.lmu` alone doesn't change the ROM, and that's fine: the port reads the dump, not the `.lmu` (`data/README.md` of each game). The change arrives with `just datos`, and there it went stale without warning.
* **Editing the dump by hand is the same path**: a `data/` different from the one that built the ROM. What Mulita did is legitimate —the dump is text on purpose—, so the recipe has to **see it**, not say it.
* What the converter reads from the original game itself —PNG, MIDI— isn't in the fingerprint either, and goes stale just the same (the last row). The RTP and the SoundFont, the same, unmeasured.

## What was done

`the-advocate`, branch `cardon-errores-y-huella`, commit "Cartuchos: el volcado entra en la huella": `fingerprint_files` adds all of `data/`, and its comment now says what stays out and why. The test `everything_that_builds_the_rom_is_in_the_fingerprint` asks for `data/maps.json` and `data/ditto.json`; red without the fix (`cartridges.rs:307`), green with it.

With the fix, the same run: after `just datos` the cartridge rebuilds on its own and gives `c6f43b98…`, same as from scratch; restoring `data/` with `git checkout` rebuilds it to `54ceac6f…`, the previous one. Sunset's ROM with the branch's tools is `54ceac6f…`, same as with the global ones.

**The original game part wasn't fixed**: putting it in the fingerprint requires `--game-dir` in the ones that only read it —`rm2k-snes-space` (`just espacio` doesn't pass it) and the `--list --json` of ABL's harness—, which otherwise would see every cartridge as stale. The original game isn't edited, and when it really changes what changes is the `.lmu`, which arrives through the dump. It's stated in the comment of `fingerprint_files`; if taro wants it, it's a separate task, touching both repos.

## Result

Branch `cardon-errores-y-huella` of `the-advocate` (with both tasks, and `tijereta-sonidos-de-una-cancion` merged); there are no commits in the ports. With the branch's tools first in the PATH (`convert`, `mapdata`, `rm2k-snes-audio`, `cartridge`), in a worktree of the ports with `main` 4072372: ABL's suite gives 1176 passed, and `abl.sfc` = `ea49ff07fd9d…`, the same as `main` with Tijereta's work. `just test` and the tests of the four crates, green.

On merging, reinstall: `just install convert mapdata rm2k-snes-audio cartridge`.

What the suite doesn't cover: any error message —no ABL test stops a cartridge—; they were seen by hand in Dooms 2 and Vampires Dawn. And the fingerprint: the suite builds from a `data/` that doesn't change; the rebuild was measured by hand in Sunset.
