---
name: "Split the converter's seal"
description: "One seal for the converter and another for rom/src/, so that editing assembly doesn't reconvert everything"
type: refactor
status: wishlist
---

Proposed on 2026-09-26 by the `just cartridges` optimisation (see
`warm-cartridges-in-ten-seconds.md`): today touching any file in
`rom/src/` reconverts everything, but the converter reads a single file from
`rom/src/`, `ram_lejana.s` (measured with an audit hook). With one seal for
the converter (flags, cases, `tools/`, binaries, `patches/manual`, ceilings and
`ram_lejana.s`) and another for `rom/src/`, `ca65` and `ld65`, editing assembly
would cost about 4 s instead of ~15. It is a structural change in
`tools/ensamblado/cartuchos.py`.

taro left it in wishlist: the gain is not much.

**Checked on 2026-10-16 (Mulita)**, at the-advocate 759aa0ba: still one fingerprint for everything —`fingerprint_files` in
`rm2k-snes/cartridge/src/cartridges.rs`, which replaced
`tools/ensamblado/cartuchos.py`—. `rom/src/` is `runtime/` since
2026-09-29 and `ram_lejana.s` is `far_ram.s`; what the converter still
reads from it is `BOOT_FRAMES_FLOOR`, in `rm2k-snes-audio`. The timings
above were measured with the Python and were not measured again.
