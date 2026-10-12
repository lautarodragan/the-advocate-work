---
name: "A screens test gives a different result with the whole workspace"
description: "the_boxes_of_the_maps_and_the_common_events gives 4 boxes with cargo test -p rm2k-snes-screens and 5 with cargo test --workspace, since the merge of the faces and the escapes (3f34ca23)"
type: bug
status: done
agents: [Hornero]
assignee: taro
---

Seen on 2026-10-06 when merging Mulita's and Carpintero's work. Bisected: at
`ea1c5beb` (the parent) it passes with the whole workspace, at `3f34ca23` it fails
(`left: 5, right: 4`, `screens/tests/python.rs:327`). With `-p
rm2k-snes-screens` alone, it passes. ABL doesn't change (the suite green, the same
fingerprint), and the binaries are installed crate by crate, so the ROM is built
by the `-p` behaviour.

The difference between the two runs is the workspace's unification of
dependencies and features: `serde_json` with `preserve_order` (requested by
`rm2k-snes-audio` and `convert`) is the suspect, together with the
`without_waits` in `text/src/refit.rs`. It wasn't followed up, because of the
usage limit.

## Solved, on 2026-10-11

It wasn't the workspace. Bisected again with `crate-test screens` —which
tests the project alone— from `97ddd8be`, where the fingerprint was born: the
first red commit is `73b263a3`, the faces and escapes one, with `-p`
too. That commit accepted on purpose `\.`, `\!` and `\|` in the middle of
a box, and the fixture's box that existed for the "doesn't
compile" path used precisely a `\|` in the middle: it started compiling and
the table gave 5 boxes. The difference with `-p` seen on 2026-10-06 doesn't
reproduce —none of the projects has features—; it was probably an old
build.

Fixed in `00710e92` of `the-advocate`: the box uses `\$`, which still
doesn't compile, and the 4 boxes come back with the previous fingerprint,
without touching it. It passes the same with `crate-test screens` and with
`cargo test --workspace`.
