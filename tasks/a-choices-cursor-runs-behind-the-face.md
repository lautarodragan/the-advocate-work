---
name: "A choice's cursor runs behind the face"
description: "When a choice is shown with a face on the left, the selection bar starts at the window's left edge, behind the face; RM2k starts it right of the face and shortens it as much"
type: bug
status: done
assignee: taro
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

## Log

**Hurón, 2026-11-02**, from the-advocate `0ba09da4`, the ports `31fb291`.

`git blame` on the bar: it is `bfa2e1c4` (2026-10-04), the commit that
brought the System's arrow and drew the bar for the converter —`bar_x` and
the width in `message_window.rs` of `rm2k-snes-screens`, the size of
`window_bar` in `msg_bar_source`—. Faces came on 2026-10-15, and nothing
since looked at the bar again: the width was not chosen against a face, it
predates them. The message says nothing about faces.

The bar is not drawn by the runtime: the converter draws the text area's
background with the System's cursor on each of the four lines
(`window_bar`, and `window_bar_bare` over nothing), and `prime_line`
composes the highlighted line over those tiles instead of the bare
background. So the fix is drawing three of each —no face, face left, face
right, the order of `MSG_FACE_DRAW`— and having `msg_bar_source` pick by
`MSG_FACE_DRAW`. The rectangle is easyrpg's: x 2 + 72 and width 236 − 72
with the face on the left, x 2 and width 236 − 72 with it on the right; on
the console's 240-wide text area the right one stops at 166, and the face
starts at 184 (RM2k: 230 and 248, the same 18).

The options' text x was already right: `msg_face_line` starts a line at
`MSG_FACE_TEXT_X` with the face on the left and adds `CHOICE_INDENT`, 72 +
12, as `InsertNewLine` does; in taro's capture the options start at the
window's x 92 = 8 + 72 + 12.

A choice that shares a box with its message: the port does not do it yet
—[a-message-and-the-choice-after-it-share-a-box-in-rm2k](a-message-and-the-choice-after-it-share-a-box-in-rm2k.md)—;
the bar is still drawn for all four lines and each face side, so when it
does the choice's lines past the first get theirs.

**No room for three bars.** Drawing the two bars with a face in the
converter —the first try— is 19 KB more per System, and A Blurred Line's
release and Vampires Dawn have no free data bank (`just space`): ABL's
release does not even take one face. So the cartridge cuts the bar with a
face out of `window_bar_bare` —the bar over nothing— and lays it over the
line's background through its transparency (`bar_compose`, FAR3, in
`message_face.s`): with the face on the right, the whole bar's cells 0–18,
its last cell, and one cell of six middle pixels of cell 27 and two edge
pixels of cell 28 (the cursor's middle repeats every 16 pixels from the
bar's start, and 72 is four and a half repeats); with the face on the left,
that moved nine cells. `the_bar_with_a_face_is_the_bar_without_one_recut`
in rm2k-snes-screens checks the recipe against the bar drawn whole over a
System of noise (red if the recipe is touched). `msg_bar_source` answers
with the carry set when there is a face, and `prime_line` takes the
background: 2 bytes of bank 0. No converter output changes; a cartridge
without faces assembles none of the new code. ~33,000 cycles per
highlighted line, counted from the loops, not measured.

**Tests**: ABL's `test_the_bar_with_a_face`, on a new cartridge
`test-faces` (cases `bar-face-left`, `bar-face-right`), red before on both
sides and green after, with four new goldens; Zounds' ship test
photographs its choice, `zounds-ship-unames-choice`. Captures in
`/shared/captures/2026-11-02-choice-cursor/`. The book's "What faces do
not model" loses the bar's item; `InputNumber`'s digits still do not move
for a face, which it already said.

**When merging**: nothing to reinstall. The Rust change is a test and the
`FaceSide`/`choice_bar` helpers it uses, in rm2k-snes-screens; no binary's
output changes, and the runtime is read from the checkout. Branches
`huron-choice-cursor` in the-advocate, the ports and the book.

**What the suite does not cover**: the bar with a face over a window
without its background (a box with a face keeps its background since
2026-10-20, so that path only runs if that changes), and a face with a
second System (`WINDOW_SYSTEMS > 1`): Desert Nightmare and Vampires Dawn
have both, `just boot` builds them, but no test opens a choice with a face
there. The cycles are not measured. To try by hand: Zounds, Unamë's locked
door ("Abrirla / Dejarla Así"), as in taro's capture.
