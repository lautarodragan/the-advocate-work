---
name: "One advocate command"
description: "Once the stages are libraries, the converter becomes one too, and rm2k-snes-cartridges becomes `advocate`, with subcommands: build, assemble, space, and whatever else is building the game"
type: refactor
status: doing
assignee: calandria
agents: [calandria]
author: taro
links:
  relates: [artistic-decision-patches, battle-tests-without-simulate, the-volume-ceilings-are-measured-without-a-rom, tests-without-the-stages-subcommands, the-cartridges-fingerprint-hashes-the-path-s-builder]
  has-part: [cartridges-runs-itself-to-assemble, the-stage-subcommands-only-the-converter-called-have-no-caller, just-culprits-reads-the-dump-without-the-project-s-common-events]
  found: [just-culprits-reads-the-dump-without-the-project-s-common-events]
  blocked-by: [the-stages-speak-json-nobody-types]
  blocks: [advocate-init-dump-and-config]
---

**Why**: building a game is today a chain of processes —
`rm2k-snes-cartridges` runs `rm2k-snes-convert`, which runs each stage,
and then runs itself to assemble—. After
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
the stages are libraries inside the converter; this takes the last step:
the converter is a library too, and what a person runs to build a game is
one command, named after the project and its `advocate.toml`.

> Hmm, I like it! And turning the converter into a library too. All the
> stages stay as libs. And advocate with subcommands. It's beautiful.

(taro, 2026-11-23)

> [a file in `build/` instead of `rm2k-snes-project`] I like that idea.

(taro, 2026-11-24)

**What is asked**: `rm2k-snes-cartridges` becomes `advocate`, with the
converter linked in:

    advocate build      what rm2k-snes-cartridges does today: convert,
                        assemble, the MSU-1 tracks
    advocate assemble   only assemble
    advocate space      each cartridge's free space

To decide in its design, each with its why:

* **`rm2k-snes-project` goes, instead of becoming `advocate project`**:
  `advocate build` leaves in `build/` a file with what it prints today,
  and the ports' tests and recipes read that file. The tests then consume
  no binary —the book's decision "One command, and no tool of ours runs
  another"—; `--unpacked` and `--harness`, its other two modes, need a
  place too.

* **The MSU-1 tracks**, `rm2k-snes-audio msu`: their cache keys on the
  sources they include (`OWN_SOURCES` in `tracks.rs`), not on a binary, so
  being a library costs them nothing.
* **What stays its own command**: the domain tools a person runs for
  something other than building the game —`ditto`, `goombario`, `fxpak`,
  `rm2k-sketch`, `rm2k-snes-events culprits`, `rm2k-snes-patches`— and the
  stages' subcommands the ports' tests call, if the stages' task left them.

**The goal at the end: `advocate` as one static musl binary, with nothing
beside it.** taro's, 2026-11-24:

> I would love to have that as a goal for `advocate`, if it can be done.
> We go back to really having a statically linked binary, with no
> dependencies, fully self-contained.

> [musl] Let's ignore this for now. We evaluate it again at the end of
> everything.

(taro, 2026-11-24: the goal stands, but it is looked at again once the
rest is done, not along the way.)

What stands in the way today, measured on the-advocate `90d1041d`:

* **The Linux releases are glibc because of one `dlopen`**: the libretro
  core `rm2k-snes-audio volume-ceilings` plays the songs in (`retro.rs`),
  and `release.yml` says so. It is not in what `advocate` links —the
  audio stage does not use `retro.rs`—, and
  [`the-volume-ceilings-are-measured-without-a-rom`](the-volume-ceilings-are-measured-without-a-rom.md)
  takes it away for good. No crate of the workspace links C today.
* **The runtime is not inside the binary**: `rm2k-project`'s `suite.rs`
  finds `runtime/` through the checkout the binary was compiled from
  (`CARGO_MANIFEST_DIR`), or beside the release's `bin/`. Self-contained
  means the runtime's sources embedded in `advocate` —a couple of MB of
  text—. What it costs: editing a `.s` then needs a rebuild of `advocate`
  before a ROM sees it, so a flag pointing at a `runtime/` on disk is
  probably kept for whoever works on the engine; and `just deliver`, which
  copies the commit's `runtime/` beside the ROM for Mesen2, takes it from
  git as it does now.
* **What it still runs is not ours**: `ca65` and `ld65`, and the MSU-1
  tracks' synthesizer and encoder. Self-contained is about `advocate`
  itself; those stay requirements on the `PATH`, as the book's decision
  says.
* **If `snes_spc` comes in** for the volume ceilings, it is C++: building
  it statically for musl needs the C++ standard library for that target,
  which is to be checked then.

The cartridges' fingerprint, which hashes the binaries the build runs,
shrinks with them; the recipes, the harness, AGENTS.md, the book and
`release.yml` follow the new name.

It goes after
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md),
and [`cartridges-runs-itself-to-assemble`](cartridges-runs-itself-to-assemble.md)
is its first step.

## Design

Calandria's, 2026-11-24, read at the-advocate `cd3a40af`, ports `4c23c9e`;
for taro before any code. Section 7 has what only taro can answer.

### 1. The shape

**A new crate, `rm2k-snes/advocate/`, with one binary, `advocate`, and
nothing else in it**: its `main` and one module per subcommand. It links
`cartridge` (which keeps the cartridges, the fingerprint, the banks, the
assembler and `space` as a library, and loses its binary),
`rm2k-snes-convert` (which gains a `[lib]`), `rm2k-snes-audio` (for the
tracks) and `rm2k-project`. Why a crate of its own and not the cartridge
crate's binary renamed: the cartridge crate does not depend on the
converter today, and the binary is the only thing that needs both; as its
own crate the layering stays readable —`advocate` on top, everything a
library under it— and `just install advocate` says what it installs.

**The converter becomes a library with the same entry**: what
`rm2k-snes-cartridges` passes it today as `argv` —`--project`, the machine
flags, `-o`, `--msu`, the cartridge's flags from `advocate.toml`, the
`--test-commands` of each case— goes through the same `options::parse`
into `convert::run`. Not typed further: a cartridge's flags *are* text in
the project file, and they go into the stamp as text. What the process
gave for free and a call does not (`convert.rs`, `cartridges.rs` at
`cd3a40af`):

