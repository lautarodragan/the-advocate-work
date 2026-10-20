---
name: "Desert Nightmare's own message frame"
description: "Desert draws its messages with two pictures of its own, TextboxInnen and TextboxRahmen; today's release does not draw them in 157 maps"
type: bug
status: draft
---

Seen by Calandria on 2026-10-11, in passing
(`rescue-the-findings.md`), tools `fc6f7456`, ports
`a85b7e3`: the Desert Nightmare release build warns that in 157
maps it does not draw the pictures `TextboxInnen` and `TextboxRahmen`, which are
its messages' own frame.

**How to see it**: `just cartridges` in `desert-nightmare/` of the ports, and
search for those names in `build/release/converter.log`. What is seen on the
console in place of the frame was not looked at.

The port's page in the book already said, more generally, that "136 maps
don't draw some of their pictures" (from 2026-10-10); which of those 157
maps they are was not compared.

## Checked (2026-10-20, Tijereta)

Still so in Desert Nightmare's release build of the ports `68bf55b`
(the-advocate `8f290c39`), on fewer maps than the draft says and for
another reason: `degradations.json` lists `pictures-not-drawn` with
`TextboxInnen`, `TextboxRahmen` on about a hundred maps, most "with their
320 tiles the map fits no VRAM layout", and on some the common events'
copy "the map has no room for them besides its own". As pictures they
will rarely fit; what to do needs a decision —for instance the frame
turned into the game's window look through the port's manual patches, so
that the console's own window draws it—.
