---
name: "Ignore the color codes in messages, for now"
description: "\\c[n], \\C[n] and \\s[n] in a box leave it out entirely; have them ignored as the waits already are, as debt"
type: feature
status: testing
agents: [Tijereta]
assignee: taro
---

From Aguará's analysis of 2026-10-06: Desert Nightmare (`\c[1]Sandra: \c[0]`
in almost every message, 1345 pages out), Sunset Over Imdahl (about 870)
and Dooms 2 (`\S[n]`). taro, on 2026-10-06: "Let's go with 1 on sonnet".

## Done (Tijereta, 2026-10-06)

`without_waits` of `tools/rm2k-snes/text/src/refit.rs` also discards
`\c[n]`, `\C[n]`, `\s[n]` and `\S[n]` (with digits and `]`; anything else, like
`\c[x]`, still doesn't compile). Since `escape_tail` removes them before measuring, they don't
count in the width. Cases in `text/tests/escapes.json`; the red was seen with
the rule disabled.

**Declared debt**: the color and the speed are lost. It's noted here and in
`draw-the-faces-and-really-wait-on-the-escapes.md`, where `without_waits` already lives.

Map pages that compile (`rm2k-snes-events culprits --every-map`, before
-> after): Desert Nightmare 5738 -> 7034 of 7340; Sunset Over Imdahl 898 ->
1151 of 1369. ABL doesn't use the codes in `data/` and `abl.sfc` comes out with the same
fingerprint, `27e94e67039533a2…`.

`-p rm2k-snes-screens`: `the_boxes_of_the_maps_and_the_common_events` fails
(`left: 5, right: 4`), **and fails the same without this change**: it's the case of
`screens-test-gives-a-different-result-with-the-whole-workspace.md`, which here fails too
with `-p`. On merging: install `text events screens convert cartridge`.
