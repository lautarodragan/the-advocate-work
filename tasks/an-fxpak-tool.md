---
name: "A tool for the FX Pak over USB"
description: "Hornero's throwaway usb2snes client made into one of the tools: a small Rust binary in snes/ that talks to the FX Pak —info, peek, put, boot, ls—, finds it by its USB ids, and holds the rules of AGENTS.md (write only under /advocate/) in its code"
type: feature
game: advocate
status: done
author: taro
assignee: taro
agents: [Hornero, Aguará]
---

> Let's go with that!

taro, 2026-11-23, to making the FX Pak's USB client a proper tool, after
it read the ROM's copy live, uploaded 9 MB and booted a ROM in
[`a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak`](a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak.md).
The rules for using it are in "Where this runs" in `AGENTS.md`.

## Log

### 2026-11-23, Hornero: taken for Aguará

### 2026-11-23, Aguará: the crate, from the source, against a fake FX Pak

Branch `aguara-fxpak` of the-advocate, from main `0b199522`; commit
`9aea07dc`. `snes/fxpak/`, one binary, `fxpak`, in `rust_projects`;
dependencies `clap` and `libc`, both already in the lock.

#### Read in sd2snes v1.11.0

`src/usbinterface.c`, with `cdcuser.c`, `memory.h`, `memory.c`, `main.c`
and `ff.c`/`ffconf.h` around it. The layouts are as the assignment said,
and cited by line in `protocol.rs`. What else came out of it:

* **Four error paths never return**, not one. Besides the GET of a missing
  file Hornero hit today (474-477 keep a stale size, 763-770 spin on
  `f_read` of an unopened file): PUT into a directory that does not exist
  answers the error and still waits for the data (278-281), and each block
  then spins on `f_write` (297-307); a transfer of 0 bytes sends no block
  (953) and the server sits in its data state, dropping every command
  (`cdcuser.c` 419), until a disconnect; and BOOT of a missing file loads
  nothing (`memory.c` 249-253) and takes the console out of reset anyway
  (635-646). The client lists the parent before GET, PUT and BOOT, refuses
  empty transfers, and when a PUT is refused all the same it sends no data
  and closes the port: a dropped DTR is a disconnect (409-417, `cdcuser.c`
  264), which clears the wait.
* **LS**: type byte (0 dir, 1 file), NUL-ended name; 2 = the next entry
  goes on in the next block; 0xFF = end; a block filled to its last byte
  has no marker. A directory that does not open answers error 1 and a lone
  0xFF: safe.
* **INFO**: features at 6, the running ROM from 16, the FW version U32BE at
  256, the version string at 260, the device name at 324.
* **PUT has no answer at its end**; an INFO after it is one, taken only once
  the last block is in. `put` and `poke` do that.
* **RESET and MENU_RESET** are a command and a response, no file and no
  data: the main loop acts on them like a short and a long press of reset
  (`main.c` 428-436). Safe for the firmware; they cut the game like a boot,
  so they print what was running first. Not tried on the console.
* FatFs has `_FS_RPATH 2` (relative paths against a current directory),
  takes `\` as a separator, code page 1252 names: so SD paths are
  normalised here (absolute, `..` resolved and not above the root, printable
  ASCII without `\ : " * < > ? |`, no trailing dot or space) and `put`/`mkdir`
  check `/advocate/` on the result, case-blind like FAT.
* **`poke`** only below `$C00000` (the ROM's copy), behind `--write-memory`:
  above it are the menu's image, its directory/database, the cheats, the
  save RAM at `$E00000` —which the FX Pak writes back to the card's `.srm`,
  so a poke there would write outside `/advocate/`—, the WRAM copy, and the
  menu's mailboxes at `$FF0000` (`SRAM_CMD_ADDR`), where a write can make
  the MCU load a ROM.
* **BOOT also writes the card**: `cfg_add_last_game` (633), the firmware's
  own last-game list in its settings, as booting from the menu does.

#### Choices

* `put` verifies by reading back **always**, `--no-verify` to skip: at the
  FX Pak's speed it is seconds for a ROM.
* Timeouts: a response 5 s, BOOT's 60 s (it answers after loading), the
  INFO after a PUT 30 s, each wait for the next byte of a transfer 5 s. A
  transfer cut halfway is drained and reported with what to do (close the
  port; if `info` answers nothing, power off with the cable out).
* Opening the port drops whatever an earlier client left unread, and takes
  an exclusive `flock`, so two `fxpak` do not interleave; a client that
  does not flock (Hornero's script) is not kept out.
* The port is found by `/sys/class/tty/ttyACM*/device/../idVendor` and
  `idProduct` = `1209`/`5a22`; `--device` and `FXPAK_DEVICE` override; the
  error names the container case. Elsewhere than Linux, only `--device`.

#### Tests

`cargo test` in the crate: 13 unit tests (blocks, response, INFO, LS
across blocks, paths) and 13 in `tests/pty.rs`, a fake FX Pak on a pty
that answers as the source and **hangs where it hangs** —it marks itself
wedged and stops answering—. Shown red: with the listing taken out of
`get_file`, `get_reads_a_file_and_never_asks_for_a_missing_one` fails.
`tests/hardware.rs`: one test, skipped without `FXPAK_DEVICE`. `cargo
clippy --all-targets -D warnings` and `cargo fmt` clean; `just test` 29
passed. No INFO reply was in the big-DMA task's log to test against; the
INFO test builds it from the source's layout.

#### Not yet

The real FX Pak: Hornero asked to wait —they were using the port, and then
it was wedged by the missing-file GET until taro power-cycles it and
recreates the container, which ends this session—. **Nothing of `fxpak`
has run against the real device**; only against the fake.

#### The hardware run, still to do

With the console on, in the FX Pak menu, after the container is back.
Install from the branch: `just install-local .local-tools fxpak` in a
worktree of `aguara-fxpak` (or `just install fxpak` after the merge), and
from that worktree, with `F=.local-tools/bin/fxpak`. Nothing boots or
resets:

1. `$F info`: the menu's ROM, `1.11.0`, the device name. This shows the
   port was found by its USB ids, with no `--device`.
2. `$F peek 0 64` and `$F peek '$C00000' 64`, the ROM's copy and the
   menu's image; twice each, so you can see the same bytes come back.
3. `$F ls /` and `$F ls /advocate`.
4. `$F get /advocate/msu-dma-v1/msu-dma-test.sfc /root/scratch/aguara/fxpak/v1.sfc`
   then `sha1sum` it: `a5908a44…`.
5. `$F get /advocate/does-not-exist.sfc x`: refused before anything is
   sent; then `$F info` still answers. This one checks the guard against
   today's hang.
6. `$F mkdir /advocate/fxpak-test`, then `$F put <a ~1.5 KB file>
   /advocate/fxpak-test/round-trip.bin` (it reads it back), then `$F ls
   /advocate/fxpak-test`.
7. `$F put Cargo.toml /sd2snes/x`: refused, nothing sent.
8. `FXPAK_DEVICE=/dev/ttyACM0 just crate-test fxpak`: the hardware test
   does 1, 2 and 6 again on its own.

Not to run without asking: `boot`, `reset`, `menu`, `poke`.

**What to install when merging**: `just install fxpak` (new binary; no
other crate changed). ABL's suite is not needed: nothing it builds
changed.

### 2026-11-23, Hornero: done

taro closed it, with eight others:

> podemos cerrar estas, no?

(taro: "we can close these, right?")
