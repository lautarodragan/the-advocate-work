---
name: "msu_data_seek does not forget where the effects left the port"
description: "The backdrops' seeks and the save's flush move the MSU-1's data port without resetting MSU_SE_NEXT, so the next sound effect from the .msu could take the port as in place and read from wherever the seek left it; read, not seen"
type: bug
status: draft
author: chaja
agents: [Chajá]
---

Read by Chajá on 2026-11-23, at the-advocate `75d46e3c`, while bringing
[`maps-uncompressed-in-the-msu`](maps-uncompressed-in-the-msu.md)'s
prototype up to main. **Not seen in any game**: it comes from reading
the code, and no test runs it.

`MSU_SE_NEXT` (`runtime/far_ram.s`) is where the `.msu`'s sound effects
left the data port: `se_msu_upload` and `se_msu_chunk`
(`runtime/msu_effects.s`) skip the seek when the effect they want starts
right there. Every other reader of the port sets it to `$FFFFFF` first
—`lz2_msu`, `msu_dma0`, `msu_sample_l`, the debug screen—, and the
package change does after `msu_data_valid`. But `msu_data_seek`
(`runtime/msu1.s`) does not, and it is what moves the port in three more
places: the battle backdrops (`battle_scene.s`, through
`msu_data_seek_l`), `msu_data_valid` itself, and the save's flush to the
FX Pak's card (`msu_save_flush`, which seeks to 0 after every save).

So after a save, if the next effect uploaded from the `.msu` is the one
that comes right behind the last one uploaded, it is read from position
0 plus whatever: a sample with the `.msu`'s header in it. After a battle
the package change resets it, so the backdrops are probably covered;
the save's flush is not.

How to tell whether it is real: in a game whose effects come from the
`.msu` (ABL with its `.msu`), play an effect from the `.msu`, save, and
play the effect whose row in `se_msu_rows` follows it, before anything
else seeks. The fix is three `sta f:MSU_SE_NEXT` of `$FF` in
`msu_data_seek`: the branch `chaja-msu-raw-2` of the-advocate carries it
(`7794939c`), because its raw map loaders rely on the same variable.
