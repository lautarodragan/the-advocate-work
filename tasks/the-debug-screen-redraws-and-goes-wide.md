---
name: "The debug screen: a black block while scrolling, and the whole names in high resolution"
description: "Scrolling the debug screen redraws the left list when it does not need to and a black block covers part of it for a moment; and taro wants the screen in the console's 512-wide mode, so the switches' names fit whole"
type: feature
status: doing
assignee: Hurón
agents: [Hurón]
---

taro, on 2026-10-20, in their words, translated, after playing
[`a-debug-screen-in-the-pause-menu`](a-debug-screen-in-the-pause-menu.md):

> Regarding the debug menu: IT WORKS PERFECTLY! and it's great.
>
> Two small changes I'd like:
> - When scrolling, the left menu seems to redraw even when it doesn't
>   need to, and a black square covers part of it for a second
> - I'd like to try rendering this screen in the SNES mode that allows
>   double horizontal resolution. It wouldn't change anything about the
>   text, it would simply use the extra space to render the full names of
>   switches, which sometimes don't fit. It doesn't matter that it looks
>   odd from the text being squeezed to 50% horizontally. I'd apply it to
>   everything equally, even if the windows' borders get a bit deformed,
>   to keep the change simple.

Their captures are in `/shared/captures/debug-menu-report/`:
`scroll-black-rectangle-0.png` and `-1.png` (the left list's lower rows
black while the page wraps), `switch-0006-name-too-long.png` (names cut:
"LBDidn'tGoThisW", "NVGetToWorkDO", "RunningIdolEsca").

**Done**: scrolling within a page does not redraw the left list, and
changing page leaves no black block; the debug screen runs in the
512-wide mode (mode 5 or 6) with the same glyphs at half width, and the
names come out whole —or as long as the wider window allows—, windows
deformed as taro accepts. Goldens red before.
