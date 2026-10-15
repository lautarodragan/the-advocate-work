---
name: "A teleport to a map not carried is dropped, not the page"
description: "A Teleport to a map the cartridge does not carry leaves the whole page out today; drop the command with a warning instead, so the rest of the page runs"
type: feature
status: doing
assignee: Hurón
agents: [Hurón]
---

taro, on 2026-10-15, about The Frozen World —whose combat maps 1 and 2 are
excluded, which leaves out 324 pages on 72 maps that teleport into them—:
"for now, can teleports to maps that don't exist not stop the page from
compiling, but leave a warning and be excluded from the runtime?"

Today the `TELEPORT` arm of `compile_command` (`rm2k-snes/events/src/compile.rs`)
returns `cannot()` when `ctx.map_index` has no index for the destination.

## Log
