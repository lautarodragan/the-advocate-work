---
name: "Notes released too early"
description: "When a note steals another's voice, the stolen note's scheduled release cuts off the new one"
type: bug
status: done
---

Seen while measuring the music stream on 2026-09-25 (see `music-weighs-789-kb.md`),
without hearing it yet. In `tools/audio/snes_music.py` (`build_events`): when
a note wins another's voice, the release the stolen note had scheduled
still stands and cuts off the new one too early. **686 notes, 10,308 frames**
in the `test-main` themes; 329 in `escape_newyork`.

And another from the same place: a note whose sample is not in the bank still
takes up the voice, because `busy` is set before the `continue`.

It is better to fix it **before or after** the change to the stream format (idea
1 of `music-weighs-789-kb.md`), not together with it: that change is verified by
the DSP writes coming out identical, and this fix changes them on purpose.

# Done, on 2026-09-25

Both, in `build_events`: the release is scheduled at the end and only for the
notes that still own their voice, and the note without a sample leaves before
a voice is chosen. Across the 22 themes of `release` there were 564 notes released too
early and 11,024 notes without a sample taking up a voice; the stream shrank 11.3%. The
numbers theme by theme and how they were measured, in point 1 of
`quality-of-the-music.md`; it is enforced by
`pruebas/herramientas/test_musica_stream.py`.

**For taro**: it is in `testing/` because it can be heard —a little: mostly the bass of
`escape_newyork` and that of `cd4`, which are no longer cut off early—. The recordings,
in `/shared/audio/2026-09-25-pasos-1-y-2/` (the `-1-` ones).

**taro listened to the recordings and approved it on 2026-09-26.**
