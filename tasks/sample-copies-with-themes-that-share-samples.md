---
name: "Sample copies with themes that share samples"
description: "A new theme that shares samples with the old ones changes which copies rm2k-snes-audio makes and lowers their rate without MSU-1"
type: feature
status: wishlist
---

From milestone 4 of the world (2026-09-27): the chapter's five themes share
samples with themes that were already there, and that changed which copies
`copies` makes, in `tools/rm2k-snes/rm2k-snes-audio/src/bank.rs`. Without MSU-1, 43 (theme, instrument) pairs from 15
themes went down and 51 went up. With only jackalstg2, 36 went down. taro listened to the before and
the after and accepted them, so the chapter did not have to be held back, but **it is going to
happen again with every theme that gets added**.

What was tried without getting them back (see
`world-4-tasgarde-eisen-and-the-bridge.md`, "La música de antes, sin MSU-1"):
`TEMAS_APARTE` (the new ones already go alone), `SE_DE_SIEMPRE` from 70 to 130 (the
best, 29 pairs, and it moves the batch of effects taro approved), `COPIA_HASTA`
at 0.85 and 0.95, without jackalstg2's inheritance, without the package of 259. The
directory was not the cause: without the second batch for the new themes it is left
with free room and 42 go down all the same.

What is missing: that `copias` choose what to copy thinking of all the themes that
use a sample, not of the order in which they arrive, and measure it pair by pair with
`Banco` against the `main` from before the chapter (not 93af39f: the `main`
455f9fc1). Whatever cannot be recovered without losing something else, recorded for
taro to listen to.

# What was thought on 2026-09-30, and why it goes to the wishlist

With the radio of the troop pages (`common-35-and-the-radio-music.md`)
it happened again: without MSU-1, the battle theme went down from 11.5 to 10 kHz and another
34 themes lost some sample, the worst from 20.4 to 6.8 kHz. taro
proposed going beyond "choosing better what to copy", and what came out of the conversation:

1. **The battle as a special case, first.** Its instruments at one quality
   and the rest's at another, even if samples get duplicated. It plays often and it is
   where most effects are, so it is probably the best cost against
   what is heard.
2. **Weigh each theme by how much it plays.** Record at which frame the theme changes
   in a run of the walkthrough and count frames per theme. Two caveats: the
   walkthrough covers the beginning of the game and not the average, and the battle is
   estimated separately, from each map's encounters, or it ends up underrepresented.
3. **The general case: a graph of instruments and themes**, partitioned
   by duplicating the samples that most improve what is heard per byte of ROM, with
   those weights. It is the generalization of "what is missing" above.
4. **The effects in the same graph**: without MSU-1 they share ARAM with the
   music. Outside battle, the most common one must be the chest's.

Why not now: with MSU-1 the music goes through tracks and this is not heard;
duplicating samples costs ROM, and `release` has few banks left, which the world is going to
ask for; and quality gets tuned when the whole game is playable
(`decisiones/primero-el-juego-entero-despues-la-calidad.md`).

**When it is taken**: first an analysis and a plan —measure the graph, the weights
and how much ROM each option costs—, and from that plan come the tasks.
