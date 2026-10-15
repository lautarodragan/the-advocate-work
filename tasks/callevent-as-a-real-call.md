---
name: "CallEvent as a real call"
description: "A CallEvent to a common event or another event's page compiles to a call into one shared body with a return, instead of pasting the body at every caller; the call stack as deep as RM2k's"
type: feature
status: testing
assignee: taro
agents: [Carpintero]
---

The next piece of Frozen World's phase 1
([`frozen-world-the-custom-battle-system`](frozen-world-the-custom-battle-system.md)):
its research recommended "calls as calls" first. Today the compiler pastes
the called body into each caller, so map 1 —the battle, a chain of calls—
carries 347,625 bytes of bytecode in six banks of the cartridge. taro, on
2026-10-15: launched on Fable, the strongest model, because it is the
hardest piece left.

Opcodes handed out: `0x50` to `0x53`.

## Log

### Carpintero, 2026-10-15

Started from the-advocate `362d3765`, the ports `0ca371b` and the book's
`main` (`8e9b636`), on branches `carpintero-calls` in the three.

**What there was**: a `CallEvent` to a common event is an `OP_CALL` to the
body in the cartridge only when the body compiled with the map is byte for
byte the one without it (`shares`), and only from a foreground page;
everything else is pasted —a map event's page always, four levels deep
(`CALL_MAX`), and a parallel page pastes all it calls—. The runtime's call
stack: three levels of five bytes at `$7E6110`, placed by hand, and
`OP_RETURN` ends a shared body; `OP_DONE` ends the page whatever the depth.

**Measured before touching anything** (a throwaway script over the eight
dumps, `depth.py`, not committed): the deepest static chain of calls from
a foreground page, counting calls to common events and to map events'
pages: A Blurred Line 2, Book of Three 2, Desert Nightmare 2, Dooms 2 0,
El Dorado 1, **Frozen World 6** (map 1, `CombatController` page 6), Sunset
2, **Vampires Dawn 4, with a cycle** (map 87: common 25 and 26 call each
other). No call by variable in any of them; parallel pages that call:
ABL 6, Frozen World 2, Sunset 3, the rest 0. ABL's `release` at the start:
`abl.sfc` sha256 `681b75cd…`, bank 0 992 B free, BSS 146 B, far RAM 13 B.

## How it is done

**The call**: `OP_CALL_PAGE page:word` (`0x50`), the callee's **index in
the map's page table**. The console reads the page's code pointer from the
table (`+8`), pushes `code_ptr` and the cursor on the same stack `OP_CALL`
uses, and starts the callee from its first byte; a zero pointer —a page
with no code— or a full stack skips the call. The index and not an address
because the table already says where each page's code is, in WRAM behind
the grid or in the cartridge (`code_in_rom`), and pointers into WRAM would
have to be carried on a teleport like the stack's are. `0x51` to `0x53`
are reserved and end the page, as `0x39`–`0x3C` do.

**The return is `OP_DONE`.** A called page is the same bytes as the page
itself, `OP_DONE` at the end included, so `OP_DONE` now ends the *frame*:
with the stack non-empty it returns to the caller, with it empty the page
ends. That is RM2k's `END` and its `EndEventProcessing`, which only end
the frame they run in; `OP_RETURN` became an alias. The three places that
run bytecode on another interpreter —`parallel_tick`, `compar_tick`,
`ba_t_page`— save the foreground's depth, run with it at zero and put it
back, so a parallel page's `OP_DONE` cannot return into the foreground's
frame; those pages paste what they call, as before, because the stack is
the foreground's (one per interpreter would be 11 bytes per parallel at
least, and far RAM has 13 bytes left in ABL).

