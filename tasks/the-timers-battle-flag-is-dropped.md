---
name: "The timer's battle flag is dropped"
description: "TimerOperation's 'also in battle' flag is compiled and ignored, on the comment that there are no battles; there are"
type: bug
status: draft
---

Seen by Cardón on 2026-10-14 (`what-the-compiler-ignores-silently.md`),
tools `14e200fc`, ports `f775b66`.

**What is seen**: not played. A timer started with "also in battle" keeps
counting through a battle in RM2k, and one without it pauses. The arm of
`compile_command` for `TimerOperation` drops the flag with a comment ("here
there are no battles"), and the battle has been in the ROM for a long time.
What the ROM's timer does inside a battle was not looked at.

**How much ABL uses it**: 1 command sets it, map 150 event 4, the quarry
job's timer (see `abl-the-quarry-timer-does-not-fit-on-108`). No other game
sets it.

**How to see it**: parameter 4 of code 10230 in that command; changing it
leaves `events.json` unchanged.
