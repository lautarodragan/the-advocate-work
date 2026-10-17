---
name: "Sunset over Imdahl: GateStreet's messages come out without their letters"
description: "On GateStreet (map 10) the scene ran but its transparent messages were hidden behind the painted map's cells in front of the hero; then the man (PanScreen lock), the statue (a six-second flash) and the statue in spring (a big picture over the map) stopped the story"
type: bug
status: done
assignee: taro
agents: [Tijereta]
---

taro, 2026-10-16, playing the delivery of that evening (the ports
`4b2d41e`, the-advocate `759aa0ba`): the hero reaches GateStreet, can walk,
and "nothing happens". Corrected by taro the same evening: EV0002's
autostart **does** run —it was skipped through too fast—, and what is seen
is that its messages ("Boy: Hello?", "Hello?!", " ...Anyone?") come out
with almost no letters. The messages of the intro, before GateStreet, look
fine.

(The file name is the first report's; it does not change.)

## What Hornero checked, statically

`just culprits release` in `sunset-over-imdahl/` leaves out no page of
EV0002; the only page of map 10 left out is event 4's (`HEJ JAG ÄR KEX`,
touch trigger, two `PanScreen`). EV0002's page 1 ends with switch 98 OFF
and switch 1 **ON** (`ControlSwitches` operation 1 is OFF, 0 is ON), which
makes page 2 —empty, on switch 1— the active one: the autostart runs once.

## Reproduced (Tijereta)

Played from the boot with the ports' harness (`tests/games.py`, tapping A
through the intro): maps 11, 22, 21, 23 and 10, the scene on 10 runs and
ends with switch 1 on and control, at tick ~10400 in snes9x. Captures of
each message: the intro's (map 22, transparent, at the top) have their
letters; GateStreet's (transparent, at the bottom) show only a glyph or two
over the edge of a roof. Forcing `MSG_BARE` off in RAM before the second
message draws it framed, and with its letters.

### Cause 1: a transparent window under BG1's cells in front of the hero

GateStreet is a **painted map** (mode 1, the painting on BG1) and its four
pictures are drawn into it: 51,486 pixels go to BG1 priority 1, in front of
the hero. The message window is BG2. In mode 1 BG2 priority 1 is always
behind BG1 priority 1, which is why `pano_ppu` turns on channel 6 —BG1's
mask on the window's lines, from 7f62dcdb, 2026-10-05—. But
`msg_hdma_build` points that channel, like the objects' one, at
`mask_none` when the window has no background (624050fc, the day before:
"what is under the window must be seen"). So a transparent message on a
painted map with cells in front leaves its letters behind them; they show
only where those cells are transparent. The intro's maps have no picture
drawn in front, so they were fine. 7f62dcdb's message already said no test
looked at that mask.

### Cause 2: event 4, the meeting with the man, did not compile

The touch at (10,13) of map 10 is the scene that sends Lohn to the statue
—the story's next step—, and it locks the camera with `PanScreen`
operation 0 and unlocks it with operation 1. The compiler took only shift
and return (2 and 3): "used by no page of the game", which was ABL. In
Sunset seven pages use them (maps 10, 14, 34, 59 and 63, and common event
8) and in Zounds two.

### Cause 3: the statue's scene did not compile either

Past the man, the square (map 1) and the statue's alley (map 15): event
16's autostart there flashes the hero for 60 tenths, 360 frames, and the
console counts a flash in a byte, so the page was left out —as were twelve
more of Sunset's, all the same flash—. The mist of the square stayed over
the screen and nothing moved the story.

### Cause 4: the statue in spring under a big picture

With the statue's scene compiling, the arrival at map 13 was black: the
big picture 'TheStatueWarmShadows' (map 15's) was up over the painting,
which already had it drawn in. `map_pictures` decides per page map and
name whether every show is drawn into its map, and reads a page in a row:
the portal of map 15 (event 4, page 2) has a choice whose spring branch
teleports to 13 and shows pictures 2 and 3, and whose summer branch then
moves pictures 2 and 3 to the top of the screen before its own teleport —
read in a row, the spring pictures moved, and so they were not drawn into
13 for map 15's pages, which left all of them big pictures.

## What was done (branch `tijereta-gatestreet` in the-advocate and the ports)

* `bbbd2692` the-advocate: on a painted map, a window without its
  background trades BG1 and BG2 on its lines (`msg_swap_build`).
* `f44d4dd4`: `PanScreen` lock and unlock compile, and the runtime keeps
  the camera still while locked and closes the gap after an unlock as
  RM2k does.
* `a2141de2`: a flash past 255 frames fades out in 255, noted as
  `flash-shortened`; the wait stays whole.
* `06dcbf41`: map_pictures reads each branch from where the branching
  command was.
* The book (`tijereta-gatestreet`, `4ff917c`): the painted map's window in
  `internals/vram.md` and in the divergence of the window without a
  background; two new divergences, `a-long-flash-fades-out-sooner` and
  `the-camera-lock-does-not-travel-in-the-save`; and a Known issues line
  for the draft `sunset-nine-pages-still-left-out`, the nine pages Sunset
  still leaves out (two autostarts on the story's way, not played).
* The ports: `tests/test_sunset_gatestreet.py`, from the boot through the
  boy's scene (golden of "Boy: Hello?"), the man (golden of a message, and
  the camera still while the hero walks) and the statue (map 13, switch
  2). Red with the main tools: the golden differs in 228 pixels, the
  letters.

## What was run

On the branch, before merging main: `just rust-test`, `just test`, `just
test-game` (FluidR3), ABL's `just tests` with the branch's tools (1563
passed, 2 skipped, no golden moved; `abl.sfc` sha1 `321974d9…`, built
before the map_pictures commit, which ABL does not use) and `just boot` at
the ports' root, whole (47 passed, the new test among them). After merging
main into each branch: `just rust-test`, `just test`, `just test-game`, and
`test_sunset_gatestreet.py` and `test_painted.py`. Not compared against the
original under Wine. Captures in `/shared/captures/2026-10-16-sunset-gatestreet/`.

What no test covers: the message trade on a painted map under a big
picture or a face; the camera's gap closing after an unlock while the hero
walks back (Sunset unlocks before giving control, or teleports); a save
made with the camera locked (not saved, see the divergence).

## To install when merging

`just install project cartridge events mapdata convert` from
`~/the-advocate`: the runtime changed (so the cartridges' tools), the
compiler, the header's emission and map_pictures.
