---
name: "fxpak's pty tests share ptsname's buffer"
description: "openpt() in snes/fxpak/tests/pty.rs names each fake FX Pak with ptsname, whose buffer is static: tests running in parallel threads can read each other's name and open the same pty, which the tool then refuses as another client's"
type: bug
game: advocate
status: todo
agents: [cardon]
author: carpintero
links:
  relates: [fxpak-s-pty-tests-fail-under-load]
  found-in: [the-stages-speak-json-nobody-types]
  duplicated-by: [fxpak-s-pty-tests-fail-under-load]
---

Seen by Carpintero on 2026-11-24, running `just rust-test --no-fail-fast`
on the-advocate `carpintero-a3` (A3 of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md),
merged with main at `dedf5252`; it does not touch `snes/fxpak/`), with
three other agents building and testing at the same time.

**What happens**: seven of the thirteen tests of `snes/fxpak/tests/pty.rs`
fail. Six with `Wire("/dev/pts/1: another fxpak is using the port; two
clients would interleave their blocks")` at `client()` (line 419) —all six
naming **the same pty**—, and `put_into_a_missing_directory_is_refused_
before_the_put` on its own assertion (line 563). Run alone right after,
`cargo test -p fxpak --test pty`, all thirteen pass.

**Why it likely is**: `openpt()` (line 99) names the pty with
`libc::ptsname`, which returns a pointer to one static buffer for the whole
process; its comment says the buffer "is copied at once", but the tests run
in parallel threads, and another thread's `ptsname` can overwrite it
between the call and the copy. Two fakes then share a slave path; the
second client's `flock` finds the first one's and answers `Busy`. Under
load the window is wider. `ptsname_r`, which writes into the caller's
buffer, closes it.

It may be the same cause as
[`fxpak-s-pty-tests-fail-under-load`](fxpak-s-pty-tests-fail-under-load.md)'s
"no response to Ls in 2s": a client that opened another test's pty asks a
fake that is not answering it. That draft blames the 2 s timeout; not
checked which it is.

**How to reproduce**: `just rust-test --no-fail-fast` while other builds
fill the CPU; the name in the six messages is the tell.

## Log

### 2026-11-24, Cardón: to todo

A flaky test with its cause read in the code and its fix named: `openpt()`
still calls `libc::ptsname` (`snes/fxpak/tests/pty.rs:107`), whose static
buffer threads share; `ptsname_r` closes it. The task also runs the pty
tests under load after the fix: if the "no response to Ls in 2s" of
[`fxpak-s-pty-tests-fail-under-load`](fxpak-s-pty-tests-fail-under-load.md),
which was closed into this one, is still there, the fake's 2 s timeout
widens too.
