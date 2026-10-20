---
name: "Zounds: the ship's transparent messages come out broken"
description: "On the ship (map 21), the boss's speech about Unamë's donation is shown in transparent boxes in the middle of the screen, and the text comes out torn in bands over the map; the choice after it too"
type: bug
status: doing
assignee: Chajá
agents: [Chajá]
---

taro, on 2026-10-20, in their words, translated, with three captures
(in `/shared/captures/2026-10-20-zounds-ship-messages/`):

> These texts come out quite broken. They are on the ship, before
> reaching the desert for the first time, when the boss tells the crew
> about Uname's "donation". I don't know if they have a ShowPicture and
> it ends up like that, or if it's the System, or because it tries to
> use a transparency, or what.
>
> I wouldn't complicate things much if VRAM is limited — I'd look for
> the cheap options.

**Read in the dump** (Hornero): map 21, event 9 "Kazar", page 1, sets
`MessageOptions` to a transparent window in the middle
(`10120 [1, 1, 0, 0]`) before Unamë's "Lo mato. Lo mato. ¿Lo mato?" and
its `ShowChoice`, and back to an opaque one at the bottom
(`[0, 2, 1, 0]`) after. No `ShowPicture` there. The converter says of
map 21: "the message arrow stays in the window's cells, and a window
without its background keeps the layer above off its bottom row: its 8
sprite palettes are taken", and it has five panoramas.

**Done**: the cause found; the cheapest fix that reads well —from
fixing the transparent window on this map, to, if that costs VRAM or
more than it is worth, a port patch of map 21 that makes these boxes
opaque—, with taro's preference for cheap noted. A golden of one of
these boxes red before.

## The cause (Chajá, 2026-10-20)

Reproduced with a case, `zounds/cases/ship-transparent-messages.json` in
the ports, which jumps to map 21 and runs the page's boxes from the
`MessageOptions [1, 1, 0, 0]` to Kazar's "¡No! ¡No lo mates!": the same
bands as taro's captures, on all four boxes.

**It is the face, not the panorama, the System or the arrow.** A box's
face takes its fifteen colours in BG palette 1, written by HDMA on the
window's first lines and put back after the face ends: over a window with
its background no pixel of the map is on those lines. Without the
background the map is, and map 21's background —8 bits, BG1— draws its
floor and walls with entries 17 to 31, so on the window's 80 lines the
whole width of the map takes the face's colours: the grey floor goes brown
and green, the corridor pink. It was already written down as a divergence
("What faces do not model" in the book: "A face in a window without its
background recolours the map under it"); how much it shows depends on how
much the map uses those entries, and on the ship it is everything. The
window's own cells are fine: dumped from VRAM, the bare plane's text tiles
are blank and its empty cells are tile 0.

The face itself came out wrong too, over the bare window: the lower half
of Unamë's and Kazar's washed in pale blue. It is gone with the fix below,
and not followed further.

How many boxes have a face in a window without its background, walking
each page in order (a script over the dumps, 2026-10-20): Zounds 34, on
maps 13, 21 (16), 24, 109, 144 and 150; Vampires Dawn 123; Desert
Nightmare 15; the other five games none.

## The fix: a box with a face keeps its background (Chajá, 2026-10-20)

Of the three ways —the map 21 fork that turns its `MessageOptions`
opaque, the face drawn without its palette, or the runtime giving the
window its background whenever the box has a face— the third: it costs no
VRAM, no CGRAM and a dozen bytes of `FAR3`, and it fixes the 34 boxes of
Zounds and the 138 of Vampires Dawn and Desert Nightmare at once, where
the fork fixes 16 and has to follow every change taro makes to map 21.
`msg_face_begin` (`runtime/message_face.s` in the-advocate), which runs
when a box opens right after `msg_place` decided the window, takes
`MSG_BARE` off `MSG_PLACE` when the box has a face; the composer and
`msg_hdma_build` read it after. A bare box without a face is still bare.
What it gives up against RM2k: those boxes show the window's blue instead
of the map. Nothing else in the runtime changed; the message window's
composer —where Tijereta works on `\c` and `\s`— is not touched.

**The test**: `tests/test_zounds_ship_messages.py` in the ports, with the
case: four boxes, each must have a face and no bare bit, and two goldens,
Unamë's (face left) and Kazar's (face right). Red before the fix ("box 0
has a face and no background"), green after.
