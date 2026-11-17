---
name: "A message and the choice after it share a box in RM2k"
description: "A ShowMessage followed by a ShowChoice whose options fit under its lines is one box in RM2k; on the console the message waits for A and the options open as a box of their own"
type: bug
game: zounds
status: testing
assignee: taro
agents: [Carpintero, Chajá]
---

Seen by Carpintero on 2026-10-19, on the-advocate `2c350d8f` and the ports
`acff443`, while making Zounds' debug room
([`zounds-a-debug-map`](zounds-a-debug-map.md)).

In RPG_RT, when the command after a `ShowMessage` is a `ShowChoice` and
its options fit in the lines the message leaves free —four in all—, the
options are drawn in the same box, under the message's lines, and the
player chooses at once: easyrpg's `Game_Interpreter::CommandShowMessage`,
"If next event command is show choices", with `4 - pm.NumLines()`. On the
console the message's box is shown alone, with the continue arrow, and
waits for A; only then the options open, in a box of their own with no
question above them.

To see it: Zounds, "New Game" with the debug map, and talk to the man in
the room —one line of question and three options, one box in RM2k—; or
the game's own, Kazar's question on map 34 the first time in the desert,
"Si/No" after his message. The choice works; what is lost is the question
on screen while choosing.

## Defined (2026-10-20, Tijereta)

Checked against the-advocate `8f290c39`: still so. The compiler already
does the same for an `InputNumber` —`number_inputs` in
`rm2k-snes/events/src/compile.rs`, with `pm.NumLines() < 4`, and
`OP_NUMBER` writing its line under the message's—, and nothing does it
for a `ShowChoice`. **Done**: a `ShowMessage` followed by a `ShowChoice`
whose options fit in the lines the message leaves is one box, the options
under the message's lines and the cursor on them at once, with no wait
for A; a choice that does not fit stays a box of its own, as in RPG_RT. A
case shows it —Zounds' debug room, the man's question, or Kazar's "Si/No"
on map 34— with its golden. **First step**: that case, red, and how
`OP_NUMBER` shares the box, to do the choice the same way.

## taro's report (2026-11-17)

taro, playing Zounds' build on Mesen, with screenshots in the shared
folder (`bug-reports-etc/zounds-message-with-options/`, copied to
`captures/2026-11-17-message-with-choices/`), translated:

> I _think_ the original RPG Maker showed the options next to the text, if
> there was room available, or some option was on, or something. I can't
> find anything about it in EasyRPG Editor. Maybe it was the default
> behaviour when a ShowMessage was next to a ShowChoice.

It is, as above: no option, the default. The captures show three cases
the port splits: Unamë's "Lo mato. Lo mato. ¿Lo mato?" then
"Matarlo, destriparlo / Quedarse quietita" (000, 001); "La puerta está
cerrada con llave." then "Abrirla / Dejarla Así" (002, 003); "Opciones-Pasaje"
then "Pasar al otro lado / <No hacer nada>" (006, 007). And in 000 and 001,
with Unamë's face, a dark brown L-shaped block sits at the window's lower
right, inside it: not seen in the other boxes —look at it too, it may be
its own bug—.

## Log (Chajá, 2026-11-17)

From the-advocate `865163eb` and the ports `8042dc8`, branches
`chaja-msg-choice` in both.

* **The shape**: a new opcode, `OP_ASK` = 0x57 —handed out by Hornero—,
  `OP_CHOICE`'s table with the question's box and its line count in
  front. `OP_NUMBER`'s trick for the rest: the question is typed as any
  message with `pick_active` at a new `PICK_ASKING` —no arrow, the page
  held, `\^` ignored as RPG_RT's `OnFinishPage` does, a `\|` at its end
  waited before the options—, and when it is done the options' box is
  composed from line `pick_first` down, the lines above left as they are.
  The bar, the face's bar and a greyed inn option count from `pick_first`.
* **The compiler**: `questions` looks for a message group followed by a
  `ShowChoice` with `lines + options <= 4`; the message is compiled where
  it is, and its last box —a face can split it in two— goes to the
  choice if the options still fit under it; otherwise the choice is its
  own box, as before. The lines counted are the console's (the project's
  box table may have rebuilt them): a translation that makes a box longer
  can leave a choice apart that RPG_RT joins. The paid inn's greeting and
  its "Yes/No" go the same way —same length, `OP_ASK` where `OP_MESSAGE`
  and `OP_CHOICE` were—.