* **Its output.** The converter writes `converter.log` through its stdout
  and stderr, which `Cartridges::convert` captures (`cartridges.rs:895`,
  stdout first, then stderr). It has 100 `println!` in nine files (two
  more are the queries' and `main`'s), the audio stage four more and the
  event compiler one `eprintln!`
  (`pages.rs:483`); in one process, eleven of ABL's cartridges converting
  at once would interleave them on one stdout. They go through a `Log` the
  conversion is handed —two buffers, out and err, so `converter.log` keeps
  its bytes—, cloned into its two thread scopes (`maps.rs:721`,
  `scene.rs:180`; mapdata's `compress.rs:34` prints nothing).
* **Its working directory.** It ran standing in the suite's root, and the
  cases' paths are given relative to it (`relative(self.case_path(case),
  &self.root)`, `cartridges.rs:889`). In one process the directory is
  wherever `advocate` was run: the paths go absolute. They are printed
  only in errors (`options.rs:391`), not in anything the build leaves.
* **Process-wide state.** `stage.rs`' `CACHE` is a `OnceLock` set by the
  first conversion and kept for the rest: harmless while every cartridge
  of a run shares one cache, wrong the day one does not, so it moves into
  the conversion. `VERSIONS` memoizes files by content: safe across
  cartridges, the sources are not touched during a build. Wally's memos
  are already forgotten per map (`layers.rs:529`), the screens' letters
  per call (A3). `TRANSLUCENT_MODE`, `DITHER_PATTERN` and `NO_CACHE` are
  read from the environment, the same for every cartridge.
* **A panic** took one converter process down with its message; in a
  build thread it takes `advocate` down. `stage::call` already catches the
  stages'; `convert::run` gets the same `catch_unwind`, and says
  "`<cartridge>`: the converter panicked: …".
* **Its exit code** (`Stop { code }`): nobody read it but to say "the
  converter failed; everything is in converter.log", which stays.

**The MSU-1 tracks**, `rm2k-snes-audio msu`, become a call of its
library (`commands/msu.rs`), with its lines on `advocate`'s stdout as they
are now and its summary line taken by the caller the same way. Its cache
keys on `OWN_SOURCES` and the versions of `fluidsynth` and `ffmpeg`, not on
a binary: nothing to change.

**The subcommands**: what `rm2k-snes-cartridges` takes today, every flag,
and where it goes.

| Today | `advocate` | Who uses it |
|---|---|---|
| `rm2k-snes-cartridges [NAMES] [--force] [--without-tracks]` + `--project` and the six machine flags | `advocate build [NAMES] …`, same flags | every game's `just cartridges` |
| `--list` | `advocate build --list`: builds nothing | a person |
| `--list --json` | **goes**: the file in `build/` (section 2) | ABL's `cartridges.py`, the generic harness's `game.py`, the ports' `games.py`, `volume-ceilings` |
| `NAME --convert-into DIR -- FLAGS` | `advocate build NAME --into DIR -- FLAGS` | `volume-ceilings` (`volume_ceilings.rs:168`), a person |
| `space [NAMES\|ROM] [--json]` | `advocate space …`, same | `just space`; ABL's `cartridges.space` until section 2 |
| `assemble SOURCE -I -o --symbols --cache` | `advocate assemble …`, same | a person; the build calls its code |
| `assemble --memory-map` | **goes**: the file | ABL's `cartridges.memory_map` |
| `assemble --sources MAIN` | **goes**: the file, for the runtime's `main.s` | ABL's `cartridges.sources` |
| bare `rm2k-snes-cartridges` builds | bare `advocate` prints its help | — |
| `rm2k-snes-project [--project]` | **goes**: the file | section 2 |
| `rm2k-snes-project --harness`, `--unpacked` | `advocate where …`, if taro agrees | section 2 and question 1 |

`--force`, `--without-tracks`, the names and the machine flags mean what
they mean today. A cartridge called `build`, `space`, `assemble` or
`where` is refused, as `SUBCOMMANDS` refuses `space` and `assemble` now.

**What stays its own command**, the task's list checked against the
workspace's binaries:

* the domain tools a person runs: `ditto`, `goombario`, `fxpak`,
  `rm2k-sketch`, `rm2k-snes-events culprits`, `rm2k-snes-patches` (`BUILD`
  and `--check`);
* the stages' binaries the tests still call (section 5), until
  [`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md)
  takes their callers away;
* `rm2k-snes-convert`, **only for its queries** —`scan`, `compile`,
  `leaders`, `map-context`, `boxes`, which 26 ABL test files call through
  `converter.py`—: its conversion mode goes, a thin `main` over the queries
  stays until the same task takes them;
* `rm2k-snes-audio`'s person and test subcommands; `volume-ceilings`
  until [its task](the-volume-ceilings-are-measured-without-a-rom.md)
  removes it. It runs the builder by name today (`CARTRIDGES`,
  `volume_ceilings.rs:35`), the one place outside the builder where one of
  ours runs another for building: it follows the rename to `advocate build
  --into` and reads the file instead of `--list --json`, and goes with it.

**What goes**: `rm2k-snes-cartridges`, `rm2k-snes-project`, the
conversion mode of `rm2k-snes-convert`, `rm2k-snes-audio msu` (its one
caller is the builder), and the dead subcommands of section 5.

### 2. The file the build leaves: `build/advocate.json`

**Every `advocate build` writes it, at the end, also when every cartridge
was up to date and also when one failed** —then that cartridge's entry
says why it is stale, as `--list --json` would—. Not `--into` (a copy
elsewhere) nor `--list`. Written aside and renamed, as the disk cache
writes, because the ports' suite builds several games at once and a
reader must never see half a file. JSON, because every reader is Python's
standard library and every one of today's answers already is.

**Where**: `<project>/build/advocate.json`, beside `advocate.toml`'s
`build/`. That is the catch: `[paths] build` is configurable, and a
harness that has to find the file without reading `advocate.toml` cannot
know it was moved. Every project, the test game included, says `build =
"build"` (the ten files, read today). Question 2.

**What it holds**: today's answers, unchanged inside, so each reader's
diff is "read a key" instead of "run a binary".

| Key | What | Today from |
|---|---|---|
| `project`, `suite`, `settings` | the project's eight paths; the suite's `directory`, `root`, `runtime`, `harness`; the whole project file | `rm2k-snes-project` (`resolved.rs`) |
| `machine` | each machine value the build was given, `{"given": …, "read": …}`; `read` is the directory it is read from, unpacked if a `.zip` | `rm2k-snes-project --unpacked` |
| `listing` | root, runtime, cases, maps, `where_is`, `fingerprint`, `fingerprint_files`, and each cartridge —`directory`, `rom`, `msu`, `flags`, `cases`, `teleports`, `without_title`, `stale`— | `rm2k-snes-cartridges --list --json` (`describe`) |
| `listing.cartridges[].space` | the numbers `space --json` gives, from when the cartridge was built; `null` if it is not | `space --json` |
| `memory_map` | bank size, banks, stack, far pool, WRAM areas | `assemble --memory-map` |
| `sources` | the runtime's `main.s` and what it includes, in `ca65`'s order | `assemble --sources` |

