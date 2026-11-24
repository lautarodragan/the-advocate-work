---
name: "Where mapdata and convert could be shorter"
description: "A read-only look at the two biggest crates of the converter —some 11,500 lines of code each— for code that is longer than what it does: repeated shapes, hand-written tables, layers that only pass things on. Each finding becomes a draft with its estimated saving"
type: research
status: testing
author: taro
assignee: taro
agents: [Calandria]
---

**Why**: after the toolchain cleanup of 2026-11-23 —the binaries nobody
ran, the Python parity, the Python's last traces—, the Rust of
the-advocate is still around 90,000 lines of hand-written production
code. Literal duplication measured low (3 to 7%), so if there is excess it
is in code that does with many lines what could be done with fewer.
`rm2k-snes/mapdata` and `rm2k-snes/convert` are the two biggest crates
with the least test code per line; `emit.rs` alone is some 5,000 lines of
code and `record.rs` 2,600.

> Going back to the little table, I think mapdata and convert could be
> interesting to analyse for possible reductions in the code, right?

(taro, 2026-11-23. Earlier the same day: "without going into code golfing
— it has to be readable".)

**What is asked**:

* Read both crates whole, and what they talk to as far as needed to judge
  them. Nothing is changed in this task.
* Each concrete reduction is a draft of its own: where, what the code
  does, what the shorter form would be —a sketch, not the change—, an
  estimate of lines saved, what it risks, and how it would be verified
  (most should leave every ROM byte for byte equal).
* Readability decides: a reduction that makes the code harder to follow
  is not proposed. What is long because the problem is long is said so,
  and is not a finding.
* At the end, a summary in this task's log: the drafts by estimated
  saving, and a judgement of how much of the two crates is inherent.

## Log

### 2026-11-23, Calandria: read, thirteen drafts, and how much is inherent

Read at the-advocate `25b2418c`, nothing changed or built there.

#### What was read

* **mapdata**: `emit.rs` almost whole (its `Rest` skimmed in places),
  `emit/header.rs`, `request.rs`' `Emit` and `Map`, `json.rs`, `asm.rs`,
  `snes.rs`, `main.rs`, `record.rs`' record, page table and map table;
  `vram.rs`, `materials.rs`, `layer_text.rs`, `panorama.rs` and `scene.rs`
  only by their declarations and heads.
* **convert**: `convert.rs` 1-1000 and the emission's request (1850-2000),
  `emit.rs`, `options.rs`, `scan.rs`' sweeps, `stage.rs`' head, the head of
  `compiler.rs`' request; `maps.rs` (`map_info`) and `pictures.rs` sampled.
  `chipsets.rs`, `game.rs`, `fork.rs`, `trim.rs`, `variants.rs`,
  `map_pictures.rs` and the small files only by their declarations.
* Who calls what: every converter flag has a caller in the ports'
  `advocate.toml`, their tests or `rm2k-snes-cartridges`; of the mapdata
  binary's six subcommands, `maps` has none.

#### The drafts, by estimated saving

| lines | draft |
|---|---|
| ~300 | [`emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines`](emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines.md) |
| ~250 | [`the-inc-s-constants-are-format-strings-with-their-values-far-below`](the-inc-s-constants-are-format-strings-with-their-values-far-below.md) |
| 200-300 in mapdata, 100-200 net | [`the-emission-reads-the-screens-answer-and-the-battle-model-by-name`](the-emission-reads-the-screens-answer-and-the-battle-model-by-name.md) |
| 100-200, from a sample | [`the-converter-reads-the-stages-answers-with-python-s-truthiness`](the-converter-reads-the-stages-answers-with-python-s-truthiness.md) |
| ~100 | [`the-converter-s-command-line-is-clap-s-builder-read-back-by-hand`](the-converter-s-command-line-is-clap-s-builder-read-back-by-hand.md) |
| 60-100 | [`the-converter-writes-the-emission-s-request-by-hand`](the-converter-writes-the-emission-s-request-by-hand.md) |
| ~75 | [`small-repeats-inside-emit-rs-s-rest`](small-repeats-inside-emit-rs-s-rest.md) |
| ~50 | [`six-sweeps-in-scan-rs-are-one-with-another-predicate`](six-sweeps-in-scan-rs-are-one-with-another-predicate.md) |
| ~50 | [`mapdata-packs-tiles-with-its-own-copy-of-voodoo-s-code`](mapdata-packs-tiles-with-its-own-copy-of-voodoo-s-code.md) |
| ~45 | [`picture-tables-and-common-entries-write-the-same-entry-twice`](picture-tables-and-common-entries-write-the-same-entry-twice.md) |
| ~43 | [`the-battle-terms-by-name-are-a-42-arm-match`](the-battle-terms-by-name-are-a-42-arm-match.md) |
| ~40 | [`the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures`](the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures.md) |
| ~30 | [`rm2k-snes-mapdata-maps-has-no-caller`](rm2k-snes-mapdata-maps-has-no-caller.md) |

Together, 1,300 to 1,550 lines of the 23,154 of production code: some
1,000 of mapdata's 11,632 (9%) and 350 to 500 of convert's 11,522 (3-4%).
Every one is verified the same way: every port's ROM byte for byte equal,
`NO_CACHE=1 just cartridges` before and after and `cmp` of each `.sfc`.

Order, if they are taken: the two of emit.rs's writing style are
mechanical and verified by the ROMs alone, so they go first and alone; the
fallbacks before typing the screens' answer, which then has one shape per
field to type; the converter's request after mapdata's types derive
`Serialize`.

#### How much is inherent

**Most of it, some nine tenths by lines.** The two crates are long because
the cartridge carries some four hundred tables, constants and blocks, and
each one has a rule of its own —what bank it lives in, what a byte means,
what RM2k does that the console has to match—; that is what most of
emit.rs and record.rs are, one table after another, and it does not fold
into a loop without hiding which table is which. Long because the problem
is long, and not drafted:

* the twelve VRAM layouts of `vram.rs`, written out as constants: they are
  the contract with the runtime and are checked against the hardware; a
  generator would be harder to read than the table;
* `record.rs`' page table, written as commented text that `numeric_bytes`
  reads back for the pages that go to WRAM: one layout for both places, on
  purpose, as its comment says;
* the map record's three lists (`MAP_SCALARS`, `MAP_BYTES`,
  `map_fields`): merging them still names each field twice;
* `convert.rs`' `run`, a single function of 2,030 lines: it is the
  conversion's order, each step with what it prints and what it loses;
  cutting it into steps would read better, but would not be shorter, so it
  is not a draft here;
* `stage.rs`' cache and the converter's flags: all used, each for a reason
  written next to it.

**Where the excess is**: in two places, and they are of two kinds.
emit.rs's *writing style* —calls rustfmt spreads over seven lines,
constants whose values are twenty lines below their names— is some 550
lines of its ~5,000, and is mechanical to take away. And the *untyped
protocol between the stages*: every answer is built with `json!` and read
back by key, as `Value`, with defaults that hide a missing field —the shape
the converter kept from Python—. In these two crates it is a few hundred
lines; its real cost is that a key renamed on one side fails at run time on
the other. It reaches beyond these two crates —the event compiler's
request in `compiler.rs` is built the same way, and Wally, the screens and
the battle answer the same way—, so it is the larger piece of work and the
one with the most to gain besides lines.

Nothing to install when merging: no code was changed.
