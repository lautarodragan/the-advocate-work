---
name: "The stages speak JSON nobody types"
description: "Each stage builds its answer with json! and whoever reads it walks a serde_json::Value key by key; one set of serde types both ends share makes the contract between stages something the compiler checks"
type: refactor
game: advocate
status: testing
assignee: taro
agents: [calandria, aguara, cardon, carpintero, chaja, mulita, tijereta]
author: taro
links:
  found: [the-event-compiler-s-left-out-warning-never-reaches-the-log, fxpak-s-pty-tests-share-ptsname-s-buffer, the-msu-and-the-tracks-are-written-through-a-nuevo-file, the-patches-request-of-release-repeats-five-maps, the-stage-subcommands-only-the-converter-called-have-no-caller, the-picture-key-is-declared-twice, the-slots-screen-line-counts-no-row-cells, mapinfo-carries-wally-s-answer-as-json-between-two-types, the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json]
  relates: [artistic-decision-patches, battle-tests-without-simulate, tests-without-the-stages-subcommands, the-emission-s-request-still-takes-seven-pieces-through-json, the-emission-s-answer-is-read-by-key, the-event-compiler-s-requests-are-built-and-read-by-hand, the-losses-the-stages-hand-over-are-json-the-converter-reads-by-key, the-screens-requests-are-built-and-read-by-hand, wally-s-map-request-is-built-and-read-by-hand]
  blocked-by: [emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines, picture-tables-and-common-entries-write-the-same-entry-twice, rm2k-snes-mapdata-maps-has-no-caller, small-repeats-inside-emit-rs-s-rest, the-battle-terms-by-name-are-a-42-arm-match]
  blocks: [a-stage-s-cache-key-once-it-is-a-library, one-advocate-command]
  has-part: [the-converter-reads-the-stages-answers-with-python-s-truthiness, the-converter-writes-the-emission-s-request-by-hand, the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures, the-emission-reads-the-screens-answer-and-the-battle-model-by-name, mapinfo-carries-wally-s-answer-as-json-between-two-types, the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json, the-emission-s-request-still-takes-seven-pieces-through-json, the-event-compiler-s-requests-are-built-and-read-by-hand, the-emission-s-answer-is-read-by-key, the-losses-the-stages-hand-over-are-json-the-converter-reads-by-key, the-screens-requests-are-built-and-read-by-hand, wally-s-map-request-is-built-and-read-by-hand]
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

### 2026-11-24, Tijereta: A8

On the-advocate `tijereta-a8`, from `8b069fc2`, with main merged twice
—`11fcaed9` (A7) in `9e17166a`, `0502be9b` (A6) in `abb98bf2`—; ports
`tijereta-a8` at `4c23c9e`, untouched. One commit, `806babc2`, on
the battle's model: `rm2k_snes_patches::stage::patches(request)` answers
the patches of one build as files named by their path in it
(`patches/auto/maps/0001.toml`), writing nothing, and
`rm2k_snes_patches::put` leaves them in the build, emptying each kind's
folder first as `write` did —so a cartridge that stops carrying a map does
not keep its old patch—. The converter calls the first through
`stage::call_uncached` (uncached, as `hand_over` was), the second itself,
and prints the per-kind lines the binary printed (`report`). The binary
keeps every flag; `--request` reads its file straight into `Request`, so a
bad one still names the file, line and column, and goes through
`patches_of`. `rm2k-snes-patches` joins the converter's `Cargo.toml`, and
with it the converter links `rm2k-snes-cartridge`, which only `--check`
uses. Three unit tests in `stage.rs`: the converter's door answers what
the binary's does for the crate's two fixture requests, and `put` leaves
exactly those files over a stale one; a bad request is a no; `put`
refuses a name outside the kinds' folders.

#### State, stderr, key order

* **State**: none in the crate —no `static`, `thread_local!`, `OnceLock`
  or memo—.
* **Key order**: the request is a serde type (`deny_unknown_fields`), read
  with `Request::deserialize`, so nothing iterates an object; the TOML is
  written by hand (`text.rs`), so the converter's `toml` `preserve_order`
  does not reach it. The patch files are byte for byte the same.
* **stderr/stdout**: the binary printed nothing to stderr while it
  succeeded; its stdout already went into `converter.log`, and the
  converter prints the same lines. **One line changes, in ABL's `release`
  only**: `patches of 313 map(s) -> patches/auto/maps (819517 B)` is now
  `308 map(s) … (812326 B)`. The request lists five maps twice —121, 133,
  261, 269 and 348, the five test maps `--check` reports as "only for the
  suite"—, each entry identical to its twin (read from the request the
  global binary was given); the binary wrote each of those files twice and
  counted both, and the answer, a map by file name, holds each once. The
  308 files are the same bytes: the second write always overwrote the
  first with the same content. The count is now the files left. Why
  `release`'s request repeats them was not looked at; if two entries of
  one id ever differed, the last would win, then as now.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), the global tools (`8b069fc2`) against these: **the 20
`.sfc` equal**, and every one of the 19,478 files in the nine `build/`
—the 2,101 patch files under `patches/auto/` included—, aside `stamp.txt`,
the 40 `.o`/`.dbg` (only the mtimes `ca65` records: equal with them
stripped) and ABL `release`'s `converter.log`, the one line above. Then
warm with the shared cache (new answers, the converter's binary being
new): equal to the uncached builds, `converter.log` included. Then twice
with a private cache (`CACHE=` a scratch directory): the first stored
2,702 stage answers, the second **wrote no file** to it —the nine in
109 s— and its builds equal the uncached ones but for Vampires Dawn's 672
left-out warnings, which a cached compile does not print (Cardón's A2).
ABL's `just patches-check` with these tools: the 303 map, 41 animation, 92
battler and 0 window patches match the 11 cartridges.

On the tree with A6 and A7 merged (`abb98bf2`), `convert`, `patches`,
`rm2k-snes-audio` and `mapdata` installed from it, the same cold build
against the global tools (`8b069fc2`) again: the 20 `.sfc` and every file
equal —25,785 now, the `.msu`s and what the earlier builds left in the
worktree's `build/` included—, aside the same `stamp.txt`, `.o`/`.dbg` and
the one line of ABL `release`'s `converter.log`; then warm, equal to it.
With A7 and A8 both in, nothing calls `stage::hand_over`: it gets the
allow `run` has, in the first merge, until A9.

#### The suites

On `abb98bf2`, those four first in the PATH: `just lint` clean; the-advocate's
`just test` 29 passed; `just rust-test --no-fail-fast` 1,246 passed, 0
failed, 3 ignored (on the A7 merge the same run had seven of `fxpak`'s pty
tests red, which passed run alone, the known
[draft](fxpak-s-pty-tests-share-ptsname-s-buffer.md)); the test game
(`SOUNDFONT=FluidR3_GM.sf2`) 231 passed, 6 skipped; the ports' `just boot`
218 passed; ABL's `just tests` 1,694 passed, 2 skipped. No golden moved:
the ports' worktree is clean. `abl.sfc` `3bf35fd7665c`. `cargo fmt
--check` and `clippy --all-targets -D warnings` clean on
`rm2k-snes-patches`, `rm2k-snes-convert` and the two merged crates. The
binary's `--request` goes through `patches_of` and `put`; the crate's
`command_line.rs` covers it, and ABL's `test_patches.py` its `--check`.

**Install when merging**: `convert` and `patches` (`just install convert
patches`).

### 2026-11-24, Calandria: A9 and A10

On the-advocate `calandria-a9`, from `330c99d5`; ports `calandria-a9` at
`4c23c9e`, untouched; the book `calandria-a10`, from `2eeea48`.

#### A9, the mechanical commit

`9ae5671a`, 39 lines in, 325 out (net -286), in three files:

* `stage.rs` loses `run`, `run_uncached`, `hand_over`, `which`,
  `write_request`, `Scratch` and `Answerer`, with the two
  `#[allow(dead_code)]`s that kept them (`ec883b2a`, `9e17166a`) and the
  `Command`, `Stdio`, `Write` and atomics they used. `key` takes the
  `Stage` itself; its `"stage 2"` tag stays, so the key moves only by the
  converter's binary, as any new converter moves it. Its tests key a
  `Stage` where they keyed a process, and the one that checked a function
  does not find a process's answer keeps only its first half.
* `rm2k-snes-cartridges`' fingerprint drops `CONVERTER_TOOLS`: it hashes
  `ca65`, `ld65`, the converter and itself. The patches' binary was in it
  because the check reads their files from the build; the converter
  writes them now. Its test puts only those four on its PATH.
* **There were no per-stage `BINARY`/`PROJECT` constants left**: A1-A8
  replaced each with its `Stage` const as they went.

**Whether the converter still needs the stages' binary names**: only as
labels. `Stage.binary` goes into the key (to tell `rm2k-snes-screens
layout` from `rm2k-snes-battle layout`, both asked `{}`) and in front of a
stage's no or panic (`rm2k-snes-battle: …`, as each `main` printed it);
nothing looks a binary up any more, and no stage crate knows its own
binary's name. A crate's name would do as well, but changes those
messages; left as it is.

**What else became dead**: nothing in the converter or the cartridges
(`clippy --all-targets -D warnings` clean). Outside them, the eleven
subcommands of the stage binaries only the converter ran —`wally map`,
`rm2k-snes-events compile`, `rm2k-snes-screens boxes`/`faces`/`convert`,
`rm2k-snes-images fullscreen`/`picture`/`background`, `rm2k-snes-battle
tables`, `rm2k-snes-mapdata emit`, `rm2k-snes-audio cartridge`— have no
caller now:
[draft](the-stage-subcommands-only-the-converter-called-have-no-caller.md).

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), the global tools (`330c99d5`) against `convert` and
`cartridge` from this branch, nothing else of it installed —the stage
binaries the build used to need came from the global PATH, and none was
run—: **the 20 `.sfc` equal**, every file of the nine `build/` equal (the
19,469 of them, raw files included), and the 20 `converter.log`. Aside:
`stamp.txt`, whose fingerprint changes once because the list of binaries
changed —every cartridge is stale once after installing this—, and the 20
`.o`/`.dbg`: the `.dbg` equal without the mtimes; the `.o` differ in 549
bytes each, every one a source's mtime (checked byte by byte against the
`.dbg`'s list, the main file's as a varint), because the runtime came from
another checkout.

