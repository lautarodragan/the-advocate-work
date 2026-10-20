---
name: "Zounds: four of its .wav songs have no MIDI, and are silent without MSU-1"
description: "The battle and victory themes, the mountains' (map 33) and the small caves' (89, 91, 92, 177) are recordings; no MIDI of them was found, and three of them were not even identified"
type: bug
status: wishlist
---

Seen by Aguará on 2026-10-16, looking for MIDIs of Zounds' five `.wav`
songs for the cartridge without MSU-1
([`zounds-wav-music-through-msu-1`](zounds-wav-music-through-msu-1.md)),
with the zounds clone at `ff8cf97`. Since that day a song can have a MIDI
next to its `.wav` under the same name, and the SPC700 plays the MIDI while
the MSU-1 track keeps coming from the `.wav`; the title theme has one.
These four do not, and **without MSU-1 they are silent**: the battles, the
victory screen and maps 33, 89, 91, 92 and 177 play nothing.

* `18 - Desert flower` (map 33, Mountains): Tales of Symphonia, disc 1,
  track 18, Triet's town theme (3:58, the `.wav` is 3:57.7). Searched by
  name and by "Triet" on VGMusic (GameCube and PS2 pages), The Midi Shrine
  (its Tales of Symphonia page has 49 MIDIs, not this one) and BitMidi:
  none.
* `04 - Cavern` (maps 89, 91, 92, 177): **not identified**. Not Tales of
  Symphonia (its disc 1 track 4 is "Lloyd"), and not Super Mario 64's
  soundtrack (track 4 is "Opening"), though the fourteen `.wav` removed the
  same day mixed both.
* `08. Mugen, Activate` (battle, 64.5 s): **not identified**; no
  soundtrack lists a track by that name in the searches done.
* `2-03 Victory!` (battle end, 24.8 s): **not identified**. Mario Party
  3's disc 2, track 3 is "Victory!" (しょうぶだ！), but it is 0:55 and a
  battle-start theme, so probably not; Ace Attorney has several
  "Victory!" too.

What would close it: taro saying where the three came from (or listening
to them), and then a MIDI for each, or a MIDI of another song chosen as a
knob. A MIDI found goes into the clone's `Music/` next to its `.wav`, with
the same name.

**taro, 2026-10-16**, listening to them: `2-03 Victory!` is probably
from Star Ocean (not confirmed); `04 - Cavern` from Zelda, Ocarina of Time
or Majora's Mask; `08. Mugen, Activate` from D.Gray-man. In their words,
translated:

> We're not going to find a MIDI of Mugen, and I don't think there's an
> acceptable one of Cavern —it's too ambient to sound good in low
> quality. For now let's not do anything. The victory one, if it's used
> in the battles, we can replace with any default victory theme from the
> RTP… and use the WAV with MSU, even though they'll be different
> themes. Some other time we'll see about choosing other music, and
> that's it.

It is the battle's end music (`battle_end_music` in the
system data), so without MSU-1 it plays the RTP's `Fanfare1`, put next to
the WAV as `Music/2-03 Victory!.mid` in the zounds clone (Hornero); with
MSU-1 the WAV still plays. Cavern, Mugen and Desert flower stay silent
without MSU-1 until another song is chosen.

## taro's decision (2026-10-20)

To the wishlist, as Tijereta recommended: taro had already said, in
their words, translated,

> for now let's not do anything

and what is left is choosing other music.
