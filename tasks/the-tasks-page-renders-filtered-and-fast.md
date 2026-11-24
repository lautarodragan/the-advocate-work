---
name: "The tasks page renders filtered, and fast"
description: "The tasks page is one ~5 MB HTML with every task, and its filter buttons appear only once the script has processed all of them: ~2 s invisible on a PC, longer on a phone, where it sometimes freezes; the first render should come already filtered from the static build, and the page lighter"
type: optimization
status: done
assignee: taro
agents: [huron]
author: taro
links:
  found: [a-placeholder-in-angle-brackets-vanishes-from-the-page]
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

### 2026-11-24, Hurón: the bodies are HTML only once opened

What was left was the parser: 113,769 elements, nine in ten of them
inside the tasks' bodies, built in tasks of up to 515 ms at 4x (520 at
6x) during which nothing answers. Two ways out were measured on a copy
of the page:

- the bodies in `<template>`: the same 1.3 s to `DOMContentLoaded` and
  the same 506 ms tasks at 4x, because a template's content is still
  parsed into elements;
- the bodies as the text of a `<script type="text/x-task-body">`, which
  the browser does not run and the tokenizer skims as text: 747 ms, and
  no task over 60 ms.

The second one went in. The build writes each body there (guarding a
`<script` or `</script` in it, which cmark-gfm already escapes in what a
task writes), and the page's script makes it a `<div class="body">` the
first time the task is opened (`toggle`). The search reads an unopened
body from that text without its tags and comments, with cmark-gfm's four
entities decoded.

What this costs, and why it is a commit of its own so it can be dropped:

- **without a script, the page shows every task's summary but no
  body** (GitHub has the files); until now it read whole;
- **the browser's own find (Ctrl+F) no longer finds text inside a closed
  task**: Chromium searched closed `<details>` and opened them; the
  page's own search box still searches every body.

Checked against the old page —built from the same tasks at `e170752`—
with the same side-by-side script, now with 42 steps: on top of the
ones before, 14 searches (`msu`, `code`, `&`, `<`, `"`, `it's`, `href`,
`class`, `found-in`, `2026-11`, `copy`, `->`, `a b`, `é`), one task
opened from its summary and 300 opened at once, comparing each open
body's HTML and text lengths. All the same. The first try was not:
cmark-gfm writes `<!-- raw HTML omitted -->` where a task wrote
`<who>`, and guarding `<!--` had made that comment visible text.

#### Before and after

Median of three loads, served gzipped from localhost; "buttons" is when
the status buttons are painted, "interactive" the end of the last long
task, "longest" the longest task (what a tap may wait for).

| | before | filtered build | + lazy bodies |
|---|---|---|---|
| bytes | 7,292,772 | 7,306,382 | 7,337,013 |
| gzip -6 | 2,144,901 | 2,146,625 | 2,149,158 |
| elements | 113,722 | 113,769 | 11,077 |
| desktop: buttons | 464 ms | 144 ms | 148 ms |
| desktop: interactive | 435 ms | 407 ms | 223 ms |
| CPU 4x: buttons | 1728 ms | 212 ms | 224 ms |
| CPU 4x: interactive | 1642 ms | 1314 ms | 616 ms |
| CPU 4x: longest task | 513 ms | 515 ms | 58 ms |
| CPU 4x: to `done` | 334 ms | 79 ms | 7 ms |
| CPU 4x: to `all` | 448 ms | 12 ms | 15 ms |
| CPU 4x: first search | 113 ms | 15 ms | 20 ms |
| CPU 4x: opening the biggest task | 379 ms | — | 33 ms |
| CPU 6x: buttons | 2812 ms | 252 ms | 240 ms |
| CPU 6x: interactive | 2692 ms | 1752 ms | 835 ms |
| CPU 6x: longest task | 519 ms | 520 ms | 76 ms |
| CPU 4x, 9 Mbps: buttons | 2400 ms | 264 ms | 236 ms |
| CPU 4x, 9 Mbps: interactive | 2476 ms | 2152 ms | 2141 ms |

What is intrinsic to the number of tasks: the bytes. The tasks' Markdown
alone is 5.36 MB, 1.96 MB gzipped, against the page's 2.15 MB, so markup
is not what weighs and trimming it would not show; at 9 Mbps the
download alone is about two seconds, and "interactive" waits for it
(the buttons and the default list do not). Brotli, if the host serves
it, makes it 1.53 MB. On the CPU side, what is left at 4x is the
tokenizer going through 7.3 MB as text, about 400 ms, in short tasks.