Then twice with the shared cache: the first stored **2,702 new stage
answers** and nothing else —the re-key, by the converter's binary—, and its
builds equal the uncached ones, `converter.log` included; the second
stored nothing, 72 s for the nine, and equals them but for Vampires
Dawn's `converter.log` without the left-out warnings a cached compile does
not print (Cardón's A2). Their `.o` are another length than a fresh
assembly's, with the same `.dbg` and `.sfc`: the cached objects of
`a_cached_object_gives_the_dbg_a_fresh_one_gives`, not this step.

#### The suites

On `9ae5671a` (main had not moved), `convert` and `cartridge` first in
the PATH: `just lint` clean; the-advocate's `just test` 29 passed; `just
rust-test --no-fail-fast` 1,246 passed, 0 failed, 3 ignored (the known
fxpak pty and cached-`.dbg` flakes did not show; the cached-`.dbg` one did
once in an earlier `cargo test -p rm2k-snes-cartridge`, and passed run
again); the test game (`SOUNDFONT=FluidR3_GM.sf2`) 231 passed, 6 skipped;
the ports' `just boot` 218 passed; ABL's `just tests` 1,694 passed, 2
skipped. No golden moved: the ports' worktree is clean. `abl.sfc`
`3bf35fd7665c`. `cargo fmt --check` and `clippy --all-targets -D
warnings` clean on both crates. **Not covered**: that a build runs with
no stage binary on the PATH at all; the global ones were there, only
nothing ran them (the fingerprint no longer asks for them, and its test
puts only the four it hashes on its PATH).

#### A10, the prose

Its own commits, with A9's diff as the list:

* the-advocate `7c52fa6c`: `LAYOUT.md` (the paragraph that said each stage
  is a process on purpose, and "the converter runs it" per crate), the
  converter's README, battle's "One stage of a converter", the
  cartridges' README (the fingerprint's list), and the audio README, whose
  claim that its binary is the audio stage's cache key had been wrong
  since A7.
* the book `d39027e` (`calandria-a10`): `tools.md` (the commands the
  pipeline runs; "Each stage is a process of its own on purpose" becomes
  what the single key costs, with a link to
  [`a-stage-s-cache-key-once-it-is-a-library`](a-stage-s-cache-key-once-it-is-a-library.md);
  the stages' shape; a line under the road saying the numbered steps are
  functions named as their binaries' subcommands),
  `internals/pipeline.md` (the diagram, the fingerprint),
  `internals/the-converters-stages.md` (calls, not runs; and
  `maps::run_all`, stale, is `run_requests`), and ABL's `pipeline.md`
  diagram. Relative links of the four files checked. Research pages and
  `decisions/one-command-and-no-tool-runs-another.md` (which describes
  the direction, and when it was decided) left as they are.
* this repo: `AGENTS.md`, the crate list's `convert/`, the conversion
  cache (every stage keyed by the converter's binary), the fingerprint's
  "the ones the converter runs", and the two places that say what to
  install: a stage change is `convert` plus the stage.

**Install when merging**: `convert` and `cartridge` (`just install convert
cartridge`). Every cartridge is stale once (the fingerprint's list
changed), and the shared cache stores each stage's answers once more (the
converter's binary changed), as any new converter does. Phase A is done;
the task stays in `doing`, for phase B.

### 2026-11-24, Aguará: B4, Wally's answer

On the-advocate `aguara-b4`, from `cef2cdda`: `94f3312c`, the typing,
and `ae968484`, Wally's README. Ports `aguara-b4` at `4c23c9e`,
untouched.

#### What B4 is

**`wally::answer`**, a new module of Wally: `map.json` is an
`answer::Map`, `layers.json` an `answer::Layers`, both `Serialize` and
`Deserialize`, and `Answer::read(&Files)` reads the two back. `map::files`
and `layers::files` build them where they built `json!`, and serde writes
them. `sprites::npc::Npc`, `posed::Placed` and `map::SharedObjects` derive
serde themselves —their fields were already their keys, in order, and
they say so—; the rest are types of the answer, because what Wally keeps
inside (bytes, pictures, `BTreeMap`s) is not what it answers. The three
shapes that are no struct are untagged enums that write the same JSON as
before: a slot by the one key it has (`{"hero": true}`, `{"event": 3}`,
`{"charset": …, "index": …, "pose": …}`…), a merge with or without its
palette first, a route graphic with or without its colours. `Note.kind`
is an enum (`note`, `discard`, `stop`) inside Wally too.

**The converter**: `maps::wally_answer` reads it, and `map_info` and
`variants::drawn` work on fields. The background's runs and its colour
words, which both built the same way, are `maps::runs` and
`maps::words`. Gone: `maps.rs`' `truthy` and `slot_key` (the slots are
counted as distinct `Slot`s, which is what the keys were for), and
`variants.rs`' `fn int`. `maps.rs` keeps its `int`, for `pages`, which
reads the compiler's records (B5).

**What stays a `Value`**: `MapInfo`'s fields that carry Wally's answer on
to the emission —`objects`, `npcs`, `movable`, `animates_*`,
`posed_table`, `panorama`, `runs`, the merges, `panorama_way`— are built
from the types with `json!` and keep their type, because B1 (Calandria,
beside this) reads them into mapdata's typed request with `typed(&Value)`.
They become Wally's types when the emission's request takes them; one
reader of them by hand is left outside `maps.rs`: `convert.rs`' flashes
(`m.npcs.as_array()`, about 1383).

#### State, stderr, key order

* **Key order**: the fields are declared in the order `json!` wrote them,
  and `answer.rs` says why it matters —the converter's serde_json keeps
  it, and the emission gets these parts as JSON—. In the converter the
  answer's bytes are the same as before (`json!` there already kept the
  insertion order). `wally map` and `wally layers` write field order
  where they wrote sorted keys: nothing calls the first (the
  [draft](the-stage-subcommands-only-the-converter-called-have-no-caller.md)),
  and the second is a person's.
* **The cache** still keeps the stage's files, packed: `map.json` and
  `layers.json` are bytes among them. A typed answer stored as base64
  JSON was not needed for Wally —most of its answer is binaries (tiles,
  blocks, PNGs), which the pack already holds as they are—; that is
  for whichever step types `stage::call` itself.
* **Defaults that carried an absence**: none showed. The only one that
  changed meaning is a map with no objects (`sprite: null`), which used to
  stop at "wally did not write " and now stops at "wally answered no
  objects"; no map of the nine has one.
* **No new state, no new stderr**: nothing in Wally runs differently.

#### The builds

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), the global tools (`cef2cdda`) against `convert` and
`wally` from this branch: **the 20 `.sfc` equal**, and every file of the
nine `build/` (19,469), the 20 `converter.log` included. Aside, as in
A1-A9: `stamp.txt`, and the `.o`/`.dbg`, the runtime's mtimes from
another checkout (a `.dbg` compared without them is equal). So no JSON
on disk moved: the parts of the answer the emission gets come out of the
types in the order they came out of `json!`.

Then twice with the shared cache: the first stored 4,642 stage answers
(with three other agents building at once; every stage's, since the
converter's binary changed), and equals the uncached build; the second
stored **none**, 92 s for the nine, and equals it but for Vampires Dawn's
`converter.log`, the 672 lines of "is left out" a cached compile does not
print (Cardón's A2, as in A9).

#### The tests

`wally::answer`'s two, which pin the JSON of the untagged shapes and of a
note with and without its loss, and read them back. Wally's
`tests/halves.rs` caught a doc line of mine on `Npc` that linked
`crate::answer` from the sprites half (`18aed7f1`).

#### Lines

`94f3312c`: the converter **-138** (242 in, 380 out: `maps.rs` -106,
`variants.rs` -32), inside the table's -100 to -200. Wally **+457**:
`answer.rs` is 455 lines, 76 of them its tests and the rest the types,
their derives and their docs; `map.rs` and `layers.rs` build the types in about the
lines `json!` took. The whole step is **+320**, with `Cargo.lock`'s
line: the draft's estimate was the converter's, "less what the types
cost on Wally's side", and that cost is larger than the saving. What it buys is the point of the task:
the converter reads no key of Wally's by name.

#### The suites

With `convert` and `wally` from this branch first in the PATH (main had
not moved): `just lint` clean; the-advocate's `just test` 29 passed;
`just rust-test --no-fail-fast` 1,247 passed, 1 failed, 3 ignored —the
failure was `tests/halves.rs` and its fix above, after which Wally's
tests pass whole—; the test game (`SOUNDFONT=FluidR3_GM.sf2`) 231 passed,
6 skipped; the ports' `just boot` 218 passed; ABL's `just tests` 1,694
passed, 2 skipped. No golden moved: the ports' worktree is clean.
`abl.sfc` `3bf35fd7665c`, as A9's. **Not covered by a test of its own**:
that `Answer::read` reads every field back as Wally wrote it is shown by
the nine games' builds, not by a test that writes a whole answer and
reads it.

**Install when merging**: `convert` and `wally` (`just install convert
wally`). Wally's stage answers are stored once more, as with any new
converter.

### 2026-11-24, Chajá: B6, the images

On the-advocate `chaja-b6`, from `cef2cdda` (main had not moved when
handing back); ports `4c23c9e`, untouched. Two commits: `2fcfc544`, the
step, and `efdde40b`, a fix of the crate's own (below).

**The six answers are the images crate's types**, and serde writes them:
`fullscreen::Screen`, `show_picture::Converted`, `scene::{Backdrop, Light,
Battler}` and `animation::Converted` already were the answers field for
field and only derive now —a battler's `merges` go through a small `with`
module, as `[victim, target, pixels]`, because Adeleine's `Merge` knows no
serde—; the layer of `background`, which carries its tiles as hex and its
texture's centre, is `request::Layer`, and a backdrop's pair
`request::BackdropAnswer`. The requests derive `Serialize` too: the
converter builds them as structs, not with `json!`, and calls the stage
with the typed request, so the `Value` doors of A4 and `request::of` went,
and the seven `*_answer` builders. The crate's pinned hashes
(`tests/answers.rs`, now over the types' JSON) did not move.

**The converter reads fields**: `images.rs` keeps one generic `answer`
that serializes the typed answer into `<command>.json` for the cache and
reads it back; `fullscreen.rs`, `scene.rs` and `animations.rs` lost their
walks over arrays of arrays, and the palettes are `[u8; 3]`s.

**The picture key is `pictures::Key`**, read once from the scan's answer
(`pictures::keys`) with the four fields the converter adds on a map
(`path`, `with_map`, `behind_map`, `screen_on_map`); `truthy` left
`pictures.rs`. Its fields go in the order the scan writes them and the
converter adds them, the last four only when set, so a table entry made
from it —what reaches the compiler and the emission— is the same object.
It is the converter's type and not the events crate's because B5 types
the scan at the same time:
[draft](the-picture-key-is-declared-twice.md) for joining them once both
are in.

**Left as `Value`, on purpose**: a big picture's layer once the converter
puts its `half`, `center` and `under` after the answer's fields, because
it goes on to the emission's request as it is (B1-B3's); the scan's
`zooms` (B5's); and `Shown`'s table entry, which goes on to the compiler.

**Outside my files**, kept small: `maps.rs` (Aguará's) where the keys are
read and marked, 400-440 and the names of `big_over_black` near 1025;
`convert.rs` (Calandria's), three lines —the common events' keys, their
numbers, a light's palette length—; `common_pages.rs`,
`common_pictures.rs`, `map_pictures.rs` (`Shown::key` builds a `Key`);
and `serde` in the converter's `Cargo.toml`, which B1 may add too.

**Net lines**: 639 in, 680 out, **-41** for the step (the table said -30
to -80); the fix adds 26, almost all its test.

#### What was checked

* **The binary**: `main` serializes each answer through a `Value`, whose
  keys come out sorted without `preserve_order`, as `json!`'s did. The
  five converter-only commands, against the global binary on the crate's
  test game: byte for byte. One case changes, not reached by anyone: a
  background asked for a texture that does not fit answered `"mode7":
  null` and now leaves `mode7` out, as one not asked for it; the
  emission reads both as null, and no test asks for a background. The
  binary's help says so.
* **State and stderr**: nothing new; the crate prints nothing while it
  succeeds.
* **The cache**: no base64 needed —the images' bytes were already a hex
  string or arrays of numbers in the JSON the binary wrote—; the typed
  answer is stored as its JSON, in its fields' order.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), the global tools (`cef2cdda`) in one ports worktree
against `convert` and `images` from this branch in another: **the 20
`.sfc` equal**, and the 19,409 other files of the nine `build/`, the raw
data and every JSON included; 34 of them —the `converter.log`s and ABL's
test cartridges' `events-request.json`— differ only by the worktree's
path in them, and are equal with it replaced. The 20 `.dbg` equal without
the mtimes; `stamp.txt` and the `.o` aside. Then twice with the shared
cache: the first stored the answers again (the converter's binary
changed) and equals the uncached builds; the second answered from the
cache, 86 s for the nine, and equals them but for Vampires Dawn's
`converter.log` without the left-out warnings a cached compile does not
print (Cardón's A2).

#### The suites

With `convert` and `images` from the branch first in the PATH: `just
lint` clean; the-advocate's `just test` 29 passed; `just rust-test
--no-fail-fast` 1,245 passed, 1 failed, 3 ignored —the failure the known
cached-`.dbg` flake, `a_cached_object_gives_the_dbg_a_fresh_one_gives`,
which passed run alone—; the test game (`SOUNDFONT=FluidR3_GM.sf2`) 231
passed, 6 skipped; the ports' `just boot` 218 passed; ABL's `just tests`
1,694 passed, 2 skipped. No golden moved. `abl.sfc` `3bf35fd7665c`.
`cargo fmt --check` and `clippy --all-targets -D warnings` clean on both
crates. The tests' calls to `backdrops`, `battlers` and `animations`
(`image_stage.py`) go through the binary; `fullscreen`, `picture` and
`background` are covered only by the builds and by the comparison of the
binaries above. `efdde40b` ran after the suites: only the crate's tests,
fmt and clippy, and it changes no path the converter takes.

**Install when merging**: `convert` and `images` (`just install convert
images`). The shared cache stores the images' answers once more, as any
new converter does.

### 2026-11-24, Cardón: B5, the event compiler's answers typed

On the-advocate `cardon-b5`, from `cef2cdda`; ports `cardon-b5` at
`4c23c9e`, untouched. One commit, `00660dba`.

#### What B5 is

* **The types live in the events crate**, `rm2k_snes_events::answer`:
  `Scan` and `Compiled`, with `Indices` flattened into both, `ScanMap` and
  `CompiledMap`, `Page` and its `OwnRoute`, `CommonPictures`,
  `CommonSet`, `Messages`, `Troops`, `TroopPages`, `Shared` and
  `Degradations`. `scan` and `compile` build them where they built
  `json!`; `route::own`, `map_pages`, `TroopPages::answer`,
  `Shared::answer` and `parallel_commons` answer fields. Bytecode is
  `answer::Hex`, a newtype serde writes as the hex string it always was.
* **What the converter only hands on stays a `Value` inside the types**:
  the picture keys and zooms (the pictures' stage reads them —B6's picture
  key—), `songs` (the audio's request, B7), `battle_audio` (the
  emission's) and the losses (`degradations.json`, with every other
  stage's).
* **The converter reads fields.** `compiler.rs`'s `run` deserializes the
  cached file into the type; `map_entry`, the converter's own `Indices`
  and its `from_answer` go (`variable_slot` stays, as a function over
  `answer::Indices`); `scan.rs`, `common_pages.rs`, `common_pictures.rs`,
  `maps.rs`, `convert.rs` and `degradations.rs` read fields.
  **`PageRecord`'s ten `Value`s are typed**, which takes the
  `unwrap_or` defaults out of `emit::page_record` (Calandria's file: one
  hunk, the `own` route's fields) and `lay_out_code`.
* **Not done**: mapdata's request still takes `troop_pages` as a `Value`
  (`request.rs:363`) and reads it by hand (`emit.rs` `troop_pages`); the
  converter passes it `answer::TroopPages`, serialized with the same keys.
  Making that field `Option<rm2k_snes_events::answer::TroopPages>` is one
  line plus that reader, and is B1/B3's to do with the rest of `Emit`:
  left there so as not to rewrite mapdata's `emit.rs` beside B1-B3. The
  requests to the compiler are still built by hand in `compiler.rs`: B5
  was the answers.
* **Other agents' files touched**: `maps.rs` (Aguará's B4), where the scan
  is read —the map's entry, its graphics, pictures, tinted and zooms— and
  where `PageRecord` and `pages` live; `emit.rs` (Calandria's), the one
  hunk above; `convert.rs`, the compile's readers and the emission's
  request's `troop_pages`, `battle_audio`, `commons` and `skill_pairs`
  lines, which keep their keys. And one line in the converter's
  `Cargo.toml`, `serde`, which other B steps may add too.

#### Key order, and the binary's output

**The fields go in the order the `json!` literals wrote them**, and what was
written only when there were some is skipped the same way
(`skip_serializing_if`): under `preserve_order` the converter writes the
same bytes from them. A2's two reordered files, `degradations.json` and
`events-request.json`, now come out **byte for byte equal** to the global
tools'.

**The binary writes its answer through a `Value`** (`stage::files`), whose
keys serde_json sorts in a binary without `preserve_order`: the tests'
`rm2k-snes-events scan` keeps its bytes. Checked on the crate's small game:
`scan` and `compile` with `tests/scan.json` and `tests/compile.json`, the
global binary (`cef2cdda`) against this one, `cmp` equal.

The cache keeps the answer as the binary's file, deserialized on the way
out; its bytes follow the types' order, which the new converter's key
throws away anyway.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), the global tools (`cef2cdda`) against `convert` and
`events` from this branch: **the 20 `.sfc` equal, every file of the nine
`build/` equal, `converter.log`, `degradations.json` and
`events-request.json` included**; aside, `stamp.txt` and the `.o`/`.dbg`
(mtimes; ABL's and Vampires Dawn's release `.dbg` equal without their `file`
lines). Then twice with a
cache of its own (`CACHE=` a scratch directory): the first stored 2,702
stage answers and its builds equal the uncached ones, `converter.log`
included; the second stored none, 3:42 for the nine against 17:47 for
the first (with three other agents building beside it), and equals them
but for Vampires Dawn's `converter.log` without the 672
left-out warnings a cached compile does not print (A2).

#### Lines

The commit is 837 lines in, 777 out: **net +60**, against the table's -50
to -150. The converter lost 155 (243 in, 398 out), as the table expected;
the events crate gained 213, which is the declaration: `answer.rs` is 279
lines, 71 of them comments and 21 blank, against the `json!` literals and
`to_json`s it replaced. The table's estimate counted the reading by hand
that goes and not the types that come.

#### The suites

On `00660dba` (main had not moved), `convert` and `events` first in the
PATH: `just lint` clean; the-advocate's `just test` 29 passed; `just
rust-test --no-fail-fast` 1,246 passed, 0 failed, 3 ignored (no flake
showed); the test game (`SOUNDFONT=FluidR3_GM.sf2`) 231 passed, 6
skipped; the ports' `just boot` 218 passed; ABL's `just tests` 1,694
passed, 2 skipped. No golden moved: the ports' worktree is clean.
`abl.sfc` `3bf35fd7665c`, as A9's. **Not covered by a test of their
own**: the cache's round trip of the typed answers is covered only by
the warm builds above, which read every answer back; `Hex`'s refusal of
a string that is not hex has no test.

**Install when merging**: `convert` and `events` (`just install convert
events`). The shared cache stores the compiler's answers once more (the
converter's binary changed). The task stays in `doing`, for phase B.

### 2026-11-24, Cardón: B5 merged with B4 and B6, and the picture key once

Hornero merged B4 (Aguará) and B6 (Chajá) into the-advocate `main`,
`1f33793d`, and asked for it merged into `cardon-b5`, then Chajá's draft
`the-picture-key-is-declared-twice` in its own commit.

#### The merge, `c8348c20`

Five files in conflict —`convert.rs`, `maps.rs`, `common_pages.rs`,
`common_pictures.rs`, the converter's `Cargo.toml`—, all one convention met
from two sides: B6 read the scan's picture keys as `pictures::Key` through
`pictures::keys(Option<&Value>)`, over the scan as a `Value`; B5 made the
scan a type, with its pictures still JSON values. `pictures::keys` took
those values (`&[Value]`) and its four callers, grepped for by hand, pass
the typed scan's lists; `pictures_own` and `tinted` come from the type.
`Cargo.toml` keeps B6's `serde` with `derive`. `maps.rs` now imports B4's
`wally::answer` too, so the events' `Page` is imported by name. Two
helpers the branches together left dead went: `maps.rs`' `int`, `text.rs`'
`unhex`.

#### The picture key, `b5d4b7a2`

Small, so done:

* `PictureKey` (`registry.rs`) derives serde, its fields in `to_json`'s
  order, `at`'s `(i32, i32)` the `[x, y]` it was. The scan's maps, common
  pictures and sets answer `Vec<PictureKey>` —the last picture keys that
  were `Value` in B5's `answer`—. `to_json` and `picture_key` go: the
  compile reads each table entry's key with serde, which skips the
  converter's fields after it.
* The converter's `Key` is `#[serde(flatten)] key: PictureKey` first and
  its four fields after, so a table entry is the object it was; it derefs
  to the key, so its readers did not change. The key's numbers are `i32`
  and the converter computes in `i64`: about a dozen places that do
  arithmetic with a number, a zoom or a centre widen them there (`wide()`
  for the centre). `pictures::keys` is now the plain conversion of the
  scan's typed list; nothing in the converter deserializes a `Key` any
  more.
* 118 lines in, 119 out. **Chajá's draft is done by this commit**: it
  came in with main, and goes to `testing` here, with its log entry.

#### Verified again, on `b5d4b7a2`

With `convert`, `events`, `images` and `wally` from this branch first in
the PATH: `NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`) against the global tools of `cef2cdda` (B5's `base`
snapshot): **the 20 `.sfc` equal, every file of the nine `build/` equal,
`converter.log` included**; aside, `stamp.txt` and the `.o`/`.dbg` as
before, and three files the earlier suites had left in this worktree's
`build/` and the converter does not write (`cartridges.lock`, two `.srm`).
`just lint` clean; `just rust-test --no-fail-fast` 1,242 passed and the 7
fxpak pty tests failed (the known flake), which passed run alone (`cargo
test -p fxpak`, 27 passed); the test game (`SOUNDFONT=FluidR3_GM.sf2`)
231 passed, 6 skipped; ABL's `just tests` 1,694 passed, 2 skipped. No
golden moved; `abl.sfc` `3bf35fd7665c`. Not run again: `just test` and
the ports' `just boot`, nor a cached build.

