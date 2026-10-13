---
name: "The title track keeps playing on starting"
description: "With MSU-1, the title track keeps playing when the game starts if the first map starts silent"
type: bug
status: done
---

Found on 2026-09-26 by the agent of "with MSU-1 the theme's samples aren't uploaded",
not fixed. With MSU-1, the title track
(`Fantasia_Of_The_Wind`) keeps playing when the game starts: `music_boot`
(`rom/src/musica.s`), when the map starts silent, silences the SPC700 but doesn't
call `msu_parar`. The track goes on until the first `PlayBGM`, and the battle
records it as the theme to restore on leaving. The fix seems to be calling
`msu_parar` on that path. Cover it with a test with `msu=True`
(`tests/abl/test_msu.py`).

## Done, on 2026-09-26

`music_boot_ya` calls `msu_parar` on its silent path. It's covered by
`test_with_msu_the_title_track_does_not_go_on_into_the_game`
(`tests/abl/test_msu.py`): with MSU-1, it checks that the title plays its track, picks
"Begin the Story" and asks that 120 frames later the title track is no longer
playing. Without the fix it's red: `MSU_SUENA` stays at 1 with `tema_actual` on
the title's.

What's left for taro: with the tracks alongside, start a game and hear
`Fantasia_Of_The_Wind` cut off on entering the corridor.

Seen in passing and not fixed: a game saved **while an MSU-1 track is
playing** saves `music_apagada` as 1 —the SPC700 is silent on
purpose—, so on loading it `music_boot` takes the silent path and the
game starts mute until the next `PlayBGM` (before this fix, the title
track kept playing). Noted in
`tasks/game-saved-with-msu-1-starts-silent.md`.
