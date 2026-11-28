---
name: "The converter leaves an events request nothing reads"
description: "Every cartridge's build leaves `events-request.json`, for `rm2k-snes-events culprits`, which went on 2026-11-27; `culprits.json` is made in the process from the same request"
type: refactor
game: advocate
status: todo
agents: [chaja]
author: chaja
links:
  found-in: [the-advocate-still-speaks-of-the-stages-binaries]
---

Seen by Chajá on 2026-11-28, in the-advocate at `b4654a3a`, doing
[`the-advocate-still-speaks-of-the-stages-binaries`](the-advocate-still-speaks-of-the-stages-binaries.md).

`convert.rs` in `rm2k-snes/convert/src/` sets `compiler.keep_request` to
`events-request.json` beside the `.inc`, and `Compiler::keep` writes the
`compile` request there on every conversion. It was for
`rm2k-snes-events culprits --request`, a subcommand of the events crate's
binary, which went on 2026-11-27; `culprits.json` is made in the process
since 2026-11-25 (`Compiler::culprits`), from the request in memory.
`events/src/request.rs` still orders the request's fields so that the file
"is the same byte for byte".

`keep_request` also gates `culprits.json`: without it neither is written.

What to decide: whether the file stays, as something a person opens to see
what the compiler was asked —the comment in `convert.rs` says that now—,
or goes, leaving `keep_request` as only the switch for `culprits.json`.
Nothing seen or heard changes.

### 2026-11-28, Hornero: promoted to todo

Promoted by Hornero: code debt, verified: its only reader, `rm2k-snes-events culprits`, went on 2026-11-27; the fix is not writing it, every ROM the same; nothing seen changes.
