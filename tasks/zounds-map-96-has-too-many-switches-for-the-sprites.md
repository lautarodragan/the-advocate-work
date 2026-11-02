---
name: "Zounds' map 96 has too many switches for the sprites"
description: "Map 96 (Arriba del Cuartito) carries 58 floor-switch events drawn from a CharSet: it lags, a switch is drawn by half, the hero loses everything below the head on some rows, and an opened chest's graphic vanishes until the hero walks"
type: bug
status: doing
assignee: Cardón
agents: [Cardón]
---

taro, on 2026-11-02, in their words, translated, with captures of the
port and of the map in the EasyRPG editor:

> On that map (96, "Arriba del Cuartito") there is a lot of lag. There
> are quite a few objects on that map. And now that I look at the
> screenshot, one of the floor switches shows rendered by half. I attach
> a screenshot of how it looks in RPG Maker (EasyRPG Editor). I think all
> the `Switch`es are a copy-paste. In theory our current system should
> detect them and de-duplicate them, but maybe they are not being
> de-duplicated for some reason, or maybe even de-duplicated there is
> still lag.
>
> When opening the chest its graphic disappears. Walking a bit to the
> right, it shows again. The same happens with other events.

In their captures the hero is also drawn with his head only, on the
rows of the switches.

Measured by Hornero at ports 31fb291: the map is 30x30 with 99 events;
58 are `Switch`, all with page 1 on CharSet `object2`, still, action
key. The converter warns (`build/release/degradations.json` in
`zounds/`): "by where they start up to 64 events are on screen at once
and the cache has 28 slots: the ones drawn last wait for one" —likely
the chest—, the 8 sprite palettes used up, and the transparent sign's
picture not drawn. A half switch and the headless hero look like the
console's sprites-per-scanline limit (32 sprites, 34 8x8 slivers), but
that is a guess.

**Done**: the causes measured (lag: where the frame goes; the half
switch and the hero: scanline limit or else; the chest: the slot
cache), and what fits fixed —e.g. still CharSet events that never
change pose baked into the background, or shared sprites— so map 96
plays as in RPG_RT, or the limit measured and written as a divergence.
Captures before/after, and a ROM test where the suite can reach it.
