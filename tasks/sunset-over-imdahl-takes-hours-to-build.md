---
name: "Sunset Over Imdahl takes hours to build"
description: "Sunset's release takes ~2 h 40 min; a single one of its 138 large images takes 4 minutes. Suspect: 27a28646, Adeleine's palettes per group of tiles"
type: bug
status: done
assignee: taro
agents: [Calandria]
---

From the re-sweep of 2026-10-10. It is not verified that it is 27a28646.

## Fixed

It was 27a28646: each group of tiles chose its palette rebuilding and
costing every trial palette from scratch. Calandria fixed it on 2026-10-10
in 1513fa7f —one table of distances, and only the candidate that can win
measured again—, with the same output byte for byte: that image, from
4 min 5 s to 1.2 s.

Measured on 2026-10-11 (Hornero), the-advocate 01388b04 and the ports at
main, in a fresh worktree with an empty `build/`: `just cartuchos release`
in `sunset-over-imdahl/` takes 31 s of real time, 2 min 2 s of user.

