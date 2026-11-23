---
name: "The console, seen and driven from here"
description: "A USB capture card for the console's picture and sound, next to the FX Pak's USB, so tests on the real console can be loaded, watched and read from the container without taro; buttons would need a controller emulator on the controller port"
type: feature
status: wishlist
author: taro
---

> With a capture card, could you control the FX Pak and see what comes out
> on the TV at the same time?

> I like that plan. I have a capture card somewhere, but I can't find it.
> It'll turn up.

taro, 2026-11-23, while chasing
[`a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak`](a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak.md)
over the FX Pak's USB (see "Where this runs" in `AGENTS.md`).

**What it would take**:

* The capture card as a UVC device (`/dev/videoN`), given to taro's
  session alone with a udev `uaccess` rule like the FX Pak's, and to the
  container with `--device`; frames and sound with `ffmpeg`.
* What it is good for: whether something looks or sounds right, timing,
  blinks and torn frames on the real console. Not goldens: the signal is
  analog and the card scales and colours it, so nothing is exact to the
  pixel.
* Buttons: usb2snes cannot press them. A microcontroller on the controller
  port emulating a pad would; until then, test ROMs run on their own.
