---
name: "The console font's origin and license"
description: "low-variable.png was derived from 'easyrpg's Mincho'; which of EasyRPG's bitmap fonts that is decides its license, and the test game is public"
type: research
status: testing
assignee: taro
agents: [Mulita]
---

Calandria, building the test game on 2026-10-15, could not confirm that the
console font (`rm2k-snes/text/fonts/low-variable.png` in the-advocate,
"derived once from RM2k's Mincho by rules, on 2026-09-30") is free. Its
source was `rm2k.png`, "easyrpg's Mincho" (the-advocate `46858161`).

EasyRPG Player (`~/ref/easyrpg-player`) carries several bitmap fonts:
Shinonome Gothic and Mincho (public domain, per its README), ttyp0 (its own
license, Uwe Waldmann), and "RMG2000-compatible" (`bitmapfont_rmg2000.h`,
no origin or license declared apart; the Player is GPL).

taro, on 2026-10-15: plan A, verify; plan B, another known free font.

## Log

### 2026-10-15, Mulita: plan A confirmed, plan B not needed

Source sheet: `rom/experimentos/fuentes/hojas/rm2k.png` from the-advocate
`46858161` (deleted later; recovered with `git show`). Its 95 ASCII glyphs
(32 to 126), decoded and compared row by row with EasyRPG Player's
generated headers (checkout of 2026-09-01):

* `bitmapfont_rmg2000.h`: **95 of 95 identical**. This is the font.
* `shinonome_gothic.h`: 90 of 95 (it shares most shapes, so looking is not
  enough; the five differences settle it).
* `bitmapfont_ttyp0.h`: 3 of 95. `shinonome_mincho.h` has no ASCII at all.

(`rm2k-snes/text/src/glyphs.rs` already said it: our `MINCHO` is rmg2000
and our `GOTHIC` is ttyp0. "Mincho" in our code is RM2k's `font_id`, not
the Shinonome Mincho family.)

License: the font's own source, `resources/shinonome/rmg2000/font_src.bit`
in EasyRPG Player, says: "Basic halfwidth (6x12dot) font compatible with
Don Miguel's RMG2000. Designed by Zikmok (rohkea) for EasyRPG project, 2017.
Partially based on Shinonome. Placed in public domain. If this is impossible
in your country, then it is distributed under CC0." The Player's README says
the same of the Shinonome family it lives in ("Glyphs were added and modified
for use in EasyRPG Player, all changes under public domain"). The Player's
GPL does not cover it, and ttyp0's license is not involved. The checkout is
one commit deep, so no earlier origin was looked for; the header is the
declaration.

The derivation: `low-variable.png` was cut from that sheet by rules (ink
plus one pixel of air, merged columns, hand-made digits; 36 of its 95 glyphs
still equal the source's). Public domain / CC0 allows any derivative with no
condition, so it changes nothing license-wise. No attribution is required;
the fonts README now credits Zikmok and EasyRPG anyway.

Conclusion: the font is free for a public repo. Plan B (replacing the sheet)
is unnecessary and not proposed.

Done: the-advocate branch `mulita-font-origin` (one commit, README of
`rm2k-snes/text/fonts/`). No AUTHORS/LICENSE file next to the sheets: the
license asks for none.

Test game: on `calandria-test-game`, `test-game/AUTHORS.md` says the font
"is the tools', in `rm2k-snes/text/`, which says where it comes from", so
it needs no row. If wanted, end that sentence with: "(EasyRPG's rmg2000
font by Zikmok, public domain / CC0; see `rm2k-snes/text/fonts/README.md`)".
I did not touch that branch.
