---
name: "Enemies without a graphic on the way to Paradise"
description: "On the newest maps, on the way to Paradise, some battle enemies aren't drawn (or don't exist), playing with MSU-1"
type: bug
status: testing
agents: [Chajá]
assignee: taro
---

From taro, on 2026-10-05: "when I tried the newest maps (the way to
Paradise), I noticed that some enemies have no graphic (it isn't rendered or it doesn't
exist). This was with the msu." Played with the build
`2026-10-04-83e4886-3e0b7b59` or the previous one, on the console or the emulator,
with the tracks and the `.msu` alongside. Later he specified: "in the forest, right
as you enter from the world map, the one that takes you to Paradise, before the
agents with the hover tram appear. I think the enemies' name
was Ogre or something like that", and "it may be the Rogue Bandit".

## What it was

**The Oblings.** Their battler is from the RTP —the `Troll` and the `Hog`—, and the
converter looked for battlers **only in the game**: `find_file` in
`scene.rs` of `rm2k-snes-convert` passed them `with_rtp = false`, which came
from Python (`_file` in `tools/port/scene.py`, 9cae36fc) with the why "so as
not to change which ones get in without looking at it". Backgrounds did look
for it since 2026-09-27. Without a file, the enemy was left with battler
`$FF` in `member_battler` and the ROM drew nothing, without a line in
`converter.log`.

It isn't the `.msu`'s: it happens the same with MSU-1 and without it. Nor any of the other causes
the brief listed —the limit of seven battlers per troop, the palettes, the
VRAM, a large battler—: measured below.

**The Rogue Bandit doesn't have the problem**: it is troop 120, with `newbie`, which
is the game's, and it is drawn with and without MSU-1, in snes9x and in bsnes, before and
after the fix. In the original (BattleTest) it is the same drawing.

## What was measured

The troops of the brief's maps —105 to 108, 109 to 128, the farm— **are
just one**: 184 on map 105, the Agency guard, with `Sagencyg`, which is
drawn. None of those maps has random encounters. The forest (310 to 313)
and the world (66) are where the battles on the way are.

Of `release`'s 80 troops, **seven** fought without a drawing —all because of
this—: 118 (Oblingx2) and 126 (Obling and Green Wylden) on 310, which is
what taro saw; 136, 137, 138 and 139, the Oblings of the world (66, and 158
outside `release`); and 178, Dr. Vago on 76, who is `Man5`.

Each `release` troop, opened in Sector 27 by swapping its place in
`troop_id` for that of 100, compared pixel by pixel against the game's
composition (WRAM and screen), in **snes9x and bsnes, with and without MSU-1**: all 80
fine with the fix, in the four combinations. And the nine troops of 310
opened on the real 310, with its background, in the same four: fine.
mesen-s couldn't be added: it carries state from one console to the next in the
same process (what `test_cores.py` says), and it stops at the second
`Teleport`.

**The whole game**: of the 152 troops that some map or common event names,
14 have some battler from the RTP —the 7 above and 163, 164, 180, 182,
183, 186 and 188, from maps `release` doesn't carry—. Of the database's 300, 86;
that's 171 members of 442, with 42 images from the RTP. **No battler of the game
is missing on both sides**: with the fix, all are found. And no
troop in the game goes past three distinct battlers or four members.

## The fix

* `rm2k-snes-convert`: `find_file` looks in the game and then in the RTP,
  for backgrounds and battlers —the parameter is gone—; and if a battler isn't in
  either of the two, `converter.log` says so.
* `tests/harness/scene.py`: the same in `_file`, which is the tests' expected
  composition.
* `patches/auto/battlers/`: the five new ones (`Troll`, `Troll-20`, `Hog-20`,
  `Hog-340`, `Man5-320`), from `just patches`.

## The test

`test_scene_each_troop_of_the_cartridge_draws_everyone`, in
`tests/rpgmaker/test_battle_scene_drawing.py`: each `release` troop
against the game's composition, in WRAM and on screen. About 25
seconds. Without the fix, red with the seven:

    la 178 ['Man5']: 1065 pixeles en la WRAM y 1065 en la pantalla
    la 136 ['Hog']: 2024 pixeles en la WRAM y 2024 en la pantalla
    la 137 ['Hog']: 2024 pixeles en la WRAM y 2024 en la pantalla
    la 138 ['Hog', 'Hog']: 4048 pixeles en la WRAM y 4048 en la pantalla
    la 139 ['Troll', 'Hog', 'Hog']: 5182 pixeles en la WRAM y 5152 en la pantalla
    la 126 ['Troll', 'Orc']: 2626 pixeles en la WRAM y 2626 en la pantalla
    la 118 ['Troll', 'Troll']: 3306 pixeles en la WRAM y 3306 en la pantalla

It runs without MSU-1, like the suite: the path with MSU-1 was measured separately (above)
and doesn't stay in the suite, because the bug wasn't on that path.

## Dr. Vago

taro: "Dr Vago doesn't show up in his battle either". It is the same cause: troop
178, the only one with him, fights on 76 with the RTP's `Man5`. Sorbe's
walkthrough plays that battle and takes a picture of it,
`sorbe-y-la-curacion/05-la-pelea-con-vago`, but it was in
`pending.txt`, without a golden: nobody was checking whether Vago was there. With the fix
he is, and the picture becomes a golden (separate commit).

## To compare with the original

Wine's RPG_RT opens a standalone battle with `RPG_RT_2015.exe BattleTest 0 0
<tropa>`: the troop goes in the third argument (easyrpg's `player.cpp`). That is how
the captures of the original came out, without playing up to the battle.

## When merging

Tools: commit `1241e7de` on `01f84afd`, in the branch of Chajá's
worktree. It only touches `rm2k-snes-convert`: reinstall `convert` in the global
(`just -f tools/justfile install convert`) and rebuild `release`, which now
carries five more battlers. ABL: branch `chaja-enemigos-sin-grafico`.

What to play: a battle with Oblings in Tangle Forest or on the world map, and the one with
Vago on Sorbe's mountain.
