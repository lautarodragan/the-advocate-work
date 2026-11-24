---
name: "The cached .dbg test sees a date move"
description: "a_cached_object_gives_the_dbg_a_fresh_one_gives failed once: the fresh build's .dbg gave mapdata.inc a modification time one second later than the cached one's, though the test writes the file once"
type: bug
status: draft
author: hornero
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
