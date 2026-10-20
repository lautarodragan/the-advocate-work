---
name: "A parallel common event's write refreshes the pages a frame late"
description: "What a parallel common event writes changes the active pages only on the next frame, after the autostart pages were already looked at; in RM2k it is refreshed before the map's events look"
type: bug
status: todo
---

Seen by Calandria on 2026-10-19, at the-advocate `54ec3daf`, reading the
frame's order while looking into
[`zounds-entering-map-88-loops-on-a-teleport`](zounds-entering-map-88-loops-on-a-teleport.md).
It was not the cause of that one, and it is not seen in any game yet: no
test or play has shown it.

EasyRPG's `Game_Map::Update` runs `UpdateCommonEvents` and then
`UpdateMapEvents`, and each interpreter's `Update` ends with `if
(Game_Map::GetNeedRefresh()) Game_Map::Refresh();`. So a parallel common
event that writes a variable or a switch has the pages refreshed **before**
the map's events run `CheckEventAutostart` in that same frame.

`map_events` in `runtime/event_pages.s` does the pending refresh first,
then `compar_tick`, then `wait_autostart`, with no refresh between the
last two: what a parallel common event writes is refreshed at the start of
the next frame. An autostart page that the write deactivates is still
marked waiting on that frame, and `events_tick` can start it once more
than RM2k would; one that the write activates starts a frame late.

To reproduce it a case would need a parallel common event that writes,
on the frame a map is entered or in the middle of play, the variable or
switch an autostart page of the map asks for.

## Defined (2026-10-20, Tijereta)

Checked against the-advocate `8f290c39`: still so. `map_events`
(`runtime/event_pages.s`) does the owed refresh, then `compar_tick`, then
`wait_autostart`, with no refresh between the last two. **Done**: a
refresh a parallel common event owes is done after `compar_tick` and
before `wait_autostart`, as each interpreter's `Update` does in easyrpg;
a test-game case where a parallel common event turns on the switch an
autostart page of the map asks for, which starts on the same frame RPG_RT
starts it —and one that turns it off, which does not start once more—.
**First step**: that case, red; and how much a second refresh pass costs
on the frames where nothing changed (it has to cost nothing there).
