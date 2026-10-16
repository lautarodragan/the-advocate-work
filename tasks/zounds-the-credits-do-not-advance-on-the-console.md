---
name: "Zounds: the credits do not advance on the console"
description: "On a real SNES, Zounds' build with MSU-1 boots and stays on the first screen, the credits with music on map 106; the boot test, without tracks and in emulators, gets past it to map 7"
type: bug
status: doing
assignee: Aguará
agents: [Aguará]
---

taro, on 2026-10-16, on the console with the delivered build (ports
`ed3e0ee`, the-advocate `30ab0ca6`, with its MSU-1 tracks): "Zounds boots
perfectly on the SNES. It stays on the first screen, a credits screen with
music. It still needs to advance to the next one, but the opening menu and
all seem to work perfectly." The boot test (`just boot -k zounds`, no tracks,
snes9x and bsnes) reaches control on map 7 since Aguará's
`zounds-the-intro-on-map-106-waits-for-a-key-nobody-reads`.
