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
