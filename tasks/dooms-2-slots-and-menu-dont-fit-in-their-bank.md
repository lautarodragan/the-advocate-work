---
name: "Dooms 2's slots and menu don't fit in their bank"
description: "With Dooms 2's map 1 (choose a character) in the cartridge, the slot screen and the menu gather more tiles than the 448 of their bank; the map is left out and the game starts on map 2"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

Measured by Calandria on 2026-10-11 (`exclusions-left-over-in-the-ports.md`):
with map 1 in, "the slot screen and the menu gather 524 tiles and
their bank fits 448" with ABL's System, and 482 with the game's own
(Tijereta, `window-in-the-tile-bank.md`, who left it as a
"separate task": "they are faces, not windows"). It is probably the same
thing Carpintero left undone on 2026-10-06 in
`degrade-instead-of-failing.md`, point 4: "the names that don't
fit in the menu's bank… try it in Dooms 2"; it wasn't checked that it is
the same stop.

**Checked today** (the-advocate `fc6f7456`, ports `a85b7e3`): with map 1
returned and `start_map = 1`, `just cartridges release` stops at
"rm2k-snes-screens: the slot screen and the menu gather 482 tiles and
their bank fits 448". The error comes from `rm2k-snes/screens/src/slots.rs`
(`SLOT_TILES_MAX`), without degrading: it stops the whole cartridge. That is
why `dooms2/rm2k-snes.toml` excludes map 1 and starts on map 2.

**What you see while playing**: the game doesn't show the character choice
—it starts on map 2, "Jack"—, and any event that leads to map 1 loses
the whole page (a `Teleport` to a map that isn't in the cartridge doesn't
compile).

What is known of the cause: it is the faces (Tijereta). That map 1 adds them
because it is where the character is chosen —more candidates for leader, each
with their face— is the obvious suspicion, not checked.

**How to see it**: remove 1 from `excluded` in `dooms2/rm2k-snes.toml` and
`just cartridges release` in `dooms2/`.

taro, on 2026-10-16, playing Dooms 2: Will is always in the party from the
start, so the hero on the map is Will; in the original the first map is
where the character is chosen. taro's idea, from memory: the map is a black
background with more NPCs than VRAM holds, NPCs that only move when talked
to. "The cheapest test first": a patch of the map that leaves the NPCs one
pose, no code changes; then the same graphic for several, or a synthetic
ChipSet from the CharSet; later, a general optimization (events that do not
fit as BG while keeping them interactive, or poses loaded when needed).
What 2026-10-11 measured was the slot screen and the menu's tile bank, not
the NPCs: to be measured again with today's tools.

## Measured again on 2026-10-16 (Calandria)

With the-advocate `30ab0ca6` and the ports at `f8aca68`, map 1 back in and
`start_map = 1`, `just cartridges release` in `dooms2/` stops at the same
place: "the slot screen and the menu gather 481 tiles and their bank fits
448". One tile less than on 2026-10-11, and it is still the faces:

* the party can hold eleven actors with map 1 in —`possible_members` in
  the converter's `scan.rs` takes every `ChangePartyMembers` that adds—
  and six without it. Map 1 adds 2, 3, 7, 8, 9, 10 and 11 —the candidates
  to lead; the chosen one stays and Will, 5, is removed— and the rest of
  the game adds 1 to 6. Ten of the eleven have a face —8, "Player", has
  none—, each 36 tiles before deduplicating.
* **the map's NPCs are not what stops it**: the converter gets through map
  1 with "31 characters, 29 slots, 500 tiles in VRAM, 8 palettes", with
  21 graphics drawn with someone else's palette and without rain. The map
  is as taro remembers it: 20x15, one screen, 18 events, 16 with a
  graphic, all still (`move_type` 0) and all on the action key
  (`trigger` 0); 11 distinct CharSets. So the NPC patches of taro's plan
  are not needed today.

