---
name: "Attack and decay"
description: "Each instrument's envelopes, read from the SoundFont"
type: feature
status: done
---

# What

Read each instrument's **attack and decay** from the SoundFont, instead of
taking them from the eight families in `sdsp.py`.

# Status

Done on 2026-09-25, together with the release and the mix's headroom: it's
item 2 of `quality-of-the-music.md`, which has the numbers. It's in
`testing/` because taro has to listen to it: the recordings, in
`/shared/audio/2026-09-25-pasos-1-y-2/` (the `-2-` ones).

`gunter sf2 --extract --json` returns the zone's volume envelope
—generators 33 to 40—, and `sdsp.envelope` translates it into what the DSP can
do. **It needs `just herramientas`** before building.

# Why

The eight families in `sdsp.py` were picked **by eye, when the bank was
synthetic**. The SoundFont carries its own per instrument and they aren't read yet.

And there's a second reason, the one that turned it into a task: the reduced
SoundFont from `audio-in-two-lossy-steps.md` **is going to be opened in a DAW** to
judge how it sounds without building the ROM. If the envelopes the ROM uses aren't
the SoundFont's, what you hear there isn't what will come out of the console,
precisely in the attacks —which is where it's most noticeable—.

**The release went in too**, even though when this was noted it wasn't included: the mechanism
is still the one in "How a note is released", in `README.md` —turn off the ADSR
and request GAIN—, but the GAIN rate now comes from the SoundFont instead of
the family, because with the family's the bass dragged a 2.4 s tail
where the SoundFont asks for 30 ms. That README paragraph —"the per-family value
is in `sdsp.py`"— went stale, and wasn't touched because taro is editing it.

**taro listened to the recordings and approved it on 2026-09-26.**