**The stack**: `CALL_LEVELS` = 8, five bytes a level, `.res` in bank 0's
`BSS` (`call_depth`, `call_stack` in `runtime/common_events.s`; the custom
menu's `CM_CALLS` grows with it). The deepest chain measured is six; the
compiler's `rm2k-snes-bytecode` carries the same number and a test in
`convert` reads the runtime's line. The runtime's `.assert` on
`COMMON_DEPTH` is gone: a chain deeper than the stack is a degradation,
`call-stack-exceeded` on the first page of the chain (or "the calls from
here loop"), computed by `map_pages` over the page calls and the shared
common bodies as a bound; the console skips what is past it.

**The compiler** (`compile_call`): a `CallEvent` to a map event's page is
a call when the frame owns the stack (`MapEvents::stack`, false for
parallel pages) and the page has not jumped to another map (the table the
console would index is the other map's); a page the map leaves out whole
has no index and is pasted as before. The table's indices skip the
left-out events, so `map_pages` decides those first (`left_out_why`) and
`MapEvents::numbered` gives the test pages, the scan's single pages and
the culprits the same numbering. A call to a page that does not compile
is emitted anyway —the console skips it— and noted after the map's pages
are compiled, `call-skipped` at the call (`PageCall`, `Losses::lose_on`).
`CALL_MAX` stays for what still pastes. Calls to common events are as they
were: `OP_CALL` when `shares` says the body is the cartridge's, pasted
otherwise.

**The hash test** `the_compilation_is_the_pythons` moved its `maps` on
purpose; checked that with the page calls off the answer was the old one.

## Measured

Bytecode per game, as the converter lays it out —each map's pages and own
routes stored once, summed over the maps of `release`; the shared common
bodies apart and unchanged—, with `rm2k-snes-events compile` on each
game's last `events-request.json` (Frozen World's with map 1 added), the
tools of `362d3765` against this branch's (`measure.py`, throwaway):

| game | before | after | biggest map before → after |
|---|--:|--:|---|
| A Blurred Line | 145,888 | 143,817 | map 11: 10,052 → 8,316 |
| Book of Three | 28,850 | 28,850 | — |
| Desert Nightmare | 74,786 | 63,896 | map 161: 6,614 → map 138: 2,099 |
| Dooms 2 | 11,566 | 11,566 | — |
| El Dorado | 35,184 | 35,184 | — |
| **Frozen World, map 1 in** | 544,342 | 198,837 | **map 1: 386,706 → 57,261** |
| Sunset over Imdahl | 23,105 | 22,192 | map 4: 2,218 → map 34: 1,809 |
| Vampires Dawn | 137,050 | 137,050 | — |

Map 1 measured 347,625 on 2026-10-15 morning from the converter's layout
with a different request; the two numbers above are the same request and
the same script, which is what the comparison needs. At 57,261 bytes it
still does not fit in WRAM (19,968), so it stays in the cartridge, in one
bank instead of six. Frozen World's `release` with map 1 put back, built
with the branch's tools before merging `main`: got past the code and
stopped where Aguará was, "rm2k-snes-audio: the samples of 1 (35577 of
-53104 B) do not fit in the ARAM even at the minimum". After merging
`main` (`07fa9010`, Aguará's relief; the ports' `dc01b28`, with map 1 in
`release`): **the whole game builds**, `frozen-world.sfc` sha256
`6364cc5d…`, with three code blocks in the cartridge —map 1 57,261 bytes
in bank `$C3`, map 2 38,062 in `$C4`, map 3 30,301 in `$C5`— and 70
`call-skipped` on map 1, all to callees that do not compile (event 15's
and 25's page 1, common event 23: the switches past 1,023 and
`ChangeActorFace`, which have their drafts); no `call-stack-exceeded`
anywhere in the eight games, as the depths measured said.

## Verified

* `cargo test -p rm2k-snes-events`: 129 unit tests (three new: the call
  by its index, pasted from a parallel page, after a jump and for a
  left-out event; the `call-skipped` loss at the call; the chains deeper
  than the stack and the loop), and `the_compilation_is_the_pythons` with
  its `maps` hash moved.
* `just test`: 29 passed. `just rust-test` with the SoundFont: every
  crate green, `the_call_stack_s_depth_is_the_runtime_s` in `convert`
  among them.
* `just test-game` (`SOUNDFONT=~/assets/soundfonts/FluidR3_GM.sf2`): 6
  passed in snes9x and bsnes; `test_nested_calls.py` was red with the
  tools of `362d3765` (1260 off: the fourth call past `CALL_MAX`).
* ABL's `just tests` with the branch's tools, first round: 1550 passed, 3
  failed, 2 skipped, 6:04. `abl.sfc` moved from `681b75cd…` to
  `c810e707…`. The three reds: `test_shared_call.py` ×2 read the stack by
  its old labels `CALL_DEPTH`/`CALL_STACK` (fixed in the ports: the new
  names), and `test_the_whole_race` —the lap of map 49 spent 50 extra
  hardware frames in 976 ticks, over the 5 per hundred it allows—: every
  page's `OP_DONE` went through a `jsl` to bank 1 to ask the depth, forty
  parallels a frame on that map. Fixed: `op_done` reads `call_depth` and
  only leaves for `call_leave` when it is not zero (seven cycles over the
  old end). No golden moved. Second round after merging `main`
  (`07fa9010`, `dc01b28`), with the merged tools installed locally
  (`bytecode cartridge events convert rm2k-snes-audio`): **1553 passed, 2
  skipped**, 4:06, `abl.sfc` sha256 `b5367669…`; no golden moved and no
  new capture. `just space release` after: bank 0 944 B free (was 992),
  bank 1 1,455 B (1,559), BSS 105 B (146: the stack's 41), far RAM 12 B
  (13: `compar_context`'s one more byte), ROM gaps 11,985 B (11,495: the
  map 11 calls save about 490 B of LZ2).
* `just boot` at the root of the ports, with the merged tools: 43 passed,
  13:34 (the seven games build and boot; Book of Three's milestones, the
  code-in-ROM pages of Frozen World's maps 2 and 3 among them).

## What the suites do not cover

* A **page called from a page of a map whose code is in the cartridge**
  (Frozen World's map 1): the call is the same opcode and the same table
  read as in the test game, whose code is in WRAM, but no test runs a
  fight on map 1; the first fight played is what tells. Nor a called page
  that **teleports and goes on** after the caller is carried to
  `CODE_CARRY`: `code_carry_before` moves every frame of the stack, as
  ABL's `test_shared_call.py` checks for a common body, and a map page's
  frame is the same five bytes, but no case builds that chain.
* A chain **deeper than the stack** at run time: the runtime skips the
  call (`call_push`'s carry), and the compiler's `call-stack-exceeded` is
  unit-tested, but no ROM test pushes nine frames —no game needs more than
  six—.
* The **custom menu's `before`** body saving and restoring the longer
  stack (`CM_CALLS`, 41 bytes): the menu tests run, but none opens the
  menu from inside a call.
* `OP_CALL_PAGE` from a **troop page** cannot happen (no map), and from a
  parallel page it is pasted, which `a_call_to_a_map_event_s_page_is_a_call_by_its_index_in_the_table` checks.

## Not done, and what is left

* A common event's body that **changes with the map** (`shares` says no)
  is still pasted at every call —Frozen World's map 1: about 8.5 KB of
  the 57 KB, per the research—. A map-local copy of the body stored once
  as an extra entry of the map's page table, called with `OP_CALL_PAGE`,
  would make every common call a call; left for when it is measured to
  matter.
* Parallel pages paste what they call, by design (one stack).
* A page called **after a jump to another map** is pasted and resolves
  "this event" and the callee against the map it was compiled on, as
  before (`MapEvents::after_jump`).

## To install when merging

`just install bytecode cartridge events convert` from `~/the-advocate`
—`cartridge` because the runtime changed and `rm2k-snes-cartridges`
assembles it from the checkout it was installed from—, and ABL's
`release` rebuilt: its ROM changes (`abl.sfc` `b5367669…` with the
merged tools). Branches `carpintero-calls` in the-advocate, the ports
(one commit, the shared-call test's labels) and the book; all three
merged with their `main` of 2026-10-15 evening.