* `python.rs`'s hashes of both `maps` moved; with `questions` answering
  none and the inn put back, the old ones come out.
* **The brown L block** in taro's 000/001: seven cells at the window's
  lower right, 8x8-aligned, in palette 1's colour. They are the last seven
  words of the right-side face's cells in the framed plane (row 4's last,
  row 5 whole) —the tail of `face_cells`' write order—: a box that clears a
  right face writes 72 tilemap words by CPU after the line's 1920-byte DMA,
  and when the line went up late the clear ran past the vblank. snes9x
  takes late VRAM writes, Mesen drops them, so the cells kept palette 1.
  Fixed by composing the 72 words into two far-RAM buffers when the box
  opens and sending them in the vblank by twelve 12-byte DMAs.
* **The display audit saw it, ABL's did not look**: on the audited bsnes
  (`AUDIT_CORE`, accurate PPU) Zounds' ship case loses 54 VRAM writes on
  one frame (Unamë's first face) and 52 on two more (Kazar's side
  change), the last on line 7. `test_display_accesses.py`'s four scenes
  are ABL's, and ABL has no box with a face: not a timing difference
  between bsnes and Mesen. A Zounds test now runs the ship's boxes on that
  core: `test_the_faces_cells_go_up_inside_the_vblank`, red before (frame
  239, 54 writes), green after.
* **A choice picked left the composer running**: with the options going
  up under the question, ABL's inn tests pressed A while they composed,
  `choice_pick` closed the window, the composer finished the box and
  `flush_video` opened it again over the night's staging —the night never
  ended, four of `test_inn.py` red—. It could happen before too, with an
  A right after a cursor move. `choice_pick` now stops the composer.
* Bank 0: `op_choice`'s table moved to far code (`choice_table`) to pay
  for `op_ask`; the tightest cartridge, `test-change-system`, has 18 B left
  (it overflowed by 23 before the move).
* Tests moved with it: ABL's inn tests waited for the greeting as a box
  of its own (`test_inn.py`, `test_inn_golden.py`, `test_touch_head_on.py`)
  and `test_choose.py`'s "open" took any `pick_active`; they wait for
  `PICK_CHOICE` now. The `choose` scene lost the press that closed "Should
  I use it?". Zounds' debug room's man, the same.
* **Goldens moved**, looked at, side by side in
  `/shared/captures/2026-11-17-message-with-choices/`: Zounds'
  `zounds-ship-unames-choice` (the question and its options; the
  question alone, `-face-left`, is gone) and `-kazars-face-right` (a
  light's phase); ABL's `choose-104`, `choose-154`, `inn-greeting-gold`,
  `inn-choice-without-the-price`; The Book of Three's campfire —a
  question now, no arrow while its options go up— and six more, and
  Zounds' `zounds-debug-desert`, by animation phase: one A fewer per
  question.

## Done (2026-11-17, Chajá)

Branches `chaja-msg-choice` in the-advocate, the ports and the book, with
main merged (the-advocate 071e92b6, the ports 75a1908).

* the-advocate: the face's cells by DMA; `OP_ASK` in the compiler and the
  runtime; `choice_pick` stops the composer.
* the ports: the ship's test and the audited one, the moved tests and
  their goldens.
* the book: a row in `internals/events.md`, and the inn's divergence
  loses the bullet this was.

Verified, with the branch's tools on the merged tree: `just crate-test
events` (new: `a_choice_that_fits_goes_under_its_message`,
`a_question_a_face_makes_too_long_is_its_own_box`), `just test`, ABL's
`just tests` (1665 passed), the ports' `just boot` (155 passed, the
audited ship's test included: it needs `AUDIT_CORE`). `just test-game`
has four reds that main has too: `test_leader_name.py` —
[`the-test-games-leader-name-goldens-are-red-on-main`](the-test-games-leader-name-goldens-are-red-on-main.md)—
and the linter —[`goombario-reads-widths-from-an-untaken-if-branch`](goombario-reads-widths-from-an-untaken-if-branch.md)—.

Not covered by any ROM test: a `\|` or a `\!` at the end of a question, a
question with no face over a window without its background, a question
in a common event, and a translation whose box the table made longer.
Bank 0: `test-change-system` is the tightest, 18 B left.

**When merging**: reinstall `cartridge` (the bytecode's `.inc`), `events`
and `convert`; the runtime goes with the checkout.
