---
name: "ABL: Arden turns into Talan when spoken to"
description: "In the scene with \"Arden... I'm sure everyone's fine\", talking to Arden draws her with Talan's CharSet in her own palette, and then she is Arden again"
type: bug
status: doing
assignee: Mulita
agents: [Mulita]
game: abl
---

taro, on 2026-11-17, translated:

> Another bug, new (it already happened last night, it is not from today):
> Arden turns into Talan when I talk to her, in this scene, and then she is
> Arden again. She seems to keep her palette ("red" Talan is Arden).

Screenshots in `/shared/bug-reports-etc/abl-arden-talanified/`
(`abl_008.png`-`abl_011.png`): during Talan's line "Arden... I'm sure
everyone's fine. They've just been brought into custody, that's all." the
sprite on Arden's cell is Talan's figure with Arden's colours; after the
box, Arden's own. Builds of the night of 2026-11-16 and of 2026-11-17
(ports `428e7c3`, the-advocate `95863f36`).

Done means: the scene reproduced in the harness, the cause found (a pose
or graphic slot of the turning NPC, the poses-only trimming, the baked
events…), fixed, with a ROM test that holds it.