## Done (Calandria, 2026-10-16)

Branches `calandria-dooms2-start` in the three repos, from the-advocate
`30ab0ca6`, ports `f8aca68`, docs `3f105f2`.

* **The bank leaves faces out instead of stopping**, one at a time, the
  last actor's first, until the text, the faces and the composed names
  fit —`slots_with_room` in `rm2k-snes/screens/src/convert.rs`—. An actor
  without a face shows without one, which the cartridge already drew for
  RM2k's DummyHero: the runtime is not touched, so it does not step on
  Chajá's cursor work in `menu.s` and `slots.s`. Declared as
  `faces-left-out` in `degradations.json` and in the converter's log; in
  Dooms 2 the three left out are Will (9) and the two Junes (10, 11), and
  the bank ends at 384 tiles of 448 with 34 of the 64 free ones asked by
  the names. The 15 `Teleport`s to map 1 that were
  `teleport-to-missing-map` compile now.
* **Dooms 2 starts on map 1** (`dooms2/rm2k-snes.toml`): `excluded` is
  empty and `start_map = 1`.
* **Played in the harness**: `tests/test_dooms2.py` at the ports' root
  boots, checks the party is `[5]` on map 1, walks to the cell below Bob,
  talks to him facing up, says yes, lands on map 3 with the party empty
  —the choice removes Will and nobody has joined— and, after the
  madhouse's opening, with `[2]`: Bob alone, the leader. `test_boot.py`'s
  `FIRST_MAP` for Dooms 2 is 1. The red the test was shown is the build:
  without the converter's change the game does not build.
* **The book**: the Known issues line of Dooms 2 says the three faces,
  instead of "there is no character choice".
* **Captures** in `/shared/captures/2026-10-16-dooms2-start/`: map 1 as
  it boots, and the pause menu with Will (face), with June 11 (no face)
  and with Bob, Bryan and the two Junes. No golden moved.
* **Not needed**: taro's NPC patches —one pose per NPC, shared graphics,
  a synthetic ChipSet—. The map's sprites fit today (29 slots, 500 tiles,
  21 graphics with a lent palette). Two drafts carry what was learned for
  the general optimizations:
  `interactive-still-events-drawn-as-background.md` and
  `poses-only-when-an-event-can-show-them.md`.

**To install when merging**: `just install screens` —the only crate
touched—.

**What was run**, with the local `rm2k-snes-screens` first on the PATH
and the rest of the tools the global ones (the-advocate `30ab0ca6`):

* in the-advocate: `just test` (29 passed), `just rust-test` (green with
  the Microsoft GS SoundFont in `SOUNDFONT`; with FluidR3 exported the
  audio crate's `the_synth_bass_releases_as_the_soundfont_says` is red,
  which is the SoundFont and not the change), `SOUNDFONT=FluidR3_GM.sf2
  just test-game` (26 passed, 1 skipped), `just crate-test screens`;
* in the ports: ABL's `just cartridges` and `just tests` (1555 passed, 2
  skipped; `abl.sfc` `92bacc160263d34b`, byte for byte the main
  checkout's: ABL's faces fit, so nothing changes there), and `just boot`
  at the root (46 passed, `test_dooms2.py` among them).

**What the suite does not cover**: the slot screen itself with a faceless
actor —the captures show the pause menu—, and a bank that fits only with
the slot screen's text last *and* faces left out, which no game asks for
today.

**Hurón, 2026-10-20**, from
[`abl-the-last-leaders-names-are-cut-in-the-slot-screen`](abl-the-last-leaders-names-are-cut-in-the-slot-screen.md):
the menu's bank got a third order, each screen's text apart, where the
slot screen composes its names over the menu's text. Dooms 2's `release`
takes it —"432 tiles of 448, each screen's text apart"— and the converter
leaves out only the two Junes' faces: Will (9) has his again. Measured in
the converter's output; not looked at in a ROM.
