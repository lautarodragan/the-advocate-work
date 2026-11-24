---
name: "The stages speak JSON nobody types"
description: "Each stage builds its answer with json! and whoever reads it walks a serde_json::Value key by key; one set of serde types both ends share makes the contract between stages something the compiler checks"
type: refactor
status: doing
assignee: calandria
agents: [calandria, aguara, cardon, carpintero, chaja, mulita, tijereta]
author: taro
links:
  found: [the-event-compiler-s-left-out-warning-never-reaches-the-log, fxpak-s-pty-tests-share-ptsname-s-buffer, the-msu-and-the-tracks-are-written-through-a-nuevo-file]
  relates: [artistic-decision-patches, battle-tests-without-simulate, tests-without-the-stages-subcommands]
  blocked-by: [emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines, picture-tables-and-common-entries-write-the-same-entry-twice, rm2k-snes-mapdata-maps-has-no-caller, small-repeats-inside-emit-rs-s-rest, the-battle-terms-by-name-are-a-42-arm-match]
  blocks: [a-stage-s-cache-key-once-it-is-a-library, one-advocate-command]
  has-part: [the-converter-reads-the-stages-answers-with-python-s-truthiness, the-converter-writes-the-emission-s-request-by-hand, the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures, the-emission-reads-the-screens-answer-and-the-battle-model-by-name]
---

**Why**: the converter's stages —screens, battle, events, images, Wally,
the emission— hand each other JSON. The side that writes builds it with
`json!`, and the side that reads walks a `serde_json::Value` with accessors
and checks the shape by hand: some 320 calls in mapdata alone, an `fn int`
copied in five files, and a `truthy` in the converter that is Python's.
A field renamed on one side compiles on both, and shows up only when a game
converts —if it does—.

> I agree. In none of these cases is it really about reducing code, but
> improvements. Let's do the four, and then we go for those types / typed
> contracts between stages.
>
> serde_json, or whichever library fits, takes care of the JSON. We gain a
> lot.

(taro, 2026-11-23)

**What is asked**: the contract between stages as Rust types that both
ends share, serialized with serde; the reading by hand goes. It starts
with a design —where the types live so that the layers still only depend
downwards (`tests/test_layers.py`), and what it does to the stage cache,
which keys each answer by its binary's hash (`stage.rs` `key`)—, shown to
taro before the code.

**Decided: the stages become libraries first, the cache is solved later.**
They are separate programs since the converter was Python, from the idea
of small tools that compose; the stage cache, from `be1f43a5`, keys each
answer by its binary's hash. As libraries inside `rm2k-snes-convert` the
contracts are plain Rust values passed between functions, and serde is
needed only to store an answer in the cache: most of this task comes from
that. Meanwhile the cache keys every stage's answer by the converter's own
binary —safe by construction, coarser: any change to any stage throws
every answer away—, and a per-stage key as trustworthy as the binary's
hash is
[`a-stage-s-cache-key-once-it-is-a-library`](a-stage-s-cache-key-once-it-is-a-library.md).
The ports' tests call some stages' subcommands directly
(`rm2k-snes-battle simulate`, `rm2k-snes-screens window`,
`rm2k-snes-images animations`, `rm2k-snes-mapdata`…): the design says
where those go.

> [the processes] I would like to review that. Does rm2k-snes-convert
> exist only for the cache? Is it a more elaborate `make`?