Measured on ABL with the global tools: `--list --json` is 93 KB and
0.11 s (the fingerprint included), `rm2k-snes-project` 9.7 KB, `space
--json` of the eleven cartridges 2.3 s. So `space` is computed **when a
cartridge is built**, into a `space.json` beside its ROM, and copied into
the file; recomputing it on every `just tests` would add two seconds for
nothing.

**"Up to date" is from when the build ran, not from when a test asks.**
Today the harness recomputes the fingerprint on every session (it passes
the machine flags to `--list --json` for that). Reading a file, a test
believes the last build: if a source is edited after `just cartridges`
and `pytest` is run by hand, the file still says "up to date" and the test
runs an old ROM. Every recipe that runs tests builds first (`just tests`,
`just boot`, the test game's `test`, `games.py`'s `prebuild`), so through
`just` nothing changes. Question 3. A gain on the side: the harness no
longer has to hand the builder the same machine flags it built with,
which is how a mismatch made a fresh cartridge look stale.

**Who reads it instead**, every caller of `rm2k-snes-project` in the four
repos (grep of `cd3a40af`, `4c23c9e`, the book's `main`; what is a comment
or prose is in step 6):

| Caller | Mode | After a build? | Instead |
|---|---|---|---|
| ABL `tests/harness/project.py` `resolved`, `path`, `settings` | default | yes, `just tests` builds first | the file's `project`, `settings` |
| ABL `project.harness()` (`places.py`, on import) | `--harness` | yes | the file's `suite.harness` |
| ABL `project.unpacked()` (`places.py:76-77`) | `--unpacked` | yes | the file's `machine.*.read` |
| ABL `cartridges.py` `listing`, `space`, `memory_map`, `sources` | `rm2k-snes-cartridges` | yes | `listing`, `…space`, `memory_map`, `sources` |
| the-advocate's `rm2k_snes_harness/game.py` `listing`, `project` | both | yes, the test game's `test` builds first | the file |
| ports `tests/games.py:302`, `:290` | default, `--list --json` | yes, after `prebuild` | the game's file |
| ports `tests/games.py:39` `_harness` | `--harness` | **no**: on import, before any game is built, and no one project | question 1 |
| ports `tests/test_round_trip.py:48` | `--unpacked` | **no**: it builds nothing, `BUILDS = ()` | question 1 |
| ports `game.just:57` `dump` | `--unpacked` | **no**: the dump is the build's input | question 1 |
| ports `justfile:104` `deliver` | default, for the tools' root | before the builds | the dirty check of the tools moves after ABL's build and reads its file |
| the-advocate `test-game/justfile:96` `deliver` | default | yes, `(cartridges "release")` | the file |
| ABL `deliver.py` | default | yes, `deliver` builds `release` | the file |
| ABL `justfile:274`, `:321` (`audit-core`, `mesen2-core`) | `--harness` | **no**: they build an emulator core, no game | question 1 |
| ABL `experiments/*/` (five scripts) | `--harness` | they run after a build | the file, or question 1 |
| `release.yml:131-132` (smoke test) | default, `--harness` | **no**: no `ca65` on the release runners | question 1 |
| `volume_ceilings.rs` | `--list --json` | it builds first | the file |

So the file covers everything that runs after a build, and five callers
run before one, where no file can exist yet: the multi-game suite's import
path, the round trip, the dump, the cores' recipes and the release's smoke
test. Question 1 is what answers those.

### 3. The fingerprint

`fingerprint_files` (`cartridges.rs:605-640`) hashes the runtime, every
input of the game, and four binaries found on the PATH: `ca65`, `ld65`,
`rm2k-snes-convert`, `rm2k-snes-cartridges`. Afterwards: **the runtime,
`ca65`, `ld65`, and the running `advocate`** —`current_exe()`, not the
PATH's—, which is the binary that converts and packs the banks. The MSU-1
tracks' `fluidsynth` and `ffmpeg` stay out, as now: the tracks are outside
the stamp and their cache keys on their versions.

**This settles
[`the-cartridges-fingerprint-hashes-the-path-s-builder`](the-cartridges-fingerprint-hashes-the-path-s-builder.md)**:
with one binary there is nothing on the PATH that builds; it is the one
running. What kept Mulita from doing it there was the crate's test
(`everything_that_builds_the_rom_is_in_the_fingerprint`, `tests/cartridges.rs:351`),
which puts stand-ins on a PATH of its own and where `current_exe` is the
test binary: `fingerprint_files` takes the builder's path as an argument,
`advocate` passes `current_exe()`, the test passes its stand-in. The draft
closes with that step.

**What it costs, besides one rebuild of every cartridge** (the stamp
changes once): the stage cache keys every answer by the converter's binary
(`stage.rs`, `current_exe`), which becomes `advocate`, so a change to the
builder's own code —the banks, the fingerprint, `space`— now throws the
stage answers away too. Measured on the-advocate's last month: 23 commits
touched `rm2k-snes/cartridge`, 11 of them nothing the converter links;
against 215 that touched the converter's side. Some 5% more cold builds,
inside the price taro accepted for one key, until
[`a-stage-s-cache-key-once-it-is-a-library`](a-stage-s-cache-key-once-it-is-a-library.md).

### 4. The runtime embedded, or not

**Not in this task: in the one that makes `advocate` a static musl binary**,
which taro left for the end. Embedding is only needed for
"self-contained", and it brings choices that are seen:

* **`ca65` reads files**, so an embedded runtime is unpacked somewhere
  before assembling —into the cache by its content, as a game's `.zip`
  is—; and the `.dbg`'s source paths, which today are relative to the
  checkout so that Mesen2 finds `runtime/` going up from `/shared/builds/`,
  would point there.
* **The converter reads the runtime too**: `low_ram.s` and
  `common_events.s` (`convert.rs:2335`, `:2360`), and its search
  directories start at `suite::root()` (`:2164`). Both readers have to see
  the same runtime.
* **`just deliver`** copies the commit's `runtime/` with `git archive` from
  the checkout the tools came from: with the runtime embedded, the binary
  has to say which commit it carries.
* **The harness**, `rm2k-snes/harness/` in Python, travels with the
  runtime for the same reason (it reads the symbols the runtime names), and
  a binary cannot carry it for `import`: a release keeps it beside `bin/`.

**The flag** for working on the engine: `--runtime <DIR>`, a machine value
in `environment::FLAGS` like `--cache`, read by `suite`'s callers instead
of the compiled path; without it, the embedded copy. Today the compiled
checkout is the default and nothing needs the flag; in this task `suite.rs`
does not change. What this task does for that one: **every test reads
where the runtime and the harness are from the file**, so when embedding
lands only `advocate` changes.

### 5. The stages' binaries

