---
name: "ShowWindow: the full version"
description: "What the proof of concept left: windows beside an open message, the MovePicture fades, a window that follows the camera, the System's cursor, text positions inside a line, and the image-to-text prompt run on a real plan"
type: feature
status: wishlist
author: hornero
agents: [Mulita]
---

What [`show-window-a-window-command-of-our-own`](show-window-a-window-command-of-our-own.md)
left for a full version, written down when it was closed on 2026-11-20
so that it is not buried with it.

**Done since the proof of concept**, all by Mulita for Desert Nightmare's
menu, in `runtime/show_window.s` and `windows.rs` of the event compiler:

- the keys, notes and maps screens, with each window id's tiles the most
  one of its windows takes (`cec66dfd`);
- **a big picture covers the windows under its number**, as a picture
  covers the lower ones in RM2k: `OP_WINDOW_COVER` (0x5B), emitted after
  every big picture's show and erase (`810d483c`, `6c3b09e1`);
- **a change shows on one frame**: a window's new text is composed into
  tiles the screen does not show (`sw_place`), only the rows a change
  touched are composed again, and they go up with the HDMA's tables in
  one vblank (`sw_commit`) —
  [`desert-nightmare-the-menu-s-boxes-update-in-part`](desert-nightmare-the-menu-s-boxes-update-in-part.md),
  `694bacec`—.

What is left of the full version:

- **Windows beside an open message**: today they go away while a box is
  up and come back when it closes (a Known issue of Desert Nightmare's
  page). Stage two, as objects, the way the gold window is drawn.
- **The fades the menu's `MovePicture`s ask for**: the windows appear at
  once.
- **A window that follows a moving camera**: what the window copies of
  the layer above is stale until the camera is back on the 8-pixel grid.
- **The System's cursor** rather than a `>`.
- **A page's own text positions** (`\x[n]`), so that a grid can be one
  window.
- **The image-to-text prompt run on a real 20 USD plan**: it was only
  counted (about 15,000 input tokens).

And the smaller limits the two tasks left written, which a full version
meets on another game: nothing beside a window on a map whose BG2 is its
panorama (`PANO_ON` 3); a System whose background is a gradient drawn
flat; a second non-zero text colour among the windows up going to the
window's nearest; `SW_MAP`, the whole screen's 1,792 bytes of far RAM,
where the span's rows would do; and nothing played on real hardware.

## Log

### 2026-11-22, Chajá: what is done and what is left

Checked at the-advocate `0ae40e0a` and the ports `89f77b4`, against
`runtime/show_window.s` (its header and `git log`), the declaration in
`rm2k-snes/bytecode/src/events.rs` (`OP_WINDOW` 0x59, `OP_WINDOW_ERASE`
0x5A, `OP_WINDOW_COVER` 0x5B) and Desert Nightmare's
`patches/manual/` and `windows/`. Added above what was done after the
list was written —the cover opcode and the one-frame changes— and the
smaller limits. The six items still stand:

- a box still takes the windows off the screen (`SW_HIDE`), and Desert
  Nightmare's page still has it in Known issues;
- no fade: nothing in `show_window.s` or `windows.rs` reads a
  `MovePicture`;
- the layer beside a window is copied again only once the camera is back
  on the 8-pixel grid (`SW_CAM`), as written;
- the cursor is still text: `Inventar_Cursor1 = ['\c[1]>']` in
  `windows/menu.toml`;
- `windows.rs` takes `\c[n]` and the message escapes, not `\x[n]`;
- `windows/prompt.md` still says the cost was "counted, not run on such
  a plan".
