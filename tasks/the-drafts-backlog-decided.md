---
name: "The drafts backlog, decided"
description: "107 drafts, mostly the agents', waited for taro to read them; one pass with AGENTS.md's criteria: each goes to todo, is closed, or carries a question for taro in its own log, assigned to them"
type: docs
status: doing
assignee: cardon
agents: [cardon]
author: taro
---

**Why**: on 2026-11-24 there were 107 drafts —the agents' findings,
mostly— and they piled up faster than taro could read them. That day taro
asked Hornero to decide them, asking only what is theirs to decide, and
the criteria went into AGENTS.md, after "A finding that is not fixed is a
draft".

> I'm thinking that maybe you could review the drafts created by agents and
> decide if they can go to `todo` as they are, or ask me if you think it
> needs my feedback.

> If the ones that need my opinion are more than 5-10, maybe it's best to
> leave the reasoning in a file, or inside the tasks themselves, so we can
> tackle it asynchronously and your reasoning is not lost in the chat
> history.

(taro, 2026-11-24, in their words, translated)

**What is asked**: every task in `draft`, one at a time, with AGENTS.md's
criteria:

* **to `todo`** when all four hold; a log entry says why;
* **closed** —`cancelled`, or `duplicates` with the link— when another
  change already fixed it or a later plan makes it moot (for example the
  stages becoming libraries, `one-advocate-command`, the tests without
  oracles, ABL's test cartridges moving to the test game); a log entry says
  why, and what fixed it if something did;
* **a question for taro** otherwise: a log entry "a question for taro"
  with what there is to decide, the options and a recommendation, and
  `assignee: taro`;
* **stays a draft** only if it is not verified yet and verifying it is
  cheap: then say what would verify it.

Hornero reviews the whole pass before it merges.

## Log

### 2026-11-24, Hornero: taken by Cardón

Nothing done yet.

### 2026-11-24, Cardón: the pass, in four batches

108 drafts at b16b110 (one more than the 107 of the morning). Read against
the-advocate `8b069fc2`, the ports `4c23c9e` and the book `1b195d7`, and
against the plans of the same day: the book's decision "One command, and
no tool of ours runs another", `the-stages-speak-json-nobody-types`,
`one-advocate-command`, `a-stage-s-cache-key-once-it-is-a-library`,
`battle-tests-without-simulate`, `tests-without-the-stages-subcommands`,
`abl-s-test-cartridges-become-test-game-cases` and
`the-volume-ceilings-are-measured-without-a-rom`. Reading and `git log`
only: no suite was run. Each draft carries its decision in its own log.

### 2026-11-24, Cardón: every draft decided

All 108, in four commits by alphabetical batches; links written with
`nu tasks/tasks.nu link`: the six `duplicates`,
`the-trim-guesses-which-maps-go-painted` blocks
`painted-events-chooses-its-maps`, and two `relates`. None touches
`the-stages-speak-json-nobody-types`, which other agents are appending
to: the drafts that are its steps B0–B4 already carried `part-of` it.

#### The counts

| Decision | Count |
|---|---|
| to `todo` | 52 |
| cancelled | 8 |
| duplicates (cancelled, with the link) | 6 |
| a question for taro (`draft`, `assignee: taro`) | 37 |
| stays a draft | 5 |

`nu tasks/tasks.nu ls -s draft -a taro` lists the questions; the five
left as drafts each say what verifies them.

#### Every draft

| Draft | Decision | Why |
|---|---|---|
| [`a-cartridge-whose-link-failed-is-taken-as-up-to-date`](a-cartridge-whose-link-failed-is-taken-as-up-to-date.md) | to `todo` | `Cartridges::build` (cartridges.rs 862-871) never deletes the old stamp before converting |
| [`a-character-stands-on-its-middle-pattern`](a-character-stands-on-its-middle-pattern.md) | to `todo` | `page_graphic` (convert/src/maps.rs:64) still takes the page's pattern; towards RM2k, RPG_RT checked |
| [`a-medicine-on-the-whole-party-heals-one`](a-medicine-on-the-whole-party-heals-one.md) | to `todo` | `target_scope` (actor_choice.s 362-372) still $FF for any medicine; towards RM2k |
| [`a-page-change-restarts-a-route-with-the-same-commands`](a-page-change-restarts-a-route-with-the-same-commands.md) | to `todo` | `apply_pages` (event_pages.s:391) still restarts; easyrpg's `RefreshPage` keeps the index |
| [`a-revived-actor-keeps-its-conditions-in-battle`](a-revived-actor-keeps-its-conditions-in-battle.md) | to `todo` | no purge at the fall (party_states.s:502, battle_items.s `fallen`); towards RM2k |
| [`a-transparent-window-over-a-flattened-panorama-shows-striped-edges`](a-transparent-window-over-a-flattened-panorama-shows-striped-edges.md) | to `todo` | reproduced on three cores, narrowed to BG2's tiles; garbage, nothing to argue |
| [`a-troop-page-s-box-drops-its-icons`](a-troop-page-s-box-drops-its-icons.md) | to `todo` | `carrying(&[])` still in events/src/messages.rs; towards RM2k; relates to the stages task |
| [`a-window-that-opens-late-builds-its-tables-past-the-vblank`](a-window-that-opens-late-builds-its-tables-past-the-vblank.md) | to `todo` | measured by the probe, unchanged since; the fix (double-buffered tables) is written |
| [`abl-s-eraseevent-tests-leave-for-the-test-game`](abl-s-eraseevent-tests-leave-for-the-test-game.md) | to `todo` | first move of the approved test-cartridges plan; test game covers it (`e93c89ae`) |
| [`abl-test-cores-event-red-once-in-a-full-run`](abl-test-cores-event-red-once-in-a-full-run.md) | to `todo` | three test_cores reds = an uninitialised read; a bug, reproduce then find it |
| [`an-event-with-no-graphic-stops-blocking-the-hero`](an-event-with-no-graphic-stops-blocking-the-hero.md) | to `todo` | reproduced on the test game, bug against RM2k, nothing to choose |
| [`an-input-number-after-a-label-has-no-message`](an-input-number-after-a-label-has-no-message.md) | to `todo` | still so (`number_inputs`, compile.rs:2808); RPG_RT's behaviour is the fix |
| [`arrancan-sunset-stale-right-after-built`](arrancan-sunset-stale-right-after-built.md) | to `todo` | flaky test seen twice; likely cause is the PATH-builder fingerprint draft |
| [`automatic-common-events-sound-only-where-the-map-carries-it`](automatic-common-events-sound-only-where-the-map-carries-it.md) | to `todo` | still parallel-only (events/src/lib.rs:1284-1306); same fix as the parallel ones on 2026-10-20 |
| [`build-oam-costs-a-third-of-the-frame-on-busy-maps`](build-oam-costs-a-third-of-the-frame-on-busy-maps.md) | to `todo` | measured, untouched since; frames lost on ABL map 11, nothing seen changes |
| [`change-event-location-s-facing-is-not-applied`](change-event-location-s-facing-is-not-applied.md) | to `todo` | still dropped (compile.rs:6490); same as Teleport's facing, `ac0b848b` |
| [`change-event-location-shifts-the-npc-table-per-event`](change-event-location-shifts-the-npc-table-per-event.md) | to `todo` | measured, `fit_far` untouched; rest of the Lazer Teeth lag |
| [`common-picture-sets-the-cartridge-carries-for-nothing`](common-picture-sets-the-cartridge-carries-for-nothing.md) | to `todo` | cartridge-space debt, obvious fix, untouched since `54cf582b` |
| [`desert-nightmare-light-masks-placed-by-an-anchor`](desert-nightmare-light-masks-placed-by-an-anchor.md) | to `todo` | still refused (map_pictures.rs:460/492); towards the original, way already said |
| [`desert-nightmare-the-warehouse-is-darker`](desert-nightmare-the-warehouse-is-darker.md) | to `todo` | wrong picture by the "shown most" rule (map_pictures.rs:524); towards the original |
| [`el-dorado-characters-cut-on-crowded-lines`](el-dorado-characters-cut-on-crowded-lines.md) | to `todo` | measured like its siblings in todo; taro set the way on 2026-11-22: no flicker, the converter's ways first |
| [`frozen-world-plates-in-the-battle-are-drawn-with-other-colours`](frozen-world-plates-in-the-battle-are-drawn-with-other-colours.md) | to `todo` | captured bug against the original, untouched since; trade asked if palettes are full |
| [`fxpak-s-pty-tests-share-ptsname-s-buffer`](fxpak-s-pty-tests-share-ptsname-s-buffer.md) | to `todo` | flaky test, `ptsname` at pty.rs:107, `ptsname_r` fixes it |
| [`mapdata-packs-tiles-with-its-own-copy-of-voodoo-s-code`](mapdata-packs-tiles-with-its-own-copy-of-voodoo-s-code.md) | to `todo` | code debt still there (snes.rs, emit.rs:1898), byte-for-byte check |
| [`msu-data-seek-does-not-forget-where-the-effects-left-the-port`](msu-data-seek-does-not-forget-where-the-effects-left-the-port.md) | to `todo` | msu1.s never resets `MSU_SE_NEXT`; fix `7794939c` on chaja-msu-raw-2, not in main |
| [`record-scene-and-panorama-write-their-tables-outside-the-inc-writer`](record-scene-and-panorama-write-their-tables-outside-the-inc-writer.md) | to `todo` | `Inc` debt still in record/scene/panorama/posed, byte-for-byte check |
| [`rm2k-snes-images-leaves-a-relative-under-relative-to-the-current-directory`](rm2k-snes-images-leaves-a-relative-under-relative-to-the-current-directory.md) | to `todo` | still so (`Background::resolve` skips `under`); one-line fix, no ROM change |
| [`six-sweeps-in-scan-rs-are-one-with-another-predicate`](six-sweeps-in-scan-rs-are-one-with-another-predicate.md) | to `todo` | still so at `8b069fc2` (scan.rs 71-161); code debt, fix written, verified byte for byte |
| [`the-attack-says-undamaged-for-a-miss`](the-attack-says-undamaged-for-a-miss.md) | to `todo` | still so (battle_message.s 78-118); text towards RM2k, RPG_RT capture taken |
| [`the-battle-leaves-teleport-and-escape-skills-out-of-the-list`](the-battle-leaves-teleport-and-escape-skills-out-of-the-list.md) | to `todo` | still so (rules.rs 93); towards RM2k, greying already exists |
| [`the-battle-s-item-list-leaves-out-what-it-cannot-use`](the-battle-s-item-list-leaves-out-what-it-cannot-use.md) | to `todo` | still so (rules.rs 319, its comment says RM2k lists the rest); towards RM2k |
| [`the-cached-dbg-test-sees-a-date-move`](the-cached-dbg-test-sees-a-date-move.md) | to `todo` | flaky test with exact output; assemble.rs 241 unchanged, side two still has no fixed date |
| [`the-cartridges-fingerprint-hashes-the-path-s-builder`](the-cartridges-fingerprint-hashes-the-path-s-builder.md) | to `todo` | still so (cartridges.rs 630-640); fix is hashing the running binary, best inside one-advocate-command |
| [`the-converter-reads-the-stages-answers-with-python-s-truthiness`](the-converter-reads-the-stages-answers-with-python-s-truthiness.md) | to `todo` | step B4 of the-stages-speak-json-nobody-types's plan (in doing) |
| [`the-converter-writes-the-emission-s-request-by-hand`](the-converter-writes-the-emission-s-request-by-hand.md) | to `todo` | step B1 of the-stages' plan |
| [`the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures`](the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures.md) | to `todo` | step B0 of the-stages' plan |
| [`the-emission-reads-the-screens-answer-and-the-battle-model-by-name`](the-emission-reads-the-screens-answer-and-the-battle-model-by-name.md) | to `todo` | steps B2/B3 of the-stages' plan |
| [`the-event-compiler-s-left-out-warning-never-reaches-the-log`](the-event-compiler-s-left-out-warning-never-reaches-the-log.md) | to `todo` | still so (pages.rs 483); warning in the answer, printed once; no ROM change |
| [`the-farm-s-goldens-move-with-the-bank-packing`](the-farm-s-goldens-move-with-the-bank-packing.md) | to `todo` | seen twice (with its duplicate); a golden that moves with packing is a flaky test |
| [`the-inc-s-constants-are-format-strings-with-their-values-far-below`](the-inc-s-constants-are-format-strings-with-their-values-far-below.md) | to `todo` | still so (emit.rs 682); code debt, byte-for-byte verifiable, after phase B |
| [`the-items-screen-s-bar-runs-ahead-of-its-text`](the-items-screen-s-bar-runs-ahead-of-its-text.md) | to `todo` | seen twice frame by frame; `items.s` still has no `tl_settled`, the equipment's and shop's fix applies |
| [`the-lowering-takes-the-boot-start-on-every-map`](the-lowering-takes-the-boot-start-on-every-map.md) | to `todo` | `wally/src/map.rs:1742` still passes `starts` to `layers::below` ignoring `boots_here`; one-line fix, nothing seen changes |
| [`the-on-screen-timer-is-expensive-to-draw`](the-on-screen-timer-is-expensive-to-draw.md) | to `todo` | profiled ~18 lines/frame, `timer_oam` unchanged; lossless CPU |
| [`the-skills-command-does-not-ask-for-a-condition-that-stops-acting`](the-skills-command-does-not-ask-for-a-condition-that-stops-acting.md) | to `todo` | `menu_list.s:977-979` reads only HP; `ic_can_act` already does CanAct |
| [`the-slot-screen-shows-no-hp`](the-slot-screen-shows-no-hp.md) | to `todo` | seen against the original; towards RM2k with nothing to choose; `layout.rs:41` unchanged |
| [`the-tools-checkout-is-searched-for-a-game-s-resources`](the-tools-checkout-is-searched-for-a-game-s-resources.md) | to `todo` | `convert.rs:2209` still searches `suite::root()`; debt, byte-for-byte verifiable |
| [`the-trim-guesses-which-maps-go-painted`](the-trim-guesses-which-maps-go-painted.md) | to `todo` | `game.rs:607`/`maps.rs:604` still use the knob alone; blocks painted-events-chooses-its-maps |
| [`vampires-dawn-characters-cut-on-crowded-lines`](vampires-dawn-characters-cut-on-crowded-lines.md) | to `todo` | as its siblings (ABL, BoT, DN in todo); taro set the way 2026-11-22 |
| [`zounds-a-sign-drawn-with-a-tile-lets-the-hero-walk-on-it`](zounds-a-sign-drawn-with-a-tile-lets-the-hero-walk-on-it.md) | to `todo` | bug vs RM2k (`WouldCollide`) with reproduction |
| [`zounds-characters-cut-on-crowded-lines`](zounds-characters-cut-on-crowded-lines.md) | to `todo` | as its siblings; taro set the way 2026-11-22 |
| [`zounds-condition-messages-are-japanese-defaults`](zounds-condition-messages-are-japanese-defaults.md) | to `todo` | seen on screen; the battle terms' fix (`UNSHOWN_IN_2003`) is the pattern |
| [`zounds-map-96-keeps-its-ceiling-above-for-its-statue`](zounds-map-96-keeps-its-ceiling-above-for-its-statue.md) | to `todo` | still no lowering line for map 96; the generic reach rule, towards RM2k |
| [`a-face-s-cells-step-runs-past-the-vblank`](a-face-s-cells-step-runs-past-the-vblank.md) | cancelled | fixed by the-advocate `8ba23af2`, test `test_the_faces_cells_go_up_inside_the_vblank` |
| [`a-snes9x-savestate-round-trip-is-not-exact`](a-snes9x-savestate-round-trip-is-not-exact.md) | cancelled | snes9x's, not ours; `96cec117` keeps only the exact power-on savestate, `test_retro.py` holds it |
| [`far3-has-669-bytes-left-in-zounds`](far3-has-669-bytes-left-in-zounds.md) | cancelled | overtaken by FAR4, `8b2e7b2a`; `just space` says the rest |
| [`painted-map-strips-may-land-on-a-big-picture`](painted-map-strips-may-land-on-a-big-picture.md) | cancelled | path does not exist: `paint_flush` (vblank.s:142) sits in `map_up`, skipped with a big picture up since `40cbad47` |
| [`test-msu-boots-different-from-its-twin-once-on-bsnes`](test-msu-boots-different-from-its-twin-once-on-bsnes.md) | cancelled | seen once on 10-20, never again in a month of merge suites, its log gone; test-msu leaves ABL per abl-s-test-cartridges-become-test-game-cases |
| [`the-converter-s-command-line-is-clap-s-builder-read-back-by-hand`](the-converter-s-command-line-is-clap-s-builder-read-back-by-hand.md) | cancelled | moot by one-advocate-command: the converter becomes a library, its command line goes |
| [`the-far-code-banks-are-nearly-full`](the-far-code-banks-are-nearly-full.md) | cancelled | the-advocate `8b2e7b2a` added FAR4, the room asked for; bytes left are `just space`'s |
| [`the-slot-screens-reference-draws-a-lent-face-with-its-own-palette`](the-slot-screens-reference-draws-a-lent-face-with-its-own-palette.md) | cancelled | the wrong side is the `rm2k-snes-screens render` oracle, which tests-without-the-stages-subcommands removes |
| [`abl-test-cores-big-picture-return-red-once-in-a-full-run`](abl-test-cores-big-picture-return-red-once-in-a-full-run.md) | duplicates [`abl-test-cores-event-red-once-in-a-full-run`](abl-test-cores-event-red-once-in-a-full-run.md) | same flaky bsnes-only window piece in test_cores |
| [`abl-the-factory-pump-s-light-is-grey`](abl-the-factory-pump-s-light-is-grey.md) | duplicates [`abl-forem-left-out-at-the-factory`](abl-forem-left-out-at-the-factory.md) | other side of the same trade; at ports `89f77b4` no tile is lent, Forem is out instead |
| [`changing-the-map-s-tiles-lags`](changing-the-map-s-tiles-lags.md) | duplicates [`a-tile-substitution-sweeps-across-the-screen`](a-tile-substitution-sweeps-across-the-screen.md) | fixed by `7132792b`, merged `1a9331e4` |
| [`fxpak-s-pty-tests-fail-under-load`](fxpak-s-pty-tests-fail-under-load.md) | duplicates [`fxpak-s-pty-tests-share-ptsname-s-buffer`](fxpak-s-pty-tests-share-ptsname-s-buffer.md) | same tests and load; the ptsname cause explains both, that todo reruns under load |
| [`the-action-key-fires-only-the-first-event-of-a-cell`](the-action-key-fires-only-the-first-event-of-a-cell.md) | duplicates [`a-second-event-on-a-cell-is-never-asked`](a-second-event-on-a-cell-is-never-asked.md) | fixed by the-advocate `a3a707c6`, tests `test_two_events_on_a_cell.py` and `test_desert_nightmare_cell_events.py` |
| [`the-celebration-golden-moves-when-a-case-is-added`](the-celebration-golden-moves-when-a-case-is-added.md) | duplicates [`the-farm-s-goldens-move-with-the-bank-packing`](the-farm-s-goldens-move-with-the-bank-packing.md) | same 338 pixels, same farmers, same cause; the other draft diagnoses it (idle frame) |
| [`a-2003-actor-s-command-window-is-the-2000-one`](a-2003-actor-s-command-window-is-the-2000-one.md) | a question for taro | undoes part of a written divergence and of "Escape is the fifth command" for 2003 games |
| [`a-battle-song-with-many-instruments-squeezes-shared-samples`](a-battle-song-with-many-instruments-squeezes-shared-samples.md) | a question for taro | a call about sound, only heard without MSU-1; recommend accept and cancel |
| [`a-bush-on-a-map-with-more-than-four-character-palettes`](a-bush-on-a-map-with-more-than-four-character-palettes.md) | a question for taro | both fixes cost an HDMA channel or palettes; recommend keep the written divergence |
| [`a-door-decompresses-the-whole-bytecode-of-the-map-it-leaves`](a-door-decompresses-the-whole-bytecode-of-the-map-it-leaves.md) | a question for taro | worth it? recommend the cheap skip when the page has nothing after its Teleport |
| [`a-map-load-still-decompresses-inside-its-tick`](a-map-load-still-decompresses-inside-its-tick.md) | a question for taro | resumable LZ2 (~400 B) vs raw streams (~206 KB for Lashe); recommend resumable |
| [`a-map-s-small-pictures-go-in-all-or-none`](a-map-s-small-pictures-go-in-all-or-none.md) | a question for taro | changes 61 DN maps arguably; recommend the windows inventory first |
| [`a-refresh-costs-frames-on-maps-of-many-pages`](a-refresh-costs-frames-on-maps-of-many-pages.md) | a question for taro | a per-switch table costs ROM; recommend yes, design first with `just space` |
| [`a-small-picture-s-fifteen-colours-lose-a-whole-hue`](a-small-picture-s-fifteen-colours-lose-a-whole-hue.md) | a question for taro | new quantiser moves every game's small pictures; recommend Adeleine |
| [`a-torn-save-slot-shows-and-loads-a-new-game`](a-torn-save-slot-shows-and-loads-a-new-game.md) | a question for taro | new "damaged" text, CRC, SRAM layout; recommend checksum on the slot screen + CRC-16 |
| [`abl-forem-left-out-at-the-factory`](abl-forem-left-out-at-the-factory.md) | a question for taro | the game's own choice on map 83: Forem, the pump's red or the rain's colours |
| [`abl-s-menu-bank-has-no-tile-left-for-names`](abl-s-menu-bank-has-no-tile-left-for-names.md) | a question for taro | nothing wrong yet and the log says when; recommend cancel or make it loud |
| [`adeleine-s-grouping-settles-on-its-first-start`](adeleine-s-grouping-settles-on-its-first-start.md) | a question for taro | changes every game's colours and conversion time; recommend yes, measured first |
| [`an-effect-played-while-it-still-waits-is-heard-late`](an-effect-played-while-it-still-waits-is-heard-late.md) | a question for taro | not heard since effects go up in pieces; path remains, cause of the lag unknown: worth chasing? (rec. wishlist) |
| [`an-event-in-a-bush-is-drawn-whole`](an-event-in-a-bush-is-drawn-whole.md) | a question for taro | still so (`bush_oam` only from the hero, oam.s:1025); costs objects and palettes 4-7 (rec. wishlist) |
| [`bsnes-draws-every-frame-of-the-suites`](bsnes-draws-every-frame-of-the-suites.md) | a question for taro | one more third-party core patch against ~40% of bsnes time (rec. yes) |
| [`desert-nightmare-events-wait-for-a-slot`](desert-nightmare-events-wait-for-a-slot.md) | a question for taro | posed-over-painting mechanism vs a game patch for map 35 vs accept (rec. patch map 35) |
| [`holding-an-arrow-scrolls-a-list-slower-than-rm2k`](holding-an-arrow-scrolls-a-list-slower-than-rm2k.md) | a question for taro | shrinking a written divergence at unmeasured cost (rec. wishlist) |
| [`map-200-has-no-room-for-the-gold-window`](map-200-has-no-room-for-the-gold-window.md) | a question for taro | what map 200 gives up for the window: shared palette vs HDMA borrow vs accept |
| [`posed-events-on-a-map-with-a-panorama`](posed-events-on-a-map-with-a-panorama.md) | a question for taro | ROM room and Wally work for 62 ABL events (rec. wishlist, flattened+mode 3 scope) |
| [`reach-does-not-know-a-scene-runs-once`](reach-does-not-know-a-scene-runs-once.md) | a question for taro | no game hits it today (Tijereta's measure): worth it? (rec. cancel) |
| [`sunset-towns-crowds-wait-for-a-slot`](sunset-towns-crowds-wait-for-a-slot.md) | a question for taro | still so in today's degradations.json (6 maps); baked_events vs engine work vs leave it is the game's choice |
| [`the-bare-window-s-arrow-keeps-its-band-on-maps-with-eight-sprite-palettes`](the-bare-window-s-arrow-keeps-its-band-on-maps-with-eight-sprite-palettes.md) | a question for taro | still so (record.rs 1626); what is lost for lack of room: divergence or another home for the arrow |
| [`the-equip-screen-could-keep-the-slots-tiles-under-its-list`](the-equip-screen-could-keep-the-slots-tiles-under-its-list.md) | a question for taro | ~3 frames for 320-600 B far RAM and bank 1 code: a cost to choose |
| [`the-fades-last-black-tick-uploads-songs-the-map-is-not-playing`](the-fades-last-black-tick-uploads-songs-the-map-is-not-playing.md) | a question for taro | moves a stall from the door's black to a later PlayBGM: where the wait goes is a choice |
| [`the-font-carries-a-box-s-icons-twice`](the-font-carries-a-box-s-icons-twice.md) | a question for taro | 18 KB in Zounds with 51 free banks: not clear it is worth it |
| [`the-msu-1-loop-bakes-the-tail`](the-msu-1-loop-bakes-the-tail.md) | a question for taro | next stage of a task taro closed; changes what is heard |
| [`the-shared-conversion-cache-grows-without-bound`](the-shared-conversion-cache-grows-without-bound.md) | a question for taro | eviction policy is a cost to choose (disk vs rebuilds) |
| [`the-song-a-map-turns-on-goes-up-inside-the-load`](the-song-a-map-turns-on-goes-up-inside-the-load.md) | a question for taro | Tijereta's open choice between two losses of when a song is heard |
| [`the-test-games-ci-job-went-red-once`](the-test-games-ci-job-went-red-once.md) | a question for taro | nothing fixed it and no plan makes it moot, verifying is not cheap: worth keeping? (rec. cancel) |
| [`vampires-dawn-loads-spend-seconds-on-effects-from-the-msu`](vampires-dawn-loads-spend-seconds-on-effects-from-the-msu.md) | a question for taro | what to do is open (Tijereta); options change cost or what is heard |
| [`vampires-dawn-s-world-grid-does-not-fit-in-wram`](vampires-dawn-s-world-grid-does-not-fit-in-wram.md) | a question for taro | new runtime path for map 1's grid; no way given |
| [`vampires-dawn-tradan-is-hidden-under-its-clouds`](vampires-dawn-tradan-is-hidden-under-its-clouds.md) | a question for taro | what Tradan shows instead: looks and a new divergence |
| [`zounds-kuak-man-loses-its-coins`](zounds-kuak-man-loses-its-coins.md) | a question for taro | still 207 left out; new engine feature vs game patch |
| [`zounds-map-134-s-chest-is-a-dark-square`](zounds-map-134-s-chest-is-a-dark-square.md) | a question for taro | something must lose colours; which is a look choice |
| [`zounds-menu-pictures-on-map-136-need-512-tiles`](zounds-menu-pictures-on-map-136-need-512-tiles.md) | a question for taro | new rule vs Zounds patch; looks and cost |
| [`zounds-pick-axe-and-notebook-fit-beside-no-map`](zounds-pick-axe-and-notebook-fit-beside-no-map.md) | a question for taro | the draft itself names it taro's (divergence or patch) |
| [`zounds-the-dreams-fog-is-not-shown`](zounds-the-dreams-fog-is-not-shown.md) | a question for taro | taro asked; answer is "not without complexity": accept or build a fog layer |
| [`a-page-waiting-on-a-pan-goes-on-two-frames-late`](a-page-waiting-on-a-pan-goes-on-two-frames-late.md) | stays a draft | not checked against RPG_RT; count frames in the original under Wine |
| [`a-victory-song-other-than-a-changed-battle-songs-uploads-at-victory`](a-victory-song-other-than-a-changed-battle-songs-uploads-at-victory.md) | stays a draft | never measured; count the frozen frames in a Dooms 2 battle without MSU-1 |
| [`sunset-over-imdahl-characters-cut-on-crowded-lines`](sunset-over-imdahl-characters-cut-on-crowded-lines.md) | stays a draft | measured 11-17, before Sunset went painted; verify with `just objects-per-line sunset-over-imdahl`, as its siblings were on 11-22 |
| [`the-skills-screen-s-and-a-custom-menu-s-bar-may-run-ahead-of-their-text`](the-skills-screen-s-and-a-custom-menu-s-bar-may-run-ahead-of-their-text.md) | stays a draft | read, not seen; verify with the frame-by-frame helper on a skills screen with 2+ skills |
| [`zounds-the-two-cores-once-arrived-sixteen-ticks-apart`](zounds-the-two-cores-once-arrived-sixteen-ticks-apart.md) | stays a draft | one-off; verify with `just boot -k zounds` x20 when the CPU is free |

#### The questions for taro

Each one's log says what to decide, the options and a recommendation.

* [`a-2003-actor-s-command-window-is-the-2000-one`](a-2003-actor-s-command-window-is-the-2000-one.md): undoes part of a written divergence and of "Escape is the fifth command" for 2003 games
* [`a-battle-song-with-many-instruments-squeezes-shared-samples`](a-battle-song-with-many-instruments-squeezes-shared-samples.md): a call about sound, only heard without MSU-1; recommend accept and cancel
* [`a-bush-on-a-map-with-more-than-four-character-palettes`](a-bush-on-a-map-with-more-than-four-character-palettes.md): both fixes cost an HDMA channel or palettes; recommend keep the written divergence
* [`a-door-decompresses-the-whole-bytecode-of-the-map-it-leaves`](a-door-decompresses-the-whole-bytecode-of-the-map-it-leaves.md): worth it? recommend the cheap skip when the page has nothing after its Teleport
* [`a-map-load-still-decompresses-inside-its-tick`](a-map-load-still-decompresses-inside-its-tick.md): resumable LZ2 (~400 B) vs raw streams (~206 KB for Lashe); recommend resumable
* [`a-map-s-small-pictures-go-in-all-or-none`](a-map-s-small-pictures-go-in-all-or-none.md): changes 61 DN maps arguably; recommend the windows inventory first
* [`a-refresh-costs-frames-on-maps-of-many-pages`](a-refresh-costs-frames-on-maps-of-many-pages.md): a per-switch table costs ROM; recommend yes, design first with `just space`
* [`a-small-picture-s-fifteen-colours-lose-a-whole-hue`](a-small-picture-s-fifteen-colours-lose-a-whole-hue.md): new quantiser moves every game's small pictures; recommend Adeleine
* [`a-torn-save-slot-shows-and-loads-a-new-game`](a-torn-save-slot-shows-and-loads-a-new-game.md): new "damaged" text, CRC, SRAM layout; recommend checksum on the slot screen + CRC-16
* [`abl-forem-left-out-at-the-factory`](abl-forem-left-out-at-the-factory.md): the game's own choice on map 83: Forem, the pump's red or the rain's colours
* [`abl-s-menu-bank-has-no-tile-left-for-names`](abl-s-menu-bank-has-no-tile-left-for-names.md): nothing wrong yet and the log says when; recommend cancel or make it loud
* [`adeleine-s-grouping-settles-on-its-first-start`](adeleine-s-grouping-settles-on-its-first-start.md): changes every game's colours and conversion time; recommend yes, measured first
* [`an-effect-played-while-it-still-waits-is-heard-late`](an-effect-played-while-it-still-waits-is-heard-late.md): not heard since effects go up in pieces; path remains, cause of the lag unknown: worth chasing? (rec. wishlist)
* [`an-event-in-a-bush-is-drawn-whole`](an-event-in-a-bush-is-drawn-whole.md): still so (`bush_oam` only from the hero, oam.s:1025); costs objects and palettes 4-7 (rec. wishlist)
* [`bsnes-draws-every-frame-of-the-suites`](bsnes-draws-every-frame-of-the-suites.md): one more third-party core patch against ~40% of bsnes time (rec. yes)
* [`desert-nightmare-events-wait-for-a-slot`](desert-nightmare-events-wait-for-a-slot.md): posed-over-painting mechanism vs a game patch for map 35 vs accept (rec. patch map 35)
* [`holding-an-arrow-scrolls-a-list-slower-than-rm2k`](holding-an-arrow-scrolls-a-list-slower-than-rm2k.md): shrinking a written divergence at unmeasured cost (rec. wishlist)
* [`map-200-has-no-room-for-the-gold-window`](map-200-has-no-room-for-the-gold-window.md): what map 200 gives up for the window: shared palette vs HDMA borrow vs accept
* [`posed-events-on-a-map-with-a-panorama`](posed-events-on-a-map-with-a-panorama.md): ROM room and Wally work for 62 ABL events (rec. wishlist, flattened+mode 3 scope)
* [`reach-does-not-know-a-scene-runs-once`](reach-does-not-know-a-scene-runs-once.md): no game hits it today (Tijereta's measure): worth it? (rec. cancel)
* [`sunset-towns-crowds-wait-for-a-slot`](sunset-towns-crowds-wait-for-a-slot.md): still so in today's degradations.json (6 maps); baked_events vs engine work vs leave it is the game's choice
* [`the-bare-window-s-arrow-keeps-its-band-on-maps-with-eight-sprite-palettes`](the-bare-window-s-arrow-keeps-its-band-on-maps-with-eight-sprite-palettes.md): still so (record.rs 1626); what is lost for lack of room: divergence or another home for the arrow
* [`the-equip-screen-could-keep-the-slots-tiles-under-its-list`](the-equip-screen-could-keep-the-slots-tiles-under-its-list.md): ~3 frames for 320-600 B far RAM and bank 1 code: a cost to choose
* [`the-fades-last-black-tick-uploads-songs-the-map-is-not-playing`](the-fades-last-black-tick-uploads-songs-the-map-is-not-playing.md): moves a stall from the door's black to a later PlayBGM: where the wait goes is a choice
* [`the-font-carries-a-box-s-icons-twice`](the-font-carries-a-box-s-icons-twice.md): 18 KB in Zounds with 51 free banks: not clear it is worth it
* [`the-msu-1-loop-bakes-the-tail`](the-msu-1-loop-bakes-the-tail.md): next stage of a task taro closed; changes what is heard
* [`the-shared-conversion-cache-grows-without-bound`](the-shared-conversion-cache-grows-without-bound.md): eviction policy is a cost to choose (disk vs rebuilds)
* [`the-song-a-map-turns-on-goes-up-inside-the-load`](the-song-a-map-turns-on-goes-up-inside-the-load.md): Tijereta's open choice between two losses of when a song is heard
* [`the-test-games-ci-job-went-red-once`](the-test-games-ci-job-went-red-once.md): nothing fixed it and no plan makes it moot, verifying is not cheap: worth keeping? (rec. cancel)
* [`vampires-dawn-loads-spend-seconds-on-effects-from-the-msu`](vampires-dawn-loads-spend-seconds-on-effects-from-the-msu.md): what to do is open (Tijereta); options change cost or what is heard
* [`vampires-dawn-s-world-grid-does-not-fit-in-wram`](vampires-dawn-s-world-grid-does-not-fit-in-wram.md): new runtime path for map 1's grid; no way given
* [`vampires-dawn-tradan-is-hidden-under-its-clouds`](vampires-dawn-tradan-is-hidden-under-its-clouds.md): what Tradan shows instead: looks and a new divergence
* [`zounds-kuak-man-loses-its-coins`](zounds-kuak-man-loses-its-coins.md): still 207 left out; new engine feature vs game patch
* [`zounds-map-134-s-chest-is-a-dark-square`](zounds-map-134-s-chest-is-a-dark-square.md): something must lose colours; which is a look choice
* [`zounds-menu-pictures-on-map-136-need-512-tiles`](zounds-menu-pictures-on-map-136-need-512-tiles.md): new rule vs Zounds patch; looks and cost
* [`zounds-pick-axe-and-notebook-fit-beside-no-map`](zounds-pick-axe-and-notebook-fit-beside-no-map.md): the draft itself names it taro's (divergence or patch)
* [`zounds-the-dreams-fog-is-not-shown`](zounds-the-dreams-fog-is-not-shown.md): taro asked; answer is "not without complexity": accept or build a fog layer

#### For Hornero

* **The book**: ABL's "Known issues" (`src/ports/abl/README.md` at
  `1b195d7`) still has the grey pump of map 83, whose draft now
  duplicates `abl-forem-left-out-at-the-factory`: at the ports `89f77b4`
  no tile is lent, Forem is left out instead. The line is about Forem
  now, or goes with that question's answer. Not touched: this task was
  this repo only.
* **Hard to place**:
  * `abl-test-cores-event-red-once-in-a-full-run` went to `todo` as an
    uninitialised read (three `test_cores` reds of that kind), though it
    has not been seen since 2026-10-19 and does not reproduce on demand.
  * `test-msu-boots-different-from-its-twin-once-on-bsnes` is closed as
    moot: seen once, and `test-msu` leaves ABL with
    `abl-s-test-cartridges-become-test-game-cases`. "Stays a draft" is
    defensible.
  * `the-test-games-ci-job-went-red-once` was first closed and then made
    a question: nothing fixed it and no plan makes it moot, so cancelling
    it for lack of evidence is taro's.
  * `el-dorado-characters-cut-on-crowded-lines` was first a question and
    went to `todo` like its siblings: taro set the way on 2026-11-22.
  * `painted-map-strips-may-land-on-a-big-picture` is closed on reading
    the code (`paint_flush` sits in `map_up`, skipped with a big picture
    up since `40cbad47`), not on a test.
  * `the-converter-s-command-line-is-clap-s-builder-read-back-by-hand` is
    closed as moot under `one-advocate-command`; it comes back if that
    design keeps a command line between `advocate` and the converter.
  * Desert Nightmare's light masks and Frozen World's plates went to
    `todo` because they move towards the original; their entries say the
    trade becomes a question if the fix runs out of tiles or palettes.
