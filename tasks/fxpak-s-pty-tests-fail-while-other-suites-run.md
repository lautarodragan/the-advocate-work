---
name: "fxpak's pty tests fail while other suites run"
description: "Several of snes/fxpak's tests/pty.rs went red at once on 2026-11-28, twice in a row on main and once on Cardón's branch —\"another fxpak is using the port\"—, while seven agents' suites ran; alone, minutes later, they passed every time"
type: bug
status: draft
author: hornero
---

**What was seen**, on 2026-11-28, all on the-advocate around `5f6d5d48`:

* Hornero's verification of main, `env -u SOUNDFONT just rust-test`: 8
  of `tests/pty.rs` red at once (`a_second_client_is_kept_out`,
  `info_reads_the_rom_firmware_and_device`, `ls_follows_continuations`,
  `nothing_is_written_outside_advocate` and four more), with six agents'
  suites running and the session's login expiring around then.
* `just crate-test fxpak` right after: 7 red.
* Minutes later, `cargo test -p fxpak --test pty` in parallel, serially,
  and `just crate-test fxpak`: green, three times.
* Cardón, on `cardon-doors`, the same hour: three of them red with
  "another fxpak is using the port" (`src/port.rs:35`, the client's
  exclusive `flock` on the tty failing), green alone.

Each test opens its own pty (`openpt` in `tests/pty.rs`, `posix_openpt`),
and the client takes `flock(LOCK_EX | LOCK_NB)` on the slave it opens
(`src/port.rs:73`), so two tests should never meet on a lock. Not
understood: whether a pts number freed by one process and reused by
another while a client of the first still holds its slave can trip the
flock, or whether it is load and a timeout surfacing as that message. Not
reproduced on purpose.

**What would show it**: running `cargo test -p fxpak --test pty` in a
loop from two or three worktrees at once, with `timeout`, until one goes
red, and reading which test and which message.
