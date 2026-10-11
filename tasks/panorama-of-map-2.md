---
name: "The panorama of map 2"
description: "The little dots over blue that scroll diagonally"
type: feature
status: done
---

# What

The panorama of map 2: the little dots over blue that scroll diagonally
on their own, behind the big screen.

# Status

Noted down, not started, and **not a priority**.

# Why

It is missed when the big screen turns on. What it costs is a
layer: **mode 3 has two background layers and both are taken** —the map, and
the layer on top with the window—, so a panorama asks for a third one or
mode 1, which the conversion does not use.

From that follows that **`ChangePBG` is accepted and dropped**: if there is no panorama, there is
nothing to change on it, and it is dropped at compile time, so nothing is left half-done.
It appears **only once in the whole game** —seven commands on the page of the ride
on the Hover-Tram, where the evening landscape runs behind and changes
speed when starting and when braking— and without it that page does not compile. So what
this buys is **the whole ride**, and what it costs today is that the
windows look still.

# Done

On 2026-10-05, with all the panoramas —`los-panoramas.md`—: map 2 goes
flattened, with the big screen on BG2, and `ChangePBG` compiles to
`OP_PANORAMA`.
