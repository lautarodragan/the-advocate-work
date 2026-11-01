---
name: "SP in the menu and in the item target picker"
description: "The main menu's and the item target picker's party boxes show HP and Ex but not SP, so an SP item cannot be aimed; the selection rectangle leaves a pixel of the text out on top; and the debug map needs a full party to try it"
type: feature
status: doing
assignee: Tijereta
agents: [Tijereta]
---

taro, on 2026-11-01, in their words, translated:

> Something we left pending: it would be nice to show the SP/MP/whatever
> in the main menu. And, above all, in the character selection menu when
> choosing to use an item. In ABL, if you want to use Cheap Wine SP, for
> example, you don't know who to apply it to because you have no idea how
> much SP they have. You have to be in battle to see it.
>
> I thought we could try the big resolution again, with the wide font, but
> it might complicate that screen too much and not end up solving the
> problem, so maybe the best is to extend each character's box vertically,
> as we already did in the past to include HP and Ex, and include SP in
> that new line.
>
> On the other hand, a nitpick from the past: at a glance, it looks like
> the red selection rectangle doesn't quite cover 100% of the text at the
> top edge — one pixel is left out. I'd like it to be inside, and to have
> one or two pixels of padding, too.
>
> To put it to the test: I don't know if in ABL at some point you have
> more than 3 characters in the party. The easiest would be to generate it
> artificially: an option in the debug map that adds several characters to
> the party. It wouldn't make sense for the game itself, but it helps to
> debug the screen itself, and it wouldn't need touching code — it can be
> done with an event and RPG Maker commands. We can add Kersh, Core, Manta,
> and have Talan at the same time. I don't remember if RPG Maker allows
> more than 4. In that case, I'd add Arden and Saldra, too.

**Done**:

* each actor's box in the main menu and in the item target picker has one
  more line, with SP (the game's own term for it, from the database's
  vocabulary), for every game; the boxes grow vertically, in the 256-wide
  mode —not the 512 one—;
* the selection rectangle covers the whole text, with one or two pixels
  of padding, wherever that cursor is drawn the same way;
* ABL's debug map has an option that fills the party —Talan with Kersh,
  Core and Manta; RM2k's party is four at most, so Arden and Saldra in a
  second option, if that is the cap—, made with RM2k commands in the
  map's patch, not in code;
* goldens moved, red before, looked at, captures in `/shared/captures/`.
