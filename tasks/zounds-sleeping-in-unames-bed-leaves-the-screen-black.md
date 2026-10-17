---
name: "Zounds: sleeping in Uname's bed leaves the screen black"
description: "Sleeping in the bed of Uname's room fades the screen out and it never fades back in; the next map's music plays"
type: bug
status: doing
assignee: Aguará
agents: [Aguará]
---

taro, on 2026-10-17, playing Zounds on Mednafen (delivery of that day,
the-advocate `69e3be10`, the ports `71a6afd`): in Uname's room, sleeping in
the bed fades the screen out and it never fades back in. The next map's
music plays fine, so the game goes on: taro suspects the tint/fade, or an
autostart event on the next map that does the fade-in and whose page does
not compile.

## Log
