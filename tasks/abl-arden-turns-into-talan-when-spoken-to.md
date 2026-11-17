---
name: "ABL: Arden turns into Talan when spoken to"
description: "In the scene with \"Arden... I'm sure everyone's fine\", talking to Arden draws her with Talan's CharSet in her own palette, and then she is Arden again"
type: bug
status: testing
assignee: taro
agents: [Mulita]
game: abl
---

taro, on 2026-11-17, translated:

> Another bug, new (it already happened last night, it is not from today):
> Arden turns into Talan when I talk to her, in this scene, and then she is
> Arden again. She seems to keep her palette ("red" Talan is Arden).

Screenshots in `/shared/bug-reports-etc/abl-arden-talanified/`
(`abl_008.png`-`abl_011.png`): during Talan's line "Arden... I'm sure
everyone's fine. They've just been brought into custody, that's all." the
sprite on Arden's cell is Talan's figure with Arden's colours; after the
box, Arden's own. Builds of the night of 2026-11-16 and of 2026-11-17
(ports `428e7c3`, the-advocate `95863f36`).

Done means: the scene reproduced in the harness, the cause found (a pose
or graphic slot of the turning NPC, the poses-only trimming, the baked
events…), fixed, with a ROM test that holds it.

## Log

**2026-11-17, Mulita.** The scene is map 38 (Sector 34 With Car), event 19
`Arden` (`Chara2` 0, action button): Talan's line is the first box of its
page. Scenes 20 and 21 of the same map move her with routes, so the
compiler gives her a walker's row (`npc_buf` +9 is her entry, 13, not
`NPC_STILL`), and map 38 has a cache of slots (`SHARE_N` bit 7).

Reproduced with a test page, `arden-talk`: Talan at (18, 21) facing right,
Arden moved to (19, 21), A. At tick 60 `TURN_EV` is 18 and `TURN_DIR`
left, and reading the OAM the way the PPU does, both 32x32 objects point at
tile 0 and both show `Future1` 0 facing right: Talan, and Talan again in
palette 3, Arden's. With Kersh leading it was Kersh. Not the poses-only
trimming nor the baked events: the pose table's entry 13 is whole.

The cause is `cache_want` in `runtime/cache_slots.s`, from 2026-10-03
(`64ce2091`): "the one facing the hero is in the turn slot, which its row
points at" draws whoever turned from its row's tile. Only a still row moves
to the turn slot (`turn_apply`); one that walks or animates in place turns
in its own cache slot (`upload_npc_pose` asks `cache_dest`), and its row's
tile byte is nobody's: 0, the hero's slot. So the turn showed the hero's
current pose in her palette, and when the page ended `TURN_EV` went back
to $FF and she was Arden again.

The fix (the-advocate `mulita-arden`, `1424bf5a`): `cache_want` takes the
row's tile only if the row is still, and a walker that turned asks for its
own key like any other frame. The test (ports `mulita-arden`):
`test_one_that_walks_turns_in_its_own_slot_in_a_cache_map` in
`tests/rpgmaker/test_talk_golden.py`, with the case `arden-talk` and a new
`sheet.drawn_silhouettes`, which reads the OAM as the PPU does —the old
`vram_silhouette` reads the row's slot, which is what lied here—. Red
before the fix ("Talan facing right at [(112, 88), (128, 88)]"), green
after, and its golden `turn-arden-60`.

Why it showed now and not before is not measured: the cause is from
2026-10-03, and it needs a map with a cache and a walker spoken to.

Verified with the tools of the-advocate `mulita-arden` (`82230ad4`, the
`cartridge` crate installed locally so the ROM is assembled from that
runtime) on ports `mulita-arden` (`7ab4a09`), both on top of main as it is
(`95863f36`, `7ea4469`): ABL's suite, `test_cores` included, 1680 passed
and 2 skipped. `just space`: the tightest is `release`, with no whole bank
free and 11 halves; bank 0 3,792 B, bank 1 825 B.

Not covered by the suite: the scene itself, with Arden after the routes of
scenes 20 and 21 (the case moves her with `ChangeEventLocation`; her row
is a walker's just the same), and the other three sides of a walker
turning in a cache map: only left is looked at.

**When merging**: no Rust changed, only `runtime/cache_slots.s`; the ROM
takes it from `~/the-advocate` once merged, with `just cartridges`.
