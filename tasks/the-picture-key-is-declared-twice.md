---
name: "The picture key is declared twice"
description: "A ShowPicture's key is rm2k-snes-events' PictureKey, written by hand with to_json and read back by hand with picture_key; since B6 the converter reads the same object as its own pictures::Key. One serde type in the events crate, with the converter's four fields beside it, would leave one declaration"
type: refactor
status: draft
author: chaja
links:
  found-in: [the-stages-speak-json-nobody-types]
---

Seen by Chajá on 2026-11-24, at the-advocate `chaja-b6` (`2fcfc544`, from
`cef2cdda`), doing B6 of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md).

**Where**: the scan answers each picture a map can show as
`PictureKey::to_json` (`rm2k-snes/events/src/registry.rs`, a `json!` of
seven fields), and the compile request carries it back, read by
`picture_key` in `rm2k-snes/events/src/lib.rs` field by field. Since B6 the
converter reads that same object as `pictures::Key`
(`rm2k-snes/convert/src/pictures.rs`), with serde, and adds four fields of
its own on the map that shows it —`path`, `with_map`, `behind_map`,
`screen_on_map`—, which then travel in the tables to the compiler and the
emission.

**Why it is two**: B5 (Cardón) types the events' scan and compile at the
same time as B6, in another branch; the converter could not take a type
from the events crate that did not exist yet without touching that crate
under B5. So B6 declared the key in the converter, with its fields in the
order `to_json` writes them, so that every table entry comes out the
object it was.

**What is left**: once both are merged, `PictureKey` deriving `Serialize`
and `Deserialize` —its `at` a `(i32, i32)` serializes as the `[x, y]` it
writes today— and the converter's `Key` being that plus its four fields
(`#[serde(flatten)]` as its first field keeps the order: the scan's fields
first, then the converter's). Then
`to_json` and `picture_key` go, and a field renamed on one side does not
compile on the other. The ROMs cannot change; the check is the nine games
byte for byte, as every step of the task.
