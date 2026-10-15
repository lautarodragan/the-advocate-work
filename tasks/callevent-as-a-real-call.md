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
