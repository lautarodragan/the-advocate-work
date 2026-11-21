---
name: "The ports' boot tests and the delivery take too long"
description: "`just boot` runs its 183 tests in one process (22 min) while ABL's 1723 take under 5 with xdist; each delivery rewrites ~10 GB of unchanged MSU-1 tracks on the NAS and builds the games one after the other"
type: feature
status: doing
assignee: Calandria
author: taro
agents: [Calandria]
---

taro, on 2026-11-21, translated:

> Is there any optimisation left we could apply to the test suite and/or
> the delivery of the games? I remember we already optimised the test
> suite several times. [...] I don't know if there is anything
> significant left to gain without doing something very hacky... or
> buying more hardware 😛

What was seen the same day, with the machine's 16 threads:

- **`just boot`** (the ports' root) is a plain `pytest`, no `-n`: 183
  tests in 22 min 30 s, against ABL's 1723 in 4 min 39 s with xdist. It
  is not parallel because each test builds its game's cartridge the first
  time it needs it (`build` in `tests/games.py`), and two workers would
  build the same one at once. ABL solved it by building first (`tests:
  _xdist cartridges`).
- **`just deliver`** (the ports' root) builds the eight games one after
  the other, and for each one deletes and copies all its `.pcm` tracks to
  the NAS: about 10 GB a delivery (ABL's own `deliver`, 2.5 GB more),
  when the tracks barely change between deliveries.

taro, on the second, the same day:

> if it's worth it, we could mount a `/shared2` (or like `/builds`,
> better) mounted on the host's disk, without going through the network.
> It stays on the same machine, it's an NVMe SSD, etc. It's probably the
> easiest. I like to minimise the writes on the SSD, but we're not
> writing 10gb a minute either... nor an hour...

The mount is the host's —taro's `box`—; what this task gives it is the
measurement, so that the choice is made with numbers.
