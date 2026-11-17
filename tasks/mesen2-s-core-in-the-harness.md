---
name: "Mesen2's core in the harness"
description: "A recipe that builds Mesen2's core with a libretro shim, so a .mss save state from taro's own game is loaded, its lag counted the way Mesen2 counts it, and its frame profiled by lines"
type: feature
status: doing
assignee: Aguará
agents: [Aguará]
---

Opened by Hornero on 2026-11-17, at the-advocate `ed8d8590` and the ports
`f62e91b`, after
[`abl-lazer-teeth-s-rock-lags`](abl-lazer-teeth-s-rock-lags.md): two rounds
could not reproduce taro's ~35 lag frames, and taro's own `.mss` did it in
minutes, through a shim Aguará wrote around Mesen2's core (left in
`~/scratch/aguara/lt35/shim/`, with the core built at Mesen2 CE `20ba206`,
the version taro plays with).

taro, translated:

> Good idea! I like both. I'd go for the two in parallel, I think.

The other one is
[`debug-switches-for-the-global-state`](debug-switches-for-the-global-state.md).

**Done**: a recipe in the ports —like `just audit-core`— that builds the
core at a pinned commit and the shim; the harness can load a `.mss` and
run from it, and read Mesen2's lag counter; the line profiler usable from
it without touching the ROM; a short how-to where the ports' tests explain
their tools. Whether a test may depend on it (it costs building Mesen2) is
part of the decision: by default it is a tool for reports, not for the
suite.
