---
name: "An inventory of the pictures that may be windows"
description: "A tool that lists every ShowPicture of a game with its context and a tentative class —a menu with a cursor, a message frame, a HUD, a scene—, so that an agent sorts the doubtful ones and taro picks which to turn into windows"
type: feature
status: todo
---

taro, on 2026-10-20, in their words, translated:

> maybe we can detect which things could be replaced by the window
> system, no? The console's turned out much better than I expected, and
> then patterns started to show up that we can detect pretty well — the
> original problem is ShowPicture, so I think we could statically analyse
> the ShowPictures and try to infer which ones are custom windows.
>
> We should be able to
> - have a binary (or functionality of an existing one) that analyses and
>   lists the ShowPictures, along with some relevant context
> - feed that list to an agent so it decides the cases that aren't
>   obvious, but without having to start from scratch
>
> That alone would only give us the list, but wouldn't implement
> anything.
>
> I don't dare yet to assume we can invent a general solution that covers
> many cases, but we could infer a pattern from the systems we've
> converted (when we have them) and see if we can leave a combination of
> traditional scripts and recipes for AI.

And, the same day, on when, in their words, translated:

> I wouldn't launch anything for now — I'd just create the task. For now
> I'd rather keep going by hand with the cases we already know, and then
> invest in this.

So it waits in `todo` until the known cases are converted by hand.

**The plan** (Hornero, agreed with taro the same day):

1. **This task**: the inventory. For each `ShowPicture`, in maps and
   common events: where (map or common event, event, page, its trigger),
   the picture (name, size, whether it covers the screen, position,
   transparency), the pictures shown with it in the same block, and its
   surroundings in the code —a `Key Input Processing` loop with branches
   per key, a `MovePicture`/`ShowPicture` of a cursor in fixed steps, the
   variable that holds the cursor, a `ShowMessage` or `ShowChoice` next
   to it, where it is erased—. And a tentative class: a menu with a
   cursor, a message frame, a HUD, a scene, unknown. JSON for agents and
   a table to read. It knows nothing about the console, so it belongs in
   `rm2k/`, preferably as a subcommand of a tool that already walks the
   event commands rather than a new binary.
2. Run it over the nine games; an agent sorts the doubtful ones and
   leaves one report per game with the candidates, ranked first by
   whether the console loses the picture today (`degradations.json`,
   `pictures-not-drawn`) —that join is the recipe's, not the tool's—.
3. taro picks which to convert —the target is
   [`show-window-a-window-command-of-our-own`](show-window-a-window-command-of-our-own.md)—,
   and with two or three converted besides ABL's console, we see what of
   the pattern can be automated.

**Done** for this task: the tool, with tests over small fixtures and
over the two known menus —ABL's portable console and The Book of
Three's three-option menu both come out as a menu with a cursor—, its
output for the nine games in `/shared/captures/`, and step 2's reports.
Nothing is implemented in the console.
