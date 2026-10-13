---
name: "The ports' `just culprits` does not run"
description: "The recipe of the seven games calls `rm2k-snes-events culprits` without --data, --request and --out, and the request is not left anywhere"
type: bug
status: draft
---

Seen by Calandria on 2026-10-12, with the-advocate `28e66b35` and the ports
`c97a0dd`.

**What is seen**: `just culprits` in any of the seven games that are not
ABL —book-of-three, desert-nightmare, dooms2, el-dorado, frozen-world,
sunset-over-imdahl, vampires-dawn— stops with "the following required
arguments were not provided: --data, --request, --out". The recipe is
from the day each project was born, 2026-10-05.

**What is missing**: `--data` is the game's `data/`, but the request is
what the converter writes to a temporary directory and deletes
(`stage::run` in `rm2k-snes/convert/` of the-advocate), so there is no
file to pass it.

**How the report was obtained instead**, for the forge
(`book-of-three-the-forge-and-a-walkthrough`): a `rm2k-snes-events` first
in the PATH that copies its `--request` aside and execs the real one, a
`just cartridges release`, and `culprits` by hand on the copy.
