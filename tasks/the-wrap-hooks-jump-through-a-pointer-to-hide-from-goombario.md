---
name: "The wrap hooks jump through a pointer to hide from Goombario"
description: "The far wrap code is reached and returns through WRAP_JUMP, a pointer in BSS, so the linter does not walk that path; taro wants Goombario improved instead, and the runtime direct"
type: tooling
status: doing
assignee: Hurón
agents: [Hurón]
---

From
[`maps-that-wrap-around`](maps-that-wrap-around.md) (Hurón, 2026-10-20):
bank 0's hooks into `runtime/wrap.s` and the far code's calls back
(`CALL0`, `RTS0`) go through `WRAP_JUMP`, 4 B of BSS, so Goombario does
not walk that path. The annotation that would have said why could not be
used: in ABL's cartridges `wrap.s` assembles nothing, and an annotation
that allows nothing is red.

taro, on 2026-10-20: "I would not change production code to please a
linter or to live with a limitation of it. If the change at run time is
nil, no drama; but if it costs even one cycle, I'd rather improve
Goombario."

**Done**: the hooks call and return directly, with no pointer and no
WRAP_JUMP; Goombario handles what it could not —an annotation on code a
cartridge does not assemble, or whatever the real limit was—, with its own
tests; ABL's cartridges still byte for byte equal to main; Zounds' wrap
tests and the test game's ring green; the cycles and bytes saved, measured.
