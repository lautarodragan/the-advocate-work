---
name: "A face's cells step runs past the vblank"
description: "In bsnes, the vblank that writes a box's face cells (msg_face_vblank's second step) ended at line 270, eight lines into the next frame, on Zounds' map 89"
type: bug
status: draft
---

Seen by Chajá on 2026-10-19, at the-advocate `54ec3daf` and the ports
`c2912ad`, measuring something else
([the map's colours after Tower (Ele)'s animations](zounds-a-map-animation-leaves-the-map-s-colours-wrong.md)):
a throwaway build latched the V counter at points of `flush_video`, in
bsnes.

On Zounds' map 89, the first box of Tower (Ele)'s second page —"¡Vamos
Kazar, a intentarlo!", with Unamë's face on the left; the switch 126 on by
hand, a jump to (13,11), right and A—, the vblank of the box's second line
went: the line's upload ended at line 248, and `msg_face_vblank`, on its
second step (`set_new`, the 36 cells to palette 1), ended at line 270. That
vblank had no battle animation frame, no flash and no tint pending. VRAM
written past line 261 is dropped on the console, so some of the face's
cells could keep palette 0.

The third step (`face_table`) of a later box ended at line 264, from 253,
with a tint pending; it writes RAM and channel 5's registers while the
channel is off, which does not look harmful. Both were measured again
with the fix of that task in, and are the same: that fix does not touch
these steps.

What was **not** seen: any damage. The box's face, in the bsnes capture of
that frame and the ones after, looks right. Not measured either: which part
of the step takes the twenty-two lines, or whether snes9x takes as long.
