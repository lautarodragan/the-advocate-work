---
name: "Zounds: the repository lacks 197 assets the data references"
description: "22 chipsets, 15 charsets, 17 songs, 131 sounds, 6 backdrops, 2 facesets, a monster, a panorama, a picture and the System2 are referenced and not in the repo: 108 are the RM2k3 RTP (not in ~/assets), 43 the RM2k RTP under other names, 55 are nowhere"
type: chore
status: doing
assignee: Aguará
agents: [Aguará]
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
over the clone of `lautarodragan/zounds` at `5fa54e6`, classified against
EasyRPG's `rtp_table.cpp` (every language's names).

**By class** (missing / of which RM2k3 RTP / RM2k RTP / nowhere):
ChipSet 22 / 2 / 13 / 7; CharSet 15 / 6 / 2 / 7; Music 17 / 3 / 1 / 13;
Sound 131 / 75 / 19 / 37 (most of the sounds come from the RTP battle
animations copied into `Battle/`); Backdrop 6 / 4 / 1 / 1; FaceSet 2 / 2
/ 0 / 0; Monster 1 (`bahamut`) / 1; Panorama 1 (`strange`) / 1; Picture
1 (`Discos Test`) / 0 / 0 / 1; System2 1 (`system2c`) / 1. The 13 RM2k
RTP chipsets found by name (`chipset6`, `ff6_town`, `ps4`…) are RTP
*file names*, which is how the RPG Advocate RTP came, so they are likely
right.

**What it means**: the RM2k3 RTP is needed to build the game as it is
—`~/assets` has RM2k's `rtp.zip` and `rtpe/`, not 2003's—; and 55 files
—custom chipsets like "Zoundz's Castle" and "Cueva de lava", charsets like
`Zounds_Chest_1`, 13 songs, 37 sounds— were never committed and only
taro may still have them. The study built with placeholders
(`~/scratch/aguara/zounds/placeholders.py`); the full lists are in
`~/scratch/aguara/zounds/missing.json`.

**taro, 2026-10-16**: the 55 that are nowhere are probably lost (said on 2026-10-15); the free RTP of EasyRPG for RM2k3 goes to `~/assets` to cover the 108 of the RM2k3 RTP ("Dale"). Taken by Aguará.
