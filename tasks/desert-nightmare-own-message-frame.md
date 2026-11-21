---
name: "Desert Nightmare's own message frame"
description: "Desert draws its messages with two pictures of its own, TextboxInnen and TextboxRahmen; today's release does not draw them in 157 maps"
type: bug
status: todo
author: hornero
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

## taro's decision (2026-10-20)

To todo, with Tijereta's recommendation: the frame becomes the game's window look —its System graphic— through the port's manual patches, so that the console's own window draws it, instead of drawing `TextboxInnen` and `TextboxRahmen` as pictures.

**Done**: Desert Nightmare's messages are drawn in a window with its own frame on every map, and `degradations.json` no longer lists those two pictures as not drawn. **First step**: how the common events show the two pictures around a message, and whether a System made from them fits RM2k's window layout.

## Log

### 2026-10-20, Tijereta: checked

Still so in Desert Nightmare's release build of the ports `68bf55b`
(the-advocate `8f290c39`), on fewer maps than the draft says and for
another reason: `degradations.json` lists `pictures-not-drawn` with
`TextboxInnen`, `TextboxRahmen` on about a hundred maps, most "with their
320 tiles the map fits no VRAM layout", and on some the common events'
copy "the map has no room for them besides its own". As pictures they
will rarely fit; what to do needs a decision —for instance the frame
turned into the game's window look through the port's manual patches, so
that the console's own window draws it—.

### 2026-11-19, Hurón: seen again

At the-advocate `62b6e5cb` and the ports `1ea90bf`, played on the motel
(map 16): the converter says the two pictures, as the commons' set, "fit
on 14 of the 189 maps". A message with a face gets the System's frame;
one without gets none, and the map's upper layer cuts its letters
(`/shared/captures/2026-11-19-desert-nightmare/messages.png`). Ranked
fourth in the book's research
`ports/desert-nightmare/research/2026-11-19-what-it-takes-to-be-playable.md`.

### 2026-11-20, Tijereta: seen again

At the-advocate `0d7ab7ed` (branch `tijereta-number-locks`) and the ports
`a93ca63`, on the tailor's (map 123), one of the maps where the two
pictures **do** fit: they go as objects —92 of them, the converter says—
**over** the text layer, so a box with no face is covered by
`TextboxInnen` and only a few letters show through where a line runs out
of slivers. Seen with the tailor's number lock, whose digits go in a box
of no lines and no face: of `0 0 0 0` only `| 0` shows, and the frame's
picture is left half-drawn around it
(`/shared/captures/2026-11-20-number-locks/contact-sheet.png`, second
row). The lock works —the right code opens it, a wrong one does not—; it
cannot be read. On the maps where the pictures do not fit (28, 42) the
same digits go over the map with no box, as any faceless message there.

### 2026-11-20, Calandria: seen again

At the-advocate `7951af2a` and the ports `42f70e8`, on the office (map 24),
another map where they fit, with a face: taro saw the frame "as lines
across the whole screen" while a message fades in
(`/shared/bug-reports-etc/dn/show-message-fadein-broken-*.png`). It is
common event 2 fading the two pictures in before the box: counted in the
OAM during the fade, up to 40 objects and 56 slivers on a line, over the
PPU's 32 and 34 on 39 lines, so what goes past is not drawn and lines are
what is left; and 320 wide on a 256 screen, so their right edge is never
seen. When the box opens, the window's mask hides them. Looked at from
task `desert-nightmare-message-text-cut-by-the-map`, and left to this one.
