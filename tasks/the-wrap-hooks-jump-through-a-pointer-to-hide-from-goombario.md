---
name: "The wrap hooks jump through a pointer to hide from Goombario"
description: "The far wrap code is reached and returns through WRAP_JUMP, a pointer in BSS, so the linter does not walk that path; taro wants Goombario improved instead, and the runtime direct"
type: tooling
status: testing
assignee: taro
agents: [Hurón]
---

From
[`maps-that-wrap-around`](maps-that-wrap-around.md) (Hurón, 2026-10-20):
bank 0's hooks into `runtime/wrap.s` and the far code's calls back
(`CALL0`, `RTS0`) go through `WRAP_JUMP`, 4 B of BSS, so Goombario does
not walk that path. The annotation that would have said why could not be
used: in ABL's cartridges `wrap.s` assembles nothing, and an annotation
that allows nothing is red.

taro, on 2026-10-20:

> I would not change production code to please a linter or to live with
> a limitation of it. If the change at run time is nil, no drama; but if
> it costs even one cycle, I'd rather improve Goombario.

**Done**: the hooks call and return directly, with no pointer and no
WRAP_JUMP; Goombario handles what it could not —an annotation on code a
cartridge does not assemble, or whatever the real limit was—, with its own
tests; ABL's cartridges still byte for byte equal to main; Zounds' wrap
tests and the test game's ring green; the cycles and bytes saved, measured.

## The work (Hurón, 2026-10-20)

From the-advocate `796b4dc9`, the ports `4749a8c`, the book `c2ed3c2`;
branches `huron-wrap-direct` in each.

### The limit, exactly

With `CALL0` as a plain `jml` and `RTS0` as pulls and a `jml`, main's
Goombario over the test game's cartridge gave nine findings, none of them a
bug:

* **call-return and stack on `cell_allowed`'s three `rts`** (cells.s 91,
  194, 197): walking `wrap_hero_step`, entered with `jsl`, it followed the
  `jml` into `cell_allowed` and took its `rts` for `wrap_hero_step`'s own,
  with the `phk`/`per`/`pea` still pushed. It did not know that an `rts`
  over a return address the routine pushed itself is a jump, and it never
  walked what comes after `back:`;
* **call-return on `wrap_rts`** and **stack on each `RTS0`'s first `pla`**:
  taking off the `jsl`'s own three bytes and leaving through an `rts` is
  returning from the bank 0 routine that called the hook, and it only knew
  "pulls more than pushed". `RTS0_16`'s `tsc`/`tcs` it did not see at all:
  after a `tcs` it stopped following the stack.

Annotations could not stand in for it: the call-return and stack ones would
go on `cell_allowed`'s lines, which every cartridge assembles, and in A
Blurred Line —no map that loops— they allow nothing, which is red. And one
in `wrap.s` is red there too: that was the first round's red, a
pull-branch annotation on wrap.s:582 (`the php/plp keeps the comparison
of…`), nine reds in ABL's `test_linter.py`, because Goombario reads the
annotations of every file the debug file names, also lines an `.ifdef` left
out.

### What changed

* **Goombario** (`4a16828e`): a stack byte carries its value when `phk`,
  `pea` or `per` pushed it, and an `rts`/`rtl` over only such bytes is a
  jump there; exactly the return address taken off —by pulls, or by `tcs`
  of the stack pointer moved by a constant, now followed— and then a return
  is a return from the caller, checked at the caller's call; an annotation
  on a line of code that put no bytes in this program is neither applied
  nor reported (one on a directive still is). Three toy tests, red first.
* **The runtime** (`fb31be8c`): no `WRAP_JUMP`; `CALL0` is `phk`, `per`,
  `pea`, `jml`; `RTS0` three `pla` and `jml`; `RTS0_16` its `tcs` and `jml`.

### Measured

Cycles per use on a map that loops: `CALL0` 36 → 18, `RTS0` 35 → 16,
`RTS0_16` 35 → 13; on a map that does not, nothing changes (the hooks
`rtl` first). Bytes, Zounds, Vampires Dawn and Sunset over Imdahl alike:
`FAR3` −95, BSS free 77 → 81, bank 0 the same (138, 48, 28), far RAM the
same. `CALL0` keeps X now.

### `wrap_pass`, the other piece shaped around the linter

The first round's red annotation was on `wrap_pass`, which kept the
comparison of `pass_x` under a `php`/`plp` and branched on the pulled Z;
it was rewritten to fold both axes through `WRAP_U` with `eor`/`ora` so
that it needed none. Now (`8715b90e`) Y counts the axes that moved, the
cheapest of the three: from the `ldx #0` to the `beq`, 60 cycles before,
33/39/45 now (none, one, both moved), and `FAR3` 8 bytes fewer. With it,
`FAR3` is 103 bytes smaller than main's in the three games.

### Verified

With this branch's tools (`goombario`, `cartridge`, `project` installed
locally) and runtime:

* **A Blurred Line's nine cartridges** byte for byte the same as with
  main's tools, twice (before and after `wrap_pass`); its suite, 1573
  passed, its linter included, after the last change. `abl.sfc`
  `f5c437e663636cba` (sha256, first 16).
* **The test game's suite**: 51 passed, the ring (`test_wrap.py`, both
  cores) and its linter included.
* **`just boot`** from the ports' root: 95 passed, Zounds' two wrap tests
  included.
* **Goombario over Zounds', Sunset's and Vampires Dawn's release
  cartridges** (not in any suite: no linter test runs over them): none
  found with this one, nine each with main's.
* `just test` 29 passed; `crate-test goombario` 14 + 6 passed; clippy and
  rustfmt on goombario clean.
* `just space` for the three games, with main's tools and with these (the
  numbers above).

Not covered by any test: Sunset's bats on map 63 and Vampires Dawn's free
fall on 254 are still not played (see `maps-that-wrap-around`); what they
run is what the test game's walkers and Zounds' tests run.

### When merging

Reinstall `goombario`, and the runtime goes in with the checkout. The
ports have no change: `huron-wrap-direct` there is main's old commit with
nothing on it, and can be deleted. The book's branch updates
`internals/maps.md` and `tools.md` (whose Goombario still described the
`--allow` file of before 2026-10-18).
