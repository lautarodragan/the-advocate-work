---
name: "CallEvent as a real call"
description: "A CallEvent to a common event or another event's page compiles to a call into one shared body with a return, instead of pasting the body at every caller; the call stack as deep as RM2k's"
type: feature
status: doing
assignee: Carpintero
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
