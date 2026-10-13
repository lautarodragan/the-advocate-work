---
name: "The message window at the top, in the middle and without background"
description: "RM2k's MessageOptions: the window's position (top, middle, bottom), no background, moving if it covers the hero and events that keep going during the message; today the compiler ignores it and everything comes out at the bottom with background"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-04: "can you make the text able to show in the
middle or at the top of the screen, like in the original rpg maker 2000? … there may
also be an option to show it without background".

It's `MessageOptions` (10120), which `compile.rs` has in `IGNORABLE` since
`c64e4d96`: "where and how the message window is drawn, which without
messages is drawn nowhere". ABL uses it 1110 times in 202 maps (counted on
2026-10-04 over the dump); the most common parameters, in the order
[no background, position, move if it covers the hero, events during the
message], with position 0 top, 1 middle, 2 bottom:

    (0,2,0,0) 284   (0,0,0,0) 223   (1,1,0,0) 175   (1,0,0,0) 134
    (0,1,0,0)  89   (1,2,0,0)  74   (0,2,1,0)  72   (0,0,1,0)  46

## Done (Quirquincho)

Tools worktree from `cc502f93`; ABL in the clone
`/extras/scratch/quirquincho/abl` from `e65a7b5`, branch
`ventana-de-mensajes`.

### The four options

* **The position**: top at line 0, middle at 72 —centred in the
  224— and bottom at 144, as always. The choice and the digits go in the
  same window, so they follow it on their own.
* **No background**: the text with its shadow over the map. With two limits,
  written in `divergences/the-window-without-a-background-does-not-cover-the-characters.md`:
  the characters pass over the text, and the map's upper layer isn't
  visible in the band while the message lasts. Both come from the
  window being BG2, the same layer as the upper one, and mode 3 has no other.
* **Move if it covers the hero**: `GetRealPosition`, on opening each window,
  with RM2k's thresholds measured from the window and not from the edge of
  the screen, which here measures 16 lines less (`DODGE_*` in
  `message_place.s`). On by default, as in liblcf: that's why several
  goldens move to the top without the game asking for it. The test covers bottom
  moving to top; top and middle moving, it doesn't.
* **Events move during the message**: the pages' own routes
  keep reading commands with a page running. It was one more
  condition in `event_routes.s`. **No test covers it**: ABL
  uses it 3 times.

And one that wasn't asked for: with the window at the top, the timer moves down to the foot
of the screen, like `Sprite_Timer` —RM2k draws it over the window and
here the object mask hid it—.

### How it moves

Neither layer scroll nor rewriting the tilemap: **HDMA**. It already changed
BG2SC and BG2's scroll at line 144; now the tables have three
segments, which are enough for the three positions, and they're written by
`msg_hdma_build` in the vblank in which the window appears. No background doesn't
write VRAM either: the window's tilemap is 32x32 and the frame used ten
rows, so below goes the same plane without the frame and the scroll chooses.

### What it uses

* Opcode `0x41`, `OP_MESSAGE_OPTIONS (options: byte)`.
* RAM: `FAR_MSG_OPTIONS` at `$7E25FB`, in the save; `MSG_PLACE`,
  `MSG_SC`, `MSG_ENTRY` and `MSG_VOFS` at `$7E25F6`-`$7E25F9`, outside it.
  The gap `$2580`-`$25EF` is full: the first version put the mask
  at `$25C4` and stomped on the MSU-1 and music state.
* VRAM: nothing new. The second plane goes in rows 10 to 19 of the window's
  tilemap, which were unused in the six layouts and in the large
  pictures.
* ROM: the object masks became four tables at `$C0`.

### Verified

* ABL's suite with `cartridge`, `events`, `mapdata` and `convert` from this
  tree: green, with the new test and 22 goldens moved. It was repeated until
  no new red appeared: five rounds.
* The red from before: the new test with the global tools gives 9 out of
  10 red —`window-down` passes, which is the usual behaviour—.
* `cargo test` of `events` and `mapdata`, and `just -f tools/justfile test`.
* Against the original under Wine: the same page from the cases placed in a
  copy of the game. The positions and the no-background text land the same.

## For taro

Play a cutscene with no-background text and one with the window at the top —the
run to work, with the timer—. The goldens side by side, the
original next to them and a LEEME, in `/shared/captures/2026-10-04-ventana-de-mensajes/`.

On merging, reinstall `cartridge` —it brings the runtime—, `events`, `mapdata` and
`convert`. `bytecode` changed but it's a library, inside those.
