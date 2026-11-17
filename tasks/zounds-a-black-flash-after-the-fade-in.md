---
name: "Zounds: a black flash after the fade-in"
description: "Entering a map in Zounds, the fade-in ends and then the screen goes fully black for several frames; when it comes back the scene has changed —lights red to blue, the tubes in other places—, as if an automatic page's changes went through a black reload instead of happening on screen"
type: bug
status: doing
assignee: Tijereta
agents: [Tijereta]
---

taro, on 2026-11-17, playing Zounds' build on Mesen with frame-numbered
screenshots (in the shared folder, `bug-reports-etc/bug3-zounds-black-flash/`,
copied to `captures/2026-11-17-zounds-black-flash/`), translated:

> Something similar, but it's not lag: the screen goes black for 1-2
> frames _after_ the fade-in has finished, on entering the map. Up to
> frame-35563.png it's just the normal fade-in, which works fine.
> frame-35567.png - frame-35573.png is 100% black. frame-35577 shows as it
> should again.

What the captures show (Hornero): 35567, 35569, 35571 and 35573 are fully
black (every pixel 0), so the black lasts at least 7 frames and at most 13
(35564–35576), not 1–2. And the scene is not the same on both sides: in
35563 the two lights on the back wall are red and the tubes stand at the
left-middle and the right; in 35577 the lights are blue and the tubes have
moved. So something between them changes the map —an automatic page on
entry: a tile substitution, events moved, page graphics— and the port does
it behind a black screen where RM2k does it in place.

Done means: which map and which page; what the port does on those frames
and why it blanks (`git blame`); RPG_RT's behaviour (EasyRPG's, or the
original under Wine if needed); the black removed —or, if it is the cost of
something that cannot be done otherwise, said and minimised—; a ROM test
on that entry that fails with the black frames.

## Log
