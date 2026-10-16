---
name: "Route: transparency"
description: "Orders 40 and 41, which raise and lower transparency"
type: feature
status: wishlist
---

# What

Route orders **40 and 41**, raising and lowering transparency by one eighth.
Today they are accepted and dropped when compiling.

# Status

Noted, not started.

# Why

The **eight routes in the game** that use them are the four screens in map 2
dimming while Manta hacks. Dropping them —and not rejecting the page— is what
lets that whole scene compile; what is lost is the fade, which **on
background tiles the SNES doesn't do cheaply**: dimming a sprite in parts asks for color
math.

Careful with the edge effect when doing it: a route left without orders because of
this **is not emitted**, because RM2k consumes it whole in the frame and leaves nothing
to wait for.

The other order that meets the same fate is **`play_sound_effect`**, which is also
accepted and dropped; the two together in `traducir`, in `tools/port/eventos.py`.
Dropping them costs no frames —RM2k doesn't touch the stop counter for them— and with that the
bytecode is still one byte per order.

**Checked on 2026-10-16 (Mulita)**, at the-advocate 759aa0ba: still accepted and dropped, now in `compile_route`
(`rm2k-snes/events/src/compile.rs`, `ROUTE_TRANSPARENCY`), which notes
each one as `route-transparency-dropped` in `degradations.json`. Two facts
above are out of date: `tools/port/eventos.py` is gone —the compiler is
Rust since the Python left—, and `play_sound_effect` (35) is **no longer
dropped**: since 2026-09-27 it plays, with the effect in the map's audio
package, except inside a jump and in a page's own route.
