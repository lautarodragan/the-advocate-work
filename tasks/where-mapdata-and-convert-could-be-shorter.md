---
name: "Where mapdata and convert could be shorter"
description: "A read-only look at the two biggest crates of the converter —some 11,500 lines of code each— for code that is longer than what it does: repeated shapes, hand-written tables, layers that only pass things on. Each finding becomes a draft with its estimated saving"
type: research
status: doing
author: taro
assignee: calandria
agents: [calandria]
---

**Why**: after the toolchain cleanup of 2026-11-23 —the binaries nobody
ran, the Python parity, the Python's last traces—, the Rust of
the-advocate is still around 90,000 lines of hand-written production
code. Literal duplication measured low (3 to 7%), so if there is excess it
is in code that does with many lines what could be done with fewer.
`rm2k-snes/mapdata` and `rm2k-snes/convert` are the two biggest crates
with the least test code per line; `emit.rs` alone is some 5,000 lines of
code and `record.rs` 2,600.

> Going back to the little table, I think mapdata and convert could be
> interesting to analyse for possible reductions in the code, right?

(taro, 2026-11-23. Earlier the same day: "without going into code golfing
— it has to be readable".)

**What is asked**:

* Read both crates whole, and what they talk to as far as needed to judge
  them. Nothing is changed in this task.
* Each concrete reduction is a draft of its own: where, what the code
  does, what the shorter form would be —a sketch, not the change—, an
  estimate of lines saved, what it risks, and how it would be verified
  (most should leave every ROM byte for byte equal).
* Readability decides: a reduction that makes the code harder to follow
  is not proposed. What is long because the problem is long is said so,
  and is not a finding.
* At the end, a summary in this task's log: the drafts by estimated
  saving, and a judgement of how much of the two crates is inherent.
