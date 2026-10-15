---
name: "The tools page, explained"
description: "The book's tools.html says little: what each tool does, in which order they run, and examples of input and output —an RTP image through Adeleine, test-game cases that show the lossy optimizations from nothing lost to too much merged—, in phases"
type: docs
status: doing
assignee: Cardón
agents: [Cardón]
---

taro, on 2026-10-15: "add more and better info to tools.html. I'd like it
to make it quite evident and friendly what each tool does, in which order
they run, and ideally examples of input and output (where it can be done
simply, we take a chipset or charset from the EasyRPG RTP and pass it
through Adeleine or whatever, and show how it changes. Since the choice of
colours etc. depends on other data, like the map, maybe we could add cases
to the test game that show these lossy optimizations, and show screenshots
of the game in those cases, compared with the original, in different
cases: when nothing is lost, when a 'reasonable' amount is lost, when it
merges too much and looks ugly... etc)". In phases, each with its commit:
adding prose is one thing, adding things to the demo game and capturing it
another.

At the start: `src/tools.md` in the-advocate-docs is 24 lines, a table of
the three layers and two paragraphs.
