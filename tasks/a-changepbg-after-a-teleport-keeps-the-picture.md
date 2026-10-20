---
name: "A ChangePBG after a Teleport keeps the picture"
description: "The Frozen World's encounters jump to its battle map and then name the backdrop; the console keeps the battle map's picture on those, because a page that jumped no longer knows which map's records to number"
type: feature
status: todo
agents: [Aguará]
---

Seen by Aguará on 2026-10-19, carrying the pictures a map's `ChangePBG`s
name —[`what-is-missing-from-the-panoramas`](what-is-missing-from-the-panoramas.md)—,
with the-advocate's branch `aguara-panorama-change` (from `54ec3daf`).

In The Frozen World every encounter on the field is a touch page that
does `MemorizeLocation`, `Teleport` to map 1 (the battle screen) and then
`ChangePBG` to the place's backdrop —`CavePanTest`, `HillBackDropTest`,
`THighBackDrop`…—: in RM2k the page goes on in map 1, so the backdrop is
map 1's. The console carries the pictures a map's own pages name **before**
any jump to another map (`named_panoramas` in Wally), and the compiler
keeps the picture on a `ChangePBG` after a jump (`MapEvents::jumped`),
because it no longer knows which map's records to number. On that build:
125 of the 126 `panorama-not-changed` left in The Frozen World's
`build/release/degradations.json` are these, on 69 field maps; map 1's
own `BackdropSetter` sets the backdrop by switch anyway, and it carries
its 17 pictures —but not `CavePanTest`, which only the field maps name—.

What it would take: the converter crediting each `Teleport`'s target with
the pictures named after it (it knows every map; Wally sees one), and the
compiler numbering after a jump to a constant map against that map's list.

To see it: build The Frozen World and read the losses of kind
`panorama-not-changed` in its `degradations.json`; the converter log says
nothing of them, because the field maps carry none.

## Defined (2026-10-20, Tijereta)

Checked against the-advocate `8f290c39` and The Frozen World's release
build of the ports `68bf55b`: still so —`CHANGE_PBG` in
`rm2k-snes/events/src/compile.rs` keeps the picture when
`MapEvents::jumped`, and `degradations.json` still has the
`panorama-not-changed` losses of the field maps (`CavePanTest` on map 12
among them)—. Since a3cea329, "Route graphics numbered where they run",
command 34 after a jump is numbered against the map it jumped to, through
`ctx.jump` and `crate::landings`: the same path serves the panoramas.
**Done**: a `ChangePBG` after a `Teleport` to a constant map is numbered
against that map's panoramas, and that map carries the pictures the pages
that jump to it name; The Frozen World's encounters show their backdrop
on map 1, its `degradations.json` loses those losses, and a compiler test
holds it. **First step**: how `landings` carries the route graphics to
the target's table, and Wally's `named_panoramas`, which today sees one
map.