**What the tests still call after this task**, unchanged —
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md)'s
list, re-grepped on `4c23c9e`—: `wally` `bakeable`, `split`;
`rm2k-snes-events` `scan`; `rm2k-snes-screens` `render`, `equip`,
`layout`, `window`, `refit`; `rm2k-snes-images` `backdrops`, `battlers`,
`animations`; `rm2k-snes-battle` `simulate`, `lines`, `experience`,
`field-skill`, `model`, `layout`; `rm2k-snes-mapdata` `vram`, `engine`,
`pages`, `compress`; `rm2k-snes-convert`'s five queries; `rm2k-snes-audio`'s
eight. This task leaves all of them working and their binaries installed;
the other task removes callers and then binaries. Each stage binary's
`main` is over its library already (phase A), so nothing here touches
them.

**And the tests' other binaries**, which the decision's "the tests consume
no binary" reaches too but neither task names: `goombario` (the linter
over every built cartridge, `test_linter.py` in ABL and the test game),
`ditto unpack`/`pack` (`test_round_trip.py`), `rm2k-snes-patches --check`
(`test_patches.py`). Question 4.

**The dead subcommands**,
[the has-part](the-stage-subcommands-only-the-converter-called-have-no-caller.md):
its eleven —`wally map`; `rm2k-snes-events compile`;
`rm2k-snes-screens boxes`, `faces`, `convert`; `rm2k-snes-images
fullscreen`, `picture`, `background`; `rm2k-snes-battle tables`;
`rm2k-snes-mapdata emit`; `rm2k-snes-audio cartridge`— **plus one it
missed**, `rm2k-snes-patches --request` (the converter's mode, `main.rs:67`;
the converter calls `rm2k_snes_patches` as a function since A8), and,
once this task folds them, `rm2k-snes-audio msu` and
`rm2k-snes-convert`'s conversion mode. Two things the draft does not say,
logged there: **crate tests drive some of them through the binary**
—`wally map` in five files (`whole_map.rs`, `decorative.rs`,
`fused_tiles.rs`, `shared_slots.rs`, `too_many_npcs.rs`),
`rm2k-snes-battle tables` and the events' in `command_line.rs`—, so
removing a subcommand moves its tests onto the stage function, which is
most of the step's size; and the book's "Running them by hand" in
`tools.md` follows. None of it touches the converter or the builder: it
goes in parallel with steps 1-3.

### 6. The steps

