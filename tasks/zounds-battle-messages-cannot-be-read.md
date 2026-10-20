---
name: "Zounds: some battle messages cannot be read"
description: "Some lines of the battle's message window come out as garbage characters, as if the text were read from the wrong place or in the wrong encoding"
type: bug
status: testing
assignee: taro
agents: [Chajá]
---

Seen by taro on 2026-10-19, playing Zounds' delivery of that day (the ports `1182513`, the-advocate `2c350d8f`).

**What is seen**, in a capture taro sent, a battle in a cave against a
purple flower: the battle's window shows two lines that start with a name
and go on as garbage:

    Imaru|I'I?U0E'?I
    Kazar 3'I?_???[?W:dZo'-'1/2?I

(transcribed by eye; the first looks like a monster's name, the second
starts with Kazar's). Not every message: "some texts in the battle".

taro adds that it is **every battle** in Zounds, and the lines are the
ones of a hit: the party's on an enemy and an enemy's on the party. The
capture, inside a screenshot of the web view (top right):
`/shared/captures/2026-10-20-zounds-battle-text/taro-web-view.png`. Its two
lines read `Imarulli'I?UOE'?I` and `Kazar 3'I?_???[?W'dZo'-'1/2?I`.
More of them in `/shared/2026-10-19-multiple-bug-reports-zounds-frozen-world/`,
`zounds-0003` to `zounds-0006` (taro's: read, not moved): four hits, each
`<attacker><garbage>` over `<target> <number><garbage>`, with Imarulli,
Kazar and Uname, and damages 3, 11, 17 and 1. Names and numbers right; the
terms after them wrong.

## Chajá, 2026-10-19

**The cause: nine battle terms are RPG Maker 2003's Japanese defaults,
never translated.** Zounds' `terms.json` (ldb_id 2003) has `attacking`
= `‚Ì\x8dUŒ‚\x81I` —`の攻撃！` in Shift-JIS, read as Windows-1252— and the
same for `defending`, `actor_critical`, `enemy_damaged`,
`enemy_undamaged`, `actor_damaged`, `actor_undamaged`, `use_item` and
`hp_recovery`. The rest of the battle's terms are the game's Spanish
(`¡Victoria!`, ` XP obtenidos!`…). The converter's `term()` in
`rm2k-snes/mapdata/src/emit.rs` takes them as they are, `plain()` stands
each letter in —`‚` as `'`, `Ì` as `I`, `½` as `1/2`— and the runtime's
`ba_message` writes `<attacker><attacking>` and `<target> <n><damaged>`:
exactly taro's two lines.

**Why the author never saw it**: RPG Maker 2003's battle never shows those
nine. EasyRPG's `Game_BattleAlgorithm::*::GetStartMessage` asks for them
only `if (Feature::HasRpg2kBattleSystem())`, and the damage is a number
that floats over the target; for 2003 it has its own `easyrpg_battle2k3_*`
terms with English fallbacks ("Defend", "Observe"…). The port fights
Zounds' battles with the 2000 battle, which does show them.

The other ports: the seven RM2k games are ldb_id 0 and have those terms
in English, or empty (Desert Nightmare, Sunset over Imdahl). Only Zounds
is 2003.

**The fix** (the-advocate `chaja-battle-text`): in a 2003 database those
nine terms come from the project's new `[battle.terms]` —by liblcf's name;
any term the battle reads from the database can be given, in any game, and
a name it does not read stops the converter— or, without it, from plain
English stand-ins (`UNSHOWN_IN_2003` in `rm2k-snes/mapdata/src/emit.rs`),
as easyrpg falls back to English for its own 2003 lines. The battle's
`Db` learns `is_2003` from `System.ldb_id`. Zounds gives them in Spanish
(the ports `chaja-battle-text`): `Kazar ataca.` over `Pez Shark 7 HP
perdidos.`, `Pez Shark ataca.` over `Kazar no recibe dano.` Captures in
`/shared/captures/2026-10-20-zounds-battle-text/after-*.png`.

**The test**: `tests/test_zounds_battle_text.py` in the ports plays
Kazar's attack on the Pez Shark (the Piedra's case) and reads the lines
from `BA_MBUF`. Red with the global tools (2c350d8f): `("Kazar'I?UOE'?I",
"Pez Shark 7'I?_???[?W'd-^'|'1/2?I")`; green with the branch's. The rule's
own test: `a_2003_games_unshown_battle_terms_are_not_its_databases` in
mapdata's `emit.rs`.

**What else it hits**: nothing. Zounds is the only 2003 game in the
ports; the other eight are ldb_id 0 and keep their database's terms.

**Verified**: the crates touched (`cargo test` of battle, mapdata and
convert, green); every other port's cartridges byte for byte equal with
the global tools and with the branch's —ABL's release and its eight test
cartridges, and the release of the other seven games—, which stands in
for ABL's suite: no ROM but Zounds' moved. Zounds' four test files and
`just boot` from the ports' root, on the trees merged with main.

**To install when merging**: `just install battle mapdata convert`
(`rm2k-snes-battle`, `rm2k-snes-mapdata`, `rm2k-snes-convert`). Without the
new `rm2k-snes-convert`, Zounds' `[battle.terms]` is ignored and the
garbage comes back.

**What to look at playing**: any battle in Zounds; the hit's lines in
Spanish. The accents still go plain in battle (`dano`), as the Known
issue on accents says.
