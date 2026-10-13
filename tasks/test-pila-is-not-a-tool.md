---
name: "test_stack is not a tool"
description: "tooling/test_stack.py runs the ROM, and tooling/ are the tests that don't"
type: test
status: done
---

`tests/README.md` says that `tests/tooling/` are the tests that do
not run the ROM, and `test_stack.py` does run it: it measures how far the stack
goes down. It was noted as an exception in the README on 2026-09-25, instead
of moving it, because it is a decision about the folder and not about the
name. Decide which one it goes to (`rpgmaker/` looks like the natural one: it
measures the ROM, not the game) and move it with `git mv`, together with its
line in the README's index —`test_index.py` enforces it—.

## Done, 2026-09-26

It went to `rpgmaker/`: it measures the ROM running and knows nothing about
ABL beyond the material they all use. In the index it ended up next to
`test_cores.py`, which is the other net against what the goldens don't see.
The exception on the `tooling/` line in `tests/README.md` is gone, and
so are the four citations of the old path —`console.py`, `bancos.py`,
`paginas_de_eventos.s` and `workflow/ESTADO.md`—.
