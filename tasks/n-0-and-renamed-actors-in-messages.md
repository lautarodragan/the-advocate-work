---
name: "\\N[0] and renamed actors in messages"
description: "A box with \\N[0] (the leader) or with the \\N[n] of an actor that some ChangeHeroName renames leaves out its whole page"
type: feature
status: testing
assignee: taro
agents: [Carpintero, Mulita]
---

Debt that Carpintero declared on 2026-10-05 when baking the names
(`n-n-in-messages.md`): `with_names`, in
`rm2k-snes/events/src/compile.rs`, writes the name from the database
into each `\N[n]` only if no `ChangeHeroName` in the game touches that
actor. `\N[0]` —the leader, which depends on who is in the party— and the
renameable actors stay as they are, and a box with that doesn't compile: the
page drops whole. It is still like that in the-advocate `fc6f7456`; the test
`an_actors_name_is_baked_into_the_text_unless_it_can_change` pins it.

What is known about the cause: the ROM's compositor doesn't write a name
at run time. `ChangeHeroName` doesn't compile today either, so a
page that renames is already out on its own (the
`EnterHeroName` screen is something else: `hero-name-screen.md`).

**Not measured today**: how many pages it leaves out in each game. On 2026-10-05
`\N[n]` in general affected four games —The Frozen World cut
its opening cutscene in map 4— and the baking unblocked that; what
remains is `\N[0]` and the renamed ones. `rm2k-snes-events culprits
--every-map`, on each game's `compile` request, says it.

taro, on 2026-10-15: do it even without `EnterHeroName`; `\N[0]` can be
tested by reordering the party.

## Measured (Mulita, 2026-10-15)

On the-advocate `97b51db6` and the ports `d9006cc`, `rm2k-snes-events
culprits --every-map` on each game's `release` request, and a scan of
every `ShowMessage` text and `ChangeHeroName` in each dump:

| game | pages out | `\N[0]` in text | `\N[n]` in text | `ChangeHeroName` |
|---|---|---|---|---|
| A Blurred Line | 138 | 0 | 0 | 0 |
| The Book of Three | 95 | 0 | 0 | 0 |
| Desert Nightmare | 117 | 0 | 0 | 0 |
| Doom's Day 2 | 85 | 0 | 8 (`\N[8]`) | 0 (one `EnterHeroName` on actor 8) |
| El Dorado | 89 | 0 | 0 | 0 |
| The Frozen World | 96 | 0 | 705 (11, 12, 13) | 0 |
| Sunset over Imdahl | 29 | 0 | 0 | 2, on one page (actor 1, "Completed Game", "Saved Game") |
| Vampires Dawn | 1614 | 0 | 0 | 0 |

So **no page of the eight is out today because of `\N[0]` or a renamed
`\N[n]`**: no game writes `\N[0]`, and the only `ChangeHeroName`s are
Sunset's two, on a page (map 35, event 1) that `ControlVars` and
`ControlSwitches` on ranges keep out too. Sunset renames its hero so that
RM2k's save screen, which shows the leader's name, reads "Completed
Game": what makes that work is the slot screen showing the saved name, not
the message. Doom's Day 2's `\N[8]` are baked, since `EnterHeroName` is not
`ChangeHeroName`; its page with `EnterHeroName` is out on its own
(`hero-name-screen.md`).

## Plan

* `\N[0]` and the `\N[n]` of a renamed actor: a mark in the text block,
  `NAME` and the actor (0 the leader), that the composer turns into the
  name's letters when the box opens, like `\V[n]`. The letters come from the
  cartridge's text table —`actor_txt`, the same name the battle and the
  equipment screen draw—, by pointing `msg_ptr` at it for its letters.
* `ChangeHeroName`: `OP_CHANGE_NAME` (0x54), the actor's rename slot and
  which of the game's renames. The set of names is known when building: the
  literals of every `ChangeHeroName`. One byte of far RAM per renamed
  actor, in the save; everything that draws a name —messages, menu, slot
  screen (from the saved game), battle, equipment, skills, level up— asks
  one routine.
* The line keeps its width as RM2k does: no rewrap, the composer cuts at
  the window's edge.

## Done (Mulita, 2026-10-15)

the-advocate, branch `mulita-leader-name`:

* `551703da`: the `NAME` mark ($FD, one pair fewer: 157) and the actor, 0
  the leader; `msg_name_mark` in the new `runtime/actor_names.s` points
  `msg_ptr` at the name's text and hands its letters out like a variable's
  digits. `OP_CHANGE_NAME` (0x54; 0x55 not used): the actor's place among
  the renamed (`name_actor`) and which rename (`name_txt`, from one).
  `ACTOR_NAME`, `NAME_SLOTS` bytes of FARBSS —none in a game that renames
  no one—, in the save right before the experience. The battle, the
  equipment, skills and level-up screens ask `actor_name_txt`; the menu
  `actor_name_row_now`; the slot screen `actor_name_row_saved`, from the
  SRAM. Test pages' `ChangeHeroName`s count as the game's.
* `b6444bb9`: a troop page's box writes `\V[n]` and names too
  (`ba_page_message`). Before, it drew the mark and the slot as two letters:
  The Book of Three's "TARAN was able to steal \V[0008] silver".
* `cd180a9b`: the test game's `test_leader_name.py`, three cases and seven
  goldens: the leader before and after reordering, a rename and the menu,
  an empty party, and the rename through save, reset and load —the slot
  screen shows the saved name—. Seen red with the tools before: the
  cartridge did not build. The save test runs on snes9x only (bsnes keeps
  the SRAM between consoles and does not expose it).

Pages left out, `culprits --every-map`, before and after: the same in all
eight games (138, 95, 117, 85, 89, 96, 29, 1614): no game has a page
waiting only on this. Sunset's `ChangeHeroName` is no longer a culprit;
its page is still out for its `ControlVars` and `ControlSwitches` on ranges.

* `b7bd02b4`, `08042d07`: the pull the battle's digits branch on, said;
  and `actor_names.s` moved to bank 1, since Sunset —which renames its
  hero, so it carries that code— overflowed `FAR2` by 14 bytes.
* Ports, `mulita-leader-name`: ABL's `linter-exceptions.txt` takes
  `ba_page_message bpl put_digits`, the same as `msg_letter`'s.

Space, `just space` in ABL, before → after: release bank 0 944 → 921 B,
bank 1 1455 → 1227 B, $C0 2795 → 2580 B, far RAM 12 → 12 B (ABL renames
no one); the tightest bank 1 is test-msu's, 872 → 644 B. Sunset over
Imdahl's release after: $C0 340 B, bank 1 1092 B.

Verified: `just test` (29), `just rust-test`, `just test-game` (11 passed,
the save test skipped on bsnes), ABL `just tests` with the branch's tools
(1553 passed, 2 skipped; no golden moved), `just boot` at the ports' root
(43 passed). Not covered by any test: a troop page's box with `\V[n]` or a
name —The Book of Three's are not on its walkthrough—; and `EnterHeroName`,
still out (`hero-name-screen.md`).

To install when merging: `events`, `mapdata`, `screens`, `convert` and
`cartridge` (the runtime changed).

Book, branch `mulita-leader-name`: divergence "What names in messages do
not model" and its row in internals/events.md.
