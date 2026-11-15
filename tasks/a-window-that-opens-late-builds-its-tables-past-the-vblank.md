---
name: "A window that opens late builds its tables past the vblank"
description: "When a box's last blanked line goes up in the vblank its window opens in, msg_hdma_build ends near line 261 and flush_video on the screen's first lines"
type: bug
status: draft
agents: [Aguará]
---

Seen by Aguará on 2026-11-15, fixing
[`a-transparent-message-keeps-the-layer-above`](a-transparent-message-keeps-the-layer-above.md)
on the console, with the-advocate's branch `aguara-layer-above-console`
and the ports' of the same name.

**What was seen**, with the ROM's probe (`--vblank-probe`, the
`test-vblank` cartridge, in snes9x): on A Blurred Line's memory, map 5,
the frames where a box's last blanked line goes up —`upload_line`, 1920
bytes— in the same vblank its window opens in —`msg_opened` and
`msg_hdma_build` in `flush_video`— end `flush_video` on the screen's lines
1 to 3. 5 frames of the memory. None of the window's writes to VRAM or
CGRAM is late there: they ask the clock and wait. What runs past line 261
is the end of building the window's HDMA tables in RAM, then the
brightness —the same value— and `HDMAEN`, which is written only if the
vblank lasts.

**What it could do on the console**, not seen: the HDMA starts the frame
from tables half built, a frame of the window's bands wrong; and an FX
Pak's in-game hooks, if on, push it further.

**Why it was left**: deferring the window's opening a frame when its
tables do not fit kept the vblank, but a box of map 5 then came up later
than the `manta` scene's A press and the scene went another way, with the
frame owed to the box or not. Building the tables a frame later with the
window's pace started now is the other way that was tried, and moved the
same golden. What would do it: tables built outside the vblank, double
buffered, so that opening is pointing the channels at them.

**To reproduce**: from `abl/` in the ports, `just cartridges test-vblank`,
then the session of `tests/rpgmaker/test_vblank_budget.py` reading
`VBLANK_END_LINE` every frame: values 0 to 224 are the late ones.

**Seen since** (Aguará, 2026-11-15, from
[`an-emulator-that-shows-vblank-overruns`](an-emulator-that-shows-vblank-overruns.md)):
on the-advocate `c9860b49`, ares's and bsnes's accurate PPUs with an audit
of what they refuse with the display on count **0** accesses on the whole
memory, including the frames where `flush_video` ends on the screen's
lines: what runs late there touches no VRAM, CGRAM or OAM, as the probe
said. A wrong HDMA frame would only be seen on the screen.
