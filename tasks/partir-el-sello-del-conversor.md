---
name: "Split the converter's seal"
description: "One seal for the converter and another for rom/src/, so that editing assembly doesn't reconvert everything"
type: refactor
status: wishlist
---

Proposed on 2026-09-26 by the `just cartuchos` optimisation (see
`cartuchos-en-caliente-en-diez-segundos.md`): today touching any file in
`rom/src/` reconverts everything, but the converter reads a single file from
`rom/src/`, `ram_lejana.s` (measured with an audit hook). With one seal for
the converter (flags, cases, `tools/`, binaries, `parches/manual`, ceilings and
`ram_lejana.s`) and another for `rom/src/`, `ca65` and `ld65`, editing assembly
would cost about 4 s instead of ~15. It is a structural change in
`tools/ensamblado/cartuchos.py`.

taro left it in wishlist: the gain is not much.
