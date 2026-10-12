---
name: "The exclusions left over in the ports"
description: "The ports' rm2k-snes.toml exclude maps from the survey that already fit: leave only the ones needed, measured with today's tools"
type: chore
status: done
assignee: taro
agents: [Calandria]
---

From the re-sweep of 2026-10-10 (`other-games-the-re-sweep.md`): the committed exclusions are the survey's and are too many. Back then Book of Three needed only 46, Dooms 2 needed 1, 10, 14 and 63, Frozen 1 and 2, and Desert the sweep's twelve. Since then the twins and the event trimming, the music and the troops in words, and the empty party have come in, so it has to be measured again.

## How it is measured (Calandria, 2026-10-11)

Global tools of the-advocate `5094ef11`; ports at `038ea64`, own worktree (branch `calandria-exclusiones`). For each game, the toml without crutches —`excluded = []`, without `system`, Dooms 2 with `start_map = 1`, Frozen with `below = 156`— and `just cartuchos release`; if the error names a map, it is excluded and built again. If what cuts it is its own System (it names no map), `system` is put back and it is repeated.

## Per game

### El Dorado

It builds as committed: it excludes nothing and has no crutches.

### The Book of Three

| what | why |
|---|---|
| (no map) | 46 came back on 2026-10-10 with its animation trimmed (Cardón); 44, 69 and 74 build |
| `system = "ablskin.png"` | with its own: "the window needs 267 tiles —27 of its frame and its arrow— and the bank has 256" |

### Sunset Over Imdahl

It builds as committed —without exclusions or crutches since the empty party (Mulita)—; its toml was not touched.

### Dooms 2

The errors below do not name the map: the four are the re-sweep's, and it was checked by taking each one out of the list (with the other three in, it does not build).

| what | why |
|---|---|
| 1 | choosing a character; with it, "the slot screen and the menu gather 524 tiles and their bank fits 448" (482 with its System) |
| 10 | "the song uses 291 sounds and the index is one byte" |
| 14 | "the song uses 411 sounds and the index is one byte" |
| 63 | "the song uses 291 sounds and the index is one byte" |
| `start_map = 2` | because 1 stays out |
| `system = "ablskin.png"` | with its own, even without 1: "the actor choice's windows are 66 8bpp tiles and reach $4840, and their tilemap is at $4800" |

For the tools: the sound index error does not say which song or which map; the map had to be taken out one at a time.

### The Frozen World

| what | why |
|---|---|
| 1 | "a page makes the hero flash, and actor 11 is drawn with rangedmelee[0], which an NPC of the map also uses. On the console they share a palette and both would flash" (also with ABL's System and 2 out) |
| 2 | "a stream of map_code is 38179 bytes and 19968 fit in WRAM: see the LZ2 reservation in runtime/far_ram.s" |
| `system = "ablskin.png"` | with its own: "the window needs 266 tiles —26 of its frame and its arrow— and the bank has 256" |

`below` goes from 135 to 156, all the maps: the cap of 255 in the sample directory no longer cuts (it degrades since `surplus-samples-dont-play`). 69 and 84 build.

### Desert Nightmare

| what | why |
|---|---|
| (no map) | it builds with all 189: what cut twelve on 2026-10-10 now degrades with a WARNING —in nine maps the events past 120 stay out, and what they lose is only their drawing or an invisible wall (Carpintero's trimming); the panoramas come out `mode1` or flattened; the NPCs past 104 are not drawn, and keep moving—. None was looked at in an emulator |
| `system = "ablskin.png"` | with its own: "the End Game screen uses 18 pairs of colours and a 4bpp palette has 16" |

`decorative_events = true` is not a crutch: it is the knob turned on on purpose (`ddb35a5`), and it stays.

### Vampires Dawn

It does not build, and its toml was not touched. With the committed one (ABL's System, without exclusions) it first cuts on maps: 15, "this map can't carry a message window: it spends 576 background tiles, 436 sprite tiles and 130 upper tiles, and there is no layout that leaves 8 KB of tiles plus 2 KB of tilemap for the window"; without 15, 57, "fits no VRAM layout: 609 background tiles, 768 sprite tiles (its animation box's 64 included) and 130 upper tiles". The sweep was cut there, on purpose: at ~2 min per round and with some eighty maps that the re-sweep saw cut, it does not pay off while the whole-playthrough walls stay open (the 281 of `Music/`, the troop members, the boot of 3), which Tijereta and Carpintero are working on. With its own System it also cuts first on 15, so whether its System is needed could not be measured: it stays.

## Result

Ports, branch `calandria-exclusiones` (`286201b`); book, branch `calandria-exclusiones` (`245f1fc`, a "What it leaves out" section in BoT, Dooms 2, Frozen and Desert). Verified: `just cartuchos release` with the final tomls builds in BoT, Dooms 2, Frozen, Desert, El Dorado and Sunset (the last one untouched). None was looked at in an emulator. Nothing to install at merge time: no tools were touched.

For the tools: "the song uses N sounds and the index is one byte" says neither the song nor the map, and "this map can't carry a message window" does not say the map on its line (you have to read the previous header of the log).
