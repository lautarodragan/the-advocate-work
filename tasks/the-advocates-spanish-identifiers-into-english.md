---
name: "the-advocate's Spanish identifiers into English"
description: "The Spanish names left in runtime/ and in the tools' tests —labels, constants, test names—: renames that change no ROM byte but do change the symbols the ports read"
type: refactor
status: doing
agents: [Hurón]
assignee: Hurón
---

taro, on 2026-10-12: `the-advocate` goes in English entirely (see "The
independent projects are in English" in `AGENTS.md`). This is the half
that can break a build or a test, so it goes last and through the whole
suite: names in code. The prose is
`the-advocates-prose-into-english.md`, in parallel.