#### What is not done, and when it would be

`done` and `cancelled` as a second file, fetched after the first paint:
5.3 MB of the 7.3, so the first download would be a quarter. It is not
needed for the first paint any more —the buttons and the default list
come in the first bytes— and the long tasks are gone; it would only
shorten the wait between the first paint and a filter answering, which
matters on a slow network more than on a slow phone. It is a second
file to build and publish, and a page that is incomplete until it
arrives (the search, a `#hash` to a done task, the `done` count's list).
Worth it only if taro still sees the phone wait after this.

### 2026-11-24, Hurón: to testing

For taro: the page as built from this branch is in
`/shared/captures/2026-11-24-tasks-page/index.html`, with the one from
before beside it as `before.html` and the tasks' images, to open both on
the phone from the NAS. What to look at: the buttons and the `doing`
list in the first paint and nothing moving after; a tap on a filter
while the page is still loading; opening a task, and a long one; the
search box. Nothing to install when merging: it is the Pages workflow,
with the same nushell and cmark-gfm.

Not covered by anything that runs: Safari. Everything was measured in
headless Chromium with its CPU throttled, which is not an iPhone. The
newest thing the script uses is `??=`, which Safari has had since
version 14, in 2020; the `toggle` event and `:scope`, older.

Found and not fixed:
[a placeholder in angle brackets vanishes from the page](a-placeholder-in-angle-brackets-vanishes-from-the-page.md).

### 2026-11-24, Hornero: the search highlights its matches

> The browser's native search is not important for the tasks, but the
> question made me think of something: the native search highlights the
> results, ours does not. It is a small feature I like. What I do not
> love is having to add spans, etc. I would love to try the Highlight
> API. Could the search's matches be highlighted with the highlight API?

(taro, 2026-11-24)

Done in `site/index.html` with the CSS Custom Highlight API: a
`Highlight` registered as `search`, one `StaticRange` per match over the
shown tasks' text —summaries and opened bodies—, and a body painted when
it opens; `::highlight(search)` paints it, with a colour for each theme.
No element is added to the text. Without the API the search filters as
before.

The ranges are `StaticRange`s on purpose: with `Range`s, which are live,
a search's thousands stayed in the browser's books until collected, and
the filters' next pass went from 18 ms to 1.5 s at 4x CPU. Measured in
headless Chromium, all 893 tasks shown, 4x CPU: painting `the` (4,385
matches) costs ~60 ms, a one-letter search (22,376) ~100 ms; a search's
filter pass with painting, 25 ms against 18 ms without. Not tried in
Safari: the API is there since 17.2.

### 2026-11-24, Hornero: the search narrows what it already found

> Can we optimise the incremental filtering? If I add characters to the
> search, the new results can only be a subset of the current ones. That
> holds for the Ranges too, to some extent (if they are relative to the
> parent).

(taro, 2026-11-24)

Done in `site/index.html`: a search that only grows, with the same
filters, looks only at the tasks the last pass showed; the counts of
types, games and authors, which depend only on the state, are redone only
when it changes; and each shown task keeps its matches as text node,
offset and the node's lowercased text, so a longer search checks the old
matches —every new one starts where an old one did— and walks no text.
For that the matches are found overlapping ("aab" in "aaab" starts inside
the first "aa"); painted, overlapping ranges are one mark. A body opened
during a search adds its matches to its task's.

Checked in headless Chromium against a fresh page searching the same
text at once, with a task opened, typing `converter`, `the stage` and
`aab` key by key with every task shown: the same tasks, the same marks
and the same counts at all 21 steps. Per key at 4x CPU: the first letter
140-250 ms (it reads each task's text the first time, as before), then
`converter` 18, 8, 20, 6, 6, 9, 8, 6 ms; before this, a key with all 893
tasks shown took 60-75 ms.

### 2026-11-24, Hornero: the search starts at three characters

> Ah, and not filter if the text has fewer than 3 characters?

(taro, 2026-11-24)

Done: `query()` gives nothing below three characters, so one or two
neither filter nor paint, and the third is the first full pass. The same
key-by-key check against a fresh page: no difference at any step; per
key at 4x CPU, `converter` 2, 3, 336 (the first read of every task's
text, which moved to the third key), then 12, 8, 10, 9, 9, 7 ms.
