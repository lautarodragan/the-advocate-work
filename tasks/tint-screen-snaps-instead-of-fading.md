---
name: "TintScreen snaps instead of fading"
description: "A TintScreen with a duration changes the screen at once and waits the time out; scenes that fade to night, to black or back to day jump instead"
type: bug
status: draft
---

Seen by Mulita on 2026-10-15, comparing The Book of Three with the original
under Wine, with the-advocate `fa9d1a14` (and `362d3765` for
`degradations.json`) and the ports `0ca371b`.

**What is seen**: where the original fades the screen —to black between two
moments of a scene, to night at a camp, back to daylight on arriving
somewhere— over half a second or a few seconds, the port jumps to the final
tint in one frame and then waits as long as the fade would have lasted. The
scene's timing is the same; the fade is not there. In The Book of Three it
is how most of its scenes cut, and it shows in every one of them.

**What the build says**: `degradations.json` lists each one as
`tint-gradient-dropped`, "the tint is applied at once instead of over N
tenths of a second": **128** in The Book of Three, on 50 maps and inside
troop 83's page. The compiler's comment on `TINT_SCREEN` in
`rm2k-snes/events/src/compile.rs` says the gradient is discarded on purpose
because the compared screen is always the settled one.

**How to see it**: any scene of the ports' `milestone-*` cases, for
example `milestone-cauldron`, against the original.
