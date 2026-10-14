---
name: "A choice with more than four options"
description: "The fifth option of a choice does not compile (CHOICE_MAX is 4): The Book of Three's 'All Five Dreams' common event (6 calls skipped), 21 in Sunset and 21 in Vampires Dawn"
type: feature
status: doing
assignee: Chajá
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
