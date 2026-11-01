---
name: "Bank 1 overflows when merging 2026-11-01's branches"
description: "Merged together, the day's branches —Hurón's debug font, Aguará's terrain rates and bushes, Mulita's conditions, Calandria's tile substitutions, Tijereta's SP in the picker— overflow ABL's test-msu bank 1 (FAR); each alone fit"
type: bug
status: doing
assignee: Tijereta
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
