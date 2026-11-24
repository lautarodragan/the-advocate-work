---
name: "A map's small pictures go in all or none"
description: "Wally takes a map's small pictures as one bank of tiles: when they do not fit, every one is lost. In Desert Nightmare the two message box pictures, 270 tiles, take with them the green marks on what can be used, on dozens of rooms"
type: bug
status: draft
assignee: taro
author: aguara
agents: [Aguará, cardon]
game: desert-nightmare
links:
  found-in: [desert-nightmare-the-screen-goes-black-before-the-first-monster]
  relates: [an-inventory-of-the-pictures-that-may-be-windows, desert-nightmare-the-warehouse-monster-is-not-drawn]
---

Seen by Aguará on 2026-11-21, doing
[`desert-nightmare-the-screen-goes-black-before-the-first-monster`](desert-nightmare-the-screen-goes-black-before-the-first-monster.md),
with the-advocate at `a537d967` and the ports at `d17237a`.

**What is seen**: in Desert Nightmare's rooms the objects that can be used
have no green mark ("All objects that can be used are marked with a green
symbol", says the game on map 28), and other small pictures are missing
too. The converter's log says, on about forty maps, "WARNING, the pictures
'TextboxInnen, TextboxRahmen, Interaktion, …' aren't drawn here: with their
N tiles the map fits no VRAM layout".

**Why**: `pictures::for_map` cuts all of a map's small pictures into one
bank of tiles, and `convert_fitting` in `rm2k-snes/wally/src/map.rs`
converts the map again without them when the bank does not fit —all of
them—. The game draws its message box with two pictures, `TextboxInnen` and
`TextboxRahmen`, about 270 tiles, which no painted room has room for; the
`Interaktion` marks are 4 tiles.

**What was tried, and set aside**: rounds in the converter, after Wally
answers: the maps whose pictures did not go in are converted again without
the name that costs the most tiles, while two or more are left (the map's
own first, when it carries copies of common events with pictures). It was
written and measured, and is in Aguará's scratch as
`maps.rs.rounds`, but not merged, because:

* it changes 61 of Desert Nightmare's maps at once, and taro has to look
  at them: map 21 kept `TextboxRahmen` alone, a box's frame without its
  inside, which may look broken;
* `picture_data` grows with what goes in: past 32 KB on the first try, the
  reason the offsets of the maps' entries are unsigned since that task;
* map 28 does not gain from it: its sprite bank has not even the 4 tiles
  of the marks.

A better cut may be by what each picture is: the message box ones are a
window, see [`an-inventory-of-the-pictures-that-may-be-windows`](an-inventory-of-the-pictures-that-may-be-windows.md).

## Log

### 2026-11-24, Cardón: a question for taro

Still so by the draft's measure (`convert_fitting` in
`rm2k-snes/wally/src/map.rs` drops every small picture of a map when the
bank does not fit). It changes what is seen in Desert Nightmare on ~40
maps, arguably: Aguará's rounds kept a box's frame without its inside on
map 21, and `picture_data` grows past 32 KB.

**To decide**: (a) Aguará's rounds, dropping the costliest picture first,
with taro looking at the 61 maps; (b) first
[`an-inventory-of-the-pictures-that-may-be-windows`](an-inventory-of-the-pictures-that-may-be-windows.md)
(todo), so the message box pictures become a window and the small marks
fit; (c) leave it.

**Recommendation**: (b) first, then (a) only for what still does not fit;
link this draft as blocked by that inventory.
