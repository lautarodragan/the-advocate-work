---
name: "The Python parity left behind"
description: "Twelve test files pin the tools' output to hashes taken from the Python they replaced, and two copies of pyjson write JSON the way Python did; the Python is gone, so both go, keeping only the tests that guard a path nothing else runs"
type: refactor
game: advocate
status: testing
author: taro
assignee: taro
agents: [carpintero]
links:
  relates: [the-python-s-last-traces-in-the-tools]
---

**Why**: when the converter went from Python to Rust, around 2026-10-01,
each stage was proved equal to the Python it replaced: tests that compare
the output against hashes taken from the Python before it was deleted
—`tests/python.rs` in battle, events, mapdata, patches, rm2k-snes-audio,
screens, text, wally (and `background_python.rs`), rm2k-render, rules and
adeleine; some 6,600 lines— and `pyjson.rs`, in `convert` and in
`rm2k-snes-audio`, two near copies of a JSON writer that formats like
Python's `json.dumps`, so that `patches/uses.json` and `music.json` came
out byte for byte as before. The Python is gone: a hash nobody can read is
a golden without its image, and is updated without looking whenever an
intended change moves it.

> Regarding pyjson, I think I'd aim to remove it. It looks like legacy
> that brings unnecessary complexity.
>
> And the parity tests with Python — aren't they all superfluous?

(taro, 2026-11-23; and "Dale!" to doing both in one task.)

**What is asked**:

* `pyjson` goes: both copies, and what they write goes out with
  `serde_json`. What changes in a versioned file —`uses.json` in the
  ports— changes once, in its own commit.
* The parity goes, whole: every hash of the Python's output, every
  "against the Python" framing, the `*-python.json` fixtures only those
  tests read.
* What is **not** dropped blind: a test that drives a path neither ABL's
  suite nor the test game nor the crate's other tests run —the synthetic
  maps of `mapdata/tests/maps.json`, made to go through every path, are
  the clearest case— and that checks a property and not a hash, stays,
  renamed for what it checks, in the crate's tests. Each survivor says
  which path it guards; each file says how much was left of it.
* No ROM changes: every game's ROM byte for byte equal to `main`'s.

## Log

### 2026-11-23, Carpintero: pyjson out, the parity tests read and decided one by one

Branch `carpintero-python-parity` in the-advocate, from ca74a4d4, with
`main` merged after Tijereta's (9066da12). The ports and the book did
not change: `uses.json` is not versioned —it lives in each build's
`patches/`—, and no page of the book describes the parity or pyjson as
current.

#### pyjson

Both copies go; `uses.json`, `music.json`, `audio-job.json` and
`effects.json` are written with `serde_json::to_string_pretty` and a
newline. Every reader parses them —`rm2k-snes-patches`, the tracks and
the ceilings, `compile` reading its own job, ABL's and the ports' tests—;
none compares the text, and no cache key or fingerprint hashes them (the
keys move only because the binaries do). A third Python-shaped writer
stays on purpose: `python_json` in mapdata's `emit.rs`, because the save
signature is a CRC of its text and goes into every ROM; it now says so.

#### The rule applied

A hash goes, always. A test stays when it drives something no game's
build reaches, and then it checks what can be said without a frozen
answer —a property, a count that says the path was taken, a message a
person can read—. Where a survivor is new, it was shown red by breaking
the code it guards. What a real build gives is A Blurred Line's suite's
and the test game's: goldens, `test_patches.py` against the versioned
patches, `test_music_writes.py`, `test_victory.py` against
`model::lines`, `render` against the console's screens, its harness's
`experience.py`.

#### Per file (lines before → after)

