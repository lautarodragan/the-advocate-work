---
name: "Audio in two lossy steps"
description: "Reduced and versioned MIDI and SoundFont, to listen to them in a DAW"
type: feature
status: todo
---

# What

Split the audio conversion into **two explicit, versioned lossy steps**,
so that the last step is mechanical:

    (all MIDIs + SoundFont)  ->  reduced SoundFont     [artistic decision]
    (MIDI + reduced SoundFont)    ->  reduced MIDI          [artistic decision]
    (reduced MIDIs + reduced SoundFont)  ->  streams + BRR samples

The first two are artifacts that are looked at, compared with the original and
**can be edited by hand** when a decision comes out wrong. The third stops
deciding anything.

# Status

Noted on 2026-09-21, not started. It is the third and fourth class of patch in
`artistic-decision-patches.md`, which were left out because the key "the
track" doesn't identify the decision.

# Today's four sacrifices, and which step they belong to

1. **Polyphony**: eight voices, and a note that starts with no free voice
   takes it from the one that ends first. **It belongs to the track and nobody else**
   —two tracks never play at once— so it goes in the MIDI step.
2. **Which tracks contribute programs to the bank**: the cut when not everything fits.
3. **The resolution of each sample**: `ARAM_BUDGET` split into equal
   parts, with what's left over redistributed.
4. **The rate that drops for everyone** as tracks are added: median from 12.5 to 8.4 kHz
   with nineteen instead of eleven.

2, 3 and 4 are the same step: they are a function of **all the tracks in the game** + the
SoundFont + the ARAM budget + the priority.

(On 2026-09-26, with the per-package budget —step 6 of
`quality-of-the-music.md`—, 2 disappeared: they all contribute. 3 and 4
are now a single one: each sample with what its worst package leaves it, and the
function becomes one of all the tracks + the SoundFont + **the packages of each
map, with its effects and what may come in already playing**. The priority is gone.)

# The coupling that fixes the order

**A note drops out of the stream when its program isn't in the bank**
—the `continue` in `build_events`—. That is, the reduced MIDI can't be
decided without knowing what was left in the reduced SoundFont. First the SoundFont,
then the MIDI.

# Decisions to make

* **What the "reduced SoundFont" is**: a real `.sf2`, which opens with
  any editor, or a directory of already resampled samples with their
  metadata. The first is more useful for looking at it; the second is more faithful to what
  the final step consumes.
* **What each sample carries already decided**: rate, loop, normalization, trim.
  The more it carries, the less the final step decides.
* **How the cut for a missing program is expressed** in the reduced MIDI:
  the note is deleted, or it stays marked.
* **The polyphony limit**: it isn't eight. There is a voice reserved for sound
  effects, and the split of voices among channels is also a decision that
  should live in the same artifact.
* **From which set of tracks the decision comes**: the ones in `abl`, following the
  rule that what's versioned is what's in the playable ROM.

# What the artifact is for: iterating without building the ROM

The reduced MIDI and the reduced SoundFont **are loaded into a DAW**, and there
adjustments are tried without asking for a build. It is the equivalent of the PNGs that
Adeleine leaves in `rom/build/<cartucho>/adeleine/`: the lossy step is judged by looking at
—or listening to— its output.

taro does that, so the artifact has to open with everyday
tools, and **that is the reason the envelopes come out of the
SoundFont** —`attack-and-decay.md`—: if the ROM uses the
eight families in `sdsp.py` and the DAW uses the SoundFont's, the attacks sound
different and the artifact lies where it shows the most.

**It does not replace testing the ROM**, and there are two differences that will always remain,
because they are not our decisions: the SPC700 interpolates with its Gaussian filter,
which rounds off the highs, and the DSP has hardware echo that the driver doesn't use.

**The reduced SoundFont doesn't go through BRR**, and that is a decision, not an oversight.
Adding an `encode` + `decode` so the DAW reproduces the loss of the 4 bits
would leave **two lossy passes** —the artifact's and the final step's—, which
have no reason to give the same result. It is better for the artifact to be exactly what
the final step consumes.

# What is not a decision

The encoding to BRR. It loses signal —16 bits to 4— but there is nothing to
choose: it is the hardware's format, like the 8x8 tiles.

## Checked on 2026-10-16 (Carpintero)

Still open: nothing in the-advocate `759aa0ba` writes a reduced SoundFont or
MIDI. Two names above moved: the envelopes' families are in `sdsp.rs` of
`rm2k-snes/rm2k-snes-audio/` (the Python left on 2026-10-02), and Adeleine's
images are in `build/<cartridge>/adeleine/` of each game's project in
the-advocate-ports. And "the ones in `abl`" is now one set per game: the
same tools build nine.
