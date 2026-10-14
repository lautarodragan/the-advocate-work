---
name: "The emitter stores identical data once"
description: "Identical samples are stored once per key, and identical actor tables once per map: storing each once saves about 418 KB of ABL's whole game, with no loss"
type: refactor
status: testing
assignee: taro
agents: [Carpintero]
---

Two of the lossless savings measured in
[`research/2026-10-14-fitting-the-whole-game-in-8-mb`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-14-fitting-the-whole-game-in-8-mb.html)
for [`abl-the-whole-game-does-not-fit-in-8-mb`](abl-the-whole-game-does-not-fit-in-8-mb.md);
taro said go on 2026-10-14:

* **Samples**: 17 groups with the same BRR, rate and loop, stored once per
  key: about 205 KB. Includes the draft
  [`identical-samples-are-stored-once-per-key`](identical-samples-are-stored-once-per-key.md)
  —and whether they also take ARAM twice—.
* **`actor_table_`**: 22 distinct tables repeated over 307 maps, shared
  whole: about 213 KB.

The third, the NPCs' poses shared whole, goes with the poses' new format in
[`poses-without-their-empty-tiles`](poses-without-their-empty-tiles.md),
which touches the same data.

## Log

**2026-10-14, Carpintero.** Branch `carpintero-dedup` in the-advocate, from
`1b4ff5ea`.

* **Samples**: on main's `release`, read from the ROM, 339 rows of
  `sample_table` and 270 distinct contents: 23 groups, 201,465 bytes
  repeated —in `release` already, not only in the whole game—, all with the
  same loop. **And the ARAM too**: 27 of the 131 packages uploaded the same
  bytes twice, up to 23 KB in one. So they are merged where the SRCN is
  chosen, not only in the ROM: `Bank::directory` gives each key its entry,
  and `merge_identical` renumbers the sounds after the songs are built per
  key —the allocation, the copies and the fingerprint (the ceilings table's)
  see what they saw—. The streams do not change; the sounds' SRCN byte
  does, and the ROM writes fewer SRCNs (the 65816 skips a register that
  already has its value), so the converter checks every song with
  `sounds_the_same`: every other write equal, and the same BRR and loop
  behind every voice's SRCN at each of them.
* **`actor_table_`**: `Materials::store_text` shares a block with symbolic
  pointers by its text, under the label of the first map. Touched in
  `rm2k-snes/mapdata`: `actor_table_asm` and the end of `map_data` in
  `record.rs`, and `materials.rs`. `emit.rs` not touched.

**Measured**, what `pack` is asked, with `rm2k-snes-cartridges` printing
it in a throwaway build (the experiment diffs of the research,
`~/scratch/carpintero/fit/`):

```text
                 before (1b4ff5ea)   after       saved
release          5,577,839 B         5,291,045   286,794 B
whole game       8,416,654 B         7,997,272   419,382 B   still 296 KB over
```

`just space` on `release`: 86 data banks used to 82, gaps 25 KB to 50 KB;
bank 0 the same, 1,183 B free —the actor table is reached by the record's
pointer, so it costs bank 0 nothing—. Of `release`'s 286 KB, 201,465 are
samples and the rest actor tables: 129 to 16.

**What ran**, with the branch's `rm2k-snes-audio` and `rm2k-snes-mapdata`:
ABL's `just tests`, 1308 green (one red the first round: see below);
`just boot`, 12; `just test`, 27; `just rust-test`, 839, with `SOUNDFONT`;
`release` with `NO_CACHE=1 --force` byte-equal to the cached one (`abl.sfc`
`3c1df6f7…a1bd`, `abl.msu` too).

* **The music, read from the ROMs** (`romsongs.py`, main's `release`
  against the branch's): the 63 streams byte for byte; the sounds equal but
  for SRCN; what each decodes to —the installed decoder— the same writes but
  276 SRCNs fewer, with the same BRR and loop behind every voice at each
  write; the sound effects' rows and samples equal; each of the 131 packages
  uploads the same set of samples, 137 KB less in all. The same for six of
  the other games (Book of Three, Desert Nightmare, Dooms 2, El Dorado,
  Frozen World, Sunset); Vampires Dawn's samples travel in the `.msu` and
  the script does not read it: there it is the converter's check and
  `just boot`.
* **A WAV does not compare byte for byte, and it cannot**: each song played
  on the title (`rm2k-snes-volume-ceilings --play` with a PCM dump) starts
  at another moment of the SPC700's clock, because its package is smaller,
  and the DSP's envelopes step on a global counter and the notes reach it
  from the 65816's frame: the same samples started elsewhere do not give
  the same bytes. Measured, not looked into further.
* **The red**: `test_scene_each_troop_of_the_cartridge_draws_everyone` read
  the troops as the words from `troop_id` to `troop_exp`, two pieces the
  packing used to put together; with the space freed they went apart and it
  read half a megabyte as troops. It reads `TROOPS_N` now (ports,
  `carpintero-dedup`).

**Not covered**: the ARAM the merge frees goes to nobody yet —the
allocation still counts one sample per key, on purpose, so that no sample
changes—: giving it to the instruments would raise rates in the 27
packages that had a repeat, and it is a judgement change for later. The
MSU-1 sound effects' rates are allocated with the real ARAM, so in a game
whose songs have no track they may rise; none of the eight is such a case
for the songs measured (ABL's all have a track).

**When merging**: reinstall `rm2k-snes-audio` and `mapdata`.
