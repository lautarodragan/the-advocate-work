---
name: "The battle terms by name are a 42-arm match"
description: "emit.rs's term() maps each liblcf term name to its field of ditto's Terms with one match arm each; Terms already serializes with liblcf's names, so the lookup can be by name"
type: refactor
status: draft
author: calandria
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/mapdata` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).

**Where**: `rm2k-snes/mapdata/src/emit.rs` 130-176, `fn term(db, name)`.

**What the code does**: `BATTLE_TERMS`, `RESULT_TERMS` and the skills
screen name the terms they need by liblcf's name (`"command_attack"`,
`"skill_failure_a"`…), and `term` turns each name into the field of
`ditto::schema::Terms` with a hand-written arm —42 of them—, and an error
for any other. A term added to the tables needs its arm too.

**The shorter form**: `Terms` is generated from liblcf's `fields.csv`
and has a `Serialize` that writes every field by that same name (the
`schema_struct!` macro in `rm2k/ditto/src/lcf.rs`). So:

```rust
fn term(db: &Db, name: &str) -> Result<String> {
    let terms = ditto::lcf::as_resolved(|| serde_json::to_value(&db.terms))
        .expect("the terms are JSON");
    terms.get(name).and_then(Value::as_str).map(str::to_string)
        .ok_or_else(|| Bad::usage(format!("there is no term {name:?}")))
}
```

computed once per emission rather than per call.

**Estimated saving**: about 43 lines.

**What it risks**: little, with one thing done right: that macro's
`Serialize` leaves out every field at its default unless the thread is in
the resolved view, which is what `ditto::lcf::as_resolved` turns on; without
it a term the game left at its default would be "no term". Inside it, it
reads the same strings the match reads, by liblcf's names (`json_name` of
the field, the same that `BATTLE_TERMS` uses —worth one look at the two
misspelled ones, `gold_recieved_a` and `item_recieved`—).

**How to verify**: a unit test that every name of `BATTLE_TERMS`,
`RESULT_TERMS` and `"lvl_short"` resolves, against a default `Terms` and a
game's; and every port's ROM byte for byte equal before and after
(`NO_CACHE=1 just cartridges`, `cmp`).