**Install when merging**: `convert` and `events` (`just install convert
events`); `images` and `wally` come with main already.

### 2026-11-24, Calandria: B0-B3

On the-advocate `calandria-b`, from `cef2cdda`; ports `calandria-b` at
`4c23c9e`, untouched. The baseline for every step: `NO_CACHE=1 just
cartridges --force` in the nine games (ABL `--without-tracks`) with the
global tools of `cef2cdda`.

#### B0

`a63397d4`: the six fallbacks of the
[draft](the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures.md)
go (`emit.rs` 28 lines in, 76 out: net -48, against the estimate's -40),
and the two made-up requests carry the six fields, filled with what each
fallback gave. The whole `.inc` and notes of both made-up cartridges are
byte for byte what they were (a throwaway dump from
`a_bare_cartridge_and_a_whole_one_are_emitted`), so no assert of
`made_up.rs` moved. The gold window and the arrow's tile past the
window's stay: they are the made-up window's own shape, not an old
answer's, and B3 decides whether they become a field the fixtures carry
(it made the gold window one; the arrow's blank tile stays).

#### B1

`35d5c832`: the converter builds `request::Emit` and hands it to
`rm2k_snes_mapdata::stage::emit` by value, no JSON between them. Every
request type derives `Serialize` beside `Deserialize`, the bytes through
one `#[serde(with = "hex")]` both ways (`hex::each` for lists); the
scene is typed (`Scene`, `SceneGeometry`, `SceneBackdrop`,
`SceneBattler`) and mapdata's `scene.rs` reads its fields instead of 21
accessor calls; `animations::request`, `Screen::request`,
`scene::request` and `Variant::request` answer the types. The nine
`request["x"] = json!(…)` patches for `json!`'s recursion limit went.

What other stages still answer as JSON —Wally's sprite, NPCs, posed and
runs, the pages' numbers and draws, the pictures' images, the big and
common pictures, the faces, the commons, `parallel_common`'s switches—
crosses with `emit::typed`, `serde_json::from_value` over the value the
emission used to read: the same deserializer, so the same answer or the
same refusal, now in the converter. **For B4, B5 and B6**: those bridges
are where their typed answers plug in —`map_record`, `page_record` and
`Variant::request` (B4/B5), `scene::request` and `animations::request`
(B6)—, and the request types they feed are mapdata's. I tried to tell
Aguará, Cardón and Chajá with SendMessage; none was reachable by name.

Checked the request itself: a throwaway converter built the old `json!`
request beside the new one and compared them as the emission sees them
—the old one deserialized into `Emit`, both serialized back— over the 20
cartridges of the nine games: all equal. With it, every `.sfc` and file
of `build/` equal to the baseline's but the cached `.o`.

Lines: 564 in, 410 out, **net +154** against the draft's -60 to -100. A
struct literal takes a line per field where `json!` took two or three
keys a line, the scene's types are new, and rustfmt spreads the
`typed(…)?` calls; what went is the reading by key and the patches.

#### B2

`66dfeb92`: `rm2k-snes-battle`'s `tables` and `model` take and answer
their types. `Request` derives serde (the tree's nodes stay `Value`s in
the dump's shape; `put_nodes` puts them into the game) and answers
`Answer` (`ExperienceAnswer`, `EncountersAnswer`) instead of 40 lines of
`Request::of` by hand; `model` takes `ModelRequest` and answers `Model`,
with `TroopReward`, `Texts`, `SkillText`, `Cut` and `PairsAsked`; the
texts and actions by number are `BTreeMap<i32, _>`. The converter builds
both requests and reads both answers (`stage::typed`), `rom_scene` takes
the per-map records, the event compiler (still JSON) gets the troops as
`json!`, and `cut_report` takes a `Cut`. The emission's `battle_model`
is a `Model` and `BattleTables::slots` the slots' `Vec<Option<i64>>`
—the save signature hashes the same JSON—; what read them by name reads
fields, through one `by_number`. The binaries write the same keys: ABL's
`model.py` reads what it read.

Lines: 446 in, 299 out, **net +147**, against -50 to -100: the types'
declarations and their docs are most of it.

#### B3

`6fa77fe7`: `rm2k_snes_screens::answer` declares the `convert` answer
—`Answer` and a type per screen, `OtherSystem` for `window`'s
`systems`—, deriving serde on the producer structs that already had the
shape (`CompactTarget`, `CompactTargetSkill`, `CompactShop`,
`MenuBlocks`, `Member`, `Ink`, `FontInk`). The screens build it, the keys
and the bytes' hex are the same, and `rm2k-snes-screens window` writes
what ABL's tests read. mapdata depends on rm2k-snes-screens;
`Emit::screens` is an `Answer`, `Emit::window_systems` a list of
`OtherSystem`; emit.rs, `custom_menu.rs`, `debug_screen.rs`,
`skills_screen.rs` and `layer_text.rs` read fields, and
`normalized_windows` pads and renumbers typed windows. The converter
reads the losses, the says, the sizes and the title's menu by field.

* **The gold window is required**: every real answer carries one, so the
  made-up window without it went (`window_systems_table`'s nine-pointer
  case); the fixtures carry a real gold window, and their `.inc` gains
  exactly `GOLD_*` and `window_gold`. `made_up.rs`' second-System test
  now asserts ten pointers. The fixtures also gain what the emission read
  as absent —the shop party's `on`, empty custom menus, no losses, no
  icons, ink 0— and lose the `prerender`s no type carries.
* **`json.rs` does not go yet**: it keeps what the troops' pages (JSON
  until B5) and the geometry lists (by name on purpose) read; `int_at`,
  `ints_at`, `text_at`, `color`, `colors`, `tile` and `tiles` went (113
  lines to 76).
* **One log line kept its number on purpose**: the slots screen's "B of
  cells" added the rows through `s["rows"][0][0][0]`, a number, so that
  term was 0 since the Rust port; it is left out and the line prints the
  same —[draft](the-slots-screen-line-counts-no-row-cells.md)—.

Lines: 1,167 in, 1,101 out, **net +66**, against -100 to -200; without
`answer.rs` (418 lines, half of them docs and the hex module) it is
-352. The screens' types are what the draft counted as "perhaps 100".

#### What of the reading by hand went, B0-B3

Accessor calls of `json.rs` in mapdata's sources (a grep of `at(`,
`int_at(`, `list_at(`, `tiles(`… outside `json.rs`, so a rough count):
446 at `cef2cdda`, 113 now, most of those the troops' pages and the
geometry lists. `json!` in the producers touched (screens, battle's
model and tables, the converter's request builders): 102 to 41. Key reads
`["x"]` in `convert.rs`: 156 to 92. Net lines of the four steps
together: **+319**, against the table's -250 to -440: typing costs the
declarations, and the drafts' estimates counted the reading that goes but
not the types that come.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`) with `convert`, `mapdata`, `battle` and `screens` of
`6fa77fe7` first in the PATH, against the global tools of `cef2cdda`:
**the 20 `.sfc` equal**, every one of the 19,469 files of the nine
`build/` equal (raw files included) but `stamp.txt` and the `.o` (each
under 64 bytes apart, the sources' mtimes), and **the 20 `converter.log`
equal**. No request or answer JSON lands in `build/` (the emission's
request never did); the battle's two requests are now built from types,
in field order, so their cache keys are new —the cache's business only;
the converter's new binary re-keys every stage anyway—.

Then twice with the shared cache: the first stored 2,702 stage answers
—the re-key by the new converter, the same count as A9's—, and its
builds equal the uncached ones, `converter.log` included; the second
stored nothing, 72 s for the nine, and equals them but for Vampires
Dawn's `converter.log`, without the left-out warnings a cached compile
does not print (Cardón's A2).

#### The suites

On `6fa77fe7`, with `convert`, `mapdata`, `battle` and `screens` of the
branch first in the PATH: `just lint` clean (again after the last two
commits); the-advocate's `just test` 29 passed; `just rust-test
--no-fail-fast` 1,246 passed, 0 failed, 3 ignored (the fxpak pty and
cached-`.dbg` flakes did not show); the test game
(`SOUNDFONT=FluidR3_GM.sf2`) 231 passed, 6 skipped; the ports' `just
boot` 218 passed; ABL's `just tests` 1,694 passed, 2 skipped. No golden
moved: the ports' worktree is clean. `abl.sfc` `3bf35fd7665c`. After
them, two commits: `c08237dd`, a test that the screens' answer reads back
as it was written (the flattened and left-out fields are what could
drift), and `023e5aca`, the READMEs of mapdata, battle and screens.

**Not covered by any build or suite**: the binaries' `tables`, `model`,
`convert` and `window` are only run by the ABL tests that call `model`
and `window` (green); the binary's `emit` and `convert`, by nothing (the
[draft](the-stage-subcommands-only-the-converter-called-have-no-caller.md)).
One change in what a binary writes: `rm2k-snes-battle model` with a font
leaves `party_line` out when the line fits, where it wrote `null`; no
test reads it.

#### Main merged: B4, B6 and B5

the-advocate `main` moved under this work twice; `calandria-b` merged it
twice: first B4 and B6 (`1f33793d`: the converter's
`serde` line and scene.rs' imports in conflict; the images' typed
battler and animation palettes, which made three `typed` bridges go),
then B5 (`5572e9e8`, merge `cf0ea7a8`: `page_record` builds
`request::Page` from `PageRecord`'s typed fields, the messages, skill
pairs and parallel commons from `Compiled`'s). With B5, **the emission's
`troop_pages` is `Option<rm2k_snes_events::answer::TroopPages>`** —mapdata
depends on rm2k-snes-events— and the troops' pages are read by field: the
made-up cartridges' `.inc` byte for byte what it was, and `json.rs` keeps
only the geometry lists' `int`, `ints`, `list`, `text` and `by_key`, 56
lines of the 113 it had.

**Verified on the merged tree** (`cf0ea7a8`, with `convert`, `mapdata`,
`battle`, `screens`, `wally`, `images` and `events` installed from it):
`NO_CACHE=1 just cartridges --force` in the nine games, against the same
`cef2cdda` baseline: the 20 `.sfc`, the 19,469 files of `build/` and the
20 `converter.log` equal (aside `stamp.txt`, and the `.o` within the
sources' mtimes). `just lint` clean; `just test` 29 passed; `just
rust-test --no-fail-fast` 1,249 passed, 0 failed, 3 ignored; the test game
231 passed, 6 skipped; `just boot` 218 passed; ABL's `just tests` 1,694
passed, 2 skipped; no golden moved, `abl.sfc` `3bf35fd7665c`.

**Install when merging**: `convert`, `mapdata`, `battle`, `screens` and
`events` (`just install convert mapdata battle screens events`; `wally`
and `images` as main already asks). The shared cache stores every stage's
answers once more (the converter's binary changed).
**For whoever merges B4-B6 after this**: `emit::typed` in the converter
is the bridge each of them replaces —`map_record`, `page_record`,
`Variant::request`, `scene::request`, `animations::request`— and
`stage::typed` reads a typed answer from a stage's files; mapdata's
request types are the target their answers feed.

### 2026-11-24, Mulita: B7, the audio and patches requests typed

On the-advocate `mulita-b7`, from `bb961337`; ports `mulita-b7` at
`4c23c9e`, untouched. One commit, `9d4446b7`.

**The music's request is `rm2k_snes_audio::stage::Request`**, in the
audio crate, `Serialize` and `Deserialize` derived: the converter builds
it as a struct and `stage::cartridge` takes it; the binary reads it from
`--request` with serde, from the text so a bad one names its line. Its
`songs` are `cartridge::Songs`, which derives serde now —a package is its
index or `"battle"`, by hand, and the per-package maps are `[key, value]`
lists through a small `by_key` module—, so `Songs::from_json` (118 lines)
and the request's walk by hand went; the backdrops are bytes, hex in the
JSON through `hex_pairs`. The crate gained `serde` in its `Cargo.toml`.
**The patches' `Request`** was already typed on the reading side: it
derives `Serialize` and `Clone` now, the converter builds it, and the
`Value` door went —`stage::patches` takes the request, `patches_of` is
gone—; its test now writes a request as JSON, reads it back and answers
the same.

**Where the converter's readers went**, file by file —the list of the
truthiness task's "What remains, for B7"—:

* `convert.rs`: `fn int` and the `truthy` closure. The substitution
  table is Wally's `(upper, old, new, pairs)` tuples in `MapInfo` and
  `CompileMap`, made JSON only in `compiler.rs` for the event compiler's
  request, as `maps.rs` used to; `[events] counters` are a
  `compiler::Counter`.
* `pictures.rs`: `fn int` (the `truthy` went in B6). The scan's `zooms`
  are `(number, zoom)` pairs in the events crate's answer (`Vec<(i32,
  i32)>`, `zooms_json` gone; the JSON is the same arrays); a `Shown`
  picture keeps its `number` and `palette` beside its entry instead of
  reading them back from it.
* `chipsets.rs`: `fn int`. A ChipSet's patch is a `Fork` with its recipe
  typed —`Recipe`, `Pose`, `Drawing`, `Recolor`, and a `Cell` that is
  `[x, y, slot]` or `[x, y, slot, under]`—: every operation read each
  field with a default of 0 or "" before. It is the project's input and
  not a stage's answer, but it was the last `fn int`.
* `maps.rs` (Aguará's, then Calandria's; kept small): `MapInfo`'s
  `colors`, `budget`, `merges_background`, `merges_above` —read only by
  the patches request— are one `patches: MapDecision`, built in
  `map_info` from Wally's types with a `patches_merge`; `panorama_way` is
  an `Option<String>`, which changed one line of `emit.rs`. The
  substitution table's two lines.
* `screens.rs`: `window_losses`, the window's losses for the patches,
  read from the screens' still untyped window answer through a small
  `Deserialize`.

**What still reads by key, on purpose**:

* `MapInfo::npcs` in `convert.rs`' flash check: Wally's rows as JSON, which
  [`mapinfo-carries-wally-s-answer-as-json-between-two-types`](mapinfo-carries-wally-s-answer-as-json-between-two-types.md)
  (Calandria, beside this) types; inlined there as
  `npc["index"].as_i64().unwrap_or(0)` so `int` could go, with a comment.
  Calandria could not be reached to agree on it; the hunk is those lines.
* The event compiler's `songs`, still a `Value` in `Compiled`, read into
  the music's type with one `from_value`; and the music's `losses`, read
  from `audio.json` by key:
  [draft](the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json.md).
* A big picture's layer's `tile_count` in `pictures::keep_objects`: the
  layer is B6's `Value` on purpose, now `expect`ed instead of defaulted.
* `degradations.rs`' local `int` closure: an `Option` over the converter's
  own loss records, not a silent default.

**Counted in the converter** (`json!` and `["key"]` reads, by grep):
199 and 164 at `bb961337`, 182 and 120 after. What is left is mostly the
event compiler's scan and compile requests, built as `Value` in
`compiler.rs` (32 `json!`) and read by hand on the events side; `MapInfo`'s
`Value`s in `maps.rs` (35 `json!`, 19 reads, Calandria's step); B6's big
picture layers and table entries in `pictures.rs` and
`common_pictures.rs`; the loss records in `degradations.rs` and their
filters in `convert.rs`; the screens' untyped `window` answer and
`layout`; and the forks' JSON in `fork.rs`.

**Net lines**: 531 in, 455 out, **+76** —the table said -30—. The stages
lost: the audio crate -47, patches -9, events -4. The converter gained
135, of which the ChipSet recipe's types are +60, the window's losses
+32 and the map decision built from Wally's types +28: typing what was
read with a default costs more lines than the reads did, and B7's
estimate did not count the recipe.

#### State, stdout, key order, the binaries

* No new state; nothing new on stderr. The patches and the music stay
  uncached (`call_uncached`), and the events' scan answer serializes its
  zooms as the same arrays: no cache value moves.
* **Key order**: the patches request is no longer JSON on the way in; the
  music's is not either; the event compiler's compile request writes the
  substitution table's objects and the counters with the same keys in the
  same order (`events-request.json` equal in the builds below).
* **The binaries**: `rm2k-snes-patches` writes the same files;
  `rm2k-snes-audio cartridge` takes the same JSON, and only its complaints
  about a bad request are serde's now; `compile` is untouched;
  `rm2k-snes-events`' scan writes its zooms as the same arrays.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`) in one ports worktree, the global tools (`bb961337`)
against `convert`, `rm2k-snes-audio`, `patches` and `events` from this
branch: **the 20 `.sfc` and the 19,469 files of the nine `build/` equal**,
the 20 `converter.log`, every `.msu` and every JSON included; aside
`stamp.txt` and the 40 `.o`/`.dbg`, which differ only in the mtimes
`ca65` records (checked on every `.dbg` with them stripped). The music
request's MSU side did not change —the same backdrop bytes—, so no build
with tracks. No warm-cache round: the two stages are uncached, and the
scan's cached answer is the same bytes.

#### The suites

On the branch (the-advocate's main had not moved), `convert`,
`rm2k-snes-audio`, `patches` and `events` first in the PATH: `just lint`
clean; the-advocate's `just test` 29 passed; `just rust-test
--no-fail-fast` 1,248 passed, 1 failed, 3 ignored —the failure the known
cached-`.dbg` flake, `a_cached_object_gives_the_dbg_a_fresh_one_gives`,
which passed run alone—, and the audio crate's with the Microsoft GS
SoundFont in `SOUNDFONT`, all passed; the test game
(`SOUNDFONT=FluidR3_GM.sf2`) 231 passed, 6 skipped; the ports' `just boot`
218 passed; ABL's `just tests` 1,694 passed, 2 skipped. No golden moved:
the ports' worktree is clean. `abl.sfc` `3bf35fd7665c`. `cargo fmt` and
`clippy --all-targets -D warnings` clean on the four crates. **No test
runs the binary's `cartridge`**, as in A7: the typed request is covered by
the builds above and the binary's reading of it by nothing; the ChipSet
recipe's types by `chipsets.rs`' five tests and ABL's four forked
ChipSets in the builds; `window_losses` by the builds, where six games write window
patches, the starting System's and the others'.

**Install when merging**: `convert`, `rm2k-snes-audio`, `patches` and
`events` (`just install convert rm2k-snes-audio patches events`). The
shared cache stores every stage's answers once more, as any new converter
does; no value changes.

### 2026-11-24, Calandria: MapInfo typed, the step after B7

[`mapinfo-carries-wally-s-answer-as-json-between-two-types`](mapinfo-carries-wally-s-answer-as-json-between-two-types.md),
in the-advocate `calandria-mapinfo` (`688342ac`, main's B7 merged in):
`MapInfo` keeps Wally's answer typed and the emission takes it as types
—mapdata's request holds Wally's `Slot`, `RouteGraphic`, `Cache`,
`SharedObjects`, `Animation` and `Placed`; the converter converts the
sprite, the panorama and the rows with plain Rust, where the emission
takes the bytes of the files Wally names—; the pages' `draws`, the
pictures' images and the common sets are mapdata's types too. Thirteen
`emit::typed` calls go; eight stay, one in Mulita's
[todo](the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json.md)
and seven in a
[draft](the-emission-s-request-still-takes-seven-pieces-through-json.md).
The nine games byte for byte against `bb961337`, the four suites green;
the task's log has the detail. **Install when merging**: `convert`,
`mapdata` and `wally`.

### 2026-11-24, Calandria: the emission's seven pieces typed

[`the-emission-s-request-still-takes-seven-pieces-through-json`](the-emission-s-request-still-takes-seven-pieces-through-json.md),
in the-advocate `calandria-seven` (`3be65428`, over `3e71d3a1`): the MSU-1
option, the other Systems' windows, the faces, the battle terms, the
shared common bodies, the big pictures' layers and the item names' width
reach the emission's and the battle model's requests from their
producers' types —the screens' `window` and `faces` answer `WindowAnswer`
and `FacesAnswer`, written through a `Value` so the binary's bytes do not
move—; `emit::typed` is left with `battle_audio`, Mulita's. The event
compiler's requests stay JSON, with the pictures' tables in `MapInfo`:
not a field's step, a
[draft](the-event-compiler-s-requests-are-built-and-read-by-hand.md); and
the emission's own answer is read by key, another
[draft](the-emission-s-answer-is-read-by-key.md). The nine games byte for
byte against `3e71d3a1`, the four suites green; the task's log has the
detail. **Install when merging**: `convert`, `mapdata`, `screens` and
`images`.

### 2026-11-24, Mulita: the songs, the battle's audio and the music's losses typed

[`the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json`](the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json.md),
in the-advocate `mulita-songs` (main's `2695bd89` merged in): the event
compiler answers `answer::Songs` and `answer::BattleAudio`, its own types;
the converter reads the songs into the music's `cartridge::Songs` with
plain Rust and hands `BattleAudio` to the emission as it is, so
`Songs::to_json`, the `from_value` and the last `emit::typed` —with the
function— went; the music's `cartridge` answers its losses as
`relief::Loss` beside its files, and the converter no longer reads
`audio.json` by key. The nine games byte for byte against `3e71d3a1`, cold
and warm, the four suites green; the task's log has the detail and what
is left read by key, with a
[draft](the-losses-the-stages-hand-over-are-json-the-converter-reads-by-key.md)
for the losses. **Install when merging**: `events`, `rm2k-snes-audio`,
`mapdata` and `convert`.

### 2026-11-24, Calandria: the last three JSON steps, and what is left

In the-advocate `calandria-last` over `5fa3d860`, one commit a step, each
built byte for byte before the next —the tasks' logs have the detail—:

* `e1d44127`,
  [`the-event-compiler-s-requests-are-built-and-read-by-hand`](the-event-compiler-s-requests-are-built-and-read-by-hand.md):
  the scan and compile requests are `request::Asked`, built as a struct
  and read with serde; the picture tables are `request::Picture`, the
  picture key moved into the events crate, the screens' `boxes` answer is
  typed. +174 net lines.
* `a9174754`,
  [`the-emission-s-answer-is-read-by-key`](the-emission-s-answer-is-read-by-key.md):
  `mapdata::answer::Answer` and its `Loss`, read with `stage::typed`;
  `stage::json` goes. +23.
* `120fcd9e`,
  [`the-losses-the-stages-hand-over-are-json-the-converter-reads-by-key`](the-losses-the-stages-hand-over-are-json-the-converter-reads-by-key.md):
  `losses::Entry`, `Where` and `CommonRun` in the event compiler, which
  `degradations.rs` keeps and the four `forget`s read by field. +210.

**On the final tree**: the nine games `NO_CACHE=1` against the global
tools' builds of `5fa3d860`, every file of `build/` equal —19469, the 20
`.sfc`, `converter.log`, `degradations.json` and `events-request.json`
included— but the 20 `.o` and 20 `.dbg` (ca65's mtimes) and the 20
`stamp.txt`; `abl.sfc` `8f3fcb518d8cd4ec5dcfe7a94123deef`. Then twice
warm with the shared cache, in a second ports worktree: the first equal
(checkout paths aside), the second equal but for Vampires Dawn's 672
left-out warnings a cached compile does not print, as before
([`the-event-compiler-s-left-out-warning-never-reaches-the-log`](the-event-compiler-s-left-out-warning-never-reaches-the-log.md)).
`just lint`, `just test` (29), `just rust-test --no-fail-fast` (133
binaries, none red), `just test-game` (231 passed, 6 skipped), the ports'
`just boot` (218) and ABL's `just tests` (1694 passed, 2 skipped) green.

#### What is left of JSON between stages in the converter

Counted on `120fcd9e` (`from_value`, `Value` fields, reads by key in
`rm2k-snes/convert/src`):

* **Wally's map request**, `maps.rs`: a `json!` of some thirty keys and
  more inserted by name (`variants::request`, `OnMap::to_json`,
  `ForMap::asked`, `Arrivals::json_of`, `MapInfo::request: Value`), read by
  Wally's `from_json`s. Phase B typed Wally's answer (B4), not its
  request: a
  [draft](wally-s-map-request-is-built-and-read-by-hand.md).
* **The screens' four requests**, `screens.rs` —`convert`, `boxes`,
  `window`, `faces`—, with `FontChoice::request()`, the custom menus'
  `{"name", "spec"}` and their `before_bodies` (`convert.rs`), read by
  the screens' `Json` reader. B3 typed their answers: a
  [draft](the-screens-requests-are-built-and-read-by-hand.md).
* **Not between stages, and staying**: the dump and the project's forks
  (`game.rs`, `fork.rs`, `letters.rs`: ditto's sections, read as the dump
  writes them); the project file's settings (`settings.rs`'s `list` and
  `table`, the custom menus' `spec`, which is the game's table, not a
  stage's contract —its keys are read in `settings.rs` for the variables
  and switches it names—); the test cases' files (`convert.rs`'s
  `commands_of`); what the converter writes for people (`patch_uses`'s
  `uses.json`, the queries' stdout, `degradations.json`'s `json!` of
  four keys); the cache's key (`stage::request_in_key`, the `json!` of a
  typed request the battle's two calls hand it); `[sound_effects]`'s
  `from_value` in `compiler.rs`, which reads the project file into the
  request's types; and the tests (`trim.rs`, `chipsets.rs`).

So phase B is not closed: two requests are still JSON both ways. The
task stays in `doing` for Hornero to decide whether those two drafts are
its last steps.

**Install when merging**: `convert`, `events`, `screens` and `mapdata`
(`just install convert events screens mapdata`). The scan's cached
answers move once —its request's key order changed—; the compile's do
not.


### 2026-11-24, Carpintero: the screens' four requests typed

[`the-screens-requests-are-built-and-read-by-hand`](the-screens-requests-are-built-and-read-by-hand.md),
in the-advocate `carpintero-screens-request` (`7c862830`, over
`633dcde7`): `convert`, `boxes`, `window` and `faces` are
`rm2k_snes_screens::request::{Convert, Boxes, Window, Faces}`, with
`TextFont` (what `FontChoice::request()` now answers), `Line`,
`OtherSystem` and `Menu` —its `spec` still the project's table—; the
converter builds them as structs, the stage functions take them and the
binary reads its file into them with serde. The `Json` readers for them
went; `render` and `equip`, the tests' commands, still read by key. −50
net lines. The nine games byte for byte against `633dcde7`, cold and
warm twice, the four suites green; the task's log has the detail. Of
the two requests Calandria counted as left, Wally's is Aguará's.
**Install when merging**: `convert` and `screens`.

### 2026-11-24, Aguará: Wally's map request typed

[`wally-s-map-request-is-built-and-read-by-hand`](wally-s-map-request-is-built-and-read-by-hand.md),
in the-advocate `aguara-wally-request` (`f6208d13` over `633dcde7`,
`main` merged at `ed7898d3`): the request is `wally::request::Asked`
—`LayersAsked` for `layers`—, built by the converter as a struct and
read by the stage and its binary with serde; the `from_json`s, the
`to_json`/`json_of`/`*_json_of` builders and their helpers went. `pages`
now carry only Wally's `ScannedPage`, not the scan's whole record. −126
net lines. The nine games byte for byte against `633dcde7`, cold and
warm twice, the four suites green on the merged tree; the task's log has
the detail. With Carpintero's screens, the two requests Calandria
counted as left are typed. **Install when merging**: `convert` and
`wally`.

### 2026-11-24, Hornero: phase B closed, to `testing`

With Wally's and the screens' requests merged (the-advocate `6edfe5ff`
and the merge after it), the stages speak types both ways: what JSON is
left in the converter is the dump and the forks, the project's settings,
the case files, what is written for people (`uses.json`, the queries,
`degradations.json`), the cache key, and the tests. Verified on the
merged tree: `just lint`, `just test`, `just rust-test --no-fail-fast`
(the flaky `a_cached_object_gives_the_dbg_a_fresh_one_gives` failed once
under load and passed three times alone), the test game, the ports'
`boot`, ABL's suite, and the nine games' `release` ROMs equal to the ones
delivered. Nothing to see or hear: every step was byte for byte.

Next in the queue, from the design's section 7:
[`one-advocate-command`](one-advocate-command.md), then
[`a-stage-s-cache-key-once-it-is-a-library`](a-stage-s-cache-key-once-it-is-a-library.md).
