---
name: "ChangeSystemGraphics"
description: "Sunset Over Imdahl changes the System in its startup event (map 11), which therefore does not run: white map and the menu with the wrong colors. Medium: the window with the System changed on the fly; cheap: ignore it"
type: feature
status: todo
agents: [Aguará]
---

From Aguará's brief analysis (Sonnet), on 2026-10-05, of what taro saw playing the ROMs of the other games.

Today it is ignored: `ChangeSystemGraphics` is accepted doing nothing, as a debt (`ACCEPTED_UNDONE` in the events compiler), so that the page that uses it does not stay out; see `doing/`/`testing/` `ignorar-changesystemgraphics.md`. When this task is done, it has to be taken off that list.

It is not only Sunset: built on 2026-10-11 (the-advocate `fc6f7456`, ports `a85b7e3`), Vampires Dawn warns about it in maps 3 (the intro) and 27, and Sunset in 11 (to `SaveMeny`). Desert Nightmare does it in its common event 1, `Init`, from `Systemset_Intro` —the database's— to `Systemset_Spiel`, so today it plays entirely with the intro's; common events do not warn about it in the log. (Calandria, 2026-10-11.)
