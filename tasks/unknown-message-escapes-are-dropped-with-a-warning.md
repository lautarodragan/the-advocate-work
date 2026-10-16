---
name: "Unknown message escapes are dropped, with a warning"
description: "A box with an escape the console cannot show leaves its whole page out today; it should drop the escape, compile the box, and say so in degradations.json, so the game can be played without solving each escape first"
type: feature
status: testing
assignee: taro
agents: [Mulita]
---

taro, on 2026-10-15: "about the message codes not implemented yet, in
general: I'd put a change in now that degrades gracefully —that simply
ignores them—. That way it can be played without solving that problem.
I'd leave a compiler warning or whatever so we don't lose and forget it."

At the-advocate `6fa69781`: `escape_tail` in `rm2k-snes/text/src/refit.rs`
returns `CannotCompile` for any escape left after `with_wait_marks`, which
already drops `\c[n]` and `\s[n]` and makes marks of the waits and of `\\`.
So `\$`, `\_`, `\>`, `\<`, a `\^` that is not a tail, and whatever else, keep
the whole page out. Aguará's Zounds study counted 678 Zounds map pages out
"only by the colour escape": a variant `with_wait_marks` does not take, to
be found.

It absorbs Aguará's draft
[`the-colour-escape-in-messages`](the-colour-escape-in-messages.md).

## Measured before (Mulita, 2026-10-15)

Tools at the-advocate `6fa69781` (the global ones), ports `f015801`, Zounds
from Aguará's throwaway project copied to `~/scratch/mulita/escapes/zounds`.
Each game's `release` built and `just culprits` run; then each message
command among the culprits classified by a throwaway script
(`~/scratch/mulita/escapes/measure/classify.py`): the escapes left after
the rule of `6fa69781`, and the letters outside printable ASCII.

The escapes that keep a box out, per game, counted as occurrences in the
culprit commands:

| game | escapes | boxes out by a letter, not an escape |
|---|---|---|
| A Blurred Line | none | none |
| The Book of Three | none | none |
| Dooms2 | none | none |
| El Dorado | none | 1 (`ä`) |
| Sunset over Imdahl | none | 5 (`ä`, `…`, `ô`) |
| Frozen World | `\ ` (backslash space) 8 | none |
| Desert Nightmare | `\h` 2, `\c` without brackets 1 | 12 (German) |
| Vampires Dawn | `\_` 1,905, `\i` 3, `\ ` 1, `\,` 1 | 638 (German) |
| Zounds | `\¿` 1, `\[` 1 | 1,742 (Spanish) |

**The 678 is a misclassification.** Zounds is in Spanish, and the console's
font is printable ASCII: `Messages::store` stops the page of any box with a
letter the font does not have (`é á ¡ ë ¿ ó í ñ ú …`). Of the 965 map pages
out only by message commands, 919 are out only by such a letter and the
other 46 by a letter and something else; not one is out by `\c[n]`, which
`with_wait_marks` already dropped. Even the boxes with no accented letter
of their own, `\c[5]\n[1]:\c[0]`, are out for the hero's name, `Unamë`,
which `with_names` writes into the text. The study counted the pages
whose only escape was `\c` and took the escape for the cause. A draft for
the letters: [`latin-1-letters-stop-a-box`](latin-1-letters-stop-a-box.md).

## What RPG_RT does with each escape

From easyrpg-player's `Window_Message::UpdateMessage` and
`Game_Message::ParseParam`:

* `\c[n]` and `\s[n]` take their argument up to the next `]` —past a nested
  `\V[n]`—, or to the end of the text; without a `[`, only the letter.
* `\$` the gold window, `\_` half a space's advance, `\>`/`\<` instant text.
* `\^` closes the box **at its end**, wherever it is written (`kill_page`).
* Any other letter: nothing is drawn, the letter is eaten, and what follows
  it is drawn —so `\q[3]` shows `[3]`—.

## What was done

the-advocate, branch `mulita-escapes`:

* `escape_tail` answers `Untailed { lines, pauses, auto_close, dropped }`.
  Every escape but the tail, the waits, `\\` and `\^` is dropped with its
  argument as `ParseParam` reads it (`c s n v` with a `[`), or only the
  letter; a backslash at the end of a line too. A `\^` anywhere closes the
  box, as `kill_page`. Only more than 15 pauses is still `CannotCompile`.
  `\_` is dropped, not made a narrow space: that wants a new mark the
  composer advances by, and it is not trivial.
* The reflow puts a reflowed box's dropped escapes at the start of its
  first box, so the compiler still sees and lists them —before, a reflowed
  box lost its `\c[n]` silently—, and a `\^` from the middle goes to the
  last box's tail.
* `Messages` keeps what each **stored** box dropped; the compiler takes it
  right after the command adds its box (`Ctx::lose_dropped`: the
  `ShowMessage`, a choice's options, the inn, the box before an
  `InputNumber`) and notes each escape once per command as
  `message-escape-dropped`, with what it loses (`dropped_escape`). The
  test pages' are thrown away, as their other losses.
* Desert Nightmare's `\c[0Yes...`, unclosed, drops to the end of the line;
  RPG_RT would go on to the next `]` past the line, which nobody writes on
  purpose.

Tests: `tests/escapes.json` (the text crate) says what each case drops and
gained eight cases; `what_a_reflowed_box_drops_is_still_there`;
in the compiler `an_escape_the_console_cannot_show_is_dropped_and_noted`
and `what_a_box_drops_is_taken_once_and_only_if_it_is_stored`; the test
game's `test_escapes.py`, a common event with `\c[2]`, `\$`, `\>`, `\<`,
`\_` and `\q`, its golden, and `degradations.json` listing them. Red before:
`escapes.json` against the old rule (`\c[x]no` does not compile), and the
test game with the global tools (no box, nothing listed).

## Measured after

`culprits --every-map`, pages out of the total, before → after:

| game | maps | commons | troops |
|---|---|---|---|
| A Blurred Line | 0 → 0 | 1 → 1 | 137 → 137 |
| The Book of Three | 0 → 0 | 0 → 0 | 95 → 95 |
| Desert Nightmare | 15 → 12 | 2 → 2 | 100 → 100 |
| Dooms2 | 4 → 4 | 0 → 0 | 81 → 81 |
| El Dorado | 5 → 5 | 4 → 4 | 80 → 80 |
| Frozen World | 15 → 15 | 1 → 0 | 80 → 80 |
| Sunset over Imdahl | 27 → 27 | 1 → 1 | 1 → 1 |
| Vampires Dawn | 1,229 → 1,016 | 23 → 23 | 362 → 362 |
| Zounds | 981 → 981 | 28 → 28 | 87 → 87 |

No message culprit is left out by an escape in any game but one box of
Zounds (`\¿`, which also has accented letters). The `message-escape-dropped`
losses per build: ABL, The Book of Three and El Dorado none; Desert
Nightmare 4,326 (`\c` 4,293, `\s` 30, `\h` 2); Dooms2 4 (`\S`); Frozen World
8 (`\ `); Sunset 1,547 (`\C`); Vampires Dawn 16,363 (`\c` 15,958, `\_` 203,
`\s` 199, `\i`, `\,`); Zounds 119 (`\c`). Most are the `\c[n]` that were
already dropped silently.

ABL compiles no box differently: no loss of the kind, the same culprits.

## Verified

With the branch's `text events screens convert` in `.local-tools`:
`just rust-test` 914 passed; `just test` 29 passed; the test game, 20
passed and 1 skipped (the save test on bsnes); ABL's `just tests` 1,555
passed and 2 skipped, no golden moved; `just boot` at the ports root, 44
passed. Captures and the tables in `/shared/captures/2026-10-15-message-escapes/`.

What the suites do not cover: no ABL box carries an escape the console
drops, so ABL's suite only says nothing else moved; the reflow that moves
dropped escapes to the first box is covered by the text crate's unit test,
not by a ROM. The `\^` in the middle of a box is covered only by
`escapes.json`.

**To install when merging**: `just install text events screens convert`
(the text crate goes into the other three).
