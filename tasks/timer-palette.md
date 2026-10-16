---
name: "The timer's palette"
description: "Reserve it only while the timer is running"
type: refactor
status: wishlist
---

# What

Timer improvement: reserve the palette only when the timer is running, free it when it isn't.

# Status

Noted, not started.

# Why

Today the converter reserves the digits' palette on **every** map of the
cartridge when the timer is set, because in RM2k the timer is global: once
started it stays visible on any map you go to, so statically it is not known
where it is needed.

What it cost, measured on 2026-09-20 on `abl`: **map 18 was left without
raindrops** for lack of a free palette after reserving the timer's. **Today it
costs nothing there**: since the Auditorium's audience was baked into its
ChipSet, map 18 has palettes to spare and it rains. The other seven maps
without drops —2, 3, 8, 9, 10, 13 and 17— are so for other reasons, so today
this gives the rain back to none of them; the converter says so when building
`abl`, with one warning per map.

It is work for the ROM, not the converter: reserve and free when starting and
stopping the timer, with what that implies for what is already drawn with that
palette.

**Checked on 2026-10-16 (Mulita)**, at the-advocate 759aa0ba: the converter no longer gives the digits to every map. A walk hands
them to the maps the timer can reach by teleports from where it starts
(`[graphics] timer_never_runs_in` and, since `16c9abfd`, `timer_stays_in`
cut it), and since `7b6bc482` a map with no free sprite palette lends the
timer the nearest one instead of stopping. Reserving and freeing at run
time is still not done; what it would give back today was not measured.
