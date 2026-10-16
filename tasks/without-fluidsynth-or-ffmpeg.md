---
name: "Without fluidsynth or ffmpeg"
description: "Drop the two external audio dependencies if what we use of them is little"
type: refactor
status: wishlist
---

Part of taro's goal that the pipeline be static Rust binaries without
dependencies (see the project memory). **Low priority**, 2026-09-26: if what
we use of fluidsynth is very little, evaluate it; it would make no sense to
end up porting fluidsynth.

What they are used for today (`git grep -n 'fluidsynth\|ffmpeg' tools/ tests/`):
**fluidsynth** renders each MIDI with the SoundFont to WAV, for the MSU-1
tracks (`tools/audio/msu.py`) and as a reference in the quality measurements;
**ffmpeg** decodes the audio replacements (`.mp3`, `.ogg`, `.flac`) of the
MSU-1 tracks.

What would need looking at: whether `rustysynth` (an SF2 synthesiser in Rust,
without dependencies) gives a render similar enough to fluidsynth's for the
MSU-1 tracks —the tracks would change bytes: it is decided by listening—, and
whether `symphonia` (decoders in Rust) is enough for the replacements. And
where it would live: probably in `gunter`, which already reads the SoundFont.

**Checked on 2026-10-16 (Mulita)**, at the-advocate 759aa0ba: both are still used, now from Rust: fluidsynth in `rm2k-snes-audio`
(`tracks.rs`, `ceilings.rs`, `bin/msu.rs`), and ffmpeg for the
replacements, a game's own `.wav` songs and, since `30ab0ca6`, the MP3 a
`.link.wav` names. `tools/audio/msu.py` is `rm2k-snes-audio`'s `msu`
binary.
