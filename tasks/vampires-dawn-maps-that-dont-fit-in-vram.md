---
name: "The Vampires Dawn maps that don't fit in VRAM"
description: "Nine Vampires Dawn maps —Shannar, Uruya, Melsan, Asran among them— are left out because of VRAM: five with no layout that holds background, sprites and upper layer, two with no room for the message window and two because of their panorama in mode 1"
type: feature
status: testing
assignee: taro
agents: [tijereta]
author: aguara
links:
  relates: [poses-only-when-an-event-can-show-them, poses-without-their-empty-tiles]
---

What is left out of Vampires Dawn because of VRAM, measured by Aguará on
2026-10-11 (`vampires-dawn-builds-from-its-toml.md`) and confirmed
by Mulita when returning the eleven from "the ROM"
(`one-quantization-per-character-for-the-poses.md`, 10 out). Each one with its
error in the comment of `excluded` in `vampires-dawn/rm2k-snes.toml`
(ports `a85b7e3`); not checked today.

| map | what it says |
|---|---|
| 15 Shannar | "this map can't carry a message window": 576 of background, 436 of sprites, 130 of upper layer, and no layout leaves the window's 8 KB |
| 150 Shannar danach | the same, only in the whole cartridge (alone, it fits) |
| 57 Shannar Hinrichtung | "fits no VRAM layout": 609 of background, 768 of sprites, 130 of upper layer |
| 99 Melsan | 451, 640, 177 |
| 165 Uruya | 817, 768, 95 (alone, it fits) |
| 225 Asran | 780, 704, 116 (alone, it fits) |
| 399 Wald12 | 716, 512, 136 |
| 402, 403 Schneeklippe | "there is no layout for a panorama in mode 1 that holds … 435 panorama tiles" |

**What is known of the cause**: it isn't the background. Tile merging
(`merge-similar-tiles-when-the-background-doesnt-fit.md`, Cardón, 2026-10-06) brings any
background down to the ceiling and "it is no longer what blocks any of them"; what
doesn't fit is the sprites and the upper layer, and merging background doesn't fix
it. Cardón left noted the possible next step: degrade the sprites with the same
criterion, "another kind of merging, more expensive: they are poses and palettes". The
window of 15 and 150 isn't the System's: its bank is 256 fixed tiles
(Tijereta, `window-in-the-tile-bank.md`). That 150, 165 and
225 fit alone and not in the whole cartridge is because in the whole one
more pages compile and more events fit (Aguará).

