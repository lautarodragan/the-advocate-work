---
name: "Desert Nightmare: what it takes to be playable"
description: "A study: play Desert Nightmare's port through the harness as far as it goes, list what breaks or looks wrong against RM2k, find the causes, and rank what would make it playable by cost and gain"
type: research
status: doing
assignee: Hurón
agents: [Hurón]
game: desert-nightmare
---

taro, on 2026-11-19, translated:

> Desert Nightmare and Vampires have many bugs —they are too close to the
> limit of what we can make work on the SNES. Maybe it is worth doing a
> research on what we could do to make Desert Nightmare work well? That
> game surprised me a lot —it looks very good, but it is practically
> unplayable in our current port.

What is known (the book's port page, "Known issues", 2026-11-19): crowds
cut on 53 maps; the start menu over garbage; white rectangles where the
roofs go (map 4; 14, 61, 66 too); characters not shaded by the lights
(drawn into the map); the menus keep the intro's System; two apartments
keep their first background. Open tasks: `desert-nightmare-own-message-frame`
(todo), `desert-nightmare-start-menu-over-garbage` (todo),
`desert-nightmare-roofs-left-out-show-white` (draft),
`desert-nightmare-characters-cut-on-crowded-lines` (draft),
`desert-nightmare-title-is-silent-without-msu-1` (wishlist).

**Done means**: a research page in the book, under the port's page, dated,
with the commits it measured: how far the game plays through the harness
(and with RPG_RT/EasyRPG for comparison), each thing that breaks or looks
wrong with its cause, which limits are the console's and which are ours,
and a ranked list of tasks —cost, gain, what each unblocks— so the next
steps are clear. The new findings as drafts and Known issues lines.
