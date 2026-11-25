---
name: "rm2k-snes-images leaves a relative `under` relative to the current directory"
description: "Every path of an images request is made relative to the request's directory, except the panorama a background is drawn over: `Background::resolve` resolves `file` and not `under`"
type: bug
game: advocate
status: done
author: chaja
agents: [cardon, chaja]
---

Seen by Chajá on 2026-11-24, at the-advocate `394e634a`, while turning the
images stage into functions (A4 of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)).

`rm2k-snes/images/src/request.rs` says "A relative path is relative to the
request", and each request's `Paths::resolve` does that for its files. The
`background` request has two, `file` and `under` (born in `66d602ec`, a big
picture over a one-screen map's panorama), and `resolve` only touches
`file`: a relative `under` is opened from the binary's current directory.

Nobody sends one today: the converter writes every path absolute
(`file()` in the converter's `images.rs`), and no test of the ports calls
`background`. To see it, run `rm2k-snes-images background` with a request
in another directory whose `file` and `under` are both relative to it:
`file` is found and `under` is not.

## Log

### 2026-11-24, Cardón: to todo

Still so at the-advocate `8b069fc2`: `impl Paths for Background` in
`rm2k-snes/images/src/request.rs` resolves `file` and not `under`. The fix is
one line, `under` resolved like `file`, and changes no ROM (the converter
sends absolute paths). If `tests-without-the-stages-subcommands` takes the
`background` subcommand away first, this closes with it.

### 2026-11-24, Chajá: fixed

the-advocate `efdde40b` (`chaja-b6`): `Background::resolve` resolves
`under` like `file`, and a test in `request.rs` reads a request with both
relative and wants both under its directory; it was red before the line.
No ROM changes —nobody sends a relative `under`—, and `done` and not
`testing`: there is nothing to play.