(It is not: of its 17,300 lines, running and caching the stages is
`stage.rs`'s 544; the rest are the decisions that join the domains.)

> I think I prefer simplifying the architecture first, and solving the
> cache later.

(taro, 2026-11-23)

What Calandria already measured, as drafts that this task takes in:

* [`the-emission-reads-the-screens-answer-and-the-battle-model-by-name`](the-emission-reads-the-screens-answer-and-the-battle-model-by-name.md)
* [`the-converter-reads-the-stages-answers-with-python-s-truthiness`](the-converter-reads-the-stages-answers-with-python-s-truthiness.md)
* [`the-converter-writes-the-emission-s-request-by-hand`](the-converter-writes-the-emission-s-request-by-hand.md)
* [`the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures`](the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures.md)

It goes after the emission's writing style —the five tasks Calandria took
the same day, linked from
[`emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines`](emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines.md)—,
because both rewrite most of `emit.rs`.

## Design

Calandria's, 2026-11-24, read at the-advocate `0d9f187c`, ports `4c23c9e`;
for taro before any code. Two phases: **A** makes every stage a function
the converter calls, with the same JSON in and the same files out, so the
ROM cannot change and the check is mechanical; **B** types the contracts,
one stage at a time, and that is where the judgement is.

### 1. The shape

**A stage is a function of its crate**, and its request and answer are
types of that same crate:

```rust
// rm2k-snes/wally/src/map.rs
#[derive(Serialize, Deserialize)] pub struct Request { pub map: i32, … }
#[derive(Serialize, Deserialize)] pub struct Answer  { pub layers: Layers, pub sprite: Option<Sprite>, … }
pub fn answer(place: &Place, request: &Request) -> Result<Answer>;
```

`Place` is what the flags say today —the dump, the folders searched, the
game and the RTP—, a plain struct of paths each stage already has under
another name (`wally::Game`, the screens' `GameArgs`…). **The converter is
the only crate that depends on every stage**: it builds each request and
reads each answer, which is what its 17,000 lines of decisions already do.

**Where an answer goes on to another stage untouched, the consumer depends
on the producer's crate.** That is the emission alone: it gets the screens'
answer, the battle model, the battle tables' slots, the troops' pages and
the window's Systems through the converter, which reads six fields of the
screens' answer and passes the rest on (`convert.rs` 1903-1921). mapdata
already depends on `rm2k-snes-battle` and `wally`; it adds
`rm2k-snes-screens` and `rm2k-snes-events`. All of it is inside
`rm2k-snes/`, so `test_layers.py` holds as it is, and a cycle does not
compile, so cargo keeps it a DAG: battle, Wally and images at the bottom;
events and screens over them; the emission; the converter.

**"No stage depends on another" is not true today, and this does not make
it true**: events uses battle's `fit`, screens battle's rules and Wally's
sprite layout, mapdata battle's database rules and Wally's sprite layout
(`cargo metadata`). Those are libraries of domain knowledge, not contracts.
If taro wants no edge between stages for contracts, the alternative is one
crate below them all, `rm2k-snes-contracts`, with only the types that cross
from one stage to another; it costs a crate and the types far from the code
that fills them, and buys nothing cargo does not already guarantee. What
it rules out is the third option, each consumer declaring its own copy and
the converter translating: that is the mirror the drafts above measured,
typed.

What each stage is called with today, and what it becomes (`file:line` in
`rm2k-snes/convert/src`):

| Today | Called from | Becomes |
|---|---|---|
| `wally map` | `maps.rs:668`, per map, 16 threads | `wally::map::answer` |
| `rm2k-snes-events scan`, `compile` | `compiler.rs:239` | `rm2k_snes_events::{scan, compile}` |
| `rm2k-snes-screens convert`, `boxes`, `faces`, `window`, `layout` | `screens.rs` | one function each in `rm2k_snes_screens` |
| `rm2k-snes-images fullscreen`, `picture`, `background`, `backdrops`, `battlers`, `animations` | `images.rs:21` | one function each in `rm2k_snes_images` |
| `rm2k-snes-battle tables`, `model`, `layout` | `convert.rs:820`, `:1772`, `compiler.rs:155` | `rm2k_snes_battle::{tables, model, layout}` |
| `rm2k-snes-mapdata emit` | `emit.rs:163` | `rm2k_snes_mapdata::emit` |
| `rm2k-snes-audio cartridge` | `convert.rs:2139`, `hand_over` | `rm2k_snes_audio::cartridge` |
| `rm2k-snes-patches` | `convert.rs:2096`, `hand_over` | `rm2k_snes_patches::write` |

`layout` (screens' and battle's) is constants with an empty request: a
plain call, not worth a cache entry. `wally layers`, `bakeable` and `split`
are not called by the converter: the first by no code (the book's
`tools.md` shows it as a command a person runs), the other two by three ABL
tests (section 4).

### 2. What a stage writes besides its answer

**A stage function writes nothing; it returns, and the converter writes.**
Three do today:

* the emission leaves each map's raw data next to the `.inc`
  (`materials::write_raw` in mapdata's `main.rs`), which is why it goes
  through `run_uncached`: the data is already a value, `Emitted.raw`, and
  goes back in the answer;
* `rm2k-snes-audio cartridge` writes `musicdata.inc`, `effects.json`, the
  `.msu` and `audio.json` into `--out`, and the converter reads
  `audio.json` back for its `losses` (`convert.rs:2167`): they become the
  answer's fields, and the converter writes the files where they went;
* `rm2k-snes-patches` writes the patches' TOML next to the ROM: the same.

So `run_uncached` and `hand_over` go; whether an answer is cached becomes
the converter's choice per call (the emission and the music stay uncached,
as now), not a property of how the stage writes. The check covers it: the
whole `build/<cartridge>/` byte for byte, not only the ROM.

### 3. The cache in the meantime

`stage.rs`' `key` keeps its shape —request, flags, each path by its
content— with two changes: **the binary is `std::env::current_exe()`**, the
converter (later `advocate`), and **the stage's name goes into the key**,
because the binary no longer tells stages apart: `screens layout` and
`battle layout` both take `{}` today. The tag goes to `"stage 2"`. In phase
A the value is the same pack of files (`pack`/`unpack`); a typed answer in
phase B is stored serialized (below). `NO_CACHE=1` stays the check, and the
only one: every cartridge of the nine games built with it and with the
cache, byte for byte, against the tools before the change. For ABL with
`--without-tracks`: `NO_CACHE=1` also turns off the tracks' cache, and
would synthesize 2.4 GB again.

**What one key costs, measured** on ports `4c23c9e` with the global tools
(the-advocate main), `just cartridges --force`, sixteen threads, nothing
else running; "stages cold" is a cache with `ca65`, the zips and the tracks
warm and no stage answers, which is what any change to the converter or a
stage leaves:

| | warm | stages cold |
|---|---|---|
| ABL, 11 cartridges, 520 answers | 16 s | 58 s |
| Book of Three | 4 s | 10 s |
| Desert Nightmare | 9 s | 31 s |
| Dooms 2 | 3 s | 8 s |
| El Dorado | 2 s | 3 s |
| Frozen World | 5 s | 34 s |
| Sunset over Imdahl | 6 s | 94 s |
| Vampires Dawn | 21 s | 97 s |
| Zounds | 7 s | 17 s |
| **the nine, one after another** | **73 s** | **352 s** |

Today a change to the converter's own code (most changes) keeps every
stage answer; with one key it costs the second column, on every worktree
that builds it first. That is the price taro accepted; the per-stage key is
[`a-stage-s-cache-key-once-it-is-a-library`](a-stage-s-cache-key-once-it-is-a-library.md).
The "ten minutes" in that task is about the nine games, not ABL alone:
six minutes cold against a minute and a quarter warm.

**How a typed answer is stored**: today's answers are 56% PNG, 21% raw
tiles and 24% JSON by bytes (a sample of 1,500 of the 10,086 in the shared
cache, 3.6 GB). As JSON number arrays the bytes would triple the cache;
proposed: serde_json, with the byte fields through one serde adapter as
base64 (+33% on those, about +25% overall), from a registry crate
(`serde_with` or `base64`), not ours. A binary serde format (postcard)
would be smaller and is the alternative if the size matters.

### 4. The stages' binaries

**In phase A every stage binary stays**, as a thin `main` over the same
library function: parse the flags, read the request, call, write the files.
The converter stops running them; the tests keep calling them unchanged.
`rm2k-snes-cartridges`' fingerprint (`CONVERTER_TOOLS`) then lists only the
converter: the others no longer reach a ROM.

Who calls what, besides the converter (grep of ports `4c23c9e` and
the-advocate's `test-game/` and `rm2k-snes/harness/`):

| Binary | Subcommands the tests call | Where |
|---|---|---|
| `wally` | `bakeable`, `split` | `map_stage.py`: 3 ABL tooling tests |
| `rm2k-snes-events` | `scan`; `culprits` is a person's (`game.just`) | the-advocate's `game.py`, ports `tests/games.py` |
| `rm2k-snes-screens` | `render`, `equip`, `layout`, `window`, `refit` | `screen_stage.py`, `screens.py`: 7 files |
| `rm2k-snes-images` | `backdrops`, `battlers`, `animations` | `image_stage.py`: 2 files |
| `rm2k-snes-battle` | `simulate`, `lines`, `experience`, `field-skill`, `model`, `layout` | `model.py`: 22 files; Zounds' 2 |
| `rm2k-snes-mapdata` | `vram`, `engine`, `pages`, `compress` | `screen_stage.py`; the-advocate's `engine.py`, which ABL's `experience.py` and `events.py` and the test game's `test_variables.py` read; `test_pages.py`, `test_lz2.py` |
| `rm2k-snes-convert` | `scan`, `compile`, `leaders`, `map-context`, `boxes` | `converter.py`: 26 ABL files; `scan` also `test_frozen_world_cursor.py` |
| `rm2k-snes-audio` | `constants`, `decode`, `msu-index`, `msu-sign`, `pitch`, `wav`, `find-song`, `volume-ceilings` | `music.py` (12 files), `test_music_ceilings.py` |
| `rm2k-snes-patches` | `--check`, `build` | `test_patches.py`, the justfile |

**Two gaps in
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md)'s
list**: the converter's own queries (`leaders`, `map-context`, `boxes`,
`compile` —it names only `scan`—), which one-advocate-command cannot keep
once the converter is a library; and the audio's eight subcommands.

**The order between the three tasks**: phase A does not wait for the test
tasks and does not get in their way —the binaries answer the same—. Phase
B types only what the converter calls; where a command is also the tests'
(`screens layout`/`window`, `images backdrops`/`battlers`/`animations`,
`events scan`, `battle model`/`layout`), its `main` has to keep writing the
same keys, and the ABL suite is what checks it. So: phase A now; the two
test tasks' classifications in parallel; phase B starting with the stages
whose test calls do not overlap the converter's (mapdata, Wally), and the
overlapping ones after the test tasks have taken their callers away, if
they are done by then. The binaries go last, when nothing calls them:
`culprits`, `rm2k-snes-patches` and the audio's person commands stay
commands, as one-advocate-command says.

### 5. The order of work

Every step is verified the same way: the nine games' cartridges with
`NO_CACHE=1 just cartridges --force` (ABL `--without-tracks`), every
`build/<cartridge>/` compared with `diff -r` against the same build with
the tools before the step, `converter.log` aside and read; then once with
the cache warm; and `just test`. Phase B steps that change what a test-called
`main` writes run those tests too.

**Phase A, mechanical** (no step changes a ROM, a cache value or a binary's
output; sizes are estimates from the `main.rs` bodies that move):

| Step | What | Size | Parallel |
|---|---|---|---|
| A0 | `stage.rs` calls a function: the key with `current_exe` and the stage's name; `pack` kept | ~100 lines | first, alone |
| A1 | Wally: `do_map` into the library; `maps.rs` calls it | ~60 moved | after A0, any order |
| A2 | events: `scan`, `compile` | ~50 | " |
| A3 | screens: five commands, ~250 lines out of `main.rs`; **and the screens' `thread_local!` letters reset at each entry**, which a process got for free (`texts.rs:12`: set by `convert`, it would leak into a later `faces` or `window` on the same thread) | ~260 | " |
| A4 | images: six commands | ~200 | " |
| A5 | battle: `tables`, `model`, `layout` | ~100 | " |
| A6 | mapdata `emit`, the raw data in the answer | ~120 | " |
| A7 | audio `cartridge`, ~260 lines out of its `main.rs`, files in the answer | ~300 | " |
| A8 | patches, files in the answer | ~150 | " |
| A9 | `run_uncached`, `hand_over`, `which`, `Scratch` go; `CONVERTER_TOOLS` is the converter | -200 | last |
| A10 | the prose: AGENTS.md (which crates to `install-local` for a stage change: the converter now), the book's `internals/the-converters-stages.md` and `pipeline.md`, battle's README "One stage of a converter" | judgement | own commit |

A1-A8 each touch their stage crate, one converter file and one line of its
`Cargo.toml`: up to eight agents at once, conflicts only in that line. The
one log change expected in phase A: the event compiler's "WARNING, event N
is left out" (`pages.rs:482`) reaches `converter.log` for the first time:
448 lines in Vampires Dawn, none in the other eight —see
[the draft](the-event-compiler-s-left-out-warning-never-reaches-the-log.md)—.

**Phase B, typed, one stage per step**, each with the reading by hand it
removes; each a judgement change verified byte for byte (net lines, from the
drafts' estimates where there is one, by analogy where not):

| Step | What | Takes in | Size |
|---|---|---|---|
| B0 | the emission's fallbacks for old answers go, its two fixtures regenerated | [fallbacks draft](the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures.md) | -40 |
| B1 | the emission's request built as `mapdata::request::Emit`, `Serialize` derived; `scene` typed | [request draft](the-converter-writes-the-emission-s-request-by-hand.md) | -60 to -100 |
| B2 | battle's `tables` and `model` typed; `Emit::battle_model`, `BattleTables::slots` | | -50 to -100 |
| B3 | the screens' answer typed; `Emit::screens`, `window_systems`; mapdata's `json.rs` goes | [screens draft](the-emission-reads-the-screens-answer-and-the-battle-model-by-name.md) | -100 to -200 |
| B4 | Wally's `map` typed; `map_info` on fields | [truthiness draft](the-converter-reads-the-stages-answers-with-python-s-truthiness.md) | -100 to -200 |
| B5 | events' `scan`/`compile` typed; `troop_pages`; `PageRecord`'s `Value`s | | -50 to -150 |
| B6 | images' six answers typed; the picture key | | -30 to -80 |
| B7 | audio's and patches' requests typed; the five `fn int` and the `truthy`s go with the last reader | | -30 |

B0-B3 rewrite `emit.rs` and go in that order, one agent; B4, B5 and B6 go
beside them, each its own agent (they touch `maps.rs`, `compiler.rs`,
`pictures.rs`/`images.rs`). A typed answer moves its stage's cache values to
the serialized form in the same step: the first build after each is cold
for that stage, which is expected and not a failure.

### 6. Risks, and what this did not settle

* **State a process got fresh**: the screens' letters (A3); Wally's two
  memos (`layers.rs:527`, `:599`), keyed by the dump's path and the map,
  which in one converter process grow over every map and, once `advocate`
  builds several cartridges in one process, could hand one cartridge's
  reach to another with the same dump and other common events —for
  one-advocate-command to look at, not this—; ditto's `thread_local!` is
  scoped and safe. Grepped across the workspace, nothing else.
* **A panic** in a stage used to be a process that died with its message;
  in a thread of `thread::scope` it takes the converter down. A
  `catch_unwind` around each call keeps "map N:" in the message; not
  measured whether any stage panics on a real game.
* **The log** changes where a stage wrote to stderr and succeeded: today
  that output is dropped (`run_uncached` uses `.output()`); in phase A it
  reaches `converter.log`. Only the event compiler's warning was found
  (Vampires Dawn's 448 lines).
* **Phase B's field order** changes the requests' keys and the answers'
  bytes: the cache goes cold once per stage, and the emission's request
  JSON changes order (not the ROM).
* **The thin `main`s writing the old keys** for the tests are a cost for
  every phase B step whose command the tests also call, until the test
  tasks remove those callers; not counted in the sizes above.
* **Not measured**: a full `NO_CACHE=1` build of the nine games (the check
  every step needs; it is minutes with sixteen threads, by the stages-cold
  numbers, plus `ca65`); the emission's own time, which stays uncached; and
  whether linking `rm2k-snes-audio` (with `retro.rs`' `dlopen`) into the
  converter changes anything for the static musl goal —nothing calls
  `retro.rs` from `cartridge`, so the linker should drop it—.
* **Not decided here, for taro**: producer-owned types with the emission
  depending on screens and events, or a contracts crate; base64 JSON or a
  binary format for the cache; and whether the two test tasks' lists take
  in the converter's queries and the audio's commands.

## taro's answers to the design

> Let's go with your recommendations.

(taro, 2026-11-24, on Hornero's recommendations to the four questions above:)

1. **The types live in the crate that produces them**; the emission
   depends on screens and events, no `rm2k-snes-contracts`.
2. **The cache stays JSON, with bytes in base64**; a binary format is
   decided later, with
   [`a-stage-s-cache-key-once-it-is-a-library`](a-stage-s-cache-key-once-it-is-a-library.md).
3. **The two gaps go into**
   [`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md):
   the converter's own queries and `rm2k-snes-audio`'s subcommands.
4. **The single key's cost, as measured, is accepted.**

## How a stage plugs in (A1–A8)

Calandria's, with A0 (the-advocate `calandria-a0`). A0 left `stage.rs` able
to call a stage as a function and converted the battle to prove it, so
**A5 is done**: its commit is the model for every other step, and is read
before starting one.

**The converter side** is one call, in `rm2k-snes/convert/src/stage.rs`:

```rust
pub type Files = BTreeMap<String, Vec<u8>>;           // name -> bytes, as --out held them
#[derive(Clone, Copy)] pub struct Stage { pub binary: &'static str, pub command: &'static str }

pub fn call<E: Display>(stage: Stage, request: &Value, flags: &[OsString],
                        answer: impl FnOnce() -> Result<Files, E>) -> Result<Files>;
pub fn call_uncached<E: Display>(stage: Stage,
                                 answer: impl FnOnce() -> Result<Files, E>) -> Result<Files>;
```

* `request` and `flags` are **what the binary was run with**, the same
  `Value` and the same `Vec<OsString>` the call site already builds for
  `stage::run` —without `--request` and `--out`—. They are what the cache
  key reads (each path in them by its content), so **the closure must read
  nothing they do not name**: it gets the same paths and the same request,
  captured from the same variables. Do not build the flags differently:
  the key then misses what the stage reads.
* `answer` is the stage crate's function. Its error is anything `Display`,
  and the converter stops with `"<binary>: <error>"`, which is what every
  `main` printed (mapdata's prints `bad.message()`: map it in the closure if
  its `Display` differs). A panic stops the conversion with `"<binary>
  <command> panicked: …"` instead of taking the converter down.
* **There is no registry**: a `const` per stage next to the call site
  (`const BATTLE_TABLES: stage::Stage = …` in `convert.rs`) is the whole
  registration, so eight agents do not meet in one list.
* **Uncached where it was uncached**: the emission (`run_uncached` today)
  goes through `call_uncached`; constants with an empty request
  (`screens layout`, like the battle's) are a plain call of the crate's
  function, no `stage::` at all.
* What reads the answer does not change: `stage::json(&files, "x.json")`,
  `stage::text(&files, "x.inc")`.

**The stage side**, in the stage's crate:

* a new module **`src/stage.rs`**, `pub mod stage;` in `lib.rs`, with
  `pub type Files = BTreeMap<String, Vec<u8>>;` and **one `pub fn` per
  command the converter calls**, named as the command, taking the paths its
  flags gave (`data: &Path`, …) and `request: &Value`, returning
  `Result<Files>` with the crate's own error. Each **returns its files and
  writes nothing**: where `main` or a library `write(dir)` wrote into
  `--out`, it becomes a function that answers the bytes (the battle's
  `Tables::write` became `Tables::files`), and the bytes are the same
  —`to_string_pretty(...) + "\n"` stays exactly as it was—;
* where a request was read from a file, the reading splits in two: the file
  into a `Value`, and the `Value` into what the stage uses (the battle's
  `Request::read` kept its path and calls the new `Request::of`);
* **`main.rs` keeps every subcommand and flag**: it reads `--request` into a
  `Value`, calls the `stage::` function, and writes each file into
  `--out`. The tests call the binaries and must not see a difference.

**One A-step's diff** is then: the crate's new `stage.rs` and its `lib.rs`
line; its `main.rs` over it; the library function that wrote files now
answering them; in the converter, the call site from `stage::run(BINARY,
PROJECT, command, &request, &flags)` to `stage::call(STAGE, &request,
&flags, || the_crate::stage::command(&path, &request))` and the `const`;
and, if the crate is not one yet, its line in the converter's
`Cargo.toml` (wally, mapdata, events and battle already are). `which`,
`run`, `Scratch` and the `BINARY`/`PROJECT` constants stay until A9, even
when a step leaves them unused in its file.

**What to check in the step**, besides the byte-for-byte build:

* **State a process got fresh**: `thread_local!`, `static`, memos. The
  screens' letters (A3) and Wally's memos (A1) are known; grep the crate.
* **JSON key order.** The converter links `serde_json` with
  `preserve_order`, and cargo turns the feature on for every crate in the
  converter's binary: a stage's `json!` objects keep their insertion order
  there, where its own binary (without the feature) sorted them. The
  answer's bytes change; what reads it by key does not. **A stage that
  iterates a JSON object** —the request's or the dump's— sees another order
  in the converter than in its binary: look for `as_object()` and `for (k,
  v) in` in the crate. The battle had none on the converter's path.
* **What it printed to stderr** while succeeding was dropped by `run`; now
  it reaches `converter.log`. Say which lines are new.
* The ROMs and every file of `build/<cartridge>/` byte for byte against
  the tools before the step, with `NO_CACHE=1 just cartridges --force` in
  the nine games (ABL `--without-tracks`), `converter.log` and
  `stamp.txt` aside —the stamp carries the tools' fingerprint—; then a
  warm build, which has to answer from the cache.
* **Install** the converter and the stage's crate: `just install-local
  .local-tools convert <crate>` —the converter links the stage now, and
  the crate's binary is what the tests call—.

## Log

### 2026-11-23, Hornero: written, waiting for the emission's writing style

Nothing done yet.

### 2026-11-23, Hornero: whether the stages stay processes comes first

Added to the design, at taro's request.

### 2026-11-23, Hornero: libraries first, the cache later

taro's call; the per-stage key went to its own task.

### 2026-11-24, Hornero: the design taken by Calandria

The design only, for taro, before any code; after Mulita's assemble work merged (the-advocate `0d9f187c`).

### 2026-11-24, Calandria: the design, for taro

Written above, under `## Design`; no code. Measured on ports `4c23c9e` with
the global tools, in a worktree of my own: every game's `just cartridges
--force` warm and with the stages' answers cold (a cache with only `ca65`,
the zips and the tracks), and the share of PNG, tiles and JSON in a sample
of the stage cache. Grepped the ports' harness, its tests and the-advocate's
test game for every stage subcommand they call. Found on the way, not
fixed: the event compiler's left-out warning never reaches the log (draft).
The task stays in `doing`: the code waits for taro's reading.

### 2026-11-24, Hornero: taro answered; A0 goes to Calandria

As above.

### 2026-11-24, Calandria: A0, and the battle through it (A5)

On the-advocate `calandria-a0`, from `0d9f187c`; ports `4c23c9e`, which A0
does not touch. Three commits: `stage.rs`' plumbing alone; the battle
converted with it, to prove it end to end —the smallest stage the
converter already linked, so A5 is done and is the model for the rest—;
and one sentence of battle's README, the only prose A0 made untrue. How a
stage plugs in is above, under "How a stage plugs in (A1–A8)".

#### What A0 is

`stage::call(stage, request, flags, || crate::stage::command(..))` and
`call_uncached`, answering the same `Files` as `stage::run`. The key of a
function stage is `"stage 2"`, `current_exe` by content and `<binary>
<command>`; a stage that is still a process keeps its key exactly as it was
(`"stage 1"`, its own binary), so its answers on disk are still found until
its step. `pack`/`unpack` unchanged. A panic in a stage is a stop with its
message (`<binary> <command> panicked: …`); a no is `<binary>: <message>`,
as each `main` printed it. Three new unit tests in `stage.rs`: two stages
asked `{}` get different keys and neither is the old process key; a no and
a panic stop with their messages; a function asked twice is called once.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), the global tools (`0d9f187c`) against these: **the 20
`.sfc` equal**, and every file of every `build/` too —4,531 files in ABL,
5,313 in Vampires Dawn—, the 20 `converter.log` included. Set aside only
`stamp.txt`, which carries the tools' fingerprint, and the `.o`/`.dbg`,
which differ only in the sources' mtimes `ca65` records. Then twice with
the cache: the first stored **35 new answers** —18 `tables`, 17 `model`,
nothing else—, because the battle's key is a new one; the second stored
none and answered everything from the cache —the nine games in 72 s, 73 s
with the global tools warm—, and its builds are byte for byte the global
tools' warm builds, `.o` included.

**The old entries**: the 105 battle answers keyed by `rm2k-snes-battle`'s
binary (54 `tables`, 51 `model`, 1.5 MB) stay on disk. The tools built from
main before this still hit them; once this is installed nothing asks for
them, and the cache has no eviction, so they stay until someone cleans it.
The same will happen with each stage's step.

**JSON key order**: the converter's `serde_json` has `preserve_order`, the
battle's binary does not, so the in-process answers' bytes are in insertion
order where the binary's were sorted. Nothing reads them but by key, and
nothing in the battle iterates an object on the converter's path; the
builds above confirm it. Written into the recipe for the other stages.

#### The suites

With these tools first in the PATH, on the branch with main merged (main
had not moved): the-advocate's `just test` 29 passed; `just rust-test
--no-fail-fast` 1,240 passed, 0 failed, 3 ignored; the test game
(`SOUNDFONT=FluidR3_GM.sf2 just test-game`) 231 passed, 6 skipped; the
ports' `just boot` 218 passed; ABL's `just tests` 1,694 passed, 2 skipped.
No golden moved: the ports' worktree is clean. `cargo fmt --check` and
`clippy --all-targets` clean on `rm2k-snes-battle` and
`rm2k-snes-convert`. The battle's subcommands the tests call —`model`,
`layout`, `simulate`, `lines`, `experience`, `field-skill`— now go through
the same `stage` functions inside the binary; the 22 files of `model.py`
and Zounds' two are what covers them.

**Install when merging**: `convert` and `battle` (`just install convert
battle`). The task stays in `doing`: A1–A4 and A6–A10 are next.

### 2026-11-24, Hornero: A1-A4 to four agents at once

After A0 and A5 merged (the-advocate `394e634a`): Aguará A1 (Wally), Cardón A2 (events), Carpintero A3 (screens), Chajá A4 (images). A6-A8 after them, so that eight suites do not fight for the CPU.

### 2026-11-24, Chajá: A4, the images

On the-advocate `chaja-a4`, from `394e634a`, with main (`508b8c95`) merged;
ports `4c23c9e`, which A4 does not touch. One commit, `c2b601cc`, on the
recipe above: `rm2k_snes_images::stage` answers the six commands the
converter asks —`fullscreen`, `picture`, `background`, `backdrops`,
`battlers`, `animations`— as `<command>.json`, the same compact
`to_string()` with no newline the binary wrote; the converter's `images.rs`
calls them through `stage::call` with the request and flags it ran the
binary with (`--data` for `animations`, nothing for the rest), one `const`
per command. `rm2k-snes-images` joins the converter's `Cargo.toml`.

Each command has two doors: the converter's takes the parsed request
(`request::of`, a relative path stays relative to the current directory;
the converter only sends absolute ones), and an `_of` one takes it already
typed. The binary is a `main` over the `_of` ones and keeps reading its
file with `request::read`, so its paths stay relative to the request and
its complaints keep the file's name and line and column.

#### What was checked about the step

* **State**: none in the crate, nor in `rm2k-render`, Adeleine or Voodoo
  —no `thread_local!`, `static`, `OnceLock` or memo—; `animations`' sheet
  map lives inside the call.
* **stderr**: the crate prints nothing while it succeeds (its only
  `eprintln!` is `main`'s error); the 20 `converter.log` are byte for byte
  the global tools'.
* **JSON key order**: the requests are serde structs, so nothing iterates
  an object; with `preserve_order` only the answers' keys change order,
  and the converter reads them by name.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), the global tools (`394e634a`) against these: **the 20
`.sfc` equal** and the 19,469 files of the nine `build/` too,
`converter.log` included; aside only `stamp.txt` and the 40 `.o`/`.dbg`,
which differ in the mtimes `ca65` records. Then twice with the cache: the
first stored **1,049 answers** —688 `picture`, 166 `background`, 116
`animations`, 17 `fullscreen`, 17 `backdrops`, 10 `battlers`, and 18
`tables` and 17 `model` of the battle, whose key is the converter's binary
and moved with it—; the second stored none, and its builds equal the
uncached ones.

Found, not fixed: `Background::resolve` leaves a relative `under` relative
to the current directory, the binary's only path that does not follow the
request
([draft](rm2k-snes-images-leaves-a-relative-under-relative-to-the-current-directory.md));
nobody sends one.

#### The suites

On the merged branch, its tools first in the PATH: the-advocate's `just
test` 29 passed; `just rust-test --no-fail-fast` 1,240 passed, 0 failed, 3
ignored; the test game (`SOUNDFONT=FluidR3_GM.sf2`) 231 passed, 6 skipped;
the ports' `just boot` 218 passed; ABL's `just tests` 1,694 passed, 2
skipped. No golden moved. `abl.sfc` `3bf35fd7665c`. `cargo fmt --check` and
`clippy --all-targets` clean on `rm2k-snes-images` and
`rm2k-snes-convert`. The tests' calls to `backdrops`, `battlers` and
`animations` (`image_stage.py`) go through the binary and its `_of`
functions; `fullscreen`, `picture` and `background` are covered only by
the builds above.

**Install when merging**: `convert` and `images` (`just install convert
images`).

### 2026-11-24, Cardón: A2

On the-advocate `cardon-a2`, from `394e634a`, with main (`508b8c95`)
merged; ports `cardon-a2` at `4c23c9e`, untouched. One commit, on the
battle's model: `rm2k_snes_events::stage::{scan, compile}` answer
`events.json` as the binary wrote it, the binary is a main over them, and
`compiler.rs` calls both through `stage::call` with the same request and
`--data` it ran the binary with. `read_request` splits the file from
`Request::from_json`, which already existed; the library's `write` went to
the binary. `culprits` stays a command, as it was.

#### What was checked

* **State**: the crate's only lazy state is `Game::windows`, a `OnceLock`
  in the `Game` each call builds; no `thread_local!` or `static`.
* **Key order**: the request's objects are read by `by_map` into
  `BTreeMap`s, so nothing the compiler reads sees `preserve_order`. Its
  answer does: `events.json` now keeps insertion order, and two files of
  every `build/<cartridge>/` change bytes but parse equal,
  `degradations.json` and `events-request.json` (the compile request carries
  the scan's `common_pictures`). Deterministic: a second cold build gave
  the same bytes.
* **stderr**: the compiler's "map N: WARNING, event E is left out" now
  reaches `converter.log`, after the converter's stdout: **672 lines in
  Vampires Dawn, 224 events in 89 maps, each three times** (scan once,
  compile twice; the design's 448 was compile alone), none in the other
  eight. Only when the compiler runs: a build that finds its answer in the
  cache prints none. The draft
  [`the-event-compiler-s-left-out-warning-never-reaches-the-log`](the-event-compiler-s-left-out-warning-never-reaches-the-log.md)
  stays a draft, rewritten with what is left.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), the global tools (`394e634a`) against these: **the 20
`.sfc` equal**, and every file of every `build/` but the two JSON above,
`stamp.txt`, the `.o`/`.dbg` (mtimes) and Vampires Dawn's `converter.log`.
Then twice with a cache of its own (`CACHE=` a scratch directory): the
first stored 2,703 stage answers and its builds equal the `NO_CACHE`
ones; the second stored none, and its builds equal the first's but for
the 672 warnings.

#### The suites

On the merged branch, with its `convert` and `events` first in the PATH:
the-advocate's `just test` 29 passed; `just rust-test --no-fail-fast`
1,240 passed, 0 failed, 3 ignored; the test game (`SOUNDFONT=FluidR3_GM.sf2
just test-game`) 231 passed, 6 skipped; the ports' `just boot` 218 passed;
ABL's `just tests` 1,694 passed, 2 skipped. No golden moved: the ports'
worktree is clean. `just lint` green on the merged tree (main fixed the
three known ones). The binary's `scan` and `compile` now go through the
same `stage` functions; the crate's `command_line.rs` and the harness's
`scan` calls (the-advocate's `game.py`, the ports' `games.py`) cover them.

Then main moved to `dedf5252` (Chajá's A4) and merged cleanly, the
`Cargo.toml` line included; on that tree only clippy, fmt and `just
crate-test convert` (86 passed) were run, not the suites.

**Install when merging**: `convert` and `events` (`just install convert
events`). The task stays in `doing`.

### 2026-11-24, Aguará: A1

On the-advocate `aguara-a1`, from `394e634a`, main (`508b8c95`) merged;
ports `4c23c9e`, untouched. Four commits: Wally's reach memos scoped to one
map's conversion; Wally through `stage::call`; a `cargo fmt` of
`events.rs` that main's `508b8c95` also made, identical; and the two
sentences of Wally's README and crate doc that said it writes into a
directory.

#### What A1 is

`wally::stage::map(dump, search_dirs, request)`, called from
`maps.rs`' `run_requests` on the same sixteen threads, under `WALLY_MAP`
and the same `--data`/`--search-dir` flags, built from the same absolute
paths the closure gets. `layers::write` and `map::write` became
`layers::files` and `map::files`; the PNGs go through a new
`voodoo::image::encode`, which `voodoo::image::write` now calls. The
binary keeps `layers`, `map`, `bakeable` and `split` as a `main` over
`wally::stage`.

#### State, stderr, key order

* **The memos** (`layers.rs` `below` and `standing`): a `static`, keyed by
  the dump, the map, the reach and the starts, never the ChipSet. In one
  converter process a ChipSet variant of a map (same map, reach and
  starts, other passability, through the request's `chipsets`) would get
  the map's own cells, or the other way round, whichever thread went
  first. Now per thread and emptied by `map::convert` on entry: what the
  process gave. **Measured, the risk did not show**: a converter without
  the reset built Frozen World and Vampires Dawn, the two games with
  variants, byte for byte the same as with it. The reset stays: it costs
  nothing, it is the process's behaviour, and it bounds what the memos
  hold. Nothing else in Wally or what it links keeps state (ditto's
  `thread_local!` is scoped).
* **stderr**: Wally prints only `main`'s error; `converter.log` gains no
  line (the 20 are byte for byte the same).
* **Key order**: Wally iterates six request objects (`map_files`,
  `chipset_files`, `dropped_events`, `walls`, `chipsets`,
  `palette_weight`), each into a map keyed by number or name, so the
  order does not matter. Its answers' keys now go in insertion order;
  the converter reads them by key, and `maps.rs`' one `as_object()`
  (`shared`) reads by key too.

#### The builds

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), the global tools (`394e634a`) against these: **the 20
`.sfc` equal**, and every file of every `build/`, the `converter.log`s
included; set aside `stamp.txt` and the `.o`/`.dbg` (the sources' mtimes).
Then twice warm: the first stored new answers (Wally's new key; the count
is shared with three other agents building at once), the second **stored
none**, and both are byte for byte the cold build's.

#### The suites

With these tools first, on the merged branch: `just test` 29 passed;
`just rust-test --no-fail-fast` 1,240 passed, 0 failed, 3 ignored; the
test game 231 passed, 6 skipped; the ports' `just boot` 218 passed; ABL's
`just tests` 1,694 passed, 2 skipped. No golden moved. `cargo fmt --check`
and `clippy --all-targets` clean on `wally`, `voodoo` and
`rm2k-snes-convert`. No new test: the reset has none of its own, since the
variants did not show the risk; the ABL tooling tests that call `wally
bakeable` and `split` cover the binary over `wally::stage`.

**Install when merging**: `convert` and `wally`, and whatever else links
`voodoo` (`screens`, `images`) only to stay in step: `voodoo::image::write`
writes the same bytes.

### 2026-11-24, Carpintero: A3, the screens

On the-advocate `carpintero-a3`, from `394e634a`, with main (`dedf5252`,
A4 included) merged; ports `4c23c9e`, which A3 does not touch. Four
commits on the recipe above:

* `dc0a3292`: a custom menu's `special` values in the order of their keys
  as text (see "JSON key order" below), with its test; `43764963` renames
  that test's subject, which `test_no_game_names` caught as ABL's.
* `6979ca09`: `rm2k_snes_screens::stage::{convert, boxes, faces, window,
  layout}` answer `<command>.json`, the same one-line `to_string()` with
  no newline the binary wrote; the converter's `screens.rs` calls them
  through `stage::call`, one `const` per command, and `layout` is a plain
  call. `Place` holds what the game flags said (dump, game folder, RTP,
  System, window background, text ink), and the converter builds it and
  the flags the key reads in one function, `game_place`, so the two cannot
  disagree. `render`, `equip` and `refit`, which only the tests call, stay
  in `main`, over `game_with_font` and `measure_of`, which moved to
  `stage`. The screens' `BINARY`/`PROJECT` constants in the converter went
  with their last use. `rm2k-snes-screens` joins the converter's
  `Cargo.toml`.
* `012a7dd9`: each of the four has an `_of` door that takes the request
  read; the binary goes through it, so a bad request file still names its
  path, as Chajá did for the images.

#### What was checked about the step

* **State**: the screens' letters (`texts.rs`' `thread_local!`, set by
  `convert` through `carry_letters`). A guard, `stage::Fresh`, empties
  them when each stage starts and again when it ends, panics included.
  `no_stage_leaves_letters_for_the_next` was shown red with the two resets
  commented out: after `convert` with `é` carried (font `low-variable`,
  which draws it) the letters stayed `['é']`, and `item_text` would write
  `é` where a fresh thread writes `e`. Today no stage after `convert` on
  the converter's thread (`faces`) writes through `item_text`, so the leak
  had no output yet. Nothing else in the crate, nor in `rm2k-snes-text`,
  Adeleine, Voodoo, `rm2k-render` or `rm2k-rules`; the screens reach
  Wally only for its sprite layout, not its memos.
* **JSON key order**: one object the screens iterate reaches the ROM, a
  custom menu table's `special` (`custom_menu.rs`), pushed in iteration
  order into the menu's blob. The binary saw the keys sorted as text; in
  the converter they would come in the project file's order. Sorted
  explicitly now (`dc0a3292`); its test is red without the sort under
  `cargo test --workspace`, where the converter's `preserve_order` reaches
  the crate. No game has more than one special value (ABL's `99`), so no
  build could show it. The other objects iterated (`by_number`,
  `lists_by_number`, `files`, `parties`, a menu's `table`) collect into
  maps or sort. The answers' own keys change order; the converter reads
  them by name and the emission's binary parses them sorted.
* **stderr**: the crate prints nothing while it succeeds; the 20
  `converter.log` are byte for byte the global tools'.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), the global tools (`394e634a`) against these (A3 alone,
before merging main): **the 20 `.sfc` equal**, and the 19,469 files of the
nine `build/` too, `converter.log` included; aside only the 20 `stamp.txt`
and the 40 `.o`/`.dbg`, whose only differences are the mtimes `ca65`
records (checked on every `.dbg` with the mtimes stripped). Then twice with
the shared cache: the first stored the screens' new answers —19 `convert`,
10 `window`, 9 `boxes`, 5 `faces`— and 19 `tables` and 18 `model` of the
battle, whose key moved with the converter; its builds equal the uncached
ones. The shared cache had other agents storing at the same time, so the
"stores none" check went to a private one (`CACHE=` a scratch directory):
a first build filled it with 2,702 stage answers, the second **wrote
nothing to it** —no file of any category— in 108 s for the nine, and its
builds equal the uncached ones.

After merging main (`dedf5252`, with A4), the same cold build with these
tools (`convert`, `screens` and `images` installed from the merged tree)
against the global tools at `394e634a` again: the 20 `.sfc` and the 19,469
files equal, aside `stamp.txt` and the `.o`/`.dbg` mtimes.

#### The suites

On the branch with main at `dedf5252` merged, `convert`, `screens` and
`images` first in the PATH: the-advocate's `just test` 29 passed (the first
run caught the ABL name in the special values' test, `43764963`); `just
rust-test --no-fail-fast` 1,234 passed, 8 failed, 3 ignored, and the eight
pass run again alone: seven of `fxpak`'s pty tests, six of them all naming
`/dev/pts/1` as another client's
([draft](fxpak-s-pty-tests-share-ptsname-s-buffer.md): `ptsname`'s static
buffer shared by parallel threads), and `a_cached_object_gives_the_dbg_a_
fresh_one_gives`, already a [draft](the-cached-dbg-test-sees-a-date-move.md);
the test game (`SOUNDFONT=FluidR3_GM.sf2`) 231 passed, 6 skipped; the
ports' `just boot` 218 passed; ABL's `just tests` 1,694 passed, 2 skipped.
No golden moved: the ports' worktree is clean. `abl.sfc` `3bf35fd7665c`.
The tests' calls to `layout`, `window` and `refit` (`screen_stage.py`,
`screens.py`) go through the binary and its `_of` doors; `convert`,
`boxes` and `faces` are covered by the builds above.

Then main moved to `f46074d6` (A1 and A2) and was merged too: with the four
steps in, nothing runs a cached stage as a process, so `stage::run` and
`Answerer::Process` are dead and the converter warned twice; `ec883b2a`
gives them an allow until A9. On that tree only `cargo fmt --check`,
`clippy --all-targets -D warnings` (clean on `rm2k-snes-screens` and
`rm2k-snes-convert`) and the two crates' tests (129 passed) ran; the
suites did not.

**Install when merging**: `convert` and `screens` (`just install convert
screens`).

### 2026-11-24, Hornero: A1-A4 merged and verified together; A6-A8 to three agents

the-advocate `8b069fc2`, with `convert wally events images screens` installed: `just lint` clean, `just test` ok, `rust-test` 1242 passed 0 failed, test game 231 passed 6 skipped, `boot` 218 passed, ABL 1694 passed 2 skipped; the nine games' release ROMs byte for byte the ones in the last delivery. A6 (mapdata) to Calandria, A7 (audio) to Mulita, A8 (patches) to Tijereta.

### 2026-11-24, Mulita: A7, the music

On the-advocate `mulita-a7`, from `8b069fc2` (main had not moved when
merging); ports `mulita-a7` at `4c23c9e`, untouched. One commit,
`05f27b7b`, on the recipe above: `rm2k_snes_audio::stage::cartridge`
answers `musicdata.inc`, `music.json`, `audio.json`, `audio-job.json`,
`effects.json` and the `.msu`, the last under `stage::MSU` because it does
not go into `--out` but where `--msu` says. It writes nothing. The
converter calls it through `stage::call_uncached` under `AUDIO_CARTRIDGE`,
writes each file into the cartridge's directory and the `.msu` alongside
and renamed, as the binary did, and reads the `losses` from the answer
instead of from `audio.json` on disk. `compile`, which only a person or a
test runs, goes through the same `stage::compile`; the binary is a `main`
over both and keeps every subcommand and flag. `rm2k-snes-audio` joins
the converter's `Cargo.toml`. `msu` and `volume-ceilings` did not move.

**Uncached, as `hand_over` was**: one answer per cartridge, and it reads
the runtime's `far_ram.s` (`BOOT_FRAMES_FLOOR`) through `suite::runtime()`,
which no flag names: a key would miss it. Whoever gives it a key, in
[`a-stage-s-cache-key-once-it-is-a-library`](a-stage-s-cache-key-once-it-is-a-library.md),
has to name that file.

#### State, stdout and stderr, key order

* **State**: none on the `cartridge` path. `retro.rs`' `static` is the
  libretro core's, which `cartridge` never reaches; `tracks.rs`'
  `OnceLock`s live in an instance; nothing in Gunter, `rm2k-rules` or
  `bytecode`.
* **stdout**: the process's went out with the converter's
  (`Stdio::inherit`), and the library prints from deep inside `compile`
  —`relief`, `compile.rs`, `effects.rs`—, so the stage still prints: its
  lines are the log, not the answer, and threading a sink through the
  compiler is not mechanical. In the same order and the same stream: the
  20 `converter.log` are byte for byte. They name the paths where the
  files go, so `stage::Flags` carries `out` and `msu` only for that. What
  changes is a failure: a process that stopped halfway had already printed
  its lines and written some files; now it has printed its lines and
  written nothing.
* **stderr**: the crate prints nothing there while it succeeds.
* **Key order**: none changes. The audio crate already linked
  `serde_json` with `preserve_order`, so its binary kept insertion order
  as the converter does; and the request it gets in memory is the same
  `Value` it used to read back from the file.
* **The tracks' key**: `OWN_SOURCES` (`tracks.rs`, `midi.rs`, `game.rs`,
  `fail.rs`, `commands/msu.rs`) names none of the files this touches; the
  tracks do not render again.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), the global tools (`8b069fc2`) against `convert` and
`rm2k-snes-audio` from this branch: **the 20 `.sfc`, the 20 `.msu` and
the 19,469 files of the nine `build/` equal**, `converter.log` included;
aside `stamp.txt` and the 40 `.o`/`.dbg`, which differ only in the mtimes
`ca65` records (checked on every `.dbg` with them stripped). Then twice
with a private cache (`CACHE=` a scratch directory): the first filled it
(2,702 stage answers, new keys because the converter's binary changed) and
its builds equal the uncached ones; the second **wrote no file** to it, in
85 s for the nine, and its builds equal the uncached ones but for
Vampires Dawn's `converter.log`, without the 672 event compiler warnings a
cached build does not print (Cardón's, above).

Found, not fixed: the `.msu` and the tracks are written through a Spanish
`<file>.nuevo`
([draft](the-msu-and-the-tracks-are-written-through-a-nuevo-file.md)); A7
kept it so that the step moved nothing but where the code runs. And
`stage::hand_over`'s doc still names the music as one of its two callers;
it goes in A9 with the function, and A8 touches the same lines.

#### The suites

On the branch (main had not moved), `convert` and `rm2k-snes-audio`
first in the PATH: `just lint` clean; the-advocate's `just test` 29
passed; `just rust-test --no-fail-fast` 1,242 passed, 0 failed, 3 ignored
(the audio crate's, with the Microsoft GS SoundFont in `SOUNDFONT`, 109
passed); the test game (`SOUNDFONT=FluidR3_GM.sf2`) 231 passed, 6
skipped; the ports' `just boot` 218 passed; ABL's `just tests` 1,694
passed, 2 skipped. No golden moved: the ports' worktree is clean.
`abl.sfc` `3bf35fd7665c`. `cargo fmt --check` and `clippy --all-targets
-D warnings` clean on both crates. The binary's `cartridge` and `compile`
go through the same `stage` functions. **No test runs the binary's
`cartridge`**: only the converter called it, so the stage function is
covered by the builds and the suites above, and the binary's `main` over it
by nothing. `compile` is covered by the crate's `command_line.rs` and ABL's
`run_compiler` (`music.py`).

**Install when merging**: `convert` and `rm2k-snes-audio` (`just install
convert rm2k-snes-audio`).

### 2026-11-24, Calandria: A6

On the-advocate `calandria-a6`, from `8b069fc2` (main had not moved);
ports `calandria-a6` at `4c23c9e`, untouched. Two commits, on the recipe
above:

* `3e187e77`: the screens' geometry —the custom menus' `layout` and the
  debug screen's `geometry`, which the emission writes as equates one
  after another— in the order of its names, through a new `json::by_key`.
  The binary saw those keys sorted; in the converter, with
  `preserve_order`, they would come in the order the screens inserted
  them, and every game's `.inc` would change (not its ROM: they are
  equates). Its test, `the_geometry_goes_in_the_order_of_its_names`, was
  shown red without the sort under `cargo test -p rm2k-snes-mapdata -p
  rm2k-snes-convert`, where the feature reaches the crate.
* `0838e6d8`: `rm2k_snes_mapdata::stage::emit` answers `mapdata.inc` and
  `mapdata.json`, the same bytes the binary wrote into `--out`, and each
  map's raw data under `raw/` (`stage::RAW`), which the binary wrote into
  `--raw`. The converter's `emit.rs` calls it through `call_uncached`
  —uncached as before, now by its choice— and writes `raw/` next to the
  `.inc` with the same `materials::write_raw`, which still empties the
  directory first and now takes the files by name from the new
  `raw_files`. The binary keeps `emit` and `--raw`, a `main` over
  `emit_of`, which takes the request already read so a bad file still
  names its path. `run_uncached` is left with no caller but the dead `run`,
  and its doc says so; both go in A9. No `Cargo.toml` line: the converter
  already linked mapdata.

#### State, stderr, key order

* **State**: none in the crate —no `static`, `thread_local!`, `OnceLock`
  or memo—; the dump's database is read on each call.
* **stderr**: the emission prints nothing while it succeeds (its only
  `eprintln!` is `main`'s error); its notes go in the answer, and the
  converter prints them as before. The 20 `converter.log` are byte for
  byte the global tools'.
* **Key order**: the request is deserialized into `request::Emit` straight
  from the converter's `Value` (`Emit::deserialize(&Value)`, no copy), so
  only its `Value` fields keep the converter's order. Of what the
  emission iterates as an object, the two geometries reach the `.inc`
  (above); the slots' `faces` go into a `BTreeMap`, and `battle_audio` is
  only asked whether it is empty. `mapdata.json` now keeps insertion
  order; the converter reads it by key.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), the global tools (`8b069fc2`) against these: **the 20
`.sfc` equal**, and the 19,469 files of the nine `build/` too —the 12,624
raw files included— and the 20 `converter.log`; aside only `stamp.txt` and
the `.o`/`.dbg`, which differ in the mtimes `ca65` records. Then twice
with a private cache (`CACHE=` a scratch directory): the first filled it
(2,702 stage answers; the emission adds none) and its builds equal the
uncached ones; the second **stored nothing** —the same 8,913 files in the
cache before and after—, took 83 s for the nine, and its builds equal the
uncached ones but for Vampires Dawn's `converter.log`, without the 672
left-out warnings a cached compile does not print (Cardón's, A2).

**The binary's `emit`**, which nothing runs any more (no test calls it):
El Dorado's emission request, dumped by a throwaway converter, given to
this branch's binary and to the global one with `--raw`: the same
`mapdata.inc`, `mapdata.json` and 104 raw files from both, and the raw
files the same as the converter left in `build/`.

#### The suites

On the branch, `convert` and `mapdata` first in the PATH: `just lint`
clean; the-advocate's `just test` 29 passed; `just rust-test
--no-fail-fast` 1,243 passed, 0 failed, 3 ignored (the new test is the
one more); the test game (`SOUNDFONT=FluidR3_GM.sf2`) 231 passed, 6
skipped; the ports' `just boot` 218 passed; ABL's `just tests` 1,694
passed, 2 skipped. No golden moved: the ports' worktree is clean.
`abl.sfc` `3bf35fd7665c`. `cargo fmt --check` and
`clippy --all-targets -D warnings` clean on `rm2k-snes-mapdata` and
`rm2k-snes-convert`. The emission is covered by the builds above and by
every ROM test; the binary's `emit` only by the hand check.

Then main moved to `11fcaed9` (Mulita's A7) and merged without a
conflict (`08df82ef`). On that tree, with its `convert`, `mapdata` and
`rm2k-snes-audio` first: the same cold build against the global tools at
`8b069fc2`, the 20 `.sfc` and every file the converter writes equal, the
20 `converter.log` too; `just lint` clean, `just test` 29 passed, `just
rust-test --no-fail-fast` 1,238 passed, 5 failed, 3 ignored —the five
pass run again alone: four of `fxpak`'s pty tests
([draft](fxpak-s-pty-tests-share-ptsname-s-buffer.md)) and
`a_cached_object_gives_the_dbg_a_fresh_one_gives`
([draft](the-cached-dbg-test-sees-a-date-move.md))—, the test game 231
passed, 6 skipped, `just boot` 218 passed, ABL's `just tests` 1,694
passed, 2 skipped; `abl.sfc` `3bf35fd7665c`, no golden moved.

**Install when merging**: `convert` and `mapdata` (`just install convert
mapdata`).
