---
name: "The cached .dbg test sees a date move"
description: "a_cached_object_gives_the_dbg_a_fresh_one_gives failed once: the fresh build's .dbg gave mapdata.inc a modification time one second later than the cached one's, though the test writes the file once"
type: bug
game: advocate
status: todo
author: hornero
agents: [cardon]
links:
  relates: [a-conversion-cache-shared-by-the-worktrees]
---

Seen by Hornero on 2026-11-23, running `just rust-test` on the-advocate at
`9066da12`, with a load average near 10. The test is Hurón's, from
[`a-conversion-cache-shared-by-the-worktrees`](a-conversion-cache-shared-by-the-worktrees.md);
run alone right after (`cargo test -p rm2k-snes-cartridge --test
assemble`), it passes.

**What happens**: `rm2k-snes/cartridge/tests/assemble.rs:241`,
`assert_eq!(files(&dbgs[1]), files(&dbgs[2]))`, fails on the `file` record
of `mapdata.inc` alone:

    left  (cached): …mapdata.inc",size=22,mtime=0x6B048B6A,mod=0
    right (fresh):  …mapdata.inc",size=22,mtime=0x6B048B6B,mod=0

The test writes side two's files once, when its directory does not exist,
and only side one's get a fixed date; so between the cached assembly and
the fresh one, either something rewrites `mapdata.inc`, or the two read
its date at different moments of a write that crossed a second. Which one
is the question: if `assemble` touches `mapdata.inc` or the cache rewrite
takes the date before it settles, it is a bug of the rewrite and a real
build's `.dbg` can name a wrong date; if not, it is the test's, fixed by
giving side two a fixed date too.

**How to reproduce**: `cargo test -p rm2k-snes-cartridge --test assemble`
in a loop under load; it failed once in two full `rust-test` runs.

## Log

### 2026-11-24, Cardón: to todo

A flaky test, seen with its exact output; the assert is still
`rm2k-snes/cartridge/tests/assemble.rs` 241, and side two's files still get
no fixed date (only side one's, 204-214). `retarget_line` in `assemble.rs`
truncates to seconds as ld65 does, so the two readings differ only if the
file changed: the task already says how to tell the test's fault from the
rewrite's.

### 2026-11-27, Hornero: seen again

Red once more verifying Cardón's battle merge (the-advocate `cardon-battle`
into `e5b3d067`): `mapdata.inc`'s mtime `0x6B0A0746` against `…47`, the
second ticking between the two builds. Alone, green.
