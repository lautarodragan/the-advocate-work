---
name: "Skills screen: SP at zero in yellow"
description: "With 0 SP the original paints the SP in the System's 'low' colour, yellow; the port's skills screen paints them white"
type: bug
status: wishlist
---

Seen by Mulita on 2026-10-12 comparing the port's skills screen with the
original under Wine (Radin without SP), and not fixed: see the task
[`the-skills-screen`](the-skills-screen.md). RM2k paints the SP figure in
the System's colour for "low" when it is at zero; the port, in white.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
A colour detail. **Done** is the skills screen painting the SP figure in
the System's "low" colour when it is 0, as the original does, and its
golden moved on purpose. First step: see where the menu's status already
picks that colour, and reuse it.
