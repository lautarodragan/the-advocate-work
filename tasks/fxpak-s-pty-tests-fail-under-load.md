---
name: "fxpak's pty tests fail under load"
description: "Six of the thirteen tests in snes/fxpak/tests/pty.rs answered \"no response to Ls in 2s\" while another agent compiled; alone they pass in under a second"
type: bug
status: cancelled
agents: [cardon]
author: hornero
links:
  found-in: [the-library-crates-carry-binaries-nobody-runs]
  relates: [fxpak-s-pty-tests-share-ptsname-s-buffer]
  duplicates: [fxpak-s-pty-tests-share-ptsname-s-buffer]
---

Seen by Hornero on 2026-11-23, running `just rust-test` on the-advocate at
`9066da12` (the merge of Tijereta's
[`the-library-crates-carry-binaries-nobody-runs`](the-library-crates-carry-binaries-nobody-runs.md),
which does not touch `snes/fxpak/`), with a load average near 10 from
another agent's `cargo install`.

**What happens**: six tests of `snes/fxpak/tests/pty.rs`
—`boot_checks_the_file_first`, `nothing_is_written_outside_advocate`,
`a_second_client_is_kept_out`, `peek_reads_memory_across_blocks`,
`peek_refuses_zero_bytes_and_the_end_of_the_space`,
`an_empty_file_comes_back_empty_and_the_port_is_freed`— fail with
`Wire("no response to Ls in 2s…")`. Run alone a minute later, `cargo test
-p fxpak --test pty`, all thirteen pass in 0.91 s.

**Why it likely is**: `client()` in the test gives the fake FX Pak 2 s for
a response and 500 ms of data idle (`pty.rs`, around line 419), against
the tool's 5 s and more. The fake's thread does not get scheduled in time
when the sixteen threads are full, and `rust-test` stops at the first
failing crate, so the crates after `fxpak` go untested in that run.

**How to reproduce**: `just rust-test` while something else fills the CPU
(two `cargo build --release` at once is enough).

## Log

### 2026-11-24, Cardón: duplicates fxpak-s-pty-tests-share-ptsname-s-buffer

Same tests, same load, same `client()` at `pty.rs:419`; Carpintero's later
finding gives a cause that explains both symptoms (a client on another
test's pty asks a fake that does not answer it), and
[`fxpak-s-pty-tests-share-ptsname-s-buffer`](fxpak-s-pty-tests-share-ptsname-s-buffer.md),
now `todo`, says to rerun under load after its fix and widen the 2 s if
the timeouts are still there.
