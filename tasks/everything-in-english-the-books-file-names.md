---
name: "Everything in English: the book's file names and URLs"
description: "The book's pages keep the Spanish file names they had before the translation: give them English names, redirect the old URLs, and fix every citation in the four repos"
type: chore
status: done
assignee: taro
agents: [Cardón]
---

taro, on 2026-10-12:

> I want the URLs and file names in English too. Let's find and fix all
> the references. Let's not modify the git history. I also want the ports
> repo in English. Basically, EVERYTHING in English, but without
> modifying the git history.

The rule is in AGENTS.md, "The
independent projects are in English".

This task is the book and the citations of it; the ports are
[`everything-in-english-the-ports`](everything-in-english-the-ports.md).

* Every page of `the-advocate-docs/src/` with a Spanish file name or
  directory gets an English one, made from its title.
* The old URLs keep working: one `[output.html.redirect]` entry per page in
  `book.toml`, which is also the table an old citation is looked up in.
* Every citation of an old name in the four repos is fixed: the book's own
  links and `SUMMARY.md`, comments in the-advocate —also the stale
  `workflow/divergencias/…`, `decisiones/…` paths—, tasks, `AGENTS.md`,
  `.claude/`, and the ports. Verbatim quotes of old commits stay.
* Leftover Spanish in the-advocate and in this repo that is not a quote:
  `.claude/agentes.md` gets an English name.

## Log

### 2026-10-12, Cardón

Branches `cardon-english` in the-advocate, the-advocate-ports and
the-advocate-docs; worktrees in `~/scratch/cardon/english/`.

**The table**: 105 pages, every one under `src/` whose file name was
Spanish, each renamed from its (English) title; directories were already
English. It lives twice, the same: `[output.html.redirect]` in the book's
`book.toml` —an old URL lands on the new page; the value is relative to
the old page, which shares its directory with the new one— and
`~/scratch/cardon/english/script/table.tsv`, next to the scripts.

**The scripts**, kept in `~/scratch/cardon/english/script/` to rerun on
branches merged later:

* `fix_citations.py [--dry] [--show] REPO...` — rewrites every old name as
  a whole token, and the stale directory in front of it (`workflow/…`,
  `decisiones/`, `divergencias/`, `docs/research/`, `docs/port/`, an ABL
  decision cited under the engine's) to the page's directory in the book.
  It leaves alone what follows `tasks/`, `RENAMES.md` and
  `decisions-and-divergences-by-repo`, and lists for a human the bare
  names that could be a page or an old task —six old page names were also
  old task names—.
* `wrapped.py REPO...` — old names cut across two lines, which the first
  cannot see (there was one, in `far_ram.s`).
* `check_book.py BOOK OUT` — every relative link of `src/` resolves and
  every redirect lands on a built page.
* `rename_pages.py`, `redirects.py` — the `git mv`s and the toml table.

**What was done by hand** (judgement commits, separate from the mechanical
ones): the READMEs of the book and of this repo that said the names were
kept in Spanish so they could be found by name, now point at the redirect
table, and Contributing explains it; three lines of studies went back to
the old names because they describe another repo as it was; in
the-advocate, citations of the book that did not say so, `tools/port/*.py`
and the rest of the deleted Python pointed at the Rust that replaced them,
`rom/pruebas/…` at the ports, `encolar_eventos` (gone with 348cf58c; the
rule is `pick_pages`', and the orphan comment of a routine that no longer
exists on top of `seek_event_page` went away) and `animacion_de_mapa`
(`map_shows_animation`); in the ports, "de las herramientas" → "del
libro".

**Left as is**: the `.inc` text the converter emits still cites
`tools/port/…` and `rom/src/…`, on purpose according to its comments; the
ports' citations of old tasks (`workflow/tasks/*/<Spanish>.md`), which are
the ports task's.

**Merged with main** after Mulita's skills screen, in the four branches,
and the script rerun on what it brought: nothing to change.

**Verified**: `mdbook build` (v0.5.4) without warnings; `check_book.py`:
every relative link resolves and the 105 redirects land (an old URL such
as `/decisions/la-grilla-vive-en-la-wram.html` is a page that sends to
`the-grid-lives-in-wram.html` in the same directory); in the-advocate,
`just test` and `just rust-test` green; `abl.sfc` (`just cartridges release` in
a ports worktree of this branch) built twice, with this branch's runtime
and converter (`install-local cartridge convert`) and with the global
tools of main at 5573c3e5: both
`417978e33580d3613241143b6b6b1d287ffb771bca96e31dfd4ecdc6bcda3522`, byte for
byte. The suite was not run: comments only.

**To install when merging**: `just install convert` (an error message
changed); the rest are comments.

Rerun `fix_citations.py` and `wrapped.py` on any branch merged after this
one; a page renamed again gets its line in `book.toml` and in `table.tsv`.