| file | before | after | what stayed |
|---|---|---|---|
| convert `src/pyjson.rs` | 101 | 0 | — |
| rm2k-snes-audio `src/pyjson.rs` | 163 | 0 | — |
| patches `tests/python.rs` + `python.json` | 164 | 150 (`check.rs`) | every complaint of the check, the copy's removal, versioned keys and the suite's own; only the file hashes went. ABL only ever runs the green `--check` |
| text `tests/python.rs` | 207 | +98 in `refit.rs` | the 300 made-up boxes, as properties: fit, settle, keep words, speaker and tail. Red with the measure widened by 3 |
| rules `tests/python.rs` + `python.json` | 225 | +49 in `rules.rs` | chip_index outside every block (34 ids); the rest runs on every map, and the experience against ABL's `experience.py` |
| battle `tests/python.rs` | 282 | 243 (`tables.rs`) | slots, records, troops of the edge game; the experience table only has to be built |
| battle `tests/model.rs` + `layout-python.json`, `lines.json` | 264 | 89 | 400 battles and 26 models answer or are refused exactly as recorded (`refused` instead of a hash). Red with `usable_in_battle` always true |
| events `tests/python.rs` + `python.json` | 537 | 251 (`small_game.rs`) | the six tests that were never the Python's |
| mapdata `tests/python.rs` | 2,595 | 434 (`made_up.rs`) | the made-up maps through `record::maps` (notes, report, frames), the two refusals, bare and whole cartridges emitted, and the nine table tests; `emit-*.json` baked with what the ten `with_*` functions made of them |
| screens `tests/python.rs` | 633 | 225 (`crowded_game.rs`) | every line the conversion says, RTP lookup, windows fitting, names refused, boxes |
| wally `tests/python.rs` | 707 | 419 (`split.rs`) | the five splits, checked for what the console needs. Red with `OBJ_COLORS` at 16 |
| wally `tests/background_python.rs` | 568 | 384 (`made_up_layers.rs`) | the counts per layer, budget, drawing 0 of a run, every cell on a block |
| rm2k-snes-audio `tests/python.rs` | 296 | 201 (`small_game.rs`) | the fixture compiled whole into everything a cartridge takes, and the two tests that were never the Python's |
| rm2k-snes-audio `tests/cartridge.rs` | 230 | 214 | the job of both games reads back in `compile`; the `.msu` reads back, each entry its bytes |
| adeleine `tests/python.rs` | 273 | 261 (`generated.rs`) | the generated sizes, as properties; the five-way tie's order written out. Red with a merge stopping one colour early |
| rm2k-render `tests/python.rs` | 142 | 110 (`every_id.rs`) | the map of every id drawn whole over both ChipSets |
| rm2k-render `tests/battle.rs` | 320 | 189 | landing and size, box, tone, hue going round, opaque backdrop |
| rm2k-render `tests/charsets.rs` | 180 | 208 | a tile in the twelve poses; a translucent pixel's bounds |
| rm2k-render `tests/screens.rs` | 491 | 288 | sizes, a face past its FaceSet, a picture's keying; RM2k's rules as they were |

The three last ones were not in the list: they were Python parity too,
under other names. `rm2k-snes/images/tests/answers.rs` keeps its hashes:
since 2026-10-02 they are not the Python's, and it says it is a
regression check.

sha2 leaves the dev-dependencies of every crate whose only hashes were
these (rm2k-rules' serde and serde_json too); rm2k-snes-audio keeps it.

Two commit messages give a wrong line count for their new file: mapdata's
says 446 for `made_up.rs` (it is 434), rm2k-snes-audio's 229 for
`small_game.rs` (it is 201). The table above is right.

#### Verified

With `just install-local .local-tools convert rm2k-snes-audio events
mapdata patches` —every crate whose binary changed, if only in a
comment—, every game's `just cartridges` (the nine in the ports and the
test game) gave the same sha256 for every `.sfc`, `.msu` and
`musicdata.inc` as a build with the global tools reinstalled from
9066da12; `uses.json` reads back as the same JSON. ABL's `abl.sfc` is
`014a082d…49e1ef`. With those tools: ABL's `just tests`, 1692 passed and
2 skipped; the test game's, 230 passed and 6 skipped. In the worktree,
`just rust-test` and `just test` green; clippy green on everything this
touched.

`just lint` is red on main already, not by this: rustfmt wants
`rm2k-snes/cartridge/src/assemble.rs` and `rm2k-snes/wally/src/events.rs`
reformatted, and clippy flags `from_the_cache(&self…)` in
`rm2k-snes-audio/src/tracks.rs` (`wrong_self_convention`).

#### What the suites do not cover

The survivors' paths are, by construction, the ones no game's build
reaches; they are covered only by these tests. And what was dropped
without a survivor is covered only by what is named above for each file:
for instance, the RM2k fonts' glyphs of `rm2k-snes-text` and the exact
pixels of an RGBA ChipSet's blend are now checked by nothing.

**To install on merge**: `just install convert rm2k-snes-audio events
mapdata patches` (`convert` and `rm2k-snes-audio` write their JSON
differently; the other three changed only comments). The ROMs do not
change.
