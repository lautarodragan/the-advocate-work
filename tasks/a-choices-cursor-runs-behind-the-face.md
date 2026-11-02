---
name: "A choice's cursor runs behind the face"
description: "When a choice is shown with a face on the left, the selection bar starts at the window's left edge, behind the face; RM2k starts it right of the face and shortens it as much"
type: bug
status: doing
assignee: Hurón
agents: [Hurón]
---

taro, on 2026-11-02, in their words, translated, with a capture of
Zounds —Unamë's face on the left and "Abrirla" / "Dejarla Así", the bar
across the whole window behind the face—:

> A small possible bug (not a new one): when choices are shown, I suspect
> the face should not be shown, or the box that marks the selected option
> should not reach all the way to the left, behind the face. I don't
> remember whether this is a Zounds bug or how it is in the original RPG
> Maker 2000, but I imagine it's a bug of our implementation.

RM2k keeps the face and moves the cursor: easyrpg's
`Window_Message::UpdateCursorRect` starts it at
`2 + LeftMargin + FaceSize + RightFaceMargin` with the face on the left
and takes the same off its width (contents width − 4); with the face on
the right only the width shrinks.

**Done**: the choice's bar in the message window, with a face on the
left or the right, has RM2k's rectangle, in every game; with a ROM test
in ABL, red before, over a choice with a face.
