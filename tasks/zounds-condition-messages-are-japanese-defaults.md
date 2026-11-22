---
name: "Zounds: the conditions' battle messages are the editor's Japanese defaults"
description: "Zounds' states carry RPG Maker 2003's untranslated Japanese messages, read as Windows-1252, and the battle's text block writes them as garbage: the revival line, and what a condition says when it is given, lasts, goes or is already held"
type: bug
status: draft
author: aguara
---

Seen by Aguará on 2026-11-22, while doing
[`zounds-skill-names-show-a-question-mark-for-an-accent`](zounds-skill-names-show-a-question-mark-for-an-accent.md),
on the-advocate `aguara-skill-accents` (from `6a8f4162`) and the ports
`001cfb7`. Found in the data and the cartridge's text, **not looked at on
the screen**.

**What it is**: the same as the nine battle terms of
[`zounds-battle-messages-cannot-be-read`](zounds-battle-messages-cannot-be-read.md),
but in the states. Zounds' `data/db/states.json` (a 2003 database) has the
editor's Japanese defaults, Shift-JIS read as Windows-1252, in the
messages of states 1 to 9 —`message_recovery` of state 1, the dead one,
is `‚Í—§‚¿\x8fã‚ª‚Á‚½\x81I`, `は立ち上がった！`—. The battle's text block
takes them as the revival line (`revived`) and as each condition's five
messages. Until 2026-11-22 each letter was a `?`; since that task they go
through the plain stand-ins like the battle's other database texts, so
they read as other garbage, `'I-S'??a'a'A'1/2?I`.

Whether RPG Maker 2003's battle shows them at all is what to measure
first: the nine terms were never shown by it, and were given the project's
`[battle.terms]` with English stand-ins for a 2003 game
(`UNSHOWN_IN_2003` in `rm2k-snes/mapdata/src/emit.rs`).

**To reproduce**: `scripts/db_scan.py` of that task, in
`~/scratch/aguara/skill-accents/`, over the ports, lists them; on the
console, an actor revived in battle, or a condition given by a skill.
