---
name: "World 5: Tangle Forest"
description: "Maps 310 to 313 in release, up to the tunnel to Paradise: measured that they fit, the EraseEvent after a jump, the timer in branches and in page conditions, cancelling outside the options, and the end of the demo at 66 ev18's Continue onward"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-01: "can we add more maps?". The plan is
`world-and-what-follows.md`, milestones 1 to 4 done. The demo ended on
entering Tangle Forest (66 ev19), and Tangle **isn't optional**: the tunnel to
Paradise is on the other side of the forest, and it's crossed through 310, 311,
313 and 312.

# It fits

Measured with `just espacio release`, as `AGENTS.md` says. "Banks" are the
data ones, from `$02` to `$7D`.

    release                         banks      free    gap       bank 0   texts
    the baseline (37ea12fc)         120 of 124   4     19,744 B  320 B    143,114 B
    + 310 to 313, no code touched   124 of 124   0     23,873 B  278 B    144,758 B
    + everything in this task       124 of 124   0      7,438 B  247 B    145,792 B

Bank 1 4,233 B and ZEROPAGE 4 B in all three; BSS 129 B, and 128 with
`timer_watch`. That is, **it just fits**: no free bank is left, and what comes
next in the ROM has to come out of that 7.4 KB gap or from the `.msu` (see
Lechuza's study). What weighed was stated by the plan on 2026-09-27 —poses,
background tiles and music—; nothing's quality needed lowering.

What the 16 KB of difference between the second and third rows ate are the
pages that started compiling —311's clearing, 312's exit and fire, 66's 18 and
348's shop— and the shop owner's twelve poses, who now turns towards the hero
(see "Goldens").

# What was missing, counted

With the compiler instrumented (an `eprintln` in the `scan`, in a `target/` in
the scratchpad, not committed), on the request `release` builds with the four
maps: **in Tangle two pages didn't compile**, not the plan's five.

* **311 ev4**, the fire cans: `EraseEvent`. It goes **after** a `Teleport` to
  312, and in easyrpg the jump sets each stack frame's event to 0
  (`Game_Interpreter_Map::OnMapChange`) and `CommandEraseEvent` with 0 does
  nothing. So it compiles to nothing when the page has already jumped
  (`MapEvents::jumped`); before the jump it still doesn't compile. The only
  other one in the game is map 150's.
* **312 ev10**, the exit from the burning forest: a `ConditionalBranch` on
  the timer. `OP_IF` with type 2 (`COND_TIMER`), which is the gold question
  —`>=` or `<=` depending on the polarity— with `timer_sec` instead of the
  gold: `op_if` now shares the comparison. It asks for `>= 0`, which always
  holds.

And one the plan counted and that didn't look like a page that doesn't
compile:

* **312 ev81**, the fire: it has a page with a **timer condition** (`timer <=
  1`, the Game Over), and an event like that was left **entirely** out of the
  table. But its page 2 is the one that fights the ship and takes you out to
  the world: without this, the forest was a dead end. The condition travels in
  the place of the variable one in the page record, with slot `$FE`
  (`TIMER_SLOT`), and `conditions_ok` reads `timer_sec` and compares `<=`. An
  event with a page that asks for both is still left out (there are none). And
  the change of second asks for the refresh, like `Game_Party::UpdateTimers`,
  **only on a map where some page asked** (`timer_watch`, a BSS byte that
  loading the map turns off and `conditions_ok` turns on); `SetTimer` too.
* **348 ev1 p2**, the world's shop: `ShowChoice` with `cancel_type` 4 and two
  options. In RM2k cancelling runs none and the page continues after the
  `ShowChoiceEnd`. `OP_CHOICE` carries one more entry, at the end, which jumps
  to the end of the choice, and the cancel byte at `$FF` (`CANCEL_PAST`) tells
  `op_choice` that entry is only for cancelling: the cursor doesn't reach it.
  The length counts it, because it's what the code steps over past the table
  —the first version didn't count it and `instruction_size` overshot—.

On 66 three don't compile: 9, 11 and the original 18, whose destinations (67,
68, 105) aren't in. The two to 312 from before now compile.

# The end of the demo

At **66 ev18**'s "Yes - Continue onward", the tunnel to Paradise, which is the
plan's goal: the fork of 66 swaps the `Teleport` to 105 for the sign ("END OF
THE DEMO / Paradise is not in the / cartridge yet. Thanks for playing!") and
the return to the title. 19 went back to being the original. On the other side
of the tunnel is 105, the next chapter: not measured.

# Tests

No new case: **`release`'s table of test pages is full**. The page number is a
byte (the record's `+2`, which the ROM doesn't read) and there are 256; one more
case breaks the assembly (`Range error (256 not in [0..255])`). So the tests use
the game's pages, which is what matters to compile:

* `rpgmaker/test_borrar_evento.py`: 311's whole autorun, from 840 to the timer
  on 312.
