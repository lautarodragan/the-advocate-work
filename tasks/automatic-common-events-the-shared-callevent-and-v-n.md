---
name: "Automatic common events, the shared CallEvent and \\V[n]"
description: "Phases 4 and 5 of the picture system: what the compiler and the interpreter lack for ABL's portable console, all generic"
type: feature
status: done
assignee: taro
---

Phases 4 and 5 of [`research/2026-10-01-the-picture-system.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-01-the-picture-system.html)
(Jilguero), from taro on 2026-10-02. The portable console is not needed to
play, but its pieces serve the custom systems of many games. What
is missing: automatic common events (not the parallel ones), a `CallEvent`
that shares the body instead of pasting it (pasted, common event 39 is 140,193
commands; shared, some 2,400), and `\V[n]` in messages. `Label` and
`JumpToLabel` are already there (`label-and-jumptolabel.md`, Pitogüé).

## What RM2k does with automatic common events

From easyrpg, `Game_Map::UpdateForegroundEvents`, `Game_CommonEvent` and
`Game_Interpreter`:

- **When**: every time the foreground interpreter becomes free, the
  first automatic common event —in number order— with its switch on is
  pushed onto the stack. Nothing needs to mark it: it is checked on every loop,
  so while its switch stays on it runs again, like an automatic page
  of the map. One without a switch always runs; here it is not taken —a ROM
  that runs one forever cannot be played— and the game has none.
- **The order against the map's**: in the same loop it pushes the common event first
  and **then** the map event that is waiting, which ends up on top and
  runs first. That is: the map's page, and in the same frame the common event.
  Here the common event waits for the map's queue to empty: it is the same with one
  event waiting, and the common event a few turns later with several. Declared in
  `common_start`.
- **With a message open**: it is pushed, but `Game_Interpreter::Update`
  stops at `IsMessagePending` before the first command. Here `events_tick`
  leaves before looking at anything with a message open, so it does not start either.
- **On changing map halfway**: the frame is a copy of the command
  list, so it continues on the new map. Here the body lives in the
  cartridge and does not move.
- **"This event"** in a common event is nobody: a common event's frame has
  `event_id` 0. Without a map, whatever names it does not compile.
- **The hero**: `IsAnyEventStarting` also looks at automatic common events,
  so with one about to start the hero does not walk. Here `common_waiting`, in
  `move_hero`.
- **`EndEventProcessing`** ends **only the frame** it runs in, not the stack:
  in a shared body, escaping from a battle with `escape_mode` 1 is an
  `OP_RETURN`.

## What was done

**One body per common event, in the cartridge, and `OP_CALL`/`OP_RETURN`** (`0x3F` and
`0x40`). `tools/rm2k-snes/events/src/commons.rs` decides before compiling
any page which common events have a body —the automatic ones, the ones the
foreground pages call and what those call, if they compile without a map— and
compiles them at the end, each one once. `rm2k-snes-mapdata` emits the tables, and
`tools/runtime/common_events.s` starts the automatic ones, pushes and pops
frames.

**The call stack** is a single one, the foreground's: three levels of
five bytes. The deepest chain in the game is four frames —39, 21, 25 and
one of 23 to 31—, that is, three levels: it fits exactly. The converter emits it
as `COMMON_DEPTH` and the assembly refuses if it does not fit. A call with the
stack full is skipped.

**A map page calls instead of pasting** when it runs in the foreground and
the body compiled with its map is byte for byte the one without a map; if not, it pastes
as always. What is forgiven is the variable refresh, and why is
in `shares` and in `decisions/call-event-into-a-shared-body.md`. Parallel
pages always paste: they share the foreground's globals.

**`CODE_CARRY` with the stack**: a body lives in the cartridge and does not move,
but the page that called it is in WRAM; `code_carry_before` now also
moves the stack's frames.

**`\V[n]`**: the compiler replaces it with a mark with the
variable's slot, and the text block carries it as byte `$FF` and the slot. The
`$FF` was the last letter pair: the pair table goes down from 161 to 160. The
compositor (`msg_letter`) writes the number when opening the box, with the minus if
it is negative, and adds to the row's length what it measures minus one —the
converter counted it as one letter—; if it goes past the window, the column
limit cuts it at the edge. Only the simple form, `\V[` digits `]`,
upper or lower case; the nested one still does not compile.

## What was found along the way

- **The RAM assigned to me, `$2560` to `$256F`, is inside
  `FAR_PAIR_LIST`**: it is `PARALLEL_MAX` (48) eight-byte entries from
  `$2400`, up to `$257F`, and the car chase has forty parallel pages.
  I used `$6110` to `$6127`, after `MAP_SONG` (one byte) and before `FAR_EXP`;
  verified with grep over `tools/runtime/` that nothing else falls there. **Aguilucho's,
  if he got `$2570`, has the same problem.**
- **Opcodes `0x39` to `0x3E` do not exist in `main`**, and the dispatch
  table does not allow gaps: I declared them as `OP_RESERVED_39` to `_3E`, which
  end the page. Whoever brings the real one replaces its entry;
  Aguilucho's are `0x3D` and `0x3E`.
- **WRAM does not start at zero**, and the suite's core fills it with `$55`:
  the first version did not set the stack to zero when starting a map
  page, and the garbage depth skipped all the calls. Four
  tests enforced it —common event 35 after the battle left 498 on and
  the hero stuck—; now `start_waiting` and `common_start` set it to zero.
- **The sign of `\V`**: an `ldx` between the read and the `bpl` clobbered N,
  and -1234 came out as 64302. `test_variable_in_text.py` enforced it.
- **The sound effect with another sample on a map**: `shares` compiled the body
  "without a map" with the map's package set, and a sound effect that on that map
  sounds with another sample came out the same in both. The test in
  `compile.rs` enforced it; now it is compiled without a package, like the cartridge's.

## How many pages compile

- **From the game, per page**: the same as before, 5560 —`rm2k-snes-events
  scan` over all maps, the global binary against the new one—. No
  map page uses `\V`, and sharing does not change what compiles.
- **The common events**: in `release` there are 25 bodies, 8,176 bytes. The
  automatic ones that run: 7 (`AbsorbAuraAbilities`), 11 (the old menu, which nobody
  turns on), **39 (the console)**, 43 (Emily's tape) and 50 (`RadinUses`).
  Not compiling: 16 (`DisplayNameMenu`, from the old menu), and 42 and 44,
  Radin's and Sern's menus, which send the hero a route that changes
  his graphic —command 34 needs a map's sprite bank, and a
  body has no map—. The console's all compile: 39, 21, 25, 23
  to 31, 40, 48 and 49 (22 compiles to nothing: it is only pictures).
- **The pages' calls**: 32 `OP_CALL` in 24 maps of `release`,
  almost all to common event 35 from `AfterBattleMint`. The maps' bytecode
  went from 136.4 KB raw (89.1 in LZ2) to 89.4 (46.8); without any call
  it would be 81.5.

## The console

**It works**, without pictures: item 81 from the menu turns on 710 and common event
39 runs; the arrows go through characters and labels; A on Sern's Skills
opens his message with the souls (`\V[0173]`); B closes it; the hero does not walk
while it is open. **No picture shows**: the console's are not
carried by any map, and the large ones —the text pages, the auras table,
the 302x202 window at 50%— are Aguilucho's. They are all missing: 17
(`NewMenu<nombre>`, `<nombre>Skill1`, `<nombre>Tutorial1`), 18
(`SkillSelect`, `TutorialSelect`), 19 (`ArrowTest`), and those of 21 and of 23
to 31 (`Aura<color>Menu`, `Aura0` to `Aura24`). In addition the sound effects of an
automatic common event (`Decision1`, `Cansel1`, `Failure1`) sound only if the map's
package already carries them: a body without a map notes nothing in any.

## Tests, and their red

- `rpgmaker/test_portable_console.py` (four): item 81 runs the common event,
  the arrows, the hero still and Sern's message against the same one written
  with 42. **Red**: with `common_start` returning zero, all four.
- `rpgmaker/test_variable_in_text.py`: three `\V` —negative, zero, two in one
  row, with leading zeros and in lower case— against the same message written
  by hand. **Red**: with the baseline compiler, `just cartridges` refuses
  ("a test page's text box does not compile"); and with the wrong sign, 776
  pixels.
- `rpgmaker/test_shared_call.py` (two): a page calls common event
  43, a jump is requested with the choice open, and the page continues afterwards.
  The two variants: the page on its map and already carried. **Red**: without looking at
  the stack's frames in `code_carry_before`, both. No common event shared today
  jumps map, so **it is the only path that executes it**.
- Unit tests in `compile.rs` and `messages.rs`: the bodies and their indices, the
  automatic one that does not compile, the battle that ends only its frame, the
  depth of a loop, a page that calls or pastes depending on the map, `\V`
  as a slot and what does not compile, and that a pair does not skip a variable.
- `test_compositor.py` also sets to zero the pending digits, which is the
  other thing the start of a row leaves set.
- `push.json`: the text block moved —one pair fewer and the texts of
  the common events—, and the box of `texto-cruza` ended up on the other side of the border.
  I removed the two padding boxes at the end, `Z1` and `Z2`.
- `rm2k-snes-mapdata/tests/python.rs`: the common events' tables are removed
  before the hash, like the pairs one; the hashes did not change.

Both suites green: `just tests` gives 988 (981 + 7) and `just -f
tools/justfile test` 39. `cargo test -p rm2k-snes-events -p
rm2k-snes-mapdata` green.

## Goldens

**None moved.** The three ROMs change —new tables, the pair fewer,
the common events—, but no golden.

## Space, in `release`

Against the baseline (`57ce2e2a…`), with `just space`: from 62 data banks to
61; bank 0 from 1,340 to 1,275 bytes free; bank 1 from 2,000 to 1,498;
the text block from 112,697 to 116,014 bytes. `NO_CACHE=1 just
cartuchos` gives the same three ROMs as with the cache.

## What is missing

- **The console's pictures**: Aguilucho.
- **Radin's and Sern's menus (42, 44)**: a shared body cannot
  change a route's graphic, because that belongs to each map's sprite
  bank. It would work if the graphic were one of the `associations`, which all
  maps reserve in the same place; whether it is was not checked.
- **Parallel common events**: not done. What would be needed: one
  parallel interpreter per common event —state like that of `FAR_PAIR_STATE`, which today
  is per map event— running in `parallel_tick` on any map, and
  deciding what happens with 2, `DisableSaving`, which has no switch and would run
  always. The equipment ones already run their own way (`equipment_commons`).
- **The parallel pages' calls** still paste: they would need a stack per
  interpreter.
- **The sound effects of an automatic common event** sound only where the map's
  package carries them.

## On merging

- **Install** `events`, `mapdata` and `cartridge`: `just -f tools/justfile
  install events mapdata cartridge`. And `install-scripts` is not needed: there are
  no new or renamed scripts.
- The reserved opcodes `0x39` to `0x3E`: Aguilucho's replace
  `OP_RESERVED_3D` and `_3E`, and `op_reserved_3d`/`_3e` of `interpreter.s` go
  with them.
- The RAM: `$6110` to `$6127` is mine, not `$2560`.
- `test_music_ceilings.py` passed; I did not run `just ceilings`.
- To play: automatic common events 7, 43 and 50 now run in the game
  —Talan's auras, Emily's tape and what Radin repairs—, and the
  console opens with item 81.
