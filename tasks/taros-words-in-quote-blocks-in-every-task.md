---
name: "taro's words in quote blocks, in every task"
description: "The tasks written before 2026-10-20 quote taro inline; each quote becomes a block, in English, said to be translated when it was Spanish"
type: workflow
status: testing
assignee: taro
agents: [Aguará]
---

taro, on 2026-10-20, in their words, translated:

> Could you cover tasks retroactively? `a-debug-screen-in-the-pause-menu`,
> for example. And I like the way you went about it in
> `rm2k-snes-toml-becomes-advocate-toml` —"in their words, translated"—.
> I think it's good to make clear that it's something I said, but that
> it's translated. It's better to keep everything in English in the
> tasks, as we had been doing.

The rule is in this repo's README. **Done**: every task that quotes
taro does it in a `> ` block, in English, with the line before it saying
so when the original was Spanish; nothing else in the tasks changes, and
no file name changes.

**2026-10-20, Aguará.** The candidates are the tasks with a paragraph
that names taro and has a quote in it, the ones whose paragraph before
names taro and ends in a colon, the ones with `taro:` or "in their
words", and the ones that already have a `> ` block: 277 files, read
whole in six groups. A quote kept in English is still marked
"translated" when the task's first version had it in Spanish —most of
the tasks before 2026-10-11 were written in Spanish and translated that
day—: taro said it in Spanish, which is what the README asks to say.

**Done, 2026-10-20, Aguará**: about 200 quotes in 161 tasks are blocks
now. A dozen were still in Spanish and are translated now —among them
`a-window-system-for-rm`, `abl-chests-change-colour-from-map-to-map`,
`changesystemgraphics`, `overloaded-audio-package-the-floor-is-a-cliff`,
`dooms-2-the-hero-is-not-drawn-on-some-maps`, the inventory of the
pictures and the five of Zounds from today—; about 140 were already in
English but Spanish in the task's first version, and say "translated"
too; the rest were written in English. The existing blocks of
`debug-map`, `debug-map-2-the-companion-picks-the-branch`,
`menu-like-rm2k`, `justfile-doesnt-know-python-exists`,
`release-troop-events` and `talan-black-with-dummyhero-as-leader` only
gained the "translated" in their introducing line.

Left inline, because they are a word or a few inside a sentence:
"perfect" (three tasks), "go ahead", "add more maps", "degrading where
needed", "every so often", "perfectly acceptable", "creative", "small",
"is very acceptable" and a dozen like them; the two Spanish ones of that
kind ("Dale") are translated in place. `nu tasks/tasks.nu html` builds,
with the blocks as `<blockquote>`, the ones inside list items too.
