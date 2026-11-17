---
name: "Debug switches for the global state"
description: "Switches in the debug screen to turn off the state the game leaves on across maps —the tint, the on-screen timer, the weather…— so lag and other bugs can be bisected in taro's own game"
type: feature
status: doing
assignee: Tijereta
agents: [Tijereta]
---

Opened by Hornero on 2026-11-17, at the-advocate `ed8d8590` and the ports
`f62e91b`, after
[`abl-lazer-teeth-s-rock-lags`](abl-lazer-teeth-s-rock-lags.md): the ~35
lag frames per stone came from the opening's tint (saturation 40), which
the game leaves on across maps and the harness cleared; the on-screen
timer cost ~3 more.

taro, translated:

> I suppose in the future we can turn off the tint, bisect-style, to test
> lag and other things.

and, about this task and
[`mesen2-s-core-in-the-harness`](mesen2-s-core-in-the-harness.md):

> Good idea! I like both. I'd go for the two in parallel, I think.

**What**: in the debug screen (which lives in the `.msu`, and yields room
and speed to the game), switches that force off, while set: the screen
tint, the on-screen timer, the weather (rain, sandstorm…), and whatever
else of that kind the runtime keeps across maps and costs per frame (find
them). Off in a clean delivery, like phasing.

**Done**: the switches work from the debug screen in ABL and Zounds; with
them off nothing changes (ROM tests); with one on, its cost leaves the
frame (measured on Lazer Teeth under the opening's tint); bank 0 and far
RAM measured with `just space` (far RAM in ABL's `release` has ~131 B).
