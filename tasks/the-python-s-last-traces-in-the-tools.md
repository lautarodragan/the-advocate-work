---
name: "The Python's last traces in the tools"
description: "Code that still imitates how the deleted Python wrote, rounded or formatted —the save signature's JSON, pyfmt, the audio's number helpers and others— goes, even where that changes every ROM"
type: refactor
status: doing
author: taro
assignee: carpintero
agents: [carpintero]
---

**Why**: after
[`the-python-parity-left-behind`](the-python-parity-left-behind.md),
`python_json` stayed in `rm2k-snes/mapdata/src/emit.rs` on purpose: the
save signature is a CRC of the text it writes, and writing it any other
way changes every cartridge. Around thirty production files of
the-advocate still name the Python —`mapdata/src/pyfmt.rs`,
`rm2k-snes-audio/src/num.rs`, `cartridge/src/text.rs`, `tracks.rs`…—, and
some of them are code that exists to come out the way the Python did.

> I'd rather remove any legacy leftover and have the ROMs change.

(taro, 2026-11-23)

**What is asked**:

* Every piece of code that exists to reproduce how the Python wrote,
  rounded, sorted or formatted something goes, and what it fed is written
  the plain Rust way. ROMs may change: saves of older builds being refused
  is fine (taro: breaking saves is never a problem).
* What only mentions the Python as history —a comment saying where a rule
  came from— stays if it still explains the line, and goes if it only
  says "as the Python did".
* Each change of ROM bytes says, in its commit, what moved and why it is
  only that: the save signature, a table's order, a rounding.
* A golden that moves goes to taro before merging.

## Log

### 2026-11-23, Carpintero: what imitated the Python, sorted and gone

Branch `carpintero-python-traces` in the-advocate, from 4b36cc8d, with
`main` merged after Aguará's subcommands (7b242bc4). Every production
file that named the Python was read and put in one of three piles.

#### Code that imitated the Python: gone

* `mapdata/src/pyfmt.rs`, the `%` formatter: the header is a format
  string with a named argument per constant (a macro, since `format!`
  takes only a literal) and the other 33 templates plain `format!`s.
  Translated by a throwaway script; the two bools that pyfmt printed as
  0/1 were found by compiling a copy where every argument had to be an
  integer or a text. A Blurred Line's thirteen cartridges came out byte
  for byte the same, `.inc` included.
* `python_json`: the save signature hashes a struct written by
  serde_json. A struct and not `json!`: `preserve_order` is asked for by
  other crates, and an object's key order would depend on the build.
* The audio crate's `num` —ties to even, flooring division, libc `pow`,
  `round(x, 3)`, numpy's pairwise sum— is `f64::round`, `/`, `powf`,
  `Iterator::sum`; the sinc is 1 at 0. `mix_fingerprint` hashes
  `format!("{writes:?}")`, the same text its loop wrote.
* Python's `repr` quoting in the converter's log, Wally's messages and the
  `.inc`'s map comments: `{:?}`. `patches --check`'s `None`/`True`/single
  quotes: TOML's text and `nothing`. `round0`: `{:.0}`. `ljust`: a
  `{:<w$}`. `str.strip`: `trim`. The refit's Python whitespace:
  `split_whitespace`. The converter's `dict` comprehension: the scan's
  keys never repeat. `patch_uses` sorting by Python tuple text: the maps'
  order. `curve_at`'s negative index: a level below 1 is `None`.
  `splitext`: `Path`'s. The cartridge packing's `splitlines`:
  `str::lines`. The shake sine's ties-to-even: `round` (no tie occurs).

#### History only: gone

Comments and READMEs that said "as the Python did" (adeleine's
`try_pack`, the battle's `floor_div`, images, rm2k-render, the runtime's
`boot.s` and `tint.s`, the audio crate's headers…), and the citations of
the converter's deleted files —`snes_convert.py`, `scene.py`,
`animation.py`, `music.py`, `rm2k.py`— pointed at the Rust that does the
same.

#### Kept, and why

* Adeleine's `try_pack` tie-break: the tiles go by their own colour order,
  a `BTreeSet`'s —plain Rust, independent of the order they come in—;
  only the paragraph about CPython's set order was history.
* The battle's `floor_div`: floor division is what `hit_rate_by_agility`
  wants; `div_floor` is not stable.
* Pillow's and numpy's arithmetic where it is the definition and not a
  quirk: `alpha_composite`'s fixed point, `NEAREST`'s column sum, the
  Blackman window, `convolve "same"`. A formula has to be some formula;
  changing them moves goldens for no gain. They now cite Pillow, not the
  Python.
* `project/src/paths.rs` (lexical like Python's `abspath`): the Python
  test suite computes the same paths. `rm2k-snes-audio/src/retro.rs`: the
  ceilings must be what the Python harness measures. Ditto's xtask: the
  liblcf CSV has a Python comprehension in it. The harness's own files.
* `vram.rs` pointing at `vram.py`'s git log: it is where the layouts'
  reasons are.
* The WAV reader's leniency: the games' WAVs need it.
* Citations of `events.py`: ABL's harness still holds that file and keeps
  the notes the runtime cites until they move to the event crate.
