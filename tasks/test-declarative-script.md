---
name: "Declarative tests"
description: "A runner for tests written as data"
type: test
status: wishlist
---

# What

A runner with declarative tests

test --game … --tests …, and each test is a file that says which case, which buttons on which frame, where to capture against which golden and which memory to check. The cases and the goldens are already data; the script is missing. 

# Status

Paused. We'll probably discard it. It's not worth adding complexity if we can't cover all the tests,
and we'll probably always need that freedom.

# Research

Of ~465 tests, 253 already have that shape. 

┌─────────────────────────────────────────────────────────────────────────────────────┬──────────────────────────────────┐
│                                                                                     │             tests                │
├─────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────┤
│ Fit the format as is                                                                │ 259: the suite's 253 and 6 more  │
├─────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────┤
│ Fit with small additions                                                            │ 34 (±3)                          │
├─────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────┤
│ Run the ROM and need code                                                           │ 95                               │
├─────────────────────────────────────────────────────────────────────────────────────┼──────────────────────────────────┤
│ Run no ROM (tools, converter, calculations on the symbol table)                     │ 78                               │
└─────────────────────────────────────────────────────────────────────────────────────┴──────────────────────────────────┘

The 78 at the end don't count for the runner: they stay in Python because there's no ROM to run.

The suite's 253 all fit. None decides anything based on what it sees. If the automatic check flagged test_tanda.py and test_tanda_pantallas.py it was out of habit, not logic: range()s that expand to fixed lists, or functions like plan() that return fixed numbers. For them to fit, the base format has to bring four things:
- the cartridge as the converter's list of flags;
- two clocks: game ticks and hardware frames (the latter for battle, menu and title), with their start;
- the harness's four kinds of press, plus held buttons;
- several captures per test, each one from a fresh console.

Why the 95 need code:
- Wait until something happens (35): press A until the map changes, play a battle's turns according to what the screen shows, the walk toward a destination.
- Save, reset and load (25): save to a slot, reset, pick the save and read what came back. With two new actions in the format about 19 would fit, but that's already a big addition.
- The expected value is computed with the LDB or with a Python model (15), like the whole battle turn by turn against batalla.Batalla.
- The expected image is drawn in Python (12), like the menu against titulo.render_menu.
- Other logic (7): the difference between two runs, the sets of samples in the ARAM, a performance measurement.
- One of test_cores, which looks at the audio channels' levels.

The important nuance: about 30 of those 95 could be frozen as "at tick N this holds". But it would change what they test: they'd go from "matches RM2k" (the value comes from the LDB or the model) to "matches what the ROM gave on the day of the snapshot", and a golden doesn't catch birth errors. It's the same loss we accepted on the 16th when removing the reference. I'd leave those in Python on purpose.

The small additions that make up the 34:
1. Read RM2k data by number: switch N, item N, the current map, variable N. The variable is the hard one, because its slot is computed by the converter from the LDB, and without it 10 tests drop. It could be solved without the runner knowing the LDB if the converter emits the symbols (VAR_17 = slot), as it already does with CASO_RANURA.
2. A richer initial state: switches, party, ir_al_mapa, and bytes whose value is that of another symbol.
3. Simple operators, like "nonzero" or a bitmask. Almost all can be replaced by freezing the exact value.
4. Compare against an engine constant, for example ORO_MAX == 999999.
5. Run on another core and compare against the golden at 15 bits, for 4 of the 5 in test_cores.

My reading: the runner is worth it for those ~290 tests, which are three quarters of the ones that run a ROM. The rest stays in Python without that being a defeat: they're precisely the ones that compare against RM2k and not against a snapshot.
