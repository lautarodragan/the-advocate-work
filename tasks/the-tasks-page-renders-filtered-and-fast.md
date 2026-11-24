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
