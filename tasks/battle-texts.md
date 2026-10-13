---
name: "The battle texts"
description: "Battle messages cut at 31 characters or running past the edge"
type: bug
status: done
assignee: taro
---

**The battle texts that don't fit in the width of the screen.**

Two cases, both on the battle screen:

- **The troop page messages are cut at 31 characters.**
  Some lines of `Absorb Aura` reach 40 ("RainDrop... GatheringWaves...") and
  lose the second technique.
- **The battle's own message runs past the edge** instead of being cut:
  "Talan has absorbed the enemy aura!". It was already like that before the troop
  pages.

They come from `talan-battle-system.md`.

**Another case, seen on 2026-09-26 while doing the elixir in battle**: "Kersh
Pungent Elixir-LIFE  used." goes past 32 columns and the full stop falls in column
0 of the line below, in front of "Core has revived!". It happens with any
item with a long name, and the name in the LDB has a trailing space.

**Two more, since the per-turn and per-HP pages run (2026-09-28)**: the
take-off in the agents' battle comes out "The Captain has taken off in th", and
the Rat King's second call loses the "s" of "sounds". See
`tasks/release-troop-events.md`.

# What was done (Cardenal, 2026-10-02)

**What the blame said about the cap of 31.** It's born in `a7cd387a` (2026-09-21), "Las
páginas de tropa se compilan", as `BA_PAG_MSG_ANCHO = 31`: it's what fits
from column 1 on a 32-cell screen, and the comment already said
that the up-to-forty lines of Talan's systems lost their
second technique, and that it was declared debt. The `messages_troop` block was
built with the map's window —39 columns— and the ROM cut when drawing.
It was a conscious decision to leave it for later, not to cut.

The battle's own messages are built by gluing pieces together since the first
version (`9527063d`): nobody decided they would run over, how long they are was
never measured. Measured over the LDB: 43 actor and skill pairs go past 31 on the
first line, the longest at 41, and 3 `using_message2` on the second, the
longest at 50 (the one for skill 144, Manta's).

**The troop pages** (the first commit): the compiler redoes the pages'
boxes for the battle window —31 by 4— with the same `refit`
the map's use for their own (`reflow` in `troops.rs`); the converter
passes it the window in the request, `troop_window`, with the width that
`rm2k-snes-battle layout` answers. The ROM doesn't change. "The Captain has taken off in
the ship!" comes out in a three-line box with TALAN at the top.

Tests, in ABL: `test_the_liftoff_reads_whole` reads the screen —not the
cartridge— and requires the whole text from the LDB; red before: "The Captain has
taken off in th". The ones that compared the block against the LDB
(`test_troop_events.py`, `test_troop_systems.py`) now compare
against the redone boxes (`screen_stage.refit`).

**The battle's own messages** (the second commit, in the ROM):
`ba_message` no longer writes letter by letter on the screen. It builds RM2k's two
lines in `BA_MBUF` —`ba_put`, `ba_put_text`, `ba_put_name`,
`ba_put_number`— and `ba_flow` splits them at the spaces into lines of 31
(a longer word, at the edge), and draws them from the bottom: with two or
fewer they go where they always went, and with more they go up over the party's, which is
what RM2k's message window covers. Up to four.

- RAM: `$7E7B00`-`$7E7BFF`, in `far_ram.s` (`BA_MBUF` and company). No
  symbol of the three cartridges fell there —measured over `abl.sfc.sym`—, and it doesn't
  touch `FAR_PAIR_LIST` (`$7E2400`-`$7E257F`).
- `ba_number_exact` is gone: only `ba_message` used it.

Tests, in ABL (`test_battle.py`): `test_the_elixir_message_fits_on_screen`
and `test_the_detect_aura_message_fits_on_screen` read the screen and
require the lines that `envolver` gives, the rule written in the test.
Red before: `'#Kersh Pungent Elixir-LIFE  used'` —the `#` is the cell the
full stop stomped on— and `'####an has perceived the enemy a'`.

**No golden moved**: none shows a message that runs over. The
captures of the new cases, before and after, in
`/shared/captures/2026-10-02-textos-de-la-pelea/`.

**What's left**: `ba_page_message`'s cut remains, for a line that
`refit` can't split (a word longer than 31). A page with `\V[n]`
that grows when the digits are put in is also cut at the edge, as in the
map.

# What taro has to look at

- **The agents' battle** on the terrace (map 32): after the
  shake, "TALAN / The Captain has taken off / in the ship!", whole.
- **The Rat King**: both calls, the second with its "sounds".
- **Talan's Absorb Aura**: the techniques he learns, now uncut.
- **Using the Pungent Elixir-LIFE** in a battle: "Kersh Pungent Elixir-LIFE"
  / "used." / "Core has revived!", three lines, the first over the place
  of the party's fourth.
- **Any skill with a long name**: Detect Aura, Mindshield, Manta's.
  If the message has more than two lines, it covers the last ones of the
  party while it lasts: on purpose, like RM2k's window. Decide
  while playing whether it reads well.

# On merging

- Install in the global: `just -f tools/justfile install events convert`
  (and `cartridge`, which builds with the checkout's runtime). `battle` only
  changed a comment in this fix; with the critical-hit one it gets installed anyway.
- Branches: `worktree-agent-a33a321932dffd972` here, `cardenal-textos-y-critico`
  in the ABL clone (`/extras/scratch/cardenal/abl`).
