---
name: "ABL: the Linkage Block's screen stays dark"
description: "On map 2 the computer screen at (39,69)-(40,70) is four events that cover the panorama; when Core gets in, a MoveEvent raises their transparency five times and RM2k shows the starry panorama through them; the port ignores the transparency moves and the screen stays dark"
type: bug
status: doing
assignee: Chajá
agents: [Chajá]
---

taro, on 2026-11-16, with captures from RPG_RT, Mesen and EasyRPG's
editor in the shared folder, `captures/2026-11-16-taro-abl-computer-screen/`:

> The computer screen in Linkage Block (39,69)-(40,70) doesn't show the
> panorama when it turns on. I never reported this because I thought it
> was by design —that the hardware didn't let us show the panorama on
> this map—, but I just found out that we're already rendering it, hiding
> BG1 in Mesen. LBScreenTopLeft (etc.) normally cover the panorama until
> Core manages to "hack" the computer. I think what happens is that we
> don't honour these commands, the `MoveEvent`s that do
> `IncreaseTransparency`, which eventually hide those events completely,
> letting the panorama be seen. In the original game, I suppose that
> looks like a fade-in, but we could make it on/off and that's it,
> tracking the transparency and hiding them if opacity = 0 /
> transparency = 100% / whatever.

What the data says (Hornero): map 2's events 11-14 (`LBScreenLeft`,
`LBScreenRight`, `LBScreenTopLeft`, `LBScreenTopRight`) draw ChipSet
tiles (indices 16 and 22), no CharSet, below the hero, one page with no
condition. Events 15 and 16 (`SeeCompPanelTop`) move each of them with
five `IncreaseTransparency` (move command 40) after "Got it! I'm in.", and
elsewhere five `DecreaseTransparency` (41).

Done means: RM2k's transparency steps on an event are tracked —what RM2k
does with each step, from EasyRPG's `Game_Character`, and what the
console can show: hidden at full transparency, as taro proposes, and
whatever is honest in between (half-transparency of an object is colour
math the port may or may not have)—; map 2's screen shows the panorama
after Core gets in, measured in a ROM test; the decrease brings them back.

## Log