**What you see while playing**: those maps aren't in the cartridge, and an event
that leads to them loses the whole page (a `Teleport` to a map that isn't
there doesn't compile). How far it can be played without them wasn't looked at.

**How to see it**: remove the map from `excluded` and `just cartridges release` in
`vampires-dawn/` of the ports (about two minutes; with the MSU-1, which the
project asks for as mandatory).

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
Shannar, Uruya, Melsan and Asran are towns of the story, and a `Teleport`
to a map that is not there leaves its page out, so todo. **Done** is the
nine maps out of `excluded` in `vampires-dawn/rm2k-snes.toml` and in the
whole `release`, or each that stays with its measured limit in that
comment. Two ways are open and the agent picks and measures: fewer sprite
tiles per map —only the poses an event can show,
[`poses-only-when-an-event-can-show-them`](poses-only-when-an-event-can-show-them.md),
on top of [`poses-without-their-empty-tiles`](poses-without-their-empty-tiles.md)—,
or a degradation of the sprites as the background has one, which Cardón
left as the next step. First step: take each map out of `excluded` with
today's tools and write down what each says now; the numbers above are of
2026-10-11.

## Comments

### 2026-11-28, taro: a question for Hornero

> Now that the related tasks are `done`, can you check this again?
>
> Regarding the panorama: let’s make it a warning, without it preventing the rom from building (exclude the panorama entirely).
>
> Regarding the message window not fitting: was it measured with a system graphic override that uses plain bsckgrounds?

### 2026-11-28, Hornero: checked again: seven fit VRAM; the messages' reach stops them

Checked on the-advocate `bb4c4a4c`, ports `351cc697`: the nine maps out
of `excluded`, and `just cartridges release` in `vampires-dawn/`,
leaving out again each map that still stops the build.

* **402 and 403, Schneeklippe**: still out, the same as before —"no
  layout for a panorama in mode 1 that holds 127 background tiles, 211
  sprite tiles, 137 upper tiles and 435 panorama tiles"—. The panorama
  alone is 435 tiles.
* **The other seven** —15 and 150 Shannar, 57 Shannar Hinrichtung, 99
  Melsan, 165 Uruya, 225 Asran, 399 Wald12— **no longer fail on VRAM**:
  neither "fits no VRAM layout" nor "can't carry a message window".
* **What stops them now is the messages**: with the seven in, the
  game's message block is **262,216 bytes**, and `OP_MESSAGE` carries a
  16-bit offset counting by 4 bytes, so it reaches 262,144
  (`rm2k-snes/events/src/messages.rs:922`). **72 bytes over.**

A question for taro, because it is a cost: how the message block grows
past 256 KB.

* **(a)** count by 8 bytes instead of 4: the reach doubles to 512 KB;
  each box starts at a multiple of 8, so on average some 2 more bytes of
  padding per box (some 6 KB of ROM over the game's ~2,900 boxes, not
  measured), and the runtime shifts the operand once more. Every game's
  ROM changes.
* **(b)** a wider operand —24 bits—: no padding change, one more byte
  per `OP_MESSAGE` in the bytecode, every game's ROM changes.
* **(c)** leave one of the seven out —any of them frees far more than 72
  bytes— and keep the 256 KB.

Recommended: **(a)**, the smallest change in the runtime, and it lasts:
Vampires Dawn is the game with the most text and 512 KB is twice what it
needs. Not started; the task stays `todo`.

### 2026-11-28, taro: (a), counting by 8

> vamos con (a), tu recomendación

### 2026-11-28, Hornero: what (a) means to do

taro answered in the chat, quoted above. What is left to do, in this
order:

1. `OP_MESSAGE`'s operand counts by 8 bytes instead of 4: the message
   block is aligned to 8 (`rm2k-snes/events/src/messages.rs:922`, and the
   runtime's read of the operand), which doubles the reach to 512 KB.
   It moves every game's ROM —some padding per message—, so ABL's suite
   and every game's build are run, and the padding is measured, not
   estimated.
2. The seven maps that now fit VRAM (15, 150, 57, 99, 165, 225, 399) come
   back into Vampires Dawn.
3. 402 and 403 stay out: their panorama alone needs 435 tiles in mode 1.

## Log

### 2026-10-20, Chajá: checked

Still out: the nine are in `excluded` with the same comments, and the
`release` built that morning (ports `68bf55b`) passes `--maps` without
them. Two things above moved:

* the project file is `vampires-dawn/advocate.toml` since 2026-10-20 (the
  ports' `71c4143`), not `rm2k-snes.toml`;
* a `Teleport` to a map that is not carried no longer leaves its page out:
  since `8d6bc064` (2026-10-15) it compiles to a "Teleport to missing map
  N" box and the page goes on —noted as `teleport-to-missing-map` in
  `degradations.json`; since `a6a0f639` the box shows over a screen the
  teleport erased—. So these maps cost their own scenes, not the pages
  that lead to them.

### 2026-11-28, Tijereta: `OP_MESSAGE` counts by eight

From the-advocate `71ccb4eb` and the ports `a9b5bc4a`, branches
`tijereta-messages-by-8` in both.

The step lives in one place, `MESSAGES_STEP` in `engine.rs` of
rm2k-snes-mapdata: the converter hands it to the event compiler as
`messages_step`, `emit.rs` writes `MESSAGES_CAP = $10000 * step`, the
`.dbg` carries it for ABL's harness, and `msg_start` in
`runtime/messages.s` `.assert`s the cap against its shifts. So the change
is the constant (4 to 8) and one more `asl`/`rol` in `msg_start`. Why it
was four is in ABL's `tests/harness/events.py` (from 2026-09-27, when the
world chapter went past 128 KB): steps 3 and a 24-bit operand had been
measured and left out then.

The new test, `the_game_s_text_block_reaches_past_256_kb` in
rm2k-snes-convert, fills a block numbered with `MESSAGES_STEP` with
distinct boxes up to 300,000 bytes: red with four ("a box past 262161
bytes does not fit OP_MESSAGE's operand"), green with eight.

Vampires Dawn: maps 15, 150, 57, 99, 165, 225 and 399 out of `excluded`;
402 and 403 stay, with their measured limit in the comment.

#### The padding, measured

Each game's text block (`texts` in `build/advocate.json`), building the
same project with the global tools (by four) and with the branch's (by
eight), Vampires Dawn with its old map list in both:

| cartridge | by four | by eight | more |
|---|---|---|---|
| ABL `release` | 211,778 | 221,714 | 9,936 |
| ABL `test-special` | 69,047 | 69,555 | 508 |
| ABL's other test cartridges | 3,053 to 15,461 | | 156 to 812 |
| Book of Three | 68,517 | 71,289 | 2,772 |
| Desert Nightmare | 48,886 | 51,974 | 3,088 |
| Dooms2 | 46,793 | 49,633 | 2,840 |
| El Dorado | 57 | 57 | 0 |
| Frozen World | 75,368 | 78,756 | 3,388 |
| Sunset over Imdahl | 47,819 | 50,191 | 2,372 |
| Vampires Dawn | 255,873 | 268,237 | 12,364 |
| Zounds | 39,190 | 41,118 | 1,928 |

About four bytes more per box, not the two estimated. Every ROM changes,
all nineteen cartridges built. ABL's `release` still builds with 0 free
banks and 18 halves, as before; Vampires Dawn's with 0 and 0, as before.

With the seven maps, Vampires Dawn's `release` builds: its block is
281,125 bytes of 524,288.

#### Map 455's event 70

Not new: "event 70 is left out: a page's condition names variable 259,
which has no slot in far RAM" —and events 63 and 68, variables 257 and
258— are in the `degradations.json` of the build in the main ports
checkout too, without the seven maps. It is the 256 variables' cap,
`variables-are-capped-at-256-slots` (`todo`): no new draft.

#### test-special's push

ABL's `test_text[text-crosses]` went red as its own message foresees: the
box fell 304 bytes past the bank edge (offset 65840). Four fewer push
boxes put it back across; the three `test_text` cases pass.

#### A second reader of the operand: `show_window`

The ports' `just boot` caught what grepping for `MESSAGES_STEP` did not:
`OP_SHOW_WINDOW`'s lines carry box offsets too, and `runtime/show_window.s`
built its own long pointer with two shifts. Desert Nightmare's menu —the
only game that draws windows from events— showed other boxes' text (five
boot tests red, 259 to 1,399 pixels). Three shifts and an `.assert`
against `MESSAGES_CAP` of its own (the-advocate `13416ada`); the five pass.
Neither ABL's suite nor the test game runs `OP_SHOW_WINDOW`.

#### Verified, and to merge

On the branches (the-advocate `13416ada`, the ports `ecf2b841`), with
`just install-local .local-tools advocate`: in the-advocate `just lint`
(SOUNDFONT on FluidR3_GM), `just test`, `env -u SOUNDFONT just
rust-test`, `just test-game` (SOUNDFONT on FluidR3_GM: without it the
recipe refuses); in the ports `just boot` at the root, which builds every
game's `release`, and ABL's `just tests`. All green; no ABL golden moved.

What the suites do not run: no game but Vampires Dawn has a block past
256 KB, so `msg_start`'s third bit runs only there, and nothing checks
Vampires Dawn's boxes past 256 KB on screen; its boot test only boots.
The seven maps were not played.

To merge: `just install advocate` (the runtime, `mapdata`, `events` and
`convert` are in it).
