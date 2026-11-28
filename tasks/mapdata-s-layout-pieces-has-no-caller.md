---
name: "mapdata's Layout::pieces has no caller"
description: "`vram::Layout::pieces` named each piece of a VRAM layout for the JSON `rm2k-snes-mapdata vram` printed; the binary went on 2026-11-27 and nothing calls it"
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

`Layout::pieces`, in `rm2k-snes/mapdata/src/vram.rs`, gives a layout's six
pieces by name, "as the keys of each layout in the JSON that
`rm2k-snes-mapdata vram` prints". That binary went on 2026-11-27
(`83d2b8ad`), and `rg 'pieces\(\)'` over the workspace finds no caller,
the crate's tests included. It is `pub`, so the compiler does not warn.

What to do: delete it. Nothing seen or heard changes; the ROMs come out
byte for byte the same, which is the check. Its comment was made to say
it is dead in the branch of the task above, so it is not wrong meanwhile.

### 2026-11-28, Hornero: promoted to todo

Promoted by Hornero: code debt, verified by grep (no caller of `Layout::pieces` since its binary went); the fix is removing it, with every ROM byte for byte the same; nothing seen changes.
