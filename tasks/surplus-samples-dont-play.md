---
name: "The surplus samples don't play"
description: "When a cartridge asks for more than 255 samples (SRCN is a byte), the surplus ones are left out with a warning, instead of stopping the build"
type: feature
status: done
agents: [Mulita]
assignee: taro
---

From taro, on 2026-10-06: "instead of getting the samples to fit, it would
be nice not to need to exclude those maps, and just drop the samples
> 255 and that's it. That the game doesn't fail — simply, that it doesn't
make a sound, where it can't." Dooms 2 today builds only by excluding maps
40 to 93.

## Done (Mulita, 2026-10-06)

- `bank::drop_surplus`, called in `compile.rs` before handing out copies:
  if the songs' samples don't fit in `255 - sound effect slots`,
  the **least used** are left out (by number of songs; tie: the last one
  in `Key` order), with a `WARNING` in the converter's log. A discarded key
  stays out of every key set, just like one the SoundFont doesn't have:
  those notes don't play and nothing points to a nonexistent sample.
  Test: `over_255_keys_the_least_used_are_left_out`.
- **The real cause in Dooms 2 wasn't that**: it had 247 keys or fewer and the
  stop came from the *copies* (`bank::copies`), which filled the directory
  up to 255 counting only `usual` (min of effects and slots) and not the
  real slots of the effects (8). Now `usual` never goes below `places`. With
  that, Dooms 2 builds with maps 40 to 93 and the drop doesn't get to trigger.
- Verified: ABL's `release` with these tools, `abl.sfc`
  `27e94e67...` the same; Dooms 2 builds, starts and shows the dialogue
  (capture at 3 s). A Blurred Line's suite wasn't run.
