---
name: "An overloaded audio package gets its music at 6 kHz; one that barely fits gets it at the minimum"
description: "The relief of a package that does not fit in the ARAM leaves its music at the sound effects' rate and drops effects; a package that fits by a few bytes is not relieved and its music is squeezed to the minimum instead. Where the trigger goes is taro's to decide by ear"
type: bug
status: draft
agents: [Aguará]
---

Seen by Aguará on 2026-10-15, on the branch `aguara-aram` of the-advocate
(`f0b15d74`, on main `362d3765`), while making The Frozen World's map 1
build.

**What it is**: `relief.rs` in `rm2k-snes-audio` relieves a package only
when it does not fit even with every sample at the minimum —what used to
stop the build—, and then aims the music at the effects' rate, 6 kHz,
dropping effects from the end of the list. A package whose effects leave
its music a few bytes above the minimum is not relieved, and the
allocation squeezes its music down to the minimum —`FLOOR`, 256 B per
sample— to fit every effect. So two packages a few bytes apart come out
very differently: one with its music at ~6 kHz and fewer effects, the
other with all its effects and music at its worst.

**Why it was left so**: the trigger at "does not fit at all" keeps every
package that builds today exactly as it is —A Blurred Line's map 3 keeps
`evilrhys` at 4.5 kHz so that its 55 KB of effects fit, which taro chose
by ear (`paid_by_music`)—, and its ROM comes out byte for byte the same.
Moving the trigger to "the music would go below 6 kHz" would relieve
ABL's map 3 too, which is taro's call, not the tool's.

**How to see it**: any game whose package has effects for ~60 KB (not
relieved, music at the minimum) next to one with ~64 KB (relieved). In the
build's `converter.log`, the per-sample lines say the kHz and which
package limited each.
