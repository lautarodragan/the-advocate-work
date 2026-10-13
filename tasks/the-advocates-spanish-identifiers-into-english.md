---
name: "the-advocate's Spanish identifiers into English"
description: "The Spanish names left in runtime/ and in the tools' tests —labels, constants, test names—: renames that change no ROM byte but do change the symbols the ports read"
type: refactor
status: done
agents: [Hurón]
assignee: taro
---

taro, on 2026-10-12: `the-advocate` goes in English entirely (see "The
independent projects are in English" in `AGENTS.md`). This is the half
that can break a build or a test, so it goes last and through the whole
suite: names in code. The prose is
`the-advocates-prose-into-english.md`, in parallel.

## The list (Hurón, 2026-10-12)

Measured from the-advocate 57abdca3. Phase 2 of the translation
(`translate-the-tools-phase-2-the-runtime-and-what-crosses-over.md`)
already turned ~4300 runtime identifiers into English word by word, so
what is left is not Spanish words in plain sight but **what the
dictionary carried over word by word**. How it was found:

* every identifier of `runtime/*.s` —code only, no comments or strings—
  split into words, ~1470 distinct, read one by one: the only Spanish word
  left is `su` (`in_su_place`, from `en_su_lugar`);
* the old → new pairs rebuilt from the diffs of the phase-2 commits
  (3330 pairs), searched for Spanish words that the dictionary translated
  with the wrong sense or left as they were: `mira_a` ("look at A") became
  `faces_a`; `si` ("yes") became `if`; `o` ("or") and `se` stayed;
  `al_dia` ("up to date") became `to_day`; `la_tengo` ("got it") became
  `have`;
* the symbols of ABL's `.dbg` that do not come from the runtime —what the
  converter emits— split the same way: all English.
* `tests/*.py`: the test names are English; `test_index.py` keeps Spanish
  variables (`AQUI`, `NOMBRADA`, `texto`, `indice`, `faltan`, `sobran`).

Renamed (all local labels, except `MUS_LOG_YES`):

| was | is | where |
|---|---|---|
| `in_su_place` | `in_place` | camera.s, msu_effects.s |
| `faces_a`, `{a,b,c,h,i,l,p,r}_faces_a` | `check_a`, `*_check_a` | battle_run, shop, equipment_screen, menu, items, variables, slots, end_game |
| `faces_up`, `faces_down`, `faces_up_act`, `faces_down_act` | `look_up`, `look_down`, `look_up_act`, `look_down_act` | battle_run.s |
| `faces_step`, `faces_start` | `check_step`, `check_start` | oam.s, title.s, game_over.s |
| `faces_lists` | `faces_ready` | slots.s |
| `if_a` | `a_pressed` | battle_run.s, shop.s |
| `a_returns_a_items` | `a_back_to_items` | battle_run.s |
| `sia_yes`, `sia_no`, `sia_skill`, `sia_eq_other` | `actor_yes`, `actor_no`, `actor_skill`, `actor_eq_other` | interpreter_conditions.s |
| `turn_yes` | `its_turn` | battle_troop.s |
| `lo_found` | `found_it` | party.s |
| `pick_6` | `second_voice` | sound_effects.s |
| `is_is` | `in_this_zone` | encounters.s |
| `have` | `got_it` | battle.s, msu_effects.s |
| `no_found` | `not_found` | battle_scene.s |
| `no_goes` | `does_not_go` | equipment_screen.s |
| `to_day` | `up_to_date` | boot.s |
| `to_final` | `at_end` | audio_package.s |
| `to_own` | `to_ally` | battle.s |
| `hero_was` | `was_hero` | action_key.s |
| `from_a_many` | `many_targets` | battle_skills.s |
| `already_no_se_saw` | `already_hidden` | timer.s |
| `fix_o_speed` | `fix_or_speed` | event_routes.s |
| `with_route_o_graphic` | `with_route_or_graphic` | event_pages.s |
| `MUS_LOG_YES` | `MUS_LOG_ON` | far_ram.s, music.s, sound_effects.s; read by two ABL tests |

Left, on purpose:

* The one-letter prefixes of the battle and shop modes (`o_`, `b_`, `h_`,
  `i_`…): they come from Spanish initials (`o` is *orden*), but a single
  letter is not a word and renaming them is noise.
* What reads oddly but is English and says the right thing: `look_page`,
  `look_var`, `pass_look`, `the_chosen`, `the_set`, `to_one`,
  `from_four`, `if_gold_picks`…
* The citations of the ports' Spanish names in runtime comments
  (`Partida.go_to_map`, `Partida.lost_frames`): they name the
  harness, which stays in Spanish.
* The file names the tools write into a port's `build/` —`memory.cfg`,
  `music.json`, `effects.json`, `crudos/`, `patches/uses.json`,
  `stamp.txt`— and `lda tabla, x` in the comment `rm2k-snes-audio` emits:
  they belong to the already-English projects, are not symbols, and the
  ports' harness opens several of them by name. A draft of their own:
  [the-tools-write-spanish-file-names-into-build.md](the-tools-write-spanish-file-names-into-build.md).

## Done

Branches `huron-identificadores` in the-advocate and in the ports, with
`main` merged into both (the-advocate's has Tijereta's prose).

the-advocate:

1. `81df01f4` the 38 local labels; `29567e78` `MUS_LOG_YES` →
   `MUS_LOG_ON`. Each verified on its own: `just cartridges` in ABL with
   `cartridge` installed from the branch gives the 74 `.sfc`, `.msu` and
   `.pcm` of release and the five test cartridges byte for byte equal to
   57abdca3's, and the six `.dbg` keep every symbol with the same id,
   value, type, size and scope —only the renamed names change—. Both are
   in `.git-blame-ignore-revs` (`11655279`).
2. `fbd75790` `test_index.py`'s variables.
3. `8975ce86`, comment only: the header of `sound_effects.s` cited the
   second effect voice as `SE2_VOZ`, a name that exists nowhere; it is
   `SE_VOICE2`, in `voices.rs`.

The ports: `e1d4a40`, the two tests that write `MUS_LOG_YES` by name and
a docstring that cited `sia_yes`.

On the merged tree: `abl.sfc` e00d8994… (the same as main's), ABL's
suite 1220 passed, `just test` 27 passed.

When merging: nothing to reinstall —no Rust changed—; the runtime is
taken from the checkout the tools were installed from, so `just
cartuchos` rebuilds from merged main on its own. The ports branch has to
go in together with the-advocate's, or the two music-log tests stop
finding the flag.
