---
name: "A Blurred Line: the chests change colour from map to map"
description: "The chests' palette changes between maps: open ones look flatter than closed ones, and in the Neon Vipers' base, with Arden, they look golden. Is there a distribution of the same number of colours that keeps them consistent without degrading anything else?"
type: research
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, 2026-10-16, playing A Blurred Line: the chests change palette from
map to map. Mostly it does not matter, but two or three cases stand out:

* open, they look flatter than closed —they must be losing a grey—;
* in the Neon Vipers' map, when Talan goes with Arden and finds that the
  agency (probably) took everyone, there are several chests, and they look
  golden.

**What taro wants, and what not**: consistent colour, but **no knob, no
hack, no palette reserved for them at the cost of other things, and no
other graphic degraded**. What is asked is whether the colour-fusing
algorithm (Adeleine, and how wally/rm2k-snes-screens use it) can change a
little so that, without treating chests as an exception, results come out
more consistent between maps with no loss of quality overall. taro's note:
that map already has a lot of grey; maybe there is a way to distribute the
colours that, with neither more nor fewer colours, makes the image more
consistent.

**First experiment, by hand, without touching the tools**: on that exact
map, from screenshots of the game running with Talan, Arden and a chest on
screen at once, look for an alternative distribution —changing what goes
into the ROM by hand, over the tools' current output, with a throwaway
script—. If one is found that improves that map, then look at what the
algorithm would need to approach it without worsening the other existing
distributions. If none is found, the algorithm is probably not worth
touching.
