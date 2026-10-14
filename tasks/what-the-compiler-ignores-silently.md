---
name: "What the compiler ignores silently"
description: "Every page field and command parameter ABL uses with a non-default value that the converter never reads: the features that compile but are not there, like trigger 2 and the movement types were"
type: research
status: doing
assignee: Cardón
agents: [Cardón]
---

taro, on 2026-10-14: "that's what I want to know: what is in those silent
holes". The culprits report says every page of ABL's whole game compiles,
but in the same week two features were found missing that it could not
see, because the pages compiled anyway: the event's touch (trigger 2,
pages compiled empty) and the movement types 1–5 (ignored). This
measures that class: a field or a parameter the compiler never reads.

## Log
