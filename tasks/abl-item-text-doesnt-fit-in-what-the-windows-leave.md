---
name: "ABL's item text doesn't fit in what the windows leave"
description: "ABL's build warns that the most loaded item list asks for more tile pairs than the item and equipment windows leave"
type: bug
status: draft
---

Seen by Tijereta on 2026-10-11 (`most-efficient-windows.md`),
tools `fc6f7456`, ports `a85b7e3`, building ABL's `release`.

**What is seen**: in the build, not when playing. `rm2k-snes-screens convert` says
in its answer:

    WARNING, item text: its list asks for 200 pairs of tiles at most, of
    the 167 the item and equipment windows leave

No other of the eight games says it. It wasn't checked what the ROM does
with an inventory that reaches that list —whether the text is cut, or which
names are lost— nor with which inventory it's reached.

**How to see it**: `just cartridges release` in `abl/` of the ports; the warning
is in what `screens` answers (the `says` of its `screens.json`).

A fact measured in passing: with the windows' background in a single color (the
book's research "The windows, made cheaper"), the windows leave 184.

**Checked on 2026-10-16** at the-advocate `759aa0ba`, by Cardón: the
warning stands, with other numbers —the release build's `converter.log`
in the ports checkout (2026-10-16) says 202 pairs of the 184 the windows
leave—: `release` carries the whole game since the ports' `74eb754`, and
the windows' background went flat with
[`windows-background-setting-and-flat-text-area`](windows-background-setting-and-flat-text-area.md).
The numbers are the build's to say; the description no longer carries
them. What the ROM does with such an inventory is still not looked at.

## Checked (2026-10-20, Tijereta)

Still so in A Blurred Line's release build of the ports `68bf55b`
(the-advocate `8f290c39`): its `converter.log` still has the "WARNING,
item text" line, and it is still the only one of the nine games with the
WARNING (Zounds' list takes all the pairs its windows leave, without
going past). What the ROM does with such an inventory is still not
looked at, and that is what would define it.
