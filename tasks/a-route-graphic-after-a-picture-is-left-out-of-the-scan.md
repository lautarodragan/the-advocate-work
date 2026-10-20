---
name: "A route's graphic after a picture is left out of the scan's table"
description: "The scan compiles each page without pictures, so a page with a ShowPicture stops there and the graphics its routes give after it are not in the map's table: the real compilation drops them with a warning. Sunset over Imdahl's map 14, MockGuard's CT1 2"
type: bug
status: todo
agents: [Carpintero]
---

Seen by Carpintero on 2026-10-19, with the-advocate
`carpintero-cursor-graphic` and the ports on `1869b99`, building Sunset over
Imdahl, while fixing
[`frozen-world-the-cursor-keeps-the-wrong-graphic`](frozen-world-the-cursor-keeps-the-wrong-graphic.md).
Not played.

**What the build says**: `build/release/converter.log` of
`sunset-over-imdahl/`:

    map 14: WARNING, a route changes to the graphic CT1 2 and the map's table does not have it —full at 255, or a page the scan did not get that far in—: the change is ignored

It is `MockGuard`'s autostart page (event 15, page 1), command 252: in the
"Knock him out." branch, the route on the guard himself that gives him
`CT1 2`. The converter builds the map's sprite bank with the table the
scan numbered, and the scan compiles each page without songs or pictures:
this page stops there at its `ShowPicture` (command 220) and never gets to
252, which the real compilation does. Since that day the compilation
numbers against the scan's table (`Graphics::frozen`), so the change is
dropped with that warning; before, with the table of eight, `CT1 2` was the
ninth and was dropped too.

**What it probably looks like**: in that scene the guard keeps the graphic
he had where the original changes it.

## Defined (2026-10-20, Tijereta)

Checked against the release build of the ports `68bf55b`, the-advocate
`8f290c39`: still so, and the only such warning in the nine games —Sunset
Over Imdahl's `converter.log`, "map 14: WARNING, a route changes to the
graphic CT1 2 and the map's table does not have it"—. **Done**: the scan
gathers the route graphics of a page past its `ShowPicture`s, so the
map's table has `CT1 2` and the warning is gone; an events compiler test
with a page whose route gives a graphic after a `ShowPicture`. **First
step**: why the scan stops at the picture —what a page compiled with
`pictures: None` answers to command 11110 in the scan, and whether it can
accept it without doing it, as the shared bodies do—.
