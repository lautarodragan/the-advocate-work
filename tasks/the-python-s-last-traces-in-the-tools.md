---
name: "The Python's last traces in the tools"
description: "Code that still imitates how the deleted Python wrote, rounded or formatted —the save signature's JSON, pyfmt, the audio's number helpers and others— goes, even where that changes every ROM"
type: refactor
status: doing
author: taro
assignee: carpintero
agents: [carpintero]
---

**Why**: after
[`the-python-parity-left-behind`](the-python-parity-left-behind.md),
`python_json` stayed in `rm2k-snes/mapdata/src/emit.rs` on purpose: the
save signature is a CRC of the text it writes, and writing it any other
way changes every cartridge. Around thirty production files of
the-advocate still name the Python —`mapdata/src/pyfmt.rs`,
`rm2k-snes-audio/src/num.rs`, `cartridge/src/text.rs`, `tracks.rs`…—, and
some of them are code that exists to come out the way the Python did.

> I'd rather remove any legacy leftover and have the ROMs change.

(taro, 2026-11-23)

**What is asked**:

* Every piece of code that exists to reproduce how the Python wrote,
  rounded, sorted or formatted something goes, and what it fed is written
  the plain Rust way. ROMs may change: saves of older builds being refused
  is fine (taro: breaking saves is never a problem).
* What only mentions the Python as history —a comment saying where a rule
  came from— stays if it still explains the line, and goes if it only
  says "as the Python did".
* Each change of ROM bytes says, in its commit, what moved and why it is
  only that: the save signature, a table's order, a rounding.
* A golden that moves goes to taro before merging.
