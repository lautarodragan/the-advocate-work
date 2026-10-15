---
name: "Book: an Optimizations section"
description: "A section of the book for the port's optimizations, Lossy and Lossless, plus what was tried and left out; checked against the code, and the decisions that are really optimizations moved there"
type: docs
status: doing
assignee: Cardón
agents: [Cardón]
---

taro, on 2026-10-15: add an **Optimizations** section to the book with two
sub-pages, **Lossy** and **Lossless**.

1. First, list every optimization we know we have (the documented ones),
   and publish that (a commit and a push of its own, so it is visible
   early).
2. Then look into the code —the runtime's assembly and the tools— for an
   optimization that was lost and is not documented, or one the
   documentation mentions that no longer exists (or never did).
3. During or after, remove pages or sections that are really about an
   optimization but live elsewhere today, e.g. under decisions:
   `decisions/a-window-with-a-gradient-is-fused-until-it-fits` should be
   documented as an optimization, not as a decision. "It isn't worth
   keeping a record of the decision if the decision is final."
4. An optimization that existed and was later removed goes to a third
   section, "Tried and left out" or similar.

## Log
