---
name: "The test page table filled up"
description: "The test page number was a byte and release already had 256: one more case did not assemble. Now 2048 pages fit per map, counting the map's own"
type: bug
status: done
assignee: taro
---

Tacuarita found it on 2026-10-01 (`world-5-tangle-forest.md`): the `release`
test page table is full, because the page number is a byte and there are
already 256. One more case breaks the assembly with `Range error`. Meanwhile,
no new map can add cases of its own.

## What it was

The only thing that did not fit was the `+2` of the page record, "its page
number", which `rm2k-snes-mapdata` (`record.rs`, `page_table`) wrote whole with
`.byte`. **The console does not read it**: `read_page` jumps from `+0` to `+3`,
and no other read of `[page_ptr], y` lands on `+2` —searched across all of
`tools/runtime/`—. Everything else was already 16-bit:

* the value page k compares the case variable against is the `.word` at
  `+26`, signed: up to 32767;
* `M_PAGE_COUNT` is a 16-bit scalar of the map record, and `pages_left` is
  2 bytes;
* the harness writes the case variable in two bytes (`_elegir_el_caso`);
* the walk uses a 16-bit `page_ofs`, and `pick_by_ev` stores that offset per
  event, with `$FFFD`–`$FFFF` as sentinels.

## What was done

The cheapest thing: `+2` carries **only the low byte** of the number, with the
reason next to it. Widening it cost one byte per page —the record already takes
all 32— for a number nobody reads, and changing the runtime. The ROMs come out
**byte for byte identical** (no page today goes past 255), and the table does
not grow.

**The new limit is `MAX_PAGES`**, in `record.rs`: 2048 pages in a map's table
—65536 / 32, because of the 16-bit `page_ofs`—, and it is the limit of the
test pages, which all go in one event of the map that carries them, added to
that map's own. `check_counts` refuses with a message if a map goes past it,
instead of letting the offset wrap around silently. The comment on
`CASE_VARIABLE` in `tools/port/events.py` points there.

## What was measured

* **The red, end to end**: with two extra cases in `pruebas/casos/` (copies of
  `contador`), `just build release` with the old `mapdata` gives
  `Range error (256 not in [0..255])` and `(257 …)` in `mapdata.inc`. With the
  new one it builds, and a throwaway test ran the two cases —pages 255 and
  256— against the goldens `contador-110` and `contador-190`: identical. The
  cases and the test were deleted afterwards.
* **The test that stays**: `more_than_256_test_pages_fit_in_the_page_table`,
  in `record.rs`: it builds the table of a test event with 300 pages and
  checks that each literal of each `.byte` and `.word` fits in its directive,
  which is what `ca65` checks. Without the fix it goes red with `256 does not
  fit in: .byte 256  ; +2  its page number`. And
  `a_map_with_more_pages_than_the_console_walks_is_refused`, that 2048 fit and
  2049 do not. They run with `cargo test -p rm2k-snes-mapdata`, **not with
  `just pruebas`**; end to end it will be covered by `release` as soon as it
  goes past 256 cases, which is the next thing Zorro or Puma adds.
* `NO_CACHE=1 just cartuchos` before and after: the 1287 files of `rom/build/`
  identical, `abl.sfc` at `6809f47d59671284…`. The goldens did not move, and
  neither did the space.

## When merging

Install `mapdata` in the global one: `just -f tools/justfile install mapdata`.
No Python renamed.
