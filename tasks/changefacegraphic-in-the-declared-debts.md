---
name: "ChangeFaceGraphic in the declared debts"
description: "ChangeFaceGraphic compiles to nothing but is not in ACCEPTED_UNDONE, so page_debts does not warn that the face is lost"
type: bug
status: testing
agents: [Codex]
assignee: taro
---

Aguará found it on 2026-10-06 while building the board against RM2k: the branch
for `ChangeFaceGraphic` in `compile_command` gives `Ok(vec![])`, but the code
is not in `ACCEPTED_UNDONE` —the list has 8—, even though the task
`faces-and-wait-escapes-in-messages.md` and commit 73b263a3 say
it went in. Besides, that branch's comment refers to
`draw-the-faces-and-really-wait-on-the-escapes.md` without saying where it lives today.

taro, on 2026-10-06: Codex's first task, to try out the circuit.

Codex, on 2026-10-06: `git blame` and `git log -S` show that it was not lost in
a merge. Commit 73b263a3 added the branch and its compilation test, but
left `ACCEPTED_UNDONE` with the same six entries; the later merges
only added other debts.

The test `change_face_graphic_is_reported_as_debt` gave red before the fix:
`page_debts` returned `[]` instead of `[10130]`.

Done: `CHANGE_FACE_GRAPHIC` goes into `ACCEPTED_UNDONE`, and the comment of its
branch follows the task without depending on the folder it is in. Verified with
`just -f tools/justfile crate-test events` and, in a clone of ABL using the
local install of `events`, with `just cartuchos` and `just pruebas`.

The suite does not run the new warning: ABL does not have command 10130 in its JSON.
It does verify that the cartridge and the rest of the suite do not change; the warning is
covered directly by the new unit test.

At merge time, install `events`.
