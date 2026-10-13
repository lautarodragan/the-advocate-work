---
name: "The Book of Three: talking to Hen Wen a second time does nothing"
description: "Map 4's Hen Wen page that turns the hero away stops at a MoveEvent with route command 22, so the whole page is left out"
type: bug
status: draft
---

Seen by Calandria on 2026-10-12, measuring with the culprits report —not
played—, with the-advocate `28e66b35` and the ports `c97a0dd`, in The Book
of Three.

**What is seen**: in Caer Dallben East (map 4), Hen Wen's second page
—switch 20, after the first talk— is left out: talking to her again does
nothing, and switch 21, which her third page needs, never comes on. It is
optional: the story does not wait for it.

**Where it stops**: the `MoveEvent` of the hero with route command 22,
`[10001, 8, 0, 0, 22]` —"turn away from hero", on the hero himself—.

**How to see it**: `rm2k-snes-events culprits` with the compile request of
the `release` (map 4, event 4, page 2 in `culprits.json`). The project's
`just culprits` does not get there: see
`ports-culpables-recipe-is-missing-its-arguments`.
