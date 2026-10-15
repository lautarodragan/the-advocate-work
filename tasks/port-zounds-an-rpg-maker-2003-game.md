---
name: "Port Zounds, an RPG Maker 2003 game"
description: "A study of how much of Zounds —taro's game, made in RPG Maker 2003— works today with the tools: the project, Ditto with the 2003 fields, what compiles, which commands are missing, and what 2003 battles and .wav music would need"
type: research
status: testing
assignee: taro
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

taro, on 2026-10-15: time for the study. "An option I find perfectly
acceptable, as a middle ground or as final, is that the battles be 2000's
and not 2003's, but how easy it is to degrade them has to be measured.
Maybe there are non-obvious impacts." `/extras` is gone: the game is
cloned again from GitHub. Launched on Fable.

## How it is being done (Aguará, 2026-10-15)

The deliverable is a research page in the book,
`src/research/2026-10-15-zounds-an-rpg-maker-2003-game.md`, on the docs
branch `aguara-zounds`, plus one draft per concrete piece of work found.
Measured against the-advocate `91d55d39`, the ports `8a9ab73`, liblcf
`6854310`; the game cloned to `~/juegos/zounds` (commit `5fa54e6`), and
a throwaway project in `~/scratch/aguara/zounds/project/` with Book of
Three's `rm2k-snes.toml` renamed. The scripts that produced every number
are in `~/scratch/aguara/zounds/*.py`; the page says what each one counts.

What was found so far, in the order it came up:

* Ditto's generator skips every `Is2k3` row of liblcf's `fields.csv` and
  every 2003 bit of `flags.csv` (`xtask/src/main.rs`): 118 of 1,043 rows.
  The 2003 chunks land in `unknown` and come back byte for byte, **but the
  flag bytes do not**: a 2003 troop page condition has 10 flags in 2 bytes
  and Ditto writes the 7 it knows in 1; the round trip over Zounds gives
  188 of 190 files equal, `RPG_RT.ldb` 107 bytes short and `Map0187.lmu`
  one byte off (its `timer2` bit). Reading the flags wrong also means the
  resolved view says no troop page is conditioned on a battle command,
  where 36 are.
* The game's images are **XYZ** (186 files, RM2k3's zlib format): the
  converter's finders accept the extension but nothing decodes it, so the
  build stops at the System. The measuring copy in scratch has them as
  PNG.
* The repo does not carry everything the data references: 22 chipsets, 15
  charsets, 17 songs, 131 sounds, 6 backdrops, 2 facesets, 1 monster, the
  System2. Classified against EasyRPG's RTP tables: part is the RM2k3 RTP
  (not in `~/assets`), part the RM2k RTP under other names, and part is
  simply absent (custom files never committed).
* Events: 28,187 commands in 6,217 pages. Only two 2003-only commands,
  both in troop pages: `ForceFlee` (36) and `CallCommonEvent` (19). RM2k
  commands the compiler lacks that Zounds uses: `ChangeParameters` (6, in
  the debug common event), `EnterExitVehicle` (2), `TeleportTargets` (1),
  `OpenMainMenu` (1, debug).
* Battle data: 10 classes (3 named, 3 actors assigned), 9 battle commands
  in use with an ATB `gauge` layout, 33 battler animations (the RTP's),
  all 36 command-triggered troop pages fire on the custom `Escapar`
  command and do a `ForceFlee`; the 18 that call common event 2 ("Robar")
  are the steal mechanic.
* Four maps exceed the console's 120 events (47, 51, 57, 178), with up to
  327 events; three more are saved by twins.
* The converter was taken to a built cartridge over a measuring copy in
  scratch (XYZ as PNG, placeholders for the 197 missing assets, flat fill
  for the System in the toml, Zounds' own fallback backdrop, the debug
  troop's 32-bit numbers capped, map 30 —200x200— excluded): `zounds.sfc`,
  54 data banks of 127 used, 54 whole banks free. Each stop on the way is a
  finding of its own, below.
* `culprits`: 3,514 of 4,495 map pages compile (78%), 41 of 69 common
  events, 18 of 105 troop pages (64 with a trigger the ROM cannot look at,
  which is the flags Ditto drops). 920 map pages are kept out by their
  messages alone, 678 of them only by the colour escape `\c[n]`, which
  Zounds puts in 2,604 of its 7,102 message lines; `\|` mid-line, `\v`,
  `\n`, `\s` are the rest. After the messages: `TileSubstitution` (8),
  `ShowChoice` with messages (43), `MoveEvent` (2), `OpenShop` (1), the
  two 2003 battle commands.
* Music: the map tree sets no music; everything is `PlayBGM`. Of the 19
  `.wav`, only 3 are referenced, and they are the System's title, battle
  and victory themes: 242 s, 42.8 MB as MSU-1 PCM at 44.1 kHz; the other 16
  (and 4 MIDIs) are never played.
* Pictures: `ShowPicture` with 16 parameters everywhere (no RM2k3 1.12
  features); maps 75, 136 and 190 keep more than the console's two
  pictures at once —a score board and a picture-made menu—.
* The measuring cartridge boots: the title passes and both cores give
  control on map 106 "Imágenes" at tick 397, where the hero moves to no
  side —the picture intro—. Captures in `/shared/captures/2026-10-15-zounds/`.

## Delivered (Aguará, 2026-10-15)

* The page, with the answers to the five questions and the plan:
  `src/research/2026-10-15-zounds-an-rpg-maker-2003-game.md` on the docs
  branch `aguara-zounds`, in `SUMMARY.md` and in the research index.
  Recommendation: engine first —XYZ, Ditto's 2003 fields with the flag
  fix, the colour escape—, then the 2000 battle with two compiler cases,
  and the 2003 battle not at all for Zounds; its real cost is its picture
  screens, its event grids, its `.wav` songs and its missing assets.
* Thirteen drafts, one per finding: `ditto-drops-the-2003-flag-bits`,
  `ditto-does-not-read-the-2003-fields`, `the-tools-do-not-read-xyz-images`,
  `a-gradient-system-stops-the-converter-at-the-actor-choice`,
  `the-colour-escape-in-messages`, `a-200x200-map-does-not-fit-the-cell-stream`,
  `an-enemy-with-32-bit-numbers-breaks-the-assembler`,
  `the-2003-battle-commands-callcommonevent-and-forceflee`,
  `zounds-the-repository-lacks-197-assets`, `zounds-wav-music-through-msu-1`,
  `zounds-maps-over-120-events`, `zounds-pictures-and-the-picture-made-screens`,
  `vehicles-enterexitvehicle-and-the-boat`.
* No code changed in the-advocate or the ports: nothing to install when
  merging. The game is in `~/juegos/zounds` (not a `.zip`: it is a git
  clone, never edited); the retouched copy and the scripts stay in
  `~/scratch/aguara/zounds/`.
