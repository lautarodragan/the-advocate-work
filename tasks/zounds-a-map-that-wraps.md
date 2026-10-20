---
name: "Zounds: a map that wraps around"
description: "Map 70, Subsuelo / Passage 1, has Wrap: Both; the runtime does not wrap maps: what it would cost"
type: research
status: doing
assignee: Hurón
agents: [Hurón]
---

Seen by taro on 2026-10-19, playing Zounds' delivery of that day (the ports `1182513`, the-advocate `2c350d8f`).

taro: "`Subsuelo / Passage 1` has `Wrap: Both` on. We do not have that
implemented, do we? How complicated would it be to implement?" Map 70 of
Zounds. To answer: what RM2k does with a map that wraps (the hero, the
events, the panorama, the camera), what the runtime does today with one,
which maps of the ports use it, and what implementing it would cost on
the console, measured where it can be.
