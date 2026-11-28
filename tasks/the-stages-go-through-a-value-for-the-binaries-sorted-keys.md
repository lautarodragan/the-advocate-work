---
name: "The stages go through a Value for their binaries' sorted keys"
description: "Several stages write their JSON answer through `serde_json::to_value` so that their binary wrote the keys sorted; the binaries went on 2026-11-27, and inside advocate, with preserve_order, the detour looks like a no-op"
type: refactor
game: advocate
status: draft
assignee: taro
agents: [chaja]
author: chaja
links:
  found-in: [the-advocate-still-speaks-of-the-stages-binaries]
---

Seen by Chajá on 2026-11-28, in the-advocate at `b4654a3a`, doing
[`the-advocate-still-speaks-of-the-stages-binaries`](the-advocate-still-speaks-of-the-stages-binaries.md).

Some stages serialize their answer to a `serde_json::Value` before writing
it, and their comments said why: a stage's own binary, without
`preserve_order`, wrote a `Value`'s keys sorted, as it had when the answer
was a `json!`; the converter, which turns `preserve_order` on for the
whole workspace, writes them in the order they were inserted. The places:

* `rm2k-snes/screens/src/stage.rs`: `faces` and `window_of` (and the doc
  of `WindowAnswer` in `answer.rs`);
* `rm2k-snes/mapdata/src/stage.rs`: `mapdata.json`;
* `rm2k-snes/events/src/stage.rs`: `files`.

The binaries went on 2026-11-27. In `advocate`, with `preserve_order`,
`to_value` of a struct keeps the fields' order, so writing the `Value`
should give the same text as writing the struct; only a crate's own tests,
run alone without the feature, still see sorted keys. Not measured.

What to do: remove the detours where they change nothing, and check it
the way the rest of this kind is checked: every ROM byte for byte the same
(`release` of ABL and the root `cartridges`) and `cargo test --workspace`.
The sorts that put bytes into the ROM in a fixed order —`json::by_key` in
mapdata, the special values in `screens/src/custom_menu.rs`— are not
these and stay: without them the project file's order would reach the
ROM.
