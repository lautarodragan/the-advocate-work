---
name: "Port Zounds, an RPG Maker 2003 game"
description: "A study of how much of Zounds —taro's game, made in RPG Maker 2003— works today with the tools: the project, Ditto with the 2003 fields, what compiles, which commands are missing, and what 2003 battles and .wav music would need"
type: research
status: wishlist
agents: [Aguará]
---

From taro, on 2026-10-05: "I'd like to try something different: port another
game, and see how well it works … I have a game I made myself (back in the day).
it was never finished, but I'd like to see it on the SNES". It is
https://github.com/lautarodragan/zounds, cloned in `/extras/zounds-rm`.

What was seen when cloning it: the database is **RPG Maker 2003**'s
(`ldb_id` 2003), with `BattleCharSet/` and `System2/`; 188 maps; 34 MIDI and
19 `.wav` in `Music/`. Ditto reads it, but what is specific to 2003 —battle
commands, classes, battler animations— falls into `unknown`.

taro, on 2026-10-05, on seeing it is 2003: "better to try another game
first, then … an rpg maker 2000 one". It stays for after porting
a second RM2k game.
