---
name: "try_pack's tie-break"
description: "That the color distribution not depend on CPython's hash order"
type: bug
status: done
---

# What

That `try_pack`'s color distribution break ties by something that is part of the
input, and not by the iteration order of a CPython hash table.

# Status

Noted and not started. **It is an Adeleine decision**, `tools/port/Adeleine.py`,
since step 8: `tools/snes/voodoo/` no longer packs, and **it does not block plugging in
Voodoo**, which has been plugged in since step 8c —until 2026-09-22 this task
said the opposite—. It gets fixed by changing the tie-break in Python, or when
Adeleine moves to Rust, where CPython's hash order does not exist.

# Why

`try_pack` distributes the colors by walking `sorted(sets, key=-len)` over a
`set` of `frozenset`, so ties —which are the normal case— are
broken by the iteration order of a hash table, which is not part of the
input. Measured: **156 of 200 shuffles of the same set give another distribution**.

Today's ROM always comes out the same because integer hashes do not vary between
runs, so it is not a ROM that changes by itself: it is a tie-break we
depend on without having chosen it, and it has a cost —in one measured call it forces
merging two colors that with a deterministic tie-break would not need
merging—.

What is known about the alternative, because it already existed: the `tools/snes/voodoo/` from before
step 8 broke ties by the colors themselves, and out of 32 calls gave **25
identical, 1 with the same palettes in another order, 6 different and none
worse**. That code is in the history of `tools/snes/voodoo/`, before `4953089`.

What it costs to do: either of the two paths **moves the tilemap of
some maps**, so there are goldens that are going to move and taro has to
re-bless them.

Done by the-advocate `3a8e381f` (2026-09-29, "las teselas del mismo tamaño
se reparten en el orden de sus colores"), still in Python, and kept when
Adeleine moved to Rust in `c5e22f0b`: `try_pack` in
`snes/adeleine/src/pack.rs` sorts tiles by size and then by their colours,
so the answer depends on the input only. Checked on 2026-10-16 at the-advocate
759aa0ba (Mulita).
