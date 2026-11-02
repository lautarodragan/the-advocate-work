---
name: "Above tiles no character can reach go below"
description: "A tile marked to be drawn above the hero goes to the layer above (BG2) even where no character can ever stand beside it, like a cave's ceiling; drawn below, the transparent message stops blacking it out and BG2 is freed"
type: feature
status: doing
assignee: Aguará
agents: [Aguará]
---

Follows [`a-transparent-message-blacks-out-tiles-on-its-lines`](a-transparent-message-blacks-out-tiles-on-its-lines.md):
on Zounds' maps 86 and 96 the cave's ceiling is the lower layer's
autotile 4500 (chipset 46's D autotile 10), whose lower passability is
`0x30` —"above the hero"—, so it goes to BG2, which a message without a
background takes on its lines.

taro, on 2026-11-02, in their words, translated:

> ah! and since a charset can take up more than a chipset tile, we need
> it drawn over the sprites, just in case… hmm…
>
> the only option that is cheap in CPU, but expensive in implementation,
> is to detect which of those tiles never overlap an event. On that map,
> it's almost all of them.
>
> in general, if a ceiling tile is marked with that setting, only the
> ones next to a walkable tile matter. If it's impossible to stand next
> to one of those tiles, then they would never share space with a
> sprite, and they don't need to use the SNES's layer 2.
>
> another alternative, simpler: only the "top edge" tiles of an autotile
> use BG2. I think, in practice, that's the case, isn't it?

Hornero picked the first, at conversion time: a 24x32 character standing
on a cell covers that cell, the one above and 4 px into each side, so
only an above tile next to a cell a character can stand on —passable for
the hero, or where an event starts— can ever be under a sprite; the
"top edge" rule misses the sides. Conservative where the analysis cannot
see: a map with events that pass through walls, jump or move freely,
`SetEventLocation` / teleports to cells, tile substitutions that change
passability, keeps today's BG2 for what it cannot prove.

**Done**: wally sends to BG1 the above tiles no character can reach, so
the map looks the same pixel for pixel when nothing overlaps them; on
Zounds' maps 86 and 96 the sign's message no longer blacks out the
ceiling; the goldens that move are looked at; and the inventory of how
many above tiles leave BG2 across the nine games, measured.
