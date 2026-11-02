---
name: "Bank 1 overflows when merging 2026-11-01's branches"
description: "Merged together, the day's branches —Hurón's debug font, Aguará's terrain rates and bushes, Mulita's conditions, Calandria's tile substitutions, Tijereta's SP in the picker— overflow ABL's test-msu bank 1 (FAR); each alone fit"
type: bug
status: testing
assignee: taro
agents: [Tijereta]
---

Seen by Hornero on 2026-11-01, integrating on `hornero-integrate`
(the-advocate: origin/main 3071048a, Mulita's conditions, plus Hurón's
`huron-debug-font` and Aguará's `aguara-terrain-rates`; the ports the
same plus the resolved `justfile` comment): `just cartridges` in ABL
stops at `test-msu`:

    memory.cfg:11: Warning: Segment 'FAR' overflows memory area 'BANK01' by 32768 bytes
    ld65: Error: Cannot generate most of the files due to memory area overflow

Every branch alone built every cartridge; Tijereta's report already said
bank 1 had some 150 bytes left on hers and moved her code to `FAR3`.

**Done**: all five branches merged, every cartridge of every game builds,
`just space` shows room in each, and the merged tree passes `just test`,
ABL's suite and the ports' `just boot`; what moved out of bank 1 says
why in a comment on its line. A change that costs a cycle in a hot path
to make room is said, measured.

## Log

**The merges** (Tijereta, 2026-11-01), all on `hornero-integrate`:
`calandria-tile-subs` and `tijereta-sp-in-the-menu` came into the-advocate
and the ports without a conflict; in the-advocate-docs, Hurón's,
Aguará's and Tijereta's, with one conflict: the data of
`progress/engine-vs-rm2k/index.html`, a single line of JSON where Mulita's
conditions (already on the book's main) and Aguará's terrains changed
disjoint items; resolved item by item, the thirteen changes kept.

Looked at by hand for what git does not mark: `after_step` in `hero.s`
calls `state_step` and then `encounter_step`, each saving what it uses
—`encounter_step` takes the terrain from `hero_terrain` itself—;
channel 7 is HDMA only on the debug screen, which turns it off on leaving
(`objects_back`), and the map's loads that use it as DMA do not run
there, as Hurón's comment in `registers.s` says; `pano_mode3` turning
color math off is what the debug screen finds before its own mode 5.

**What was in bank 1, and who grew it.** ld65's "32768 bytes" is the
`.align $8000` of `header.s`: one byte over pads a whole second half. The
real size comes from linking a copy of the runtime with that line out and
`BANK01` doubled, against `build/tests/msu/`'s generated includes, and
`.dbg` spans per file: FAR was 38 bytes over. Against Aguará's branch
alone, which fit with ~100 bytes left, the merge adds the 512-wide mode in
the text layer's hot paths (Hurón, 93 bytes), Mulita's conditions in
`level.s` and `bank1.s` (44) and the SP picker in `actor_choice.s` (4).

**What moved**: `menu_exp_paint` and `menu_exp_close`, the menu's
experience line, to `FAR3` with the SP picker that was already there:
entered with `jsl`, their own data bank and long addresses, so it costs
no cycle and no byte. ABL's `just space` after it: every cartridge builds,
test-msu's bank 1 has 574 B, release's 1,151 B.

**What was run on the merged tree** (the-advocate `hornero-integrate`
f40fbee1, the ports' `hornero-integrate`, every tool from the merge's
`.local-tools`): `just test` and `just rust-test` in the-advocate, green;
`just test-game`, green; ABL's `just cartridges`, `just space` and `just
tests`, green on the first round —no golden moved, so there is nothing in
`/shared/captures/2026-11-01-integration/`—; the ports' `just boot`,
green; and `just cartridges` and `just space` in each of the other eight
games, all built. The tightest of each line, measured: bank 0 and `$C0`
in Sunset over Imdahl's release, bank 1 in Vampires Dawn's release; none
over. The menu's experience is drawn by ABL's `test_experience_drawing.py`
and the menu goldens, which ran on the moved code.

Not run: CI's `fmt` and `clippy` (`the-rust-on-main-is-not-formatted.md`
is already open for the first).

**To install globally when merging**, from `~/the-advocate`: `just install
adeleine wally images text battle events screens mapdata convert cartridge
rm2k-snes-audio` —what changed since the global checkout's 422f904d and
the binaries that compile it in—.