Every step that touches the build is verified as phase A was: the nine
games with `NO_CACHE=1 just cartridges --force` (ABL `--without-tracks`),
**every file of `build/<cartridge>/` byte for byte** against the same build
with the tools before the step —`converter.log` included, which is the
check of the `Log`—, the `.o` and `.dbg` aside (`ca65`'s mtimes) and
`stamp.txt` aside where the fingerprint changes; then a warm build that
answers from the cache; then `just test`, `just rust-test`, the test game,
the ports' `just boot` and ABL's `just tests`.

| Step | What | Repo | Size | Order |
|---|---|---|---|---|
| 1 | the converter a library: `[lib]`, `convert::run(options, &Log)`, the 100+5 prints through the `Log`, `CACHE` into the conversion; its binary over it, unchanged | the-advocate | ~250 lines, mostly mechanical | first |
| 2 | the builder calls it: `Cartridges::convert` without `Command`, absolute case paths, `catch_unwind`; the tracks as a call; `fingerprint_files` with the builder's path, `CONVERT` and `CARTRIDGES` out; closes the fingerprint draft | the-advocate | ~200 | after 1 |
| 3 | `rm2k-snes/advocate/` with `build`, `assemble`, `space` (`where` if question 1 says so); the file, `space.json`; the cartridge crate's subcommand modules move into its library so both binaries share them; **`rm2k-snes-cartridges` and `rm2k-snes-project` stay**, as they are; the test game's recipes and `game.py` move to `advocate` and the file; `release.yml`'s smoke test; `volume-ceilings` to `advocate`; `rust_projects` gets `advocate` | the-advocate | ~500 | after 2 |
| 4 | the ports to `advocate` and the file: `game.just`, ABL's and the root's `justfile`, ABL's `project.py`, `cartridges.py`, `places.py`, `deliver.py`, `games.py`, `test_round_trip.py`, the five experiments; `RENAMES.md` gets its rows | ports | ~300 | after 3 is merged **and installed** |
| 5 | `rm2k-snes-cartridges`, `rm2k-snes-project`, the converter's conversion mode, `assemble --memory-map`/`--sources`, `--list --json` go | the-advocate | -600 | after 4 is merged |
| 5b | the has-part: the dead subcommands and their crate tests onto the functions | the-advocate | ~-400, tests moved | any time; `msu` and the conversion mode with 5 |
| 6 | the prose, its own commit per repo: AGENTS.md (the install lines —a stage change is `install-local .local-tools advocate <stage>`—, "Where this runs", the fingerprint, `rm2k-snes-project`), the roster if it names them, LAYOUT.md, the crates' READMEs, the justfiles' comments, the book —`tools.md`, `internals/pipeline.md`, `internals/the-converters-stages.md`, `internals/vram.md`, `maps.md`, `events.md`, `the-msu-file.md`, `the-pause-menu.md`, `ports/abl/README.md` and `pipeline.md`, `progress/the-test-game.md`, the current decisions that name the old binaries, and the decision's "It is a direction" paragraph—; research pages are snapshots and stay | all four | judgement | after 5 |
| 7 | `[paths] build` goes, if question 2 says so | the-advocate, ports | small | with 3 and 4 |

**The rename's window**: the ports call the builder by name, so `main`
stays green only if, at every merge, what the ports call is installed.
Step 3 adds `advocate` beside the old two, step 4 switches the ports,
step 5 removes the old ones. Between 3 and 5 both builders exist and
stamp differently (each hashes itself), so switching from one to the
other rebuilds once; harmless. **Removing a binary does not uninstall
it**: `just install` skips a crate that has become a library, and the old
`/usr/local/bin/rm2k-snes-cartridges` and `rm2k-snes-project` would stay,
answering from an old build for whoever still calls them. Merging step 5
deletes them by hand (`cargo uninstall rm2k-snes-cartridge rm2k-project`),
in the global root and in the `.local-tools` of any open worktree. CI
installs into a fresh root and does not see this.

**What can run in parallel**: 5b beside 1-3 (other crates); the book's
prose drafted beside 4. 1 → 2 → 3 → 4 → 5 is serial: each changes what the
next calls.

**Install when merging**: 1, `convert`; 2, `cartridge convert` (and
`rm2k-snes-audio` if the tracks' call changes its crate); 3, `advocate`;
5, `advocate convert` and the uninstall above.

### 7. Risks, and what this does not settle

* **Memory**: eleven of ABL's conversions in one process weigh what eleven
  processes weighed; not measured, and it does not grow.
* **The test of "up to date" moves from the session to the build**
  (question 3).
* **A failed `--force` rebuild**: `build` writes the stamp after a
  success and does not remove it before converting, so a conversion that
  fails half-way with the same inputs leaves the old stamp, which still
  matches. The file would say "up to date" exactly as `--list --json` does
  today; not reproduced, so not a draft; step 3 can remove the stamp
  first.
* **The JSON key order** inside the file is `describe`'s and
  `resolved`'s, which run with `preserve_order` in the same binary: no
  difference for a reader by key.
* **Not settled here**: the cache key per stage (its own task); the
  runtime embedded (section 4); the tests' other binaries (question 4).

## Log

### 2026-11-23, Hornero: written

Nothing done yet.

### 2026-11-24, Hornero: the project as a file the build leaves

At taro's word; the decision is in the book, `src/decisions/one-command-and-no-tool-runs-another.md`.

### 2026-11-24, Hornero: a static musl binary as the goal

At taro's word; what blocks it, measured, above.

### 2026-11-24, Calandria: the design, for taro

Read-only, at the-advocate `cd3a40af`, ports `4c23c9e`, the book's
`main`; written above as `## Design`. Measured on ABL with the global
tools: `--list --json` 0.11 s and 93 KB, `rm2k-snes-project` 9.7 KB,
`space --json` of eleven cartridges 2.3 s, `assemble --sources` and
`--memory-map` a few milliseconds; the builder crate alone changed in 11
of the last month's commits against 215 on the converter's side.

Found and logged in
[the has-part](the-stage-subcommands-only-the-converter-called-have-no-caller.md):
`rm2k-snes-patches --request` has no caller either, and crate tests drive
`wally map`, `rm2k-snes-battle tables` and `rm2k-snes-events compile`
through the binary.

#### Calandria: questions for taro

1. **What runs before any build.** The file answers everything that runs
   after `advocate build`; five callers of `rm2k-snes-project` run before
   one, where no file exists yet: the ports' multi-game suite, which puts
   the harness on its import path when it is imported, before building any
   game (`--harness`); the cores' recipes in ABL (`--harness`); the
   release's smoke test, on runners without `ca65` (both modes); the
   `dump` recipe, whose output is the build's input (`--unpacked`); and the
   round trip, which builds nothing (`--unpacked`). Options:
   * **(a) `advocate where suite|game_dir|rtp_dir`**: prints the suite's
     paths, needing no project, or the directory a machine value is read
     from. The two modes of `rm2k-snes-project` under another name, for
     what has no build to read; the tests then call it only for the
     multi-game suite's import path and the round trip.
   * (b) each caller on its own: Ditto reads a `.zip` (the reader moves
     down from `rm2k-project`), the multi-game suite imports the harness
     after building, the cores' recipes build ABL first and read its file.
     It leaves the release's smoke test with nothing to ask, and the
     round trip and the dump would read the game without the port's own
     files merged in, which is what `--unpacked` gives today.
   * (c) as (a), with `advocate dump` doing `just dump` whole.

   **Recommended: (a).** The decision lists `build`, `assemble` and
   `space`; this would be a fourth, which is why it is asked.

2. **`[paths] build` goes?** The harness finds the file by the project's
   directory; with `build` configurable it would have to read
   `advocate.toml` to find it, a second reader of that format. The ten
   projects all say `build = "build"`. **Recommended: it goes, and
   `build/` beside `advocate.toml` is fixed**, the way Cargo's `target/`
   is; the alternative is the harness reading that one key with
   `tomllib`.

3. **"Up to date" from the build, not from the test.** Today every test
   session recomputes the fingerprint; with the file, a `pytest` run by
   hand after editing a source and without building runs the old ROM
   without a warning. Through `just` nothing changes: every recipe that
   runs tests builds first. Options: **(a) accept it**, which is the
   decision's "the tests consume no binary" taken whole; (b) the harnesses
   run `advocate build` once at the start of a session, as the ports'
   `prebuild` already does —ABL's "the tests build nothing" goes—.
   **Recommended: (a).**

4. **The tests' other binaries**: `goombario` over every built cartridge,
   `ditto unpack`/`pack` in the round trip, `rm2k-snes-patches --check`.
   They are domain tools a person runs too, but the tests run them, and no
   task says whether "the tests consume no binary" reaches them.
   **Recommended**: not in this task; they go into
   [`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md)'s
   classification, where the answer can be "they stay: they test the
   tool, or lint the product".

### 2026-11-25, Hornero: taro's answers

> I agree with points 2, 3 and 4.

(taro, 2026-11-25) So: `[paths] build` goes and `build/` beside
`advocate.toml` is fixed; "up to date" is what the last build saw, the
by-hand `pytest` without building accepted; and `goombario`, `ditto` and
`patches --check` in the tests go to the classification of
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md).

On question 1:

> Hmm, it seems the best decision right now, but in my mind the tests
> should never call any binary, they should only require the ROM.

(taro, 2026-11-25) Hornero proposed a fourth option, **(d) no `advocate
where`**: `--harness`, which most of the five callers ask, is where the
Python package `rm2k_snes_harness` lives —an installation problem, not
the tests'—, so `just install` installs it too (a `.pth` pointing at the
checkout is enough) and the tests import it; `GAME_DIR` and `RTP_DIR` are
already exported by `machine.just` and reach the tests, and Python reads
a `.zip` with `zipfile`; `just dump` and the round trip are recipes and
may call `ditto`, a domain tool that stays; the release's smoke test,
with the package installed and the variables, has nothing to ask. It
costs installing the package and the harness reading a `.zip`; it keeps
the rule whole. Waiting for taro.

### 2026-11-25, Hornero: (d) chosen; steps 1-3 to Calandria, 5b to Tijereta

> Go ahead. [option (d)]

(taro, 2026-11-25) Question 1 settled: no `advocate where`; the harness
installed as a Python package, the machine paths from the environment.
Steps 1-3 (the converter as a library, the builder calling it, `advocate`
born beside the old binaries) go to Calandria in series; 5b (the dead
subcommands,
[`the-stage-subcommands-only-the-converter-called-have-no-caller`](the-stage-subcommands-only-the-converter-called-have-no-caller.md))
to Tijereta in parallel. Step 4 with (d) after them.

### 2026-11-25, Hornero: no `space` subcommand

> What does the space subcommand do, exactly? Do we really need it, or
> could it be part of build's output?

(taro, 2026-11-25) It does not need to be a subcommand: `advocate build`
already computes each cartridge's space when it builds it (section 2) and
keeps the whole detail in `build/advocate.json`; at the end it prints one
line per cartridge —free data banks and the tightest bank—. The ports'
`just space` reads the file (step 4), and a ROM built apart is measured
by the `advocate.json` its build left beside it. What is lost: measuring a
loose `.sfc` no build of ours made, which nothing does. taro agreed
("dale"). So `advocate` is `build` and `assemble`.

### 2026-11-25, Hornero: `patches --check` and `culprits` fold into `build`

> `rm2k-snes-events culprits` and `rm2k-snes-patches --check`: does it
> make sense that they exist outside the advocate binary? Shouldn't they
> be subcommands?

> I like your proposal!

(taro, 2026-11-25) Neither stays a command of its own, nor becomes a
subcommand:

* **The versioned patches**: `advocate build` already makes the decisions
  `patches/auto/` versions, so it compares them against what is
  versioned, records what is stale in `advocate.json` and says so when it
  prints; ABL's `test_patches.py` reads the file instead of running
  `rm2k-snes-patches --check`. Writing them is a flag,
  `advocate build --write-patches`, instead of the binary without
  `--check`.
* **`culprits`**: a report for people, so `advocate build` leaves
  `culprits.json` in `build/<cartridge>/` on every build, as it leaves
  `converter.log`, if it is cheap —to be measured: `--every-map`
  compiles every map of the game—; if it is not, `advocate culprits`.

`advocate` stays `build` and `assemble`.

### 2026-11-25, Hornero: no `assemble` either

Nothing calls `rm2k-snes-cartridges assemble` —no recipe, test or CI; the
design's table says "a person"—, and `advocate build` with the cache
already does what it was for: after a change to `runtime/` alone the
stages' answers come from the cache and only the assembly runs.

> Go ahead, out it goes.

(taro, 2026-11-25) So `advocate` builds; whether it keeps subcommands at
all is being talked over with taro (`ditto` as `advocate dump`, an
`init`, a machine config file) and will be written here when settled.

### 2026-11-25, Hornero: subcommands stay, the rest is another task

`advocate` keeps subcommands, `build` the main one; `init`, `import` (Ditto; first called `dump`)
and `config` (a machine file under flags and environment variables) are
[`advocate-init-dump-and-config`](advocate-init-dump-and-config.md), in
`todo`, after this one (taro, 2026-11-25: "dale! directo a `todo`").
`goombario` folding into `build`, like the patches, is noted there for
step 4 or `tests-without-the-stages-subcommands`.

### 2026-11-25, Calandria: step 1, the converter a library

the-advocate `d2080587` (branch `calandria-advocate`, from `cd3a40af`).
`rm2k-snes-convert` gains a `[lib]`, `rm2k_snes_convert`: `convert(argv,
&Log)` is the conversion as the binary runs it, with what it says in a
`Log` instead of stdout and stderr. The `Log` is
`rm2k-snes/project/src/log.rs`: `outln!`/`errln!` write into the log the
thread converts into, or onto stdout and stderr when there is none —so
every binary prints as before—, and it keeps two buffers so
`converter.log` stays stdout first and stderr after. What goes through
it: the converter's 101 `println!`, the audio stage's six lines and the
event compiler's one warning (`pages.rs`; the events crate gains
`rm2k-project` for it). A thread-local and not a parameter: the prints
sit behind a hundred signatures, and the stages are called through
functions shaped by their request. The stages' `CACHE` is no longer a
`OnceLock`: a thread-local set by the conversion with a guard, and both
it and the log are carried into the conversion's two thread scopes
(`stage::carried`). A flag the parser refuses no longer exits the
process (`From<clap::Error> for Stop`); the binary prints it as before.

#### Verified

The nine games with `NO_CACHE=1 just cartridges --force` (ABL
`--without-tracks`), the global builder of `cd3a40af` with this step's
`rm2k-snes-convert` first on the PATH, against the same with the global
tools: every file of each `build/` byte for byte (a script, comparing
4,476 files of ABL's and 15,000 more), and the only differences are
`stamp.txt` (the converter's binary is in the fingerprint), the `.o`, the
`.dbg`'s `mtime`s, and the checkout's path where a file names it —the
`.dbg`, `converter.log`'s three `->` lines, `events-request.json`'s
manual maps—. Every `.sfc`, `.msu`, `mapdata.inc`, and `converter.log`
apart from those paths, equal. `cargo test` of `rm2k-project` and
`rm2k-snes-convert`, and clippy of the four crates touched, clean.

### 2026-11-25, Calandria: step 2, the builder calls the converter

the-advocate `88b2fc25` and `4e78d1f7`. `Cartridges::convert` calls
`rm2k_snes_convert::convert` with the flags it passed the binary, the
cases by their whole path, inside a `catch_unwind` ("`<cartridge>`: the
converter panicked: …"), and writes the `Log`'s bytes as `converter.log`;
a panic is said in that log (`log::panics_into_logs`). The MSU-1 tracks
are `Tracks::build` of `rm2k-snes-audio`, its lines on stdout as they came
and the summary built by the caller. `fingerprint_files` hashes
`Cartridges::builder`, the running binary (`current_exe`), and no longer
`rm2k-snes-convert` nor `rm2k-snes-cartridges` from the PATH: that closes
[`the-cartridges-fingerprint-hashes-the-path-s-builder`](the-cartridges-fingerprint-hashes-the-path-s-builder.md)
—its test hands the field a stand-in, and checks that an
`rm2k-snes-cartridges` on the PATH is not hashed—.

Two things the design did not see:

* **A dependency cycle**: the builder's crate now links the converter,
  which links the patches, whose binary linked the builder's crate only to
  know where each cartridge is built for `--check`. That moved into
  `rm2k-project` as `Environment::cartridge`, with `RELEASE`; the
  patches' `main.rs` lost the dependency (one hunk; Tijereta's 5b touches
  the same file).
* **Temporary names by process id**: in one process two conversions wrote
  a project ChipSet's image under the same `<name>.png.<pid>.png` and one
  renamed the other's away; ABL's `test-twins` failed with the PNG not
  found, on the first full run. The same shape was in the fork's dump with
  the project's common events, the unpacked `.zip` and the game with the
  port's own files (process id and nanoseconds); all four take the cache's
  `aside`, now public, which carries a counter of the process.

#### Verified

The same nine `NO_CACHE=1 --force` builds, with this step's
`rm2k-snes-cartridges` first on the PATH and, in front of it, a
`rm2k-snes-convert` and an `rm2k-snes-audio` that fail if run (none was):
against the global tools' builds, every file equal but the ones named in
step 1 (`stamp.txt`: the builder's binary changes; `.o`; the `.dbg`'s
`mtime`s; the checkout's path). And ABL's `release` with its tracks,
`NO_CACHE=1 --force`, through both: the 106 `.pcm` byte for byte, the
same 106 track lines and the same summary; what else the run prints is
fluidsynth's own ALSA and PipeWire noise, interleaved differently each
time. `cargo test` of `rm2k-snes-cartridge` and `rm2k-snes-patches`, clean
(`a_cached_object_gives_the_dbg_a_fresh_one_gives` red once, green alone,
the known flake).

### 2026-11-25, Tijereta: step 5b done

[`the-stage-subcommands-only-the-converter-called-have-no-caller`](the-stage-subcommands-only-the-converter-called-have-no-caller.md)
is in `testing`: the eleven subcommands and `rm2k-snes-patches --request`
removed, on the-advocate branch `tijereta-dead-subcommands` (two commits,
the removal with its tests moved onto the stage functions, then the
crates' prose), and the book's "Running them by hand" in `tools.md`, on
the book's branch of the same name. The nine games' ROMs come out byte
for byte equal. The converter's crate, `runtime/message_face.s`,
`LAYOUT.md` and the book's road diagram still name the old subcommands as
the stages' names: that is step 6's prose. `rm2k-snes-audio msu` and the
converter's conversion mode were not touched, as the design says.

### 2026-11-25, Calandria: step 3, `advocate` beside the old builder

the-advocate `a240f508`, then `15b1178f` merging `main` (Tijereta's 5b:
no conflicts, the workspace's clippy clean). `rm2k-snes/advocate/`, one
binary with one subcommand, `build` —no `space`, no `assemble`, per
taro's answers above—: the names, `--force`, `--without-tracks`, `--list`
and the machine's flags as `rm2k-snes-cartridges` took them, and `--into
DIR -- FLAGS` for what was `--convert-into`. A bare `advocate` prints its
help. `rm2k-snes-cartridges` and `rm2k-snes-project` stay as they were.

What both builders share moved into the cartridge library:
`build_these` (the threads that build several and the tracks after
`release`, from the binary's `main`; it now prints every cartridge's line
and answers the first failure after all are joined), `measure_space`
into a `space.json` beside each ROM when it is built, `Measure::json`,
`assemble::memory_map`. And `build` removes the stamp and the space
before converting: the design's risk of a failed `--force` leaving a
stamp that still matched.

**`build/advocate.json`**, on every `advocate build` (not `--list`, not
`--into`), also when nothing was stale and when a cartridge failed,
written aside and renamed: `project`, `suite`, `settings` (what
`rm2k-snes-project` printed); `machine`, each value given and the
directory it is read from (`--unpacked`'s answer, but in the cache the
build was given and not the project's own: the game with the port's
files on top is keyed by the unpacked game's path, so its directory's
name differs from `rm2k-snes-project --unpacked`'s, which unpacks into
`build/cache/`); `listing`, what `--list --json` printed, with each
cartridge's `space` (`null` when stale); `memory_map`; `sources`. Step
4's readers each find their old answer under one key. Where the file is:
`project.build()`, which every project has as `build/`; step 7 (fixing
`build/`) is not done. At the end `advocate build` prints one line per
cartridge: "release: 0 free data banks (0 fast) and 18 halves; the
tightest, bank 1 with 1099 B left", or why it is stale.

Moved to it: the test game's `just cartridges` and `deliver`, the
harness's `Game` (reads the file; it no longer takes the machine's
flags, and `test-game/tests/conftest.py` stopped passing them), and
`volume-ceilings` (`advocate build --into`; where `release` is, from
`Environment::cartridge`). `rust_projects` has `advocate`.
**`release.yml`'s smoke test is not touched**: it asks
`rm2k-snes-project`, which stays until step 5, and the packaging copies
every binary, `advocate` included; with (d) it goes with step 5.

#### Verified

The nine games with `advocate build --force --without-tracks` and the
recipes' flags, `NO_CACHE=1`, against the global tools' builds: every file
of each `build/` equal but the ones named in step 1, and the new
`advocate.json` and the twenty `space.json`. `advocate.json` of each game
checked against the global `cd3a40af` tools (a script): `project`,
`suite`, `settings` (and its order) equal to `rm2k-snes-project`'s, the
suite's paths apart from the checkout; `machine.*.read` the same
directory below each cache, as said above; `listing` equal to
`rm2k-snes-cartridges --list --json` but `stale`, `fingerprint` and
`fingerprint_files`, which hash each builder (every cartridge `null` in
the file, and its `fingerprint_files` name `advocate` and no old binary);
each cartridge's `space` equal to `space --json` of its ROM;
`memory_map` and `sources` equal to `assemble --memory-map` and
`--sources`.

### 2026-11-25, Calandria: step 3b, the patches and the culprits folded in

the-advocate `45e3ac57`, its own commit after step 3, as Hornero's
message allowed: both fit without touching step 3's verification.

* **The versioned patches**: every `advocate build` compares
  `patches/auto/` against what its built cartridges decided —the
  library's `check`, what `rm2k-snes-patches --check` ran—, keeps it in
  `advocate.json` as `patches: {stale, versioned, own}` (`null` when no
  cartridge has patches) and prints the stale ones after the cartridges'
  lines; a stale patch does not fail the build. `--write-patches` writes
  `release`'s first, what `rm2k-snes-patches build/release` did. The check
  costs a tenth of a second on ABL.
* **`culprits.json`**: cheap, so every cartridge the builder builds gets
  it beside its ROM, as `converter.log` (in the cartridge library's
  `build`, so `rm2k-snes-cartridges` leaves it too until step 5). Measured
  with the global `rm2k-snes-events culprits --every-map` on `cd3a40af`,
  the machine otherwise idle: 0.65 s for ABL's game and 1.1 s for Vampires
  Dawn's, one thread; in the build it runs in the cartridge's thread. No
  `advocate culprits`.

#### Verified

ABL's `release` built by `advocate build`: `culprits.json` equal as JSON
to `rm2k-snes-events culprits --every-map` run on the same
`events-request.json`, with its keys in the order the report writes them
(the builder links `serde_json` with `preserve_order`, the events binary
alone does not), so not byte for byte. `patches` says what `--check`
says —303 maps, 41 animations, 92 battlers, 0 windows versioned; maps
121, 133, 261, 269 and 348, `GreenDragon1` and `Royal` only in some
cartridge—; with `maps/0002.toml` moved away both say the same complaint,
and `advocate build --write-patches` wrote it back byte for byte. The
complaint's text still says "run `rm2k-snes-patches`": the patches
library's message, for step 4 or 6 to change with the ports' side.

### 2026-11-25, Calandria: what the design left unmeasured

On the-advocate `45e3ac57` and then `8833c963`, the nine games built in
series with the flags their recipes pass, `--force`, ABL without tracks,
today's chain (the global tools of `cd3a40af`: `rm2k-snes-cartridges`
running one `rm2k-snes-convert` per cartridge) against `advocate build`;
the machine otherwise idle. Seconds:

| | cold, chain | cold, `advocate` | warm, chain | warm, `advocate` |
|---|---|---|---|---|
| ABL (11 cartridges) | 87.0 | 88.4 | 11.5 | 12.7 |
| The Book of Three | 13.3 | 14.3 | 3.2 | 3.7 |
| Desert Nightmare | 44.5 | 45.4 | 6.1 | 6.9 |
| Dooms 2 | 10.8 | 11.4 | 2.9 | 3.3 |
| El Dorado | 4.1 | 4.4 | 1.3 | 1.5 |
| The Frozen World | 46.3 | 53.9 | 4.4 | 4.9 |
| Sunset Over Imdahl | 95.5 | 99.4 | 3.5 | 4.4 |
| Vampires Dawn | 126.2 | 128.9 | 13.4 | 14.2 |
| Zounds | 25.0 | 26.1 | 4.7 | 5.2 |
| **the nine** | **452.7** | **471.2** | **51.0** | **56.8** |

Cold is an empty cache; warm, the same cache again. `advocate` does more
than the chain did: it measures every cartridge's space, leaves
`culprits.json` (which the chain never made), compares the patches and
writes `advocate.json`; the 4% cold and 11% warm are that, mostly the
culprits' first time and the space's `.dbg` reading, and The Frozen
World's culprits are the biggest (4.5 s). With the culprits in the
builder and uncached (`45e3ac57`) the warm build was 66.6 s, which is why
they became a cached stage in `8833c963`. In process, without the
converter's spawns, nothing came out faster: the stages' work dominates.

**Memory**, the peak resident size sampled every 50 ms (MiB): of the
whole process tree summed, and of its largest process.

| `NO_CACHE=1` | chain, sum | chain, largest | `advocate` |
|---|---|---|---|
| ABL, eleven cartridges at once | 3,676 | 1,623 (`release`'s converter) | 3,785 |
| Vampires Dawn, one | 2,046 | 2,033 | 2,245 |
| Sunset Over Imdahl, one | 835 | 829 | 1,326 |

With a cold cache, ABL 4,408 against 4,076. So eleven conversions in one
process weigh what eleven processes weighed, as the design guessed —
within a few percent either way between runs, since how many overlap
depends on timing—; a game with one cartridge weighs somewhat more in
`advocate`, not looked into: the sum includes `ca65` and `ld65`, and a
guess is that memory the converter frees stays with the process while it
goes on to assemble, measure and write.

### 2026-11-25, Calandria: the culprits, a stage of the conversion

the-advocate `8833c963`. Measured above: in the builder, uncached, The
Frozen World's culprits cost 4.5 s on every build, warm or not. They are
now asked by the converter, beside the request it keeps
(`Compiler::culprits`, through `stage::call` as `rm2k-snes-events
culprits`, keyed by the request and the dump), so a warm build takes them
from the cache; the cartridge crate no longer links the event compiler.
`rm2k-snes-convert` writes them too.

**They read the dump the conversion compiled**, which in a game whose
project brings its own common events is the fork with them (`fork.rs`
in the converter), and not the game's `data/` that `just culprits`
passes as `--data`: The Frozen World's commons' table has 18 commands in
the build's `culprits.json` and 22 in the recipe's, ABL's are equal (no
common events of its own; compared as JSON, the keys' order apart). The
recipe's is the one that was wrong; it goes with step 4, when the ports
read the build's file.

### 2026-11-25, Calandria: the whole runs, and steps 1-3 handed back

On the final tree, the-advocate `4c18e020` (branch `calandria-advocate`,
`main` merged at `0010d275`), with every binary the branch touches
installed in a `.local-tools` first on the PATH, the ports at `4c23c9e`:

* `just lint`, `just test` (29), `just rust-test --no-fail-fast` (1,256
  passed): green. The first run had two reds: the known flake
  `a_cached_object_gives_the_dbg_a_fresh_one_gives` (green alone), and
  the queries' usage in `queries.rs`, an indented doc comment that became
  a doctest once the converter is a library (fenced as `text`,
  `4c18e020`).
* `SOUNDFONT=…/FluidR3_GM.sf2 just test-game`: 231 passed, 6 skipped. The
  first run had 47 red: `game.py` had lost its `import subprocess`, which
  `variable_slots` still uses (`4c18e020`).
* The ports' `just boot`: 218 passed. ABL's `just tests`: 1,694 passed,
  2 skipped. Both build through `rm2k-snes-cartridges` —the ports move
  to `advocate` in step 4—, which is the same library as `advocate` now.
* The double build: ABL with `advocate build`, warm cache, twice: the
  first rebuilt the eleven (the stamps were the old builder's), the second
  said all eleven up to date in a second. `abl.sfc`'s sha256:
  `3bf35fd7665c2045e6cd3b8d30471b66abb686d107e52a9ac8da1cdd1d691718`.

**What the suites do not cover**: no suite runs `advocate build` but the
test game's; that it builds the nine games the same is the byte-for-byte
comparison of step 3, not a test. No test reads `advocate.json` beyond
the test game's harness (`listing`, `project`); its other keys were
checked once against the old tools by a script, not by a test. The
patches' comparison and `--write-patches`, the `space` line and a
`--force` that fails half-way (the stamp removed first) were run by hand,
once each, or not at all for the last. `volume-ceilings` was compiled and
not run.

**Install when merging**: the whole workspace, `just install`: the branch
touches `rm2k-project`, which every binary compiles in, and adds
`advocate`. `rm2k-snes-cartridges` and `rm2k-snes-project` stay
installed and working until step 5.

**For step 4**, what the file gives and what is still to do on the
ports' side: every old answer under one key (`project`, `suite`,
`settings`, `machine`, `listing` with `space`, `memory_map`, `sources`,
and `patches` for `test_patches.py`); `culprits.json` beside each ROM for
`just culprits`; the patches' complaint still says "run
`rm2k-snes-patches`" (the patches library's text); `release.yml`'s smoke
test still asks `rm2k-snes-project`, for step 5 with (d). Step 7 (`[paths]
build` fixed) is not done: the file goes to `project.build()`, which every
project has as `build/`.

Found and not fixed:
[`just-culprits-reads-the-dump-without-the-project-s-common-events`](just-culprits-reads-the-dump-without-the-project-s-common-events.md).

### 2026-11-25, Hornero: back to `doing`

Steps 1-3b merged; 4 to 7 remain, so the task stays `doing`.

### 2026-11-25, Hornero: step 4 to Calandria

taro: "dale". The ports move to `advocate` with option (d).
