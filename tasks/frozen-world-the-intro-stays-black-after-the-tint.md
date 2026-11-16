---
name: "Frozen World: the intro stays black after the tint"
description: "At the end of map 6, after EV0005's TintScreen to black, the box \"They were dark days.\" never opens and the screen stays black with the music on; intermittent, on Mesen and bsnes, since the window's vblank writes started waiting for room"
type: bug
status: doing
assignee: Aguará
agents: [Aguará]
---

taro, on 2026-11-16, playing The Frozen World's build of the-advocate
`c9860b49` and the ports `7bbddaa`:

> The screen stays black during the intro. Before, it was playable. [...]
> The music keeps going, even though the screen stays black.

> I just tried it in bsnes. It breaks almost consistently at the end of
> Town (map 6). I think it gets to run EV0005's
> `Tint Screen: (R0,G0,B0,S100), 0.0s`. The `Show Message: They were dark
> days.` I don't get to see. But I just tried it 3 times, and 3 times it
> worked fine. I can't find the pattern.

On Mednafen 1.32.1 and Mesen 2.2.1 too. In Mesen's tilemap viewer every
layer is black.

## What Hornero read

Not reproduced in the harness: the same ROM (sha256 `dc91d95a…`), from
the title with A every 16 ticks, reaches the beach (map 11) with control
on snes9x with and without MSU-1, bsnes, and bsnes with the accurate PPU
(the audit core).

**taro's Mesen savestate**, at the black screen, is in the shared folder
(`captures/2026-11-16-fw-black/tfw-map6-black.mss`). It is a zlib stream
of `name\0 + u32 size + data` fields (`memoryManager.workRam`,
`ppu.cgram`, `ppu.vram`…); a reader is in `~/scratch/hornero/fw-black/mss/`
(`rd.py`, with the release `.sym`). What it holds:

* map 6; `msg_state` 1 (composing), `msg_upload` 1 (a line waits for
  VRAM), `msg_open` 0, `msg_line` 2, `msg_lines` 0;
* `MSG_PLACE` 5: **a window without its background** (`MSG_BARE`);
* INIDISP brightness 15, no forced blank, main screen BG1, BG2, OBJ;
  CGRAM black but entries 1-7, 210-223 and 241-247: the tint is done
  (`tint_pending` 0);
* the CPU waiting in the main loop.

**The suspect**: `upload_line` in `runtime/vblank.s`, since `7f2a0ae2`
(2026-11-15, the fix of
[`a-transparent-message-keeps-the-layer-above`](a-transparent-message-keeps-the-layer-above.md)),
starts a bare window's line only up to `LINE_LATEST_BARE` = 238 (measured
on ABL's memory in snes9x), so between 225 and 238; otherwise it waits for
the next vblank with `msg_upload` set, and the window does not open until
the line is up. If what goes before it in the vblank reaches 238 on every
frame of this map, it waits forever. That fits: intermittent, on the
accurate emulators, and new in the build taro played.

Done means: reproduced (the vblank line `upload_line` sees on map 6, on an
accurate core), the cause proven, a line that cannot wait forever, a ROM
test that fails without the fix, ABL's console fix kept.

## Log
