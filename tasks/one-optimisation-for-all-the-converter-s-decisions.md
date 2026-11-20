---
name: "One optimisation for all the converter's decisions"
description: "Instead of stages that decide one after another, each map's decisions —bake or sprite, which colours merge, which pictures, which VRAM layout— taken together against shared prices for each budget, with one measure of loss: the pixels that differ from RM2k's render at 15 bits"
type: research
status: wishlist
---

taro, on 2026-11-19, after
[`the-converter-s-stages-and-what-each-spends`](the-converter-s-stages-and-what-each-spends.md),
translated:

> I'd love to have a universal optimisation model that applies to any
> game and always finds the best combination. Which colours merge is
> affected by baking, but baking is affected by which colours merge. Maybe
> the rule is simple: losing whole graphics always matters more than
> colours… But the decision to bake affects the palettes of both layers,
> doesn't it? There may be cases where it is better not to bake *all* the
> objects that can be, but only some in particular. Isn't the cost of each
> resource relative to the cost of the other resources, and of all the
> possible decisions? How can each decision be taken for each palette,
> each tile, each layer, without computing every possible combination?

And, to leaving it as a wishlist task: "sip".

**The model, as Hornero sketched it**:

* **Per map**: VRAM, CGRAM, sprite slots and tiles, the line limits and
  WRAM rows are reset by each map; only the ROM is global, and that is the
  packing's own problem. So it is 189 small independent problems, not one
  huge one: parallel and cached per map.
* **Variables**: per event —sprite, baked, painted, decorative, trimmed—;
  per picture, in or out; which colours merge (Adeleine, as an inner
  optimiser that answers "with this many colours I lose this much"); the
  VRAM layout and the mode.
* **One measure of loss**: today's degradations are not comparable (a
  missing roof against a merged colour). `rm2k-render` draws the map as
  RM2k does, so the loss can be the pixels that differ at 15 bits —with a
  lexicographic order on top if taro wants one ("never lose a whole
  graphic before a colour")—.
* **Prices instead of order** (Lagrangian relaxation): each budget gets a
  price; every decision chooses what is best for itself against the
  prices alone, without knowing the others; the prices of the budgets
  over-asked rise and the others fall, and it repeats until it closes.
  Each decision looks at a few numbers, not at 2^N combinations. The
  prices also give a bound: how far from the best possible the solution
  can be at most.
* **Or an integer programming solver** (branch and bound) per map, for
  maps of a few hundred decisions.

**Steps, when it is taken up**: first
[`painted-events-chooses-its-maps`](painted-events-chooses-its-maps.md)
(a two-point search); then count, per game, the maps with a budget at its
limit and a degradation —the ceiling of what any joint optimisation can
gain—; then prices for the decisions that clash most (events: sprite,
baked or painted, against slots, tiles and colours). The expensive part is
the loss: rendering and comparing every candidate; it has to be estimated
without a full render each time.
