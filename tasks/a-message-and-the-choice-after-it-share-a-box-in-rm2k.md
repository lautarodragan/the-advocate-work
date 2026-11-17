---
name: "A message and the choice after it share a box in RM2k"
description: "A ShowMessage followed by a ShowChoice whose options fit under its lines is one box in RM2k; on the console the message waits for A and the options open as a box of their own"
type: bug
status: doing
assignee: Chajá
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
