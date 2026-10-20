---
name: "The justfile doesn't know Python exists"
description: "The justfile only calls executables from the PATH; the .py files that get executed become real executables, and a grep test makes sure ABL's side doesn't name tools/"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-28, as a first step to separate the tools from ABL (see
`decisions/the-tools-split-from-abl.md` and
[`research/the-map-of-the-python-tools.md`](https://lautarodragan.github.io/the-advocate-docs/research/the-map-of-the-python-tools.html)),
in their words, translated:

> A first step occurs to me: that the justfile doesn't know Python exists. ABL
> can't know the tools directory exists — it only knows there's a suite of
> tools available in the path. The Python files that are executables become
> real executables, with a hashbang and chmod +x.
>
> Then we can have a very simple test with grep: if anything in abl matches
> the tools path, the pipeline fails.

Measured before starting: the `justfile` has 50 lines that name `python3` or
`tools/` (`grep -c "python3\|tools/" justfile`), and 63 files of `tests/`
import modules from `tools/` directly. That's why the grep test starts with an
exceptions list for `tests/` that can only shrink.

## What was done (Espinillo)

Three commits, in the order AGENTS.md asks for: what's verified with the ROMs
first, the test and the prose afterwards, the docs separately.

### The executables

The eight `.py` files that have `__main__` get a hashbang and `chmod +x`, and
`just herramientas` installs them as symlinks in `{{cargo_root}}/bin`, next to
the Rust ones:

    rm2k-snes-cartridges        tools/ensamblado/cartuchos.py
    rm2k-snes-assemble          tools/ensamblado/ensamblar.py
    rm2k-snes-space             tools/ensamblado/espacio.py
    rm2k-snes-convert           tools/port/snes_convert.py
    rm2k-snes-patches           tools/port/parches.py
    rm2k-snes-msu               tools/audio/msu.py
    rm2k-snes-volume-ceilings   tools/audio/techos.py
    abl-entregar                tools/ensamblado/entregar.py

The `justfile` only calls five: `rm2k-snes-convert`, `-assemble` and `-msu`
are used by the other scripts internally or run by hand, and they're installed
anyway because they get executed.

**The names follow the repo where each program is going to live.** The suite
is going to be a repo in English (decided on 2026-09-28), so its executables
already go in English: the name is what ABL consumes, and putting it in
Spanish would force renaming it twice —in the `justfile`, in the docs and in
taro's `bin/`, where the old one would be left dangling—. The flags stay in
Spanish (`--lista`, `--medir`): those get translated with the code.
`entregar` stays with ABL according to the research (§ the modules table), so
it goes with `abl-` and in Spanish. The prefix is because the `bin/` is
shared: a bare `espacio`, `parches` or `msu` doesn't say what it is and can
clash with anything; with `rm2k-snes-<TAB>` the whole suite shows up. The Rust
ones remain without a prefix, and `protocol` is the one with the most risk of
a clash: not part of this task.

**Symlinks and not copies**, as the assignment asked. I found no reason to
copy.

### The deviation: a symlink points at a single checkout

With just `realpath`, a script run from the PATH uses the symlink's checkout.
In a sub-agent's worktree, `just cartridges` would then build **the ROMs of
another tree, with another tree's converter and in that one's `rom/build/`**,
and the worktree's suite refused to run against its own, stale ones. It broke
every sub-agent from the first `just herramientas` run from `main` onwards.

So each script, when starting from the PATH, searches upwards from the current
directory for a checkout that has its own copy of the same file, and if there
is one and it isn't itself, it does an `execv` of that one
(`tools/comun/ejecutable.py`). The symlink's checkout remains as the last
resort: outside any checkout. It's the same thing any tool that prefers the
project's version over the installed one does.

`comun/` is the layer that imports nothing; `ensamblado/` imports it only when
starting as a script. `tools/README.md` moves it down to a row of its own.

What this does **not** solve: if the checkout the symlink points at gets
deleted —a worktree that gets cleaned up—, the executables are left dangling
until `just herramientas` is run again from another one. Hence:

> **When merging, run `just herramientas` from `main`.** Today the symlinks in
> `/usr/local/bin` point at Espinillo's worktree.

### `video.py` and pytest

`video.py` belongs to `tests/`, so it isn't installed: the `justfile` calls
it by its path, and the `-O` goes in the hashbang (`#!/usr/bin/env -S python3
-O`). It didn't need to go in any exceptions list. `env -S` is from coreutils
8.30 onwards.

The tests run with `pytest` instead of `python3 -m pytest`; the only thing the
`-m` added was the root in `sys.path`, and nothing imports `pruebas.` or
`tools.` from there. `_xdist` asks with `pytest -p xdist --help`, which exits 1
if the plugin isn't there (measured with a non-existent `-p`: `--version`
exits 0 anyway, which is why it doesn't work).

### The test

`tests/tooling/test_abl_side.py`. What ABL's side is, is written
above the test: the `justfile` except the eight recipes of the tools
(`protocolo`, `*-pruebas`, `ditto-vuelta-entera`, `herramientas`),
`patches/`, `data/`, and `tests/` + `pytest.ini` with 28 exceptions. Both
lists can only shrink: it fails if a new one appears and if one on the list no
longer names `tools/`.

For it to go green the header the converter writes in each versioned patch
had to change —136 files of `patches/auto/`, one line each— as well as
`ceilings.toml`'s, plus the READMEs of `patches/` and `data/` and the prose of
ABL's recipes.

The exceptions of `tests/` are of two kinds. The ones that build the import
path or read files from `tools/` (`pytest.ini`, `video.py`,
`test_repartos.py`, `test_musica_stream.py`, `test_protocolo.py`) go away when
the tests get separated from the tools. The rest name it in the prose —"ver
`tools/port/eventos.py`"— and go away when that's rewritten.

What the test doesn't look at, on purpose: imports by package name (`from
rpgmaker import lcf`), which don't say where anything is.

### Verified

See each commit's message. At the end, on the tree merged with `main`:

* **ROMs byte for byte**: `just cartridges` on `2bf9ff2c`, before touching
  anything, and `SIN_CACHE=1 just cartridges` on the final tree: the 47 files of
  `rom/build/release/` and `rom/build/tests/special/` —two `.sfc`, two `.msu`
  and 43 `.pcm`— with the same sha256. `abl.sfc` `7a3c6483…6a66552`,
  `prueba.sfc` `fb6db844…66a0617`.
* **`just tests`**, run from the scratchpad with `--justfile`: 973 pass,
  none fails.
* `just herramientas` installs the eight; all eight answer `--help` by their
  name from outside the repo.
* From outside the repo too: `just space release`, `just space <ruta a
  abl.sfc>`, `just patches-check`, `just build release`, `just video release …
  quieto:120` (the hashbang's `-O` works: without it, `video.py` refuses) and
  `just ceilings --medir`.
* The re-exec, with a fake checkout in the scratchpad whose `cartridges.py`
  only prints: `rm2k-snes-cartridges` run inside it runs that one.
* The grep test, with a line violating each rule put in by hand and removed
  afterwards: see the message of `2aa151be`.

**What wasn't tested**: nothing on the host. `CARGO_ROOT=~/.cargo just
herramientas` wasn't run; the recipe does `mkdir -p` of the `bin/` and uses
absolute paths, so it shouldn't depend on where, but it isn't measured. `just
entregar` wasn't run either, as instructed: only `abl-entregar --help`. And the
`_xdist` branch without the plugin wasn't run in full; only that `pytest -p
<inexistente> --help` exits 1 was measured.

**For taro**: after merging, `just herramientas` once, on the host side too.
Without that, `just cartridges` says `rm2k-snes-cartridges: command not found`.
