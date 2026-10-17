---
name: "Zounds: the screen goes black up the stairs after the guard"
description: "In the intro, after Uname knocks out a guard, takes his uniform and hides the body, going north up the stairs to the next map leaves the screen black; the music goes on and the menu opens"
type: bug
status: done
assignee: taro
agents: [Aguará]
---

taro, 2026-10-16, on the console with the delivery of that evening (the
ports `4b2d41e`, the-advocate `759aa0ba`). The intro, in order: the still
credits; a garden map where Uname shows up; a teleport —to another map or
the same one, still outside—; an interior; another interior, where Uname
knocks out a guard, steals his uniform and hides the body; from there north
and up some stairs, and on arriving at the next map everything stays black.
The music goes on and the menu opens, so the game is alive.

taro's captures, in `/shared/builds/zounds/`: `zounds 2026-10-16
18-13-41.png` (the guard's room, with the body on the floor) and
`18-13-46.png` (the black screen).

The game blocks there: nothing after it can be played.

## Work (Aguará, 2026-10-16)

Worktrees in `~/scratch/aguara/zounds-stairs/`, branches
`aguara-zounds-stairs` from the-advocate `759aa0ba` and the ports
`4b2d41e`.

**The chain**: map 1 → 106 (credits) → 107 → 1 → 4 "Castle Courtyard" →
5 "Back Enter" → 6 "Inner Castle" → 7 "Get Suit (Armor)", where the boot
test gets control → 8 "To King's Room". Map 7's event 2 "AutoStart" is a
**parallel** page with no condition: it walks Uname to the guard, knocks
him out, swaps the CharSet, walks him north and ends
`TintScreen (0,0,0) wait; Teleport 8 (20,14); TintScreen (100,100,100) wait`.

**Reproduced** (snes9x, `release` from the ports `4b2d41e`): from control
on map 7 at tick 4437, the tint goes black at 5001, the jump at 5031, map 8
at 5055 and stays `tint 0,0,0` with the player in control.

**The cause**: `op_teleport` ended the frame for every interpreter, saving
the cursor for the page to resume after the load —right for the foreground,
easyrpg's `CommandTeleport` (ccbcf440, 2026-09-03)—. For a parallel page
the load clears its state, so the tint back never ran. easyrpg returns true
there for a background interpreter: "parallel events should keep on running
in 2k and 2k3". Fixed in the runtime (the-advocate `1a97c8ca`), with a test
game case, `parallel-teleport`, red before and green after.

**The next block**: map 8's autostart (event 3, the talk with the two
guards that leads to map 9) is left out whole by its messages: `é`, `¿`,
`¡`, `ë` —the font has no Latin-1, the draft
[`latin-1-letters-stop-a-box`](latin-1-letters-stop-a-box.md)—. With the
fix the map shows, the player walks, and the story does not go on.

The suspects taro passed on, checked against the build: both
`TintScreen`s on map 7 compile (only their half-second gradient is
dropped, `tint-gradient-dropped` in `degradations.json`); common event 4
"Conditional Save", which map 8's autostart calls, compiles; that
autostart is not what waits forever: it is never in the cartridge.

### Delivered

* the-advocate `aguara-zounds-stairs`: `1a97c8ca`, the runtime
  (`op_teleport` goes on to the next command when `pair_ev` is below
  `PAIR_BATTLE`; `op_location` shares it), the test game's "Jump Away"
  event, case `parallel-teleport` and `test_parallel_teleport.py`, and
  a doc comment on the compiler's `after_jump`.
* the ports `aguara-zounds-stairs`: `af7c4d2`, `tests/test_zounds.py`
  —from control on map 7 to map 8, its tint neutral and the screen not
  black; snes9x only—, red with the tools of `759aa0ba` (tint 0,0,0),
  green with the fix; and `2438921`, main merged.
* the docs `aguara-zounds-stairs`: `8361321`, Zounds' known issues (the
  intro now reaches map 8 and stops there, by the accented letters) and a
  sentence in `internals/events.md`.
* The draft `latin-1-letters-stop-a-box` notes that it is where the intro
  stops now.

### What was run, with the tools of the branch (`cartridge` installed locally)

* `just rust-test`, `just test` (29 passed), `just test-game` (30 passed,
  1 skipped; the new case red with the runtime before the change, both
  cores).
* ABL's `just tests`: 1563 passed, 2 skipped, before and after merging
  main; no golden moved. `abl.sfc` `ae69f8fd9d5b…` (sha1).
* `just boot` at the ports root, whole: 47 passed (with Book of Three's
  playthrough and the new Zounds test).

Not covered by any test: a **parallel common event** that teleports
—it now goes on in the same frame too, as in easyrpg—, and
`RecallToLocation` from a parallel; how many pages of the games do
either was not measured.

### What to install when merging

Nothing: the change is in `runtime/`, which `rm2k-snes-cartridges`
reads from the checkout; the compiler change is a comment.
