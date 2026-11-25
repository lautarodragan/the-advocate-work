---
name: "Six sweeps in scan.rs are one with another predicate"
description: "has_rain, has_sandstorm, teleports_with_a_facing, transparent_messages, types_a_colour and window_slots each walk the maps, the common events and the test pages with their own copy of the loop, and convert.rs passes them the same three arguments six times"
type: refactor
game: advocate
status: todo
author: calandria
agents: [cardon]
links:
  found-in: [where-mapdata-and-convert-could-be-shorter]
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/convert` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).

**Where**: `rm2k-snes/convert/src/scan.rs` 71-184, and their callers in
`convert.rs` (247, 449-466, 1957-1977).

**What the code does**: six public functions with the same signature
—`maps: impl IntoIterator<Item = &GameMap>, common_events:
&BTreeMap<i32, Vec<Command>>, extra: &[Command]`— and the same body:
`extra.iter().any(p) || common_events.values().flatten().any(p) ||
maps.into_iter().any(|m| m.all_commands().any(p))`, each with its own
predicate (`window_slots` collects instead of `any`). `has_rain` takes no
common events, and `has_sandstorm([], …)` is called once more with no maps
to ask whether a common event or a test page starts one. The callers
repeat `every_refs.iter().copied(), &game.db.common_events,
&file_commands` each time.

**The shorter form**, a sketch: the three sources once, and the questions
as predicates:

```rust
pub struct Commands<'a> { maps: Vec<&'a GameMap>, commons: &'a BTreeMap<i32, Vec<Command>>, extra: &'a [Command] }
impl<'a> Commands<'a> {
    pub fn all(&self) -> impl Iterator<Item = &'a Command> + '_ { … }
    pub fn without_maps(&self) -> impl Iterator<Item = &'a Command> + '_ { … }
}
let everything = Commands::of(&every_refs, &game.db.common_events, &file_commands);
request["teleport_facing"] = json!(everything.all().any(scan::faces));
```

with each predicate a named `fn(&Command) -> bool` beside its doc comment,
which is what the six comments explain and should stay.

**Estimated saving**: about 50 lines —30 in scan.rs, 20 in the callers—.

**What it risks**: one thing: whether rain should look at the common
events. `has_rain` does not today, unlike the other five; keeping that is
the mechanical change (`extra` and the maps only), and deciding it is
another one. `git blame` on it first.

**How to verify**: every port's ROM byte for byte equal before and after
(`NO_CACHE=1 just cartridges`, `cmp`); `just crate-test rm2k-snes-convert`,
whose scan tests cover rain and the sandstorm.

## Log

### 2026-11-24, Cardón: to todo

Still so at the-advocate `8b069fc2`: the six functions at `scan.rs` 71-161,
called from `convert.rs` 258, 460-469, 1968-1982. Code debt with the fix
written, verified by ROMs byte for byte; whether rain looks at the common
events stays out of it, as the draft says (that one would be a question).
