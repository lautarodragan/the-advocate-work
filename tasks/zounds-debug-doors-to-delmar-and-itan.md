---
name: "Zounds: debug doors to Delmar and Itân"
description: "Two more doors in Zounds' debug room, to Delmar (183) and the town of Itân (157), which the story does not reach: only the developer's Tests map (2) leads there"
type: feature
status: doing
assignee: Mulita
agents: [Mulita]
---

taro asked on 2026-11-02 whether Zounds offers a way to reach Delmar (183)
or Itân (157). Hornero measured from the dump (ports `3e4e95d`): every
`Teleport` of every map and common event, walked from map 1.

* Delmar, 183 under 182: entered from 185 (Casa 1), 186 (Muelle) and 188,
  its own children, and from map 2, "Tests" (event 5, to (4,37)).
* Itân, 157: only from map 2's event 5, to (19,35).
* Map 2, "Tests", under the intro: only map 75, "Super Race", leads there,
  and 75 hangs from map 2 itself. Nothing in the story reaches it.
* The "Teleport" skill (30): map 2 alone sets teleport targets
  (`TeleportTargets`, 11810), and no actor learns it.

Asked whether to add two doors to the debug room, taro, in their words,
translated:

> Go ahead

## Log
