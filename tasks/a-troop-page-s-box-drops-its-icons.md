---
name: "A troop page's box drops its icons"
description: "A box a troop page shows draws no ExFont icon, as it draws no Latin-1 letter: the battle composes it with the text screens' glyphs, and the event compiler writes it without letters"
type: feature
status: draft
assignee: null
agents: [Hurón]
---

Seen by Hurón on 2026-11-02, the-advocate `huron-exfont` (on top of
244f4013), while doing
[`rm2k-s-exfont-icons-in-names-and-texts`](rm2k-s-exfont-icons-in-names-and-texts.md).

**What is seen**: in Zounds, a box a troop page shows —the common event
of the prize, "Objeto Especial $dVeneno x1", called from 144 troop pages—
shows "Objeto Especial Veneno x1": the icon is left out. The same box on
the map draws it. Zounds' release build lists them in
`build/release/degradations.json` as `letter-plain` losses with a `troop`,
"the icon $d as nothing" (and `$K`, `$g`).

**Why**: the troops' window carries no letter —`Window` for the troops in
the event compiler, `carrying(&[])`— because the battle draws their boxes
with the text screens' glyphs and not the message window's. Since
2026-11-02 the text screens' tables do carry icons: the ones the
database's items and skills use, after `TL_FIGURE`'s place, a byte each
from 129 (`ICON_GLYPH_FIRST` in `rm2k-snes-screens`). So the troops'
window could carry those same halves at those same indices, if the event
compiler knew the screens' list —it is decided by the screens stage, after
the compiler runs—, and a troop box's icon that is not an item's or a
skill's would still be dropped. The Latin-1 letters the same way, once the
text screens carry any.

To reproduce: build Zounds' release and grep its `degradations.json` for
`"the icon` with `"troop"`.
