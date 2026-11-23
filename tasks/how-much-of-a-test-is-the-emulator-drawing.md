---
name: "How much of a test is the emulator drawing"
description: "Many ROM tests advance hundreds of frames nobody looks at; measure how much of a suite's CPU goes to the core rendering frames, and whether skipping the render of frames no test captures would save it, without changing what the tests see"
type: research
status: doing
author: taro
assignee: Chajá
agents: [Hornero, Chajá]
---

> I would measure the emulator itself.

taro, 2026-11-22, on where the CPU goes when several agents run the
suites: of the four ideas —Rust's cache, a conversion cache, running the
suites incrementally, the emulator—, the emulator is the one to measure
first.

**What to find out**: in ABL's suite, the ports' `boot` and the test game,
how the CPU splits between the cores' emulation, their video rendering,
the Python harness (frame reading, PNG and pixel comparisons) and the
rest. Whether the libretro cores can skip the render of frames nobody
captures —snes9x's and bsnes' frame skip, a null video callback, the
harness asking for the screen only when a test reads it— and how much
that saves, measured, without moving any golden. And whether `PROCESSES`
should follow the number of agents running.

## Log

### 2026-11-22, Hornero: taken for Chajá, on a free machine

taro:

> Yes, let's wait. Let's do the measurement first, anyway.

Launched with nothing else running, after merging the six fixes of the
afternoon (the-advocate `1240ecc9`, the ports `0699267`).
