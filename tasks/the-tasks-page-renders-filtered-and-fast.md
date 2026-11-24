---
name: "The tasks page renders filtered, and fast"
description: "The tasks page is one ~5 MB HTML with every task, and its filter buttons appear only once the script has processed all of them: ~2 s invisible on a PC, longer on a phone, where it sometimes freezes; the first render should come already filtered from the static build, and the page lighter"
type: optimization
status: doing
assignee: huron
author: taro
---

**Why**: `nu tasks/tasks.nu html` builds a single `index.html` from
`tasks/` and `site/index.html` (the Pages workflow publishes it). With
nearly nine hundred tasks it weighs about 5 MB, and the filter buttons
show up only after the client-side script has gone through every task.

> As there are many, the page as a whole takes quite a while to load, and
> the filter buttons load only once all the tasks have been processed.
> That means they stay invisible for ~2 s on a refresh on the PC, and it
> can take longer on mobile.
>
> What occurs to me: that the list already comes filtered in the static
> page, for its first render, so we can show all the buttons immediately.
> The client-side JavaScript will take care of whatever is needed for the
> dynamic part, but we remove the layout shift (mostly).
>
> And if you think of something to optimise the page a little, even
> better. On mobile it sometimes freezes. I have a relatively modern
> iPhone (it is several years old, but it was top of the range — it
> should run fine). If it is intrinsic to the number of tasks we have,
> then I would not worry. Perhaps the alternative would be loading the
> tasks that are in `done` asynchronously, which should not be much more
> complex, but requires building at least 2 files statically instead of
> one. But I would start by seeing whether it is feasible to optimise it a
> little without splitting the load.

(taro, 2026-11-24)

**What is asked**:

1. **The first render filtered, from the static build**: the default
   filter's list and all the buttons in the HTML as served, so nothing
   shifts when the script arrives; the script takes over for what is
   dynamic.
2. **Measured, then optimised without splitting the load**: where the
   time goes —bytes, parsing, the script's work, layout of what is
   hidden— and what removes it. Only if that is not enough, the `done`
   tasks loaded asynchronously as a second file.
3. **Measured limit**: before and after, the page's size and the time to
   first render and to interactive, on desktop and with a phone's CPU
   throttled.

## Log

### 2026-11-24, Hornero: written

Nothing done yet. Hurón takes it.

### 2026-11-24, Hurón: taken, and the page measured as it is

At `e170752`, 889 tasks. The page built by `nu tasks/tasks.nu html`
weighs 7,292,772 bytes, 2,144,901 gzipped (`gzip -6`); the tasks'
Markdown alone is 5,357,396 bytes and 1,957,876 gzipped, so nine tenths
of what travels is the tasks' own text, and `done` is 5.2 MB of the 7.3.
The DOM is 113,722 elements, 50,362 of them `<code>`.

Measured with headless Chromium over the DevTools protocol (a throwaway
script, not committed), the page served gzipped from localhost, a
412x900 window, median of three loads. "Buttons" is when the status
buttons are painted (Element Timing); "interactive", the end of the last
long task after the script.

| | first paint | buttons | interactive | to `done` | to `all` | search |
|---|---|---|---|---|---|---|
| desktop | 160 ms | 464 ms | 435 ms | 78 ms | 108 ms | 25 ms |
| CPU 4x | 216 ms | 1728 ms | 1642 ms | 334 ms | 448 ms | 113 ms |
| CPU 4x, 9 Mbps | 284 ms | 2400 ms | 2476 ms | 299 ms | 448 ms | 116 ms |

Where it goes, at 4x: of 1.7 s of main thread, the script is 90 ms,
layout 214 and style 136; the rest is parsing the 7.3 MB. The buttons
wait for all of it because the script that makes them is at the end of
the page, and until then every task of every state is laid out. The
first paint is the tasks of every state, which the script then hides:
that is the shift taro sees.

### 2026-11-24, Hurón: the first render comes filtered from the build

`nu tasks/tasks.nu html` writes the four rows of filter buttons —with
their counts, pressed and dimmed as the script used to leave them— and
marks `hidden` every task and section that is not in the default state;
the script goes before the list instead of after it, finds the buttons,
answers clicks from the first paint and waits for `DOMContentLoaded`
only for what needs every task. A URL with another filter, or a hash,
keeps the list and the state-dependent counts out of sight
(`.pending`) until the script has picked, so the default's list is never
shown and then swapped. Without a script, a `noscript` rule shows every
task, as before.

Along the way, the script's per-task work: each task's attributes are
read once into an object; the counts are one pass instead of one filter
per button; a task's `hidden` is written only when it changes; the
lowercased text for the search is read the first time and kept; and only
the selected tasks' select buttons are touched, not all of them.

Checked against the old page with a throwaway script over the DevTools
protocol, both loaded side by side: the buttons (labels, counts,
pressed, dimmed), the tasks and sections shown, the URL, the selection
bar and the pressed select buttons are the same on the first load —the
new page's buttons with its script off too—, after each of 25 steps
(every state, every row of filters combined, a search, a select, a hash
change, clear), for five URLs with filters or a hash, and with a stored
selection that names a task that is gone. One difference turned up and
was fixed: nushell's `sort-by --reverse` turns ties around too, so
`docs` and `test` came out swapped.

| | first paint | buttons | interactive | to `done` | to `all` | search |
|---|---|---|---|---|---|---|
| desktop | 144 ms | 144 ms | 407 ms | 19 ms | 16 ms | 10 ms |
| CPU 4x | 212 ms | 212 ms | 1314 ms | 79 ms | 12 ms | 15 ms |
| CPU 4x, 9 Mbps | 264 ms | 264 ms | 2152 ms | 72 ms | 14 ms | 7 ms |

The buttons are now in the first paint. What is left of "interactive" is
the parser going through the 7.3 MB, and at 4x it does so in tasks of up
to 515 ms, during which a tap waits: a freeze, on a phone.
