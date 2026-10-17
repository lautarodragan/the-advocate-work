---
name: "The first map shows for a few frames before the title"
description: "Booting Dooms 2 and Desert Nightmare, the start map is drawn for a few frames before the title screen; The Book of Three plays its first map's music for about a second; the original does not, and ABL seems not to"
type: bug
status: testing
assignee: taro
agents: [Chajá]
---

taro, 2026-10-16, on the delivery of that evening (the ports `4b2d41e`,
the-advocate `759aa0ba`), with the original Dooms 2 running under Wine to
compare: the SNES ROM of Dooms 2 shows the start map for a few frames
before the title screen, which the original does not. Desert Nightmare
too. The Book of Three probably the same, but nothing is seen —its first
map starts in black— and its first map's music is heard for about a
second before the title. taro has not seen it in ABL, and wonders whether
it is for the same reason.

## Chajá, 2026-10-16

**Reproduced** in snes9x, frame by frame from the reset, on the-advocate
`f4709d0b` and the ports `66ed09c`: Dooms 2 shows its first map from frame
12 to 101 and Desert Nightmare from 11 to 45; El Dorado and Sunset a few
frames too. The Book of Three's first map is black, and its song (38)
starts on frame 31, before the title on 46. ABL does exactly the same,
unseen and unheard: its first map is black and `SONG_BOOT` is $FF.

**Cause**: `runtime/boot.s` always enters the first map, runs
`flush_video` —which ends writing `brightness` to INIDISP, turning the
screen on—, turns the screen on, uploads the driver and runs `music_boot`,
which starts `SONG_BOOT`; only after BOOT_FRAMES does it go to
`title_screen`. That order comes from `c5f5b4e0` (2026-09-10), which put
the title after the boot so that a ROM without one reaches the loop on the
usual frame; keeping the map hidden was never done. It is a birth defect,
not a regression. The title, on leaving, already does `enter_map`,
`flush_video` and `music_boot` itself.

**Fix** (the-advocate, `chaja-title-first`): with a title, the boot skips
`flush_video` and the screen-on —forced blank until `title_upload`— and
leaves `music_off` at 1 instead of `music_boot`. Without a title, the same
path as before.

**Test** (ports, `chaja-title-first`): `tests/test_title_first.py`, in
`just boot`: from the reset until BOOT_FRAMES plus a second, each lit pixel
has to be the settled title's, and nothing sounds and `music_off` is set,
unless the title's own song is the one on. Red on five games at the base
(Book of Three, Desert Nightmare and Dooms 2 by the music; El Dorado and
Sunset by a map frame), green on the eight with the fix.

Seen on the way and not a bug of this: Desert Nightmare's title song
(`music13`) has only an MSU-1 track, so without MSU-1 the title is silent.

**Verified** on the merged tree (the-advocate `9d9325e9`, the ports
`f1b2f72`), with the branch's tools: `just rust-test`, `just test`, `just
test-game` (FluidR3), ABL's `just tests` —green, no golden moved: ABL's
boot was already black and silent— and `just boot`, whole, with the new
test green on the eight games. Leaving the title by "New Game" is what
`test_boot.py` and ABL's title cases already play. Not looked at on
hardware: taro sees it on the next delivery. Captures in
`/shared/captures/2026-10-16-title-first/`.

**When merging**: the runtime only (`runtime/boot.s`); no crate changed,
nothing to reinstall for this.