* `rpgmaker/test_cronometro_condiciones.py`: 312's exit (the branch) and the
  fire's page, which doesn't run with 2 seconds and does with 1.
* `rpgmaker/test_elegir.py`,
  `test_cancelar_a_una_opcion_que_no_esta_no_corre_ninguna`: the shop owner,
  B, and the page ends without opening anything.
* `rpgmaker/test_cores.py`, `test_el_fuego_del_cronometro`: the fire's page in
  snes9x and in bsnes.
* `abl/test_tangle.py`: 310 and 311 just arrived, with a golden.
* `abl/test_recorrido_tangle_golden.py`: from 310 to the title, through the
  tram, the cans, the burning forest against the timer, the ship and the
  tunnel. With the party at level 20: at the starting level the hits do
  nothing to the Para Guards and the battle doesn't end. Its screenshots
  aren't blessed.
* `abl/test_recorrido_capitulo_golden.py` now ends on arriving at 310.
* The compiler's three in `compile.rs`, and `maps`'s one.

**The four ROM ones were seen red** with the global tools and Tangle in
`release`: the clearing doesn't jump, the exit doesn't turn on 845, the fire
doesn't run, the owner's choice doesn't open. Against easyrpg it was confirmed
by reading the source (it isn't compiled here): `CommandEraseEvent` and
`OnMapChange`, `CommandConditionalBranch` case 2, `AreConditionsMet` with
`GetTimerSeconds`, `UpdateTimers` with `SetNeedRefresh`, and `InputChoice`
with `CommandOptionGeneric`.

The two of `python.rs` (events and maps) used the timer as "the condition the
ROM doesn't evaluate": now that page asks for timer **and** variable, which
still isn't evaluated, and the Python hashes weren't touched.

`just pruebas`: all green except `test_musica_techos.py` (both cases, see
below), also on the tree with `main` merged (`aef95674`, Lechuza's study,
which doesn't touch the ROM). `just -f tools/justfile test` green. `NO_CACHE=1
just cartuchos` gives the same fingerprints as with the cache.

# Goldens

* **New**: `tangle-310-llegada` and `tangle-311-llegada`, in their commit.
* **Moved**: the five of `test_heroe` on 348 and `ventana-348`, 16 pixels of
  the hero —three tones: the skin, the hair and the clothes—. It's the shop:
  its page 2 now compiles, the owner turns towards the hero, asks for his
  twelve poses and one more slot (`9 with their twelve poses` against 8), and
  the palette the hero shares loses those three colors. Before and after in
  `/shared/capturas/2026-10-01-tangle/`. **The merge waits for taro.**

# What isn't done

* **`test_musica_techos.py` fails**: the new theme is
  `T_AVGFighter_KyaraSelect` (the clearing and the tram), and
  `golden_axe-turtlevillage2` clips. `just techos` wasn't run.
* **The earlier music goes down**: comparing the rates in `conversor.log`
  against the baseline's, 48 (theme, sample) pairs go down and 21 go up.
  Almost all are the copies of drum hits —KICK264, SOLKK60A, FATSD60A,
  CHH__60A, OHH__60B, SYBS133, SAW0_60…— which drop from ~22 to ~10.6 kHz in
  Lunar_Pyramid, Tnt07, wb3shop, Story, cd4, escape_newyork and others; and
  four base samples "limited by 311" (VIBE_76A, EORG173, SYBS233, ATMOS60A,
  from 22 to 17-19 kHz). It's the same as what happened in milestone 4: 311's
  package carries the new theme with Lunar_Pyramid and has 1,265 B left.
  **Nothing was changed or recorded**; the options are the usual ones
  (`apart_themes` for the clearing's theme, which also plays in the tram;
  touching how `copias` chooses). taro decides by listening.
* **The battles in the clearing and with the ship** are played with the party
  at level 20. Whether they can be won with a played save's party wasn't
  measured.
* The duration of `TintScreen`s is still discarded: the fire and the return to
  the world change abruptly.
* 348 is still in `[maps] test`, even though the world now leads to a shop
  that works.

# What `just pruebas` doesn't cover

* The fire's Game Over on reaching zero (the test checks that the page runs,
  not the Game Over).
* The cans' other branch: with Saldra (56) or AG7 (150) in the party, the
  messages are different.
* The false branch and the timer's `<=` in `OP_IF`: the game doesn't use
  them; the comparison is the gold one, which `test_oro.py` checks both ways.
* 310's chests and the save point.

# When merging

Install `events`, `maps` and `cartridge` (`just -f tools/justfile install
events maps cartridge`). The `.py` files only changed in content.

# What taro has to test

* From the bridge: enter the forest, the north, the clearing, the battle, the
  tram, the cans and **the burning forest against the timer**: are the two
  minutes enough to reach the exit? And let it reach zero: the Game Over.
* The ship, the exit to the world, and the tunnel: "Not yet" and "Continue
  onward".
* 348's shop: buy, rest and cancel.
* Listen to the themes that go down (see above).
