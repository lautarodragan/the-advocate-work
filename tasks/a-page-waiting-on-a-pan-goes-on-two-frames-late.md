---
name: "A page waiting on a pan goes on two frames late"
description: "After a PanScreen with a wait, the console runs the next command two ticks after the camera's last move; easyrpg's reading says the same frame. One or two frames, and not checked against RPG_RT"
type: bug
status: draft
author: tijereta
links:
  found-in: [two-pans-without-wait-move-one-after-the-other]
---

Seen by Tijereta on 2026-11-20, doing
[`two-pans-without-wait-move-one-after-the-other`](two-pans-without-wait-move-one-after-the-other.md),
with the-advocate `tijereta-diagonal-pan` (from `ed6bb119`) and ABL's
cases `pan`, `pan-diagonal`, `pan-adds-up` and `pan-edge`.

**What is measured**: in every one of those cases the `TintScreen` after
the waiting pan lands —`tint_b` changes— **two ticks after** the tick the
camera moves for the last time. The pan itself starts moving on the same
tick the command runs. ABL's `tests/rpgmaker/test_pan_axes.py` only holds
that the lag is the same with two pans as with one, not its value; the
`pan` case's goldens (ticks 64, 65, 66) hold where the tint lands today.

**What easyrpg says**, read and not run: `CommandPanScreen` sets
`wait_time = GetPanWait()` in the foreground events, which run after
`Game_Player::Update`, so the pan's first frame is the next one; the
interpreter's loop takes one off `wait_time` in that same frame, and the
next command runs on the frame of the pan's last move. That is the
camera starting a frame later than here and the page going on with its
last move, not two after.

**What is not known**: what RPG_RT does —the original under Wine could
say it, counting frames between a pan's end and a tint— and whether the
two frames come from `ev_waiting`'s countdown or from where `pan_tick`
sits in the main loop (`runtime/boot.s`, after the interpreter).
