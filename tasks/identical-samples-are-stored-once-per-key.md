---
name: "Identical samples are stored once per key"
description: "The sample bank carries the same BRR —same rate, same loop— several times, once per key that uses it: 205 KB of the whole ABL"
type: bug
status: testing
assignee: taro
agents: [Carpintero]
---

Seen by Carpintero on 2026-10-14, with the-advocate `51b4b1b2` and the
ports `d91049e`, in ABL, measuring
[`abl-the-whole-game-does-not-fit-in-8-mb`](abl-the-whole-game-does-not-fit-in-8-mb.md)
on the cartridge with every map.

**What is seen**: in the build's `audio.json`, `bank.voices` has entries
that are the same sample —name, rate, bytes and `loop_block` equal— and
the `.inc` carries a `sample_N` label for each with the same bytes:
`MMBAS40` is `sample_35` to `sample_38`, `STRNG71B` fourteen labels,
`CHH__60A` sixteen. Seventeen groups, **205,452 bytes** of repeated BRR in
the ROM of the whole game. 14 of the 309 audio packages list two samples
of one of those groups (the largest, 19 KB); whether both reach the ARAM,
and take room the music's rates need, was not looked at.

**How to see it**: build any cartridge and compare the `.byte` of the
`sample_N` labels in its `musicdata.inc`, or the entries of
`bank.voices` in its `audio.json`; `release` should show it too, at a
smaller scale.

**Fixed** in
[`the-emitter-stores-identical-data-once`](the-emitter-stores-identical-data-once.md),
on 2026-10-14: the repeats were in `release` too —23 groups, 201,465 B— and
they did take ARAM twice, in 27 of its 131 packages.
