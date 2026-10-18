---
name: "Zounds: no way back from map 189"
description: "Map 44's event 7 teleports to map 189 (5 > Arriba), whose exits back to 44 do not work on the console; EasyRPG crashes on that map"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

taro, on 2026-10-17, playing Zounds on Mednafen (the-advocate `30786e0b`,
the ports `1d93da4`): event 7 of map 44 ("Main / Cave / 2") teleports to
map 189 (`[189, 6, 7]`), and from there taro cannot go back. Map 189
(20x15, 7 events) has three touch exits: event 1 at (17,8) to map 81, and
events 2 and 3 at (5,8) and (6,8) back to map 44. `degradations.json`
lists no loss on map 189. taro also says EasyRPG crashes on that map,
consistently.

## Log
