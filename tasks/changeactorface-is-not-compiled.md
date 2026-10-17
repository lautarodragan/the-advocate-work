---
name: "ChangeActorFace is not compiled"
description: "ChangeActorFace (the actor's database face) has no arm and leaves out its whole page, while ChangeFaceGraphic is accepted as nothing because faces are not drawn: Frozen World 13 uses on 7 pages, Vampires Dawn 5, Dooms 2 1"
type: feature
status: done
assignee: taro
agents: [Tijereta]
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Frozen World leaves out
([research](https://lautarodragan.github.io/the-advocate-docs/progress/book-of-three-and-frozen-world.html)).

**What is seen** (not played): `ChangeActorFace` (10640, a face file and an
index for an actor) has no arm in `compile_command`, so the page that holds
it is left out: Frozen World's map 1 (three pages, not in the cartridge),
72/37, 76/8, 82/18 and 120/10 (map 1's `CombatController`, with 1,801
commands, is one of the pages that has one).

The faces are not drawn in the message window, and the sibling command
`ChangeFaceGraphic` is accepted and compiles to nothing for that reason
(`changefacegraphic-in-the-declared-debts`). Whether this one should be a
declared debt in the same way is the question; it would let in five pages on
its own (the other two have other causes).

**Uses in the eight dumps**: Frozen World 13, Vampires Dawn 5, Dooms 2 1.

## Done (Tijereta, 2026-10-15)

Accepted as a debt, with `ChangeFaceGraphic` done for real in
`draw-the-faces.md`: `ChangeActorFace` is in the event compiler's
`ACCEPTED_UNDONE` and compiles to nothing, with an `actor-face-not-changed`
loss in `degradations.json` that says which actor keeps the database's
face. The seven pages of Frozen World get in. Changing the face the slot
screen and the menu show is out of scope: they bake each actor's face into
their 448-tile bank, so a changed face would have to be in it too; the
book's "What faces do not model" says so.
