---
name: "Frozen World does not open under Wine"
description: "With ABL's RPG_RT copied in, as Dooms 2 needed, the window opens and closes; Wine logs an exception outside the stack limits"
type: bug
status: doing
assignee: Chajá
agents: [Chajá]
---

taro, on 2026-10-17, on their machine: Frozen World's `RPG_RT.exe` opens
its window and closes it at once, also with ABL's `RPG_RT` copied in,
which is what made Dooms 2 run. The log says, among the usual noise:

    err:seh:call_seh_handlers invalid frame 00007FFFF0D1DDA0 (00007FFFF0D22000-00007FFFF0F20000)
    err:seh:NtRaiseException Exception frame is not in stack limits => unable to dispatch exception.
    err:system:NtUserChangeDisplaySettings Changing L"\\\\.\\DISPLAY1" display settings returned -2.
    fixme:ddraw:ddraw7_WaitForVerticalBlank … stub!

## Log

## Chajá, 2026-10-17

Tried in here with wine 11.17 (pure WoW64, like taro's: their frame
addresses are 64-bit), on a copy of the game, with its own `RPG_RT.exe` (the
English-translated RPG_RT 2000, byte for byte the same as The Book of
Three's), ABL's `RPG_RT.exe` and the 2015 one. **All three reach the title
and the first maps** once three things are in place, and each one of them
missing stops the game:

| missing | what the runtime does here |
|---|---|
| `Harmony.dll` next to the exe (2000 only) | "Harmony.dll not found" |
| the `RuntimePackagePath` key | "RunTime Package not found. Install RTPe.exe", and it quits |
| Don Miguel's RTP behind the key | "Cannot open file vehicle" |
| Wine's virtual desktop | "DirectDraw Error(DDERR_UNSUPPORTED)" |

**What sets Frozen World apart from Dooms 2 is the RTP.** Dooms 2 boots with
the key pointing nowhere: it carries every asset. Frozen World uses some 280
files of the RTP (a name scan over its `.ldb` and `.lmu`; it over-counts a
little), and **with Don Miguel's names**: its first one is `CharSet/vehicle`,
`Vehicle.png` in Don Miguel's RTP and `Vehicles.png` in the official
English one —Humble's, and EasyRPG's free RTP, which copies its names—. With
an RTP of official names behind the key, both runtimes stop on that file;
the 2015 one does not translate the names.

**Not reproduced: the crash itself.** In here every one of those failures is
a dialog; taro's log has `Exception frame is not in stack limits`, which in
WoW64 is an exception the 32-bit side could not dispatch, and the runtime
dies instead of showing the box. The most likely cause is one of the four
above —the RTP one, since Dooms 2 ran with the same exe and the same
prefix— with the dialog never painted; it was not confirmed.

**What taro has to do on their machine** (inside their Wine prefix):

1. Don Miguel's RTP, unzipped anywhere: it is `rtp.zip` in the container's
   assets folder (the same one ABL is checked against). Not the official
   English RTP from Humble: its names are not the ones the game asks for.
2. Point both keys at it, with the path as Wine sees it:

       wine reg add 'HKCU\Software\ASCII\RPG2000' /v RuntimePackagePath /d 'Z:\path\to\rtp' /f
       wine reg add 'HKCU\Software\KADOKAWA\RPG2000' /v RuntimePackagePath /d 'Z:\path\to\rtp' /f

   (the first is the 2000 runtime's, the second the 2015 one's). Instead of
   the keys, copying the RTP's folders into the game's without overwriting
   (`cp -rn rtp/. game/`) also gives the files, but the 2000 runtime still
   asks for the key.
3. `Harmony.dll` next to the game's own `RPG_RT.exe` —the real one from
   ABL's Wine folder; the hollow stub boots too, without music—. Or use
   `RPG_RT_2015.exe`, which does not need it. ABL's `RPG_RT.exe` is not
   needed: the game's own runs.
4. The virtual desktop at 640x480 (winecfg, Graphics, "Emulate a virtual
   desktop"; or the two `HKCU\Software\Wine\Explorer` values in
   `~/wine/abl/LEEME.txt`).

If it still closes, `WINEDEBUG=+seh,+loaddll wine RPG_RT.exe 2>&1 | tail
-200` right before the crash says which file or DLL it was on.

Captures —title, first map, the intro, and each failure's dialog— with a
README, in `/shared/captures/2026-10-17-frozen-world-wine/`.
