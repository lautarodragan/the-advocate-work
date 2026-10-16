---
name: "The shop's party ignores ChangeSpriteAssociation"
description: "The shop's party window draws every member with the database's CharSet, not the one a ChangeSpriteAssociation gave them"
type: bug
status: wishlist
---

Seen by Chajá on 2026-10-15, while making the party window
(`party-in-the-shop.md`), tools branch `chaja-shop-party` off `91d55d39`,
ports off `8a9ab73`.

**What is seen**: not played. The shop carries each possible member's
database CharSet (`party.rs` in `rm2k-snes-screens`), and the runtime
draws that one. In RM2k, `Window_ShopParty` draws `GetSpriteName()`, which
a `ChangeSpriteAssociation` (code 10630) changes. The cartridge keeps that
change per actor as an index into the current map's table of graphics
(`actor_gfx_read` in `runtime/menu.s`), which is not a cartridge-wide
identity the shop could look up.

**How much ABL uses it**: 212 commands in its maps, all on actors 19 and
20, the two cars (`Future3` and `BLVehicles`), which never stand in a
shop's party. The other games were not looked at.

**How to see it**: a test page that gives a party member another CharSet
with `ChangeSpriteAssociation` and then opens a shop.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
ABL never shows it and the other games were not looked at. **Done** is the
shop's party drawing each member with the graphic a
`ChangeSpriteAssociation` gave them, which needs a cartridge-wide identity
for the actor's graphic or the shop carrying the changed ones; a test page
that changes a member's CharSet and opens a shop. First step: count, in the
nine games, the `ChangeSpriteAssociation`s on actors that can stand in a
shop's party.
