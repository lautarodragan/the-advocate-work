---
name: "Zounds: a black flash after the fade-in"
description: "Entering a map in Zounds, the fade-in ends and then the screen goes fully black for several frames; when it comes back the scene has changed —lights red to blue, the tubes in other places—, as if an automatic page's changes went through a black reload instead of happening on screen"
type: bug
status: done
assignee: taro
author: taro
agents: [Tijereta]
---

taro, on 2026-11-17, playing Zounds' build on Mesen with frame-numbered
screenshots (in the shared folder, `bug-reports-etc/bug3-zounds-black-flash/`,
copied to `captures/2026-11-17-zounds-black-flash/`), translated:

> Something similar, but it's not lag: the screen goes black for 1-2
> frames _after_ the fade-in has finished, on entering the map. Up to
> frame-35563.png it's just the normal fade-in, which works fine.
> frame-35567.png - frame-35573.png is 100% black. frame-35577 shows as it
> should again.

What the captures show (Hornero): 35567, 35569, 35571 and 35573 are fully
black (every pixel 0), so the black lasts at least 7 frames and at most 13
(35564–35576), not 1–2. And the scene is not the same on both sides: in
35563 the two lights on the back wall are red and the tubes stand at the
left-middle and the right; in 35577 the lights are blue and the tubes have
moved. So something between them changes the map —an automatic page on
entry: a tile substitution, events moved, page graphics— and the port does
it behind a black screen where RM2k does it in place.

Done means: which map and which page; what the port does on those frames
and why it blanks (`git blame`); RPG_RT's behaviour (EasyRPG's, or the
original under Wine if needed); the black removed —or, if it is the cost of
something that cannot be done otherwise, said and minimised—; a ROM test
on that entry that fails with the black frames.

## Log

### 2026-11-17, Tijereta

Started from the-advocate 865163eb and the ports 8042dc8, branches
`tijereta-black-flash` in both.

**The map is 31, `Sala de Máquinas`** (chipset 10, 20x15), found by
rendering every map's layers with `rm2k-render` and looking: its two
"lights" are windows onto the panorama, `dawn1`, and the "tubes" are the
machines, events 1-4 and 8-11, whose pages follow variables 12 and 13
that two parallel events (6 and 12) step every 8 frames: they move on
their own, in RM2k too.

**The page is event 7, `Set`, an autostart**: by variable 91 (the time of
day) a `ChangePBG` to `Zounds_DawnPanorama_01`, `…Morning…`, `…Dusk…` or
`…Night…`, then 12 and 13 to 0 and `EraseEvent`. The red-to-blue is the
panorama swap.

**What blanks**: `pano_image` in `runtime/pano.s` swaps the picture with
the screen in forced blank for the rest of the frame —the LZ2 of its
tiles, the DMA, and the ring of its tilemap built row by row—. `git blame`:
d8b7f2cff (Aguará, 2026-10-19), whose message says the swap "loses 4
frames black on Zounds' map 32 … on these maps it happens behind the
entering fade"; 8fc13507a (2026-11-16) put the tiles in LZ2, which adds
the decompression to the blank. So the black was on purpose, on the
assumption that the swap falls inside the fade.

**RPG_RT does not run it inside the fade.** EasyRPG's `Scene_Map`
(`FinishPendingTeleport2/3`): after a jump, *parallel* pages get one
pre-update before the fade-in starts, but foreground ones (autostart)
only run once the transition ends —a `ShowScreen` in the page that
jumped is an async op the interpreter waits for—. So on map 31 RM2k
shows `dawn1` through the fade-in and swaps it in place right after;
the port does the same thing and then blanks for it. On 20 and 21 the
pages are parallel.

**Measured** (snes9x, `measure.py` in my scratch, frame by frame from the
jump by map 19's door to (1, 6)): the fade ends on frame 81, 82-90 are
all black, the windows come back blue on 91. The main loop is held for
the whole of it: the tick that swaps lasts ~13 frames.

**The fix** (the-advocate `tijereta-black-flash`, `runtime/pano.s`):
with `brightness` at 0 the swap goes as before, in forced blank; with
the screen on, `pano_live` builds the ring into `LZ2_BUFFER` and
decompresses the tiles after it (when both fit: tiles up to $5000 bytes,
every picture today; otherwise ring after the tiles went up) while the
screen shows the frame before, then takes the panorama's layer off `TM`
and DMAs 512 bytes at a time, each started inside the vblank before line
256, and puts the layer back with its colours. A picture's tiles and ring
are up to 28 KB and a vblank takes about 6, and the new tiles go over
the old ones, so a swap with no visible step is not possible without
twice the VRAM. Result on map 31: no black frame; the windows show the
backdrop for 4 frames (90-93), the screen otherwise holds the frame
before for ~9; the settled frame is the old path's, pixel for pixel but
for the hero, who now gets moving earlier. Cost: in mode 3 the message
window is BG2, so a box open during a swap blinks off with it.

**Test**: `test_the_machine_room_swaps_its_panorama_with_the_screen_on` in
the ports' `tests/test_zounds.py`, with `go_to_map(..., by_frames=True)`
(by ticks it returned after the black, and passed on the old ROM). Red on
865163eb: frames 0-8 after the fade all black. Green on the branch, with
the golden `zounds-machine-room-panorama`.

**Survey**: the swaps the converter carries (`by a ChangePBG` in each
game's converter log): Zounds 20, 21 (parallel pages), 31 (autostart),
32 (both); The Frozen World 1 (the battle screen's parallel
`BackdropSetter`) and 145, `Falling 2`, whose autostart swaps to
`TheHubOnTheScreen` in the middle of a scene, with the screen on: the
same black there. ABL and the other five carry none.

**The Frozen World's map 145** with the branch (snes9x, entered at
(11, 3)): its autostart swaps to `TheHubOnTheScreen` on frame 475 after
the fade, mid-scene, with no black frame; the only black one, 497, is the
scene's own `TintScreen` to black before it jumps to 147.

**Suites**, with the branch's tools (`install-local .local-tools project
cartridge`): the-advocate's `just test`, 29 passed; ABL's `just tests`,
1665 passed and 2 skipped; the ports' `just boot`, 154 passed (all the
games built with the branch's runtime, Zounds' new test included). Not
covered by any test: the `apart` path of `pano_live` (tiles of more than
$5000 bytes, which no picture today has), a box open during a swap, and
a swap on a PAL console.

Captures, before and after side by side, in
`/shared/captures/2026-11-17-zounds-black-flash/` with a README.

**On merging**: the-advocate `tijereta-black-flash` (runtime only), the
ports `tijereta-black-flash` (the test, `go_to_map(by_frames=)` and the
golden), the book `tijereta-black-flash` (`internals/vram.md`).
Reinstall `project` and `cartridge` from the-advocate: the runtime is
taken from the checkout they were installed from. Then `just cartridges`
in the games.

## Closed (2026-11-17)

> I just tested Zounds, from the start of the ship until entering the desert of death.

By taro, with the builds of the ports `428e7c3` and the-advocate `fe5529a3`.
