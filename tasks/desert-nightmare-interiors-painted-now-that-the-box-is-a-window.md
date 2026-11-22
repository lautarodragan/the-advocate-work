---
name: "Desert Nightmare's interiors painted, now that the box is a window"
description: "42 one-screen interiors were left out of painted_events because the message box's two pictures did not fit beside a painting; since the box is the message window those pictures are never shown, and the 42 can be measured again"
type: feature
status: doing
assignee: Hurón
agents: [Hurón]
author: huron
---

Seen by Hurón on 2026-11-21, doing
[`desert-nightmare-own-message-frame`](desert-nightmare-own-message-frame.md),
with the-advocate at `a537d967` and the ports' branch `huron-dn-frame`
(from `a36d80b`).

**What changed**: `painted_events`, in Desert Nightmare's `advocate.toml`,
leaves out 42 one-screen interiors because painting them made the message
box's two pictures, `TextboxInnen` and `TextboxRahmen`, not fit —measured
on 2026-11-19 in
[`still-pieces-painted-into-a-painted-map`](still-pieces-painted-into-a-painted-map.md)—.
Since that branch common event 2 no longer shows them: the box is the
message window. So that reason is gone, and the 42 may now be painted at
no cost, or at another one.

**How to see it**: add the 42 to `painted_events`, `just cartridges` in
`desert-nightmare/`, and compare `build/release/degradations.json` with
and without them, as that task did.
