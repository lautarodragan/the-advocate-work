---
name: "The losses the stages hand over are JSON the converter reads by key"
description: "`degradations.json`'s entries reach the converter as `serde_json::Value` —the event compiler's `Degradations::losses: Vec<Value>`, the emission's `Vec<Value>`— and the converter keeps them so in `degradations.rs` and filters them by key (`l[\"kind\"] == \"event-left-out\"`, `l[\"map\"].as_i64()`) in four `forget`s of `convert.rs`: one loss type both ends see would make a renamed key fail to compile"
type: refactor
status: testing
assignee: taro
agents: [mulita, calandria]
author: mulita
links:
  found-in: [the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json]
  relates: [the-stages-speak-json-nobody-types, the-emission-s-answer-is-read-by-key]
  part-of: [the-stages-speak-json-nobody-types]
  found: [the-screens-requests-are-built-and-read-by-hand, wally-s-map-request-is-built-and-read-by-hand]
---

Seen by Mulita on 2026-11-24, typing the music's losses
([`the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json`](the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json.md)),
in the-advocate `mulita-songs` over `2695bd89`.

**What**: the music's losses now reach the converter as
`rm2k_snes_audio::relief::Loss`, but every loss still ends up a
`serde_json::Value` in `rm2k-snes/convert/src/degradations.rs`
(`losses: Vec<Value>`), and the converter reads them by key:

* the event compiler answers them as `Vec<Value>`
  (`rm2k-snes/events/src/answer.rs`, `Degradations::losses`, built by
  `Loss::to_json` in `losses.rs`), which `answer.rs`' header keeps on
  purpose as "what the caller only passes on";
* but the caller does not only pass them on: `convert.rs` drops some with
  four `degradations.forget(|l| …)` filters that read `l["kind"]`,
  `l["map"].as_i64()`, `l["event"].as_i64()` and `l["subject"].as_str()`
  —the events painted into the map, the pictures drawn into it, the
  panoramas never seen, the copies of automatic common events—; and
  `degradations.rs` sorts and counts by `["kind"]` and `["text"]` with
  `unwrap_or("")`.

A `kind` renamed in the compiler (`"event-left-out"`,
`"picture-not-shown"`, `"panorama-not-changed"`) compiles and the filter
stops matching without a word: the loss stays listed in
`degradations.json`.

**How it would go**: one loss type in a crate the stages and the
converter see —the place fields (`map`, `event`, `page`, `command`,
`common`, `troop`, `x`, `y`…) as `Option`s, `kind`, `text` and what
else an entry carries (`subject`, `name`, `code`, `via`)—, the
compiler's `Loss::to_json` becoming its conversion, and `degradations.rs`
holding it; the `kind`s the converter filters on as constants beside it.
`degradations.json`'s shape stays: checked byte for byte with the nine
games.

**How to reproduce**: `rg 'l\["kind"\]|l\["map"\]' rm2k-snes/convert/src`
in the-advocate.

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: counted in the merged code, the same rule as the
rest of phase B —taro asked to finish taking the JSON out—, checked byte
for byte with nothing seen or heard changing. A step of the stages task.

### 2026-11-24, Calandria: one loss type

In the-advocate `calandria-last`, `120fcd9e` over the step before.

**What it is**: an entry of `degradations.json` is
`rm2k_snes_events::losses::Entry`: its place a `Where` —`map`, `event`,
`troop`, `page`, `x`, `y`, `common`, `command`—, `via` (a list of
`Where`), `code`, `name`, `kind`, `text`, `subject` and `events`; and how
a common event runs, `CommonRun`. The compiler's `Loss::to_json` became
`Loss::entry`, `answer::Degradations` holds `Vec<Entry>` and
`BTreeMap<i32, CommonRun>`, `degradations.rs` keeps both typed and builds
its own entries with them (`map`, `event`, `troop`, `cartridge`), sorts
and counts by field, and the four `forget`s in `convert.rs` read
`l.kind`, `l.place.map`, `l.place.event` and `l.subject`. The kinds they
filter on —`EVENT_LEFT_OUT`, `PICTURE_NOT_SHOWN`, `PANORAMA_NOT_CHANGED`,
and `LETTER_PLAIN` for the warning— are constants beside the type, used
where the compiler loses them.

**Where it lives, and why**: in the event compiler, the producer whose
losses have the whole shape —a stack of places, the command, its code, a
subject— and the only one whose entries the converter filters. The
emission's (step 2), the music's (`relief::Loss`), Wally's and the
screens' are a map or the cartridge, a kind and a text, each typed in its
own crate, which the converter puts into an `Entry`. A crate both ends
depend on for one type would be one more dependency for every stage, to
say what the compiler already says; the emission already depends on the
compiler and does not need it either.

**The order of the keys**: one struct for every kind of place, in an
order every old entry fits —`troop` before `page`, `common` before
`command`, `events` after `text`—; `page` and `command` keep the
difference between null and not written (`Option<Option<i64>>`, read with
a small `deserialize_with`), since an event left out whole writes
`"page": null` and a common event's entry writes no page. A test writes a
loss inside a pasted body and reads it back.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), with the commit's `convert` first in the PATH, against
the global tools' builds of `5fa3d860`: 19469 files in `build/`, every
`.sfc` (20) equal, `converter.log`, `degradations.json` and every
`events-request.json` included. What differs is what always does: the 20
`.o` and the 20 `.dbg` by ca65's mtimes alone, and the 20 `stamp.txt`
(the inputs' fingerprint, which names the binaries).

The warm cache, built twice over this tree in the second ports worktree,
and ABL's suite and the ports' boot run against these builds: see the
stages task's entry.

**Measured**: +210 net lines (351 in, 141 out): the type, its docs and
the round trip test, and the degradations' tests, which built JSON by
hand, built with the type.

**Install when merging**: `convert` and `events`.
