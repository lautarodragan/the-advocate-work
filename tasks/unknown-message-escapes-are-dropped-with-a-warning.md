---
name: "Unknown message escapes are dropped, with a warning"
description: "A box with an escape the console cannot show leaves its whole page out today; it should drop the escape, compile the box, and say so in degradations.json, so the game can be played without solving each escape first"
type: feature
status: doing
assignee: Mulita
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
