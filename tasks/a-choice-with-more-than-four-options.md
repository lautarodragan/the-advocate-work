---
name: "A choice with more than four options"
description: "The fifth option of a choice does not compile (CHOICE_MAX is 4): The Book of Three's 'All Five Dreams' common event (6 calls skipped), 21 in Sunset and 21 in Vampires Dawn"
type: feature
status: testing
assignee: taro
agents: [Chajá]
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Book of Three leaves out
([research](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-14-book-of-three-and-frozen-world-left-out.html)).

**What is seen** (not played): common event 9, `All Five Dreams`, offers five
Dreams ("Dreams of Glory", "Hope", "Freedom", "Honor" and a fifth), nested.
It does not compile, and the six calls to it from maps 24, 53, 62, 63 and 80
are skipped, so the player is not asked.

**Where it stops**: `choice_options` in `compile.rs` keeps the options with
index below `CHOICE_MAX` (4); the fifth `ShowChoiceOption` (index 4) is not
among them and the choice is refused. The window is the limit: a choice's
options are the lines of its box.

**Uses in the eight dumps**: a fifth option, Book of Three 5, Sunset 21,
Vampires Dawn 21.

Whether a fifth line fits the window, or the choice scrolls, was not looked
at.

## What it is (Chajá, 2026-10-14)

**It is not a fifth option: it is the editor's cancel branch.** Every use in
the eight dumps is a `ShowChoice` with `cancel_type` 5 and a
`ShowChoiceOption` with index 4 after its options, with an empty text:
The Book of Three 5 (four options plus the branch, nested in the
`ConditionalBranch`es of common event 9), Sunset 21 (2, 3 and 4 options
plus the branch) and Vampires Dawn 21 (3 and 4 plus the branch). In
easyrpg, `GetChoices(4)` leaves index 4 out of the window and
`Window_Message` sets `choice_result = cancel_type - 1` on cancel, so B runs
the index-4 body. The window shows four lines at most, and nothing has to
scroll.

**The fix is in the compiler only.** `OP_CHOICE` already carried an entry
past the options for cancel —`CANCEL_PAST`, the shop of map 348, whose
cancel picks an option that is not there—: the cursor never reaches it and
cancel picks it. The cancel branch is that entry with the branch's body as
its destination instead of the end of the choice. No new opcode, no runtime
change. With another `cancel_type` the index-4 body is unreachable, as in
RM2k, and compiled all the same; two index-4 options do not compile.

Touched: `rm2k-snes/events/src/compile.rs` —`CANCEL_BRANCH`, the `Choice`
struct, the `SHOW_CHOICE`, `SHOW_CHOICE_OPTION` and `SHOW_CHOICE_END` arms
of `page`, and the test `cancelling_runs_the_cancel_branch`—. ABL:
the case `tests/cases/choose-cancel-branch.json` (four Dreams plus the
branch, then two options plus the branch) and three tests in
`tests/rpgmaker/test_choose.py`. With the tools of 14e200fc the case does
not build: "the test page doesn't compile", and `just cartridges` fails.

In The Book of Three, `just culprits` with the fix: commons 21 of 25
compile, and `ShowChoiceOption` is no longer a culprit; the 82 skipped calls
left are common 19's.

## Verified, and what to install

With the tools of `chaja-five-options` (events and convert installed
locally): `just test`, `just rust-test`, ABL's `just tests` and `just boot`,
all green, the three new tests included. No golden moved. `just culprits`:
in Sunset, `ShowChoice` stops being a culprit and one more common
compiles; in Vampires Dawn, its culprits in the commons go away. **Not
played**: the Dreams are reached from map 24 on, and no test walks there;
what covers the ROM path is ABL's case.

Branches `chaja-five-options` in the-advocate, the ports and the book.
**When merging, install `events` and `convert`**: `just install events
convert`.

Found and not fixed: Vampires Dawn's victims' choice, "Talk / Suck Blood /
Convert / Leave", is the only culprit of 210 pages, and not because of the
cancel branch: draft
[`vampires-dawn-the-victims-choice-does-not-compile`](vampires-dawn-the-victims-choice-does-not-compile.md),
and a line in Known issues of its page in the book.
