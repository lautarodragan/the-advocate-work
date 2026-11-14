---
name: "A transparent message keeps the map's layer above"
description: "A message with a transparent background hides the roofs and treetops on its lines, because its text takes BG2 there; RM2k draws the text over them"
type: feature
status: doing
assignee: Aguará
agents: [Aguará]
---

Asked by taro on 2026-10-19, after
[`show-window-a-window-command-of-our-own`](show-window-a-window-command-of-our-own.md)
made keeping the layer above beside a window a strict requirement.

**What is seen**: a message with a transparent background
(`ChangeMessageStyle`) shows its text over the map, but on its lines the
map's layer above —roofs, treetops— is gone: the message window's HDMA
points BG2, which is that layer, at the window's tilemap for the whole
line (`msg_hdma_build` in `runtime/message_place.s`). With a framed window
it is covered anyway; with a transparent one it shows.

**The idea** (Hornero, not measured): bake the layer above into the text's
own tiles when the message is composed. VRAM probably does not grow: the
text area is already 240 tiles, one per cell and not deduplicated
(`runtime/messages.s`), so each cell would start from the layer's pixels
instead of from transparent. What it costs:

* **CPU**: copying the layer's pixels into each cell before the letters
  are composed over them. The map's BG2 scrolls by the pixel and the text
  cells are aligned to the screen, so a cell straddles up to four of the
  map's tiles. Where the line has no tile of the layer above, nothing to
  copy.
* **Palettes, the hard part**: a BG tile has one 16-colour palette, so a
  cell with a roof under it needs the text's colours and its shadow in the
  roof's palette, or the closest ones —an Adeleine decision, made at
  build time per map—.
* **Where the layer's tiles are read from**: VRAM can only be read in
  vblank; the map's decompressed tiles in WRAM or ROM are cheaper.
* **The map moving while the text is up** (a parallel event, a pan):
  the baked cells would have to be baked again. **Out of the first phase**
  (taro, 2026-10-19): looked into within this task, and implemented with
  the base case only if it turns out free; otherwise it goes to the
  wishlist as its own task, and the build warns in its log on every map
  where the camera can move while a transparent message is up. taro
  remembers no such case in ABL, and it would hurt reading anyway.

**First step**: how many transparent messages the ports show over tiles
of the layer above, and on which maps, before choosing.

## The palettes: the text's colours win (taro, 2026-10-19)

The text keeps its exact colours, and the background gives way: in each
palette of the layer above that a baked cell uses, the entry closest to
each of the text's colours —and its shadow's— becomes that colour. The
layer above changes colour slightly, maybe differently from tile to tile,
and that is less disruptive than text whose colour changes between cells,
however imperceptibly. taro's words:

> consistency in the text matters more than in the background.

What that leaves to measure (Hornero): the change is to the palette, so
it is seen on every tile of the map that uses that entry, not only under
the text —done at build time it is permanent on that map; done in CGRAM
while the message is up, the rest of the layer would flicker—. And it
costs one entry per colour the text can take there: the colour codes
(`\c[n]`) a message uses are known when it is compiled, so the build can
say, per map, how many entries each palette gives up.

## Baked at build time, on every map of a game that can show one (taro, 2026-10-19)

At build time, permanent on the map —taro had proposed doing it when the
text opens, and chose this instead—. **Here, without narrowing it**: a
game with any `ChangeMessageStyle` that sets the window transparent bakes
every map with tiles in the layer above; a game with none bakes nothing.
Narrowing it to the maps that can actually show one is a different
problem —a static analysis of the events— and is its own task, in the
wishlist:
[`a-transparent-message-baked-only-where-it-can-be-shown`](a-transparent-message-baked-only-where-it-can-be-shown.md).

## Rendering everything: ABL's maps 5 and 6 (taro, 2026-11-14)

taro, on 2026-11-14, about A Blurred Line's Core Retrospective (map 5),
`EV0002`'s `ShowMessage` "CORE / I know. You're a telepath, too. / I
can tell.", in their words, translated:

> I think it's the first moment of the game where we show text with a
> transparent background (or without a background, rather) over a
> relatively complex map, and we have to avoid rendering the top of a
> tree to be able to render the text that way.
>
> […] Right now, for example, I only see half a tree not rendered, under
> the "tell" of "I can tell.".
>
> Do you think there could be some way to render everything? It's a
> fairly complete situation. We have, in the same space of the screen:
> water, an animated autotile; over the water, the treetop; over the
> treetop, the text. And we have the limit of how many objects we can
> show per line. […] We also have a tint on the screen while all this
> happens.

Hornero's answer: yes, by carrying the layer above inside the window's
plane on the text's lines —the cells without letters copy the layer
above's tilemap entries (the draft
[`a-window-without-a-background-could-copy-the-layer-above`](a-window-without-a-background-could-copy-the-layer-above.md)),
the cells with letters are composed from the layer's pixels with the
glyph over them (this task, with the palette rule above)—. It uses no
objects, and the water is BG1, which the message never touches. What it
has to watch: the screen's tint must not reach the text's colours once
they live in the map's palettes (RM2k does not tint the window), so the
tint skips those entries.

Then, on including map 6:

> Include Core Retro II (map 6) in the analysis and experiment. That map
> also has a similar situation: the fence that appears over Manta and
> Core for a second, while they walk, at positions (0, 9) - (1, 10),
> forming a 2x2 square (the fence is bigger than that, but that is the
> part that conflicts) disappears while the text appears.

On the alternatives, which taro calls plans B and C and would rather
avoid:

> A rather extreme optimization, very tied to this case, would be to take
> advantage of the fact that we know this map's event commands move the
> sprites out of the fence before showing text, so we could pre-bake a
> floor+fence tile and use the two separate tiles while they have sprites
> between them […] and swap them for the baked tiles from that moment on
> (or do it every time we use ShowMessage, which is more generalizable).
>
> But that kind of optimization we can do in a generic way: whenever we
> do ShowMessage with a transparent background, we pre-bake tiles that
> are not animated, doing a "flatten", without analysing what impact it
> has on other layers / NPCs, or we do the static analysis of the
> commands and the movement possibilities within the map, which is very
> complex and probably gains very little.
>
> A third option is to do it as a patch of the map, using RPG Maker's
> native commands: we add a Tile Substitution between the 5th and 6th
> command, the `Wait: 1.0s` and the first `ShowMessage`.
>
> But that is a solution that only applies to this map, and is not
> applicable to the previous map, unless we bake an animated water tile
> with a forest canopy on top, which implies consuming quite a lot more
> VRAM.

On the text's position, which the copied cells need aligned with the
camera's fine scroll:

> I'd rather avoid the text shifting, but if it is unavoidable, I'd like
> to try it in the game before deciding. I anticipate several problems
> (different ShowMessages would appear at different vertical positions
> of the screen, depending on what is under them).

So: the text stays where RM2k draws it —the composer draws it shifted
by the camera's fine part, three cell rows per line vertically— unless
that turns out impossible, measured; then a build with the shift for
taro to play before anything is decided.

**Done**: on ABL's maps 5 and 6 the transparent messages show the layer
above beside and under the text, with the text in RM2k's place and its
exact colours, the tint not reaching them; the goldens that move looked
at; what it costs (bank 0, far banks, VRAM, CPU when the window opens,
palette entries per map) measured.
