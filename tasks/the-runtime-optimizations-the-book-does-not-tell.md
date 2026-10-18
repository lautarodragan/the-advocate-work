---
name: "The runtime's optimizations the book does not tell"
description: "Audit runtime/ for optimizations missing from the book's Optimizations section, and write them in"
type: docs
status: doing
assignee: Hurón
agents: [Hurón]
---

taro, on 2026-10-18: are there optimizations we make that the book does
not tell, above all the runtime's? Found the same day: the twins (copies of
an event sharing a row) were only in a divergence, not in "Lossless:
events" (added in the book's `7633a4d`).

## Log
