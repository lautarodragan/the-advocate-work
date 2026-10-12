# How work is done in these repos

This is what can **not** be deduced by reading the code. Everything else is
in better sources, and one has to go to them before this file.

**There are four repos, and this is the only one with instructions**: this
file and `.claude/` —the roster of sub-agents— apply to all four, and none
of the others has its own. It is taro's, from 2026-10-10. The CLI runs
standing here, and the other repos are next to it:

    the-advocate-work   this one: where we left off —`tasks/`— for every
                     repo; its README explains each folder
    the-advocate        the tools and the runtime: the converter, the engine
                     in assembly, their tests, and how each part works
    the-advocate-ports  the ported games, one per directory: `abl/` —A
                     Blurred Line, with the suite and its goldens— and the
                     seven from the survey of other games
    the-advocate-docs   the book, public and in English, for people and for
                     AIs: **all the documentation** —what the project is,
                     how it works inside, the reference for RM2k and for
                     the console, the decisions, the divergences from
                     RM2k, the research and one entry per port—

**The paths in this file are from inside each repo**, and which one is
said by the section or by the path itself: `runtime/…`, `snes/…`, `rm2k/…`
and `rm2k-snes/…` are from `the-advocate`; `pruebas/…`, `parches/…`, and a
bare `justfile` and `rm2k-snes.toml`, from `abl/` in `the-advocate-ports`.
Inside `the-advocate`:

    justfile         what can be run —testing and installing the
                     tools—; the comments explain the why. It is run with
                     `just`, standing anywhere in the repo
    README.md        what the project is, how it is installed, and the
                     architectural whys that have no line of code to live in
    LAYOUT.md        what each folder of the repo does

Until 2026-10-10 all of that lived in a `tools/` folder of that repo, and
it was run with `just -f tools/justfile`: **a `tools/x` citation is `x`**.

And inside `abl/`, in `the-advocate-ports` —each game is a whole project in
its directory, and everything is run standing in it; the README at the
root says which ones there are—:

    justfile         what can be run; the comments explain the why
    README.md        what the game is, how it is built and how it finds the
                     tools
    data/            the dump to JSON; its README sees it from inside
    pruebas/         the suite: its README says which ROM there is and
                     which test covers what

    git log          in all four: the messages are long on purpose, they
                     are the record

**History was split twice.** On 2026-10-02 ABL left the tools for its own
repo, without history: the history before that date is in `the-advocate`,
and what in the ports is `abl/X` was `rom/X` there (how to ask for its
`blame`, in "`git blame` and mechanical changes"). That repo had ABL at the
root until 2026-10-10, when it moved to `abl/` with a `git mv` —`blame`
follows it without options— and the other seven games came in. On
2026-10-10 `tasks/`, `decisiones/` and `divergencias/` left the `workflow/`
folder of `the-advocate` for this repo, **with** their history: **a
`workflow/…` cited in another repo is the same path here**, without the
prefix, and the hashes the tasks cite are from `the-advocate`, or from the
ports when they talk about ABL. And the same day `decisiones/`,
`divergencias/` and all the `docs/` —of the tools and of ABL— moved to the
book, translated and with the same file names: **an old citation is found
by name**, and this repo's README says where each folder went.

**ABL's tests are, until the test game exists, the engine's only ROM
tests**: see "The rule that holds everything up".

When starting, look at the tasks in `doing` and `testing` —`nu
tasks/tasks.nu ls -s doing`—, which is where we left off. The task is
written **while working, not at the end**, and when finishing its `status`
is changed. The tasks all live in `tasks/`, and **their file name never
changes**: it is what links them from the other repos and the book (see
this repo's README).

**Taking a task is moving it to `doing` with its `assignee`, before
anything else.** With sub-agents the one launching them does it, on `main`
and before launching them, so the worktree already starts with the task
taken and two agents do not grab the same one. The `assignee` is the
agent's name: the one launching them gives them one —one word, not the
tool's code— and tells it in the assignment. A task the agent opens on its
own is born in `doing` with its name. It is taro's, from 2026-09-28; until
that day the state was called `wip` and was barely used.

**A finding that is not fixed is a draft**, and if it shows while playing a
port, it goes to "Known issues" of its page in the book, one line told from
what is seen; whoever fixes it removes both things in the same change. When
merging a sub-agent's branch, what its report says it found and did not fix
has to be there. It is taro's, from 2026-10-11: until that day findings
stayed in the agent's task and were buried with it. What a draft is, in
this repo's README.

## Where each thing one wants to leave written goes

Two rules, taro's, from 2026-09-15. Both come from the same problem: what
is written by hand in a document ages without warning, and what lives far
from the code nobody reads when it is needed.

**A number is written only if it is a property of the hardware or of the
format.** The 32,704 bytes of bank 0, the 8x8 tiles, the 15-bit colour, the
64 KB of ARAM: those do not change. **A number that describes the state of
our work is not written anywhere; the command that prints it is**: how many
cases pass is said by the suite, how much the cartridge weighs is said by
the build.

On 2026-09-15 there were **three different numbers for the same question**
—281, 314 and 332 of 489— in two files, all three stale, and the real one
was 350. One of those I had written myself an hour earlier.

**A why stays in the README only if it is an architectural decision that
has no line of code to live in**: why fixed mode 3, why LoROM. **A why that
protects a concrete line goes as a comment on that line.** The reasoning is
taro's and is hard to argue with: nobody editing a routine is going to look
for the reason in a five-thousand-line README, so there it protects no one.

And if the mistake is not one of those that get made again, it goes
nowhere: the `git log` already has it.

**The documentation does not name the environment where we run this**:
not the container, not `box`, not the folders in `~` that are not repos,
not `/shared`, not paths of this machine. It says which variable or which
flag points to it —`GAME_DIR`, `RTP_DIR`—, and the environment stays in
this file and in `maquina.just` of the ports, which are the only ones that
describe it. It is taro's, from 2026-09-26; tasks and code defaults do not
count.

**All written code is assumed to be intentional**, knowing it may not be.
Each intentional case is not documented, because the unintentional ones are
the exception. In front of something that looks like a bug, the first step
is **`git blame`**: it separates "this is on purpose" from "this broke in
some change", which is the difference between touching it with confidence
and touching it blindly. Only with the intention shown —and shown wrong, or
partly wrong— is it fixed.

The other way round too: **if one writes on purpose something that looks
odd, one clarifies it right there.** taro's example: "here the variable
called NUMBER is of type string and not number, counterintuitive as it is,
but it cannot be fixed because that is what an API we do not control
expects". That is what a comment has to say; what the code already says,
no.

## The book: decisions, divergences, research

Since 2026-10-10 **all the documentation lives in the book**,
`the-advocate-docs`, and it is written **in English**, its commits too. It
is taro's: "The book is for people and for AIs", and having it in a single
place is useful to him. What that asks for when working:

* **A new decision** goes to `src/decisions/<slug>.md` —or to
  `src/ports/<game>/decisions/` if it is a game's—, with `## What`,
  `## Why` and, if needed, `## How it applies`; **a new divergence**, to
  `src/divergences/<slug>.md`; **a research**, to `src/research/<slug>.md`
  or to its port's. Each one, also, in `src/SUMMARY.md`, where it belongs.
* **A research is a snapshot**: at the top, the date and the commit of what
  it measured; it is not updated, a new one is made. **A page in
  `internals/` has to be up to date**: whoever changes what it describes
  changes it in the same commit, in the book.
* **The book is public**: it does not name the environment —not `~`, not
  `/shared`, not the container—. **A task is cited with a link** to
  `tasks/<name>.md` on GitHub, since this repo went public on 2026-10-11
  (taro). Files of the other repos are named as text ("`runtime/hero.s`
  in the-advocate"): the-advocate-ports is private.
* **mdBook does not warn about broken links.** Before pushing to the book,
  the relative links of what was touched are checked. Each push to `main`
  publishes it on its own, with its workflow.

The whys that protect a line of code **still go as a comment on that
line**, in Spanish: the book is for what has no line to live in.

## The independent projects are in English

Everything goes in Spanish —comments, documentation and commit messages—,
**except the book, `the-advocate-docs`, which is for the outside and goes
in English entirely, its commits included; this repo, `the-advocate-work`,
which goes in English entirely too —tasks, README, this file and
`.claude/`, its commits included— since 2026-10-11, taro's decision the
same day it went public; and the directories of `the-advocate` that are
separate projects**, which go in English from end to end: code, comments,
test names and README. The rest of `the-advocate` and the ports stay as
they were: comments and commits in Spanish, except those projects. Since
2026-09-19 they live inside the tools —see `LAYOUT.md`—:

    snes/        the console's formats, knowing nothing about RPG Maker
      gunter/          Gunter: BRR codec and SoundFont reader
      goombario/       Goombario: the 65816 linter, what assembles fine and
                       is wrong; reads the ROM, the `.dbg` from `ld65` and
                       the source
      adeleine/        Adeleine: which colours are lost and how they are
                       grouped into palettes
      voodoo/          Voodoo: from an image to tiles, palettes and tilemap
      lz2/             Nintendo's LC_LZ2, which the maps are compressed with
    rm2k/        RPG Maker 2000's, knowing nothing about the console
      ditto/           reads and writes its formats; as a library, the only
                       place in Rust that reads the dump
      rules/           rm2k-rules: what the format means —passability,
                       pages, experience—
      rm2k-render/     a map's layers, its CharSets, the battle stuff and
                       the faces, windows and signs of the screens, drawn
                       like RM2k
    rm2k-snes/   the ones that join both things
      project/         the library: which game, its knobs, the machine's
                       flags; and `rm2k-snes-project`, which tells it in
                       JSON to a game's tests
      bytecode/        the cartridge's two bytecodes, declared once: the
                       Rust constants and the assembler's `.inc`
      cartridge/       the cartridges: the split into banks, ca65 + ld65,
                       the space
      patches/         the patches: what the converter decides to lose, in
                       TOML
      rm2k-snes-audio/ the music: from the MIDI and the SoundFont to
                       musicdata.inc
      battle/          the battle: experience and encounters, the model and
                       its text screen, and the played battle for the tests
      events/          the event compiler: from RM2k's pages to the
                       bytecode
      wally/           Wally: a whole map —layers, baking, sprites—, with
                       its two halves as modules that do not know each
                       other: the background and its 16x16 blocks, and the
                       characters as objects
      text/            the font, a line of text over the System and the
                       split of the boxes to the window's width
      screens/         the screens: the message window, the title, the
                       slots, the menu, the text screens, End Game
      images/          the images: the title and the Game Over, the one of
                       `ShowPicture`, the battle backgrounds and battlers
                       and their animations, scaled and with their palettes
      mapdata/         the emission: the cartridge's `.inc` with what each
                       stage answered, the LZ2 streams and the VRAM layouts
      convert/         the converter: it asks each stage, in order, for
                       what the cartridge needs, and gives it what the
                       others answered

The layers only depend downwards —`rm2k-snes/` on the other two, and those
on nothing of the rest—, and `tests/test_layers.py` guards it. They are
all one Cargo workspace, with the `Cargo.lock` and the `target/` at the
root of `the-advocate`.

Until 2026-09-16 there was one more, `w65/`, the 65816 assembler. It was
replaced by `ca65` and `ld65`, from the cc65 project: see "Where this runs".

**They are consumed from the PATH, not from `target/release`.** They are
installed with `just install` —`cargo install --locked --path …`— and from
then on they are system tools, like `python3` or a libretro core: **no
script or test of this game calls `cargo`**. It is taro's, from 2026-09-15,
and what it avoids is each run of the suite being tied to the Rust
toolchain.

`CARGO_ROOT` says where they install; by default `/usr/local`, which here
is in the PATH.

The rule to know whether something goes inside one of those is a single
one: **if it does not need to know anything about this game, it is a
separate project and goes in English.** Inside, neither ABL nor the port is
named, and their flags are English even if the recipes' equivalent has
them in Spanish (`--include`, `--symbols`). Talking about the console *as a
format* —the SPC700, the 65816— is fine: that is the domain, not the
project.

It is not an oversight to correct: if someone "fixes" it into Spanish, they
undo the decision. **Commit messages stay in Spanish for those directories
too**: they belong to the repo.

And **what those tools generate goes in English too**, even if it lands in
the tools repo or in `runtime/`: it is their output, not source of this
tree, and it says at the top that it is generated and where from; and also
what they leave in a port's `build/`, like the comments in the converter's
`.inc` files. On 2026-09-14 the rule was the opposite —"the language of the
tree where it lands"— and it lasted a day: when generalising the generator
for the second bytecode it became clear that making it speak Spanish ties
it to this repo.

The tests of those projects do not depend on the game. Ditto receives the
corpus through `DITTO_CORPUS`, and without that variable the ones that need
it are skipped with a message; `rm2k-snes/rm2k-snes-audio/` receives the
SoundFont through `SOUNDFONT`, the same; `snes/goombario/` assembles toy
programs and needs `ca65` and `ld65` in the PATH, and without them it is
skipped the same way; and `snes/gunter/`, `snes/voodoo/`, `snes/lz2/`,
`snes/adeleine/`, `rm2k/rules/`, `rm2k/rm2k-render/`, `rm2k-snes/battle/`,
`rm2k-snes/bytecode/`, `rm2k-snes/events/`, `rm2k-snes/patches/`,
`rm2k-snes/wally/` and the two of the screens, `rm2k-snes/images/`,
`rm2k-snes/mapdata/` and `rm2k-snes/convert/` need nothing.

### `snes/voodoo/` does not decide colours, and that is not to be fixed

`snes/voodoo/` converts an image **that already fits**: it receives indexed
PNGs whose indices are CGRAM entries, and if the image breaks the format,
it says where and does not fix it. Which colours are lost and how they are
grouped into palettes is decided by Adeleine, `snes/adeleine/` —`wally`,
`rm2k-snes-screens` and `rm2k-snes-images` use it as a library—, which runs
**before**; what it decided for each map stays as images in
`build/<cartridge>/adeleine/`, in the game's project. The test to know
which side something goes on is whether it changes a pixel of what is
seen.

It is taro's, from 2026-09-17. Voodoo had a `--merge` that fused colours;
it was removed so that there is a single answer to "which colour was
lost". Giving it back any decision of that kind undoes the design, however
convenient it is.

## An opcode's number is chosen in the declaration

In `rm2k-snes/bytecode/` and nowhere else. There are two declarations,
each one an invocation of the `bytecode!` macro: `src/events.rs`, the
bytecode that `run_code` interprets, and `src/music.rs`, the stream that
`irq_music` reads. The Rust side takes the constants with a `use`, and
`rm2k-snes-assemble` writes the 65816 one —`event_opcodes.inc` and
`music_opcodes.inc`— in the cartridge's directory on each build: there is
no committed generated file that can go stale. Both land in the same symbol
space of the assembler, so two opcodes of different bytecodes can share a
**number** but not a **name** —that is why `OP_FIN` is called `OP_DONE`:
`OP_END` already belonged to the music stream—, and that, like a repeated
number or a gap in the dispatch, **does not compile**: they are `const`
asserts of the crate, with the opcode in the message.

Until 2026-10-02 they were declared by two TOML files in `snes/protocol/`,
a generator that wrote both sides and committed them, and a test that
made sure they did not go stale.

Before that, the event one was declared by `tools/port/events.py` and
reached the interpreter inside `mapdata.inc`, which is how two branches
could pick the same one without git seeing anything; the music one was
written by hand on both sides. (`mapdata.inc` still exists and `main.s`
still includes it: what left it is the bytecode, not the map tables.) When
splitting work among sub-agents it is still worth handing out the numbers
in advance, but now the collision is a git conflict in a file and not a
bug that travels inside a merge.

From the event one also comes **the dispatch table** of `run_code` (the
`EVENT_HANDLERS` macro), so a new opcode is its entry in `src/events.rs`
and its `.proc op_x`, with the opcode's name in lowercase; the dispatch is
not touched. That requires **contiguous numbers from 0**: if an opcode is
removed, the gap has to be closed —renumbering, or giving the number to the
next one added—, because the declaration does not compile with gaps.

## `git blame` and mechanical changes

Everything in this section is about `the-advocate`, except the last
paragraph, which says how to ask for the `blame` of what is in the ports.

`.git-blame-ignore-revs` lists the commits `git blame` has to skip: mass
renames and reformats, which without this answer "it was the rename" on
every line they touched. The criterion for putting one in is that its
change **cannot alter behaviour**, and in this repo that is demonstrated,
not assumed: the two that are in there have both ROMs coming out byte for
byte equal.

If it does not work as expected, we can pass it as an argument: git blame --ignore-revs-file .git-blame-ignore-revs <file>.

And what it does **not** fix: it only works for `blame`. For `git log` and
`git diff` there is no equivalent, so to track when something changed
`git log -S '<text>'` still holds, which searches by content and therefore
ignores the noise on its own.

**`runtime/` gets across the split of `main.s` only with
`git blame -C --diff-algorithm=histogram <file>`.** On 2026-09-25 `main.s`
was split into one file per subsystem, and the split is **not** in
`.git-blame-ignore-revs` because it does not help: ignoring a commit passes
the blame to the same file in the parent, and none of the new ones
existed. Without options, `blame` answers "it was the split" on every line;
with `-C` alone, almost the same, because the default diff (Myers) pairs
the repeated lines —`rts`, `.endproc`, blanks— with the first ones it finds
in thirty thousand lines and the chunks end up shorter than `-C`'s minimum.
With histogram, which anchors on the unique lines, **each line comes out
with the same commit the old `main.s` gave**: measured over the
thirty-four thousand. `git log --follow` does not cross the split; `git log
-S` does, because it searches in every file.

**The move from `rom/src/` to `runtime/`, on 2026-09-29, costs nothing**:
it was a commit with a `git mv` alone, without touching a line, and `blame`
follows renames without options. With the options above, each line of
`runtime/` comes out with the same commit it gave in `rom/src/` before the
move: measured over `main.s`, `hero.s`, `interpreter.s`, `battle.s`,
`registers.s`, `audio_package.s` and `event_opcodes.inc`, four thousand
lines. With `data/`, `parches/` and `pruebas/`, which moved inside `rom/`
in the same commit, `blame` without options was enough: measured over
`rom/pruebas/arnes/consola.py`.

**ABL's stuff left for its own repo on 2026-10-02, without history**: in
`the-advocate-ports` each file is born in a single commit. Its `blame` is
asked for in `the-advocate`, on the path it had and at the parent of the
commit that deleted it —`git blame d356bfb7^ --
rom/pruebas/arnes/consola.py`—, and `git log -S` still finds everything
that happened before that date, on both sides.

IDEs that do not let you pass options to `blame` —JetBrains' annotate—
need configuration on the host side: see "JetBrains" in the book, in
`contributing/`.

## The rule that holds everything up

Nothing is taken as good because it looks good: **it is compared pixel by
pixel, at 15 bits**, which is the console's real depth. What changed on
2026-09-16 is against what.

Until that day it was compared against a **Python reference** that did the
same as the ROM. Today it is compared against **frozen captures** —the
goldens of ABL's suite, in `pruebas/golden/tanda/` of its repo, which are
what the ROM drew the day the suite was green—. Three obligations come out
of that, and one of them is new.

**The engine's ROM tests live in ABL, for now**: almost all of
`pruebas/rpgmaker/` in the ports is what RM2k does, using ABL as a stage.
They left with the game on 2026-10-02, because they need one, and they
come back to `the-advocate` little by little when the test game exists
—phase 2 of `research/2026-10-02-el-juego-de-pruebas.md` in the book—.
Until then **a change in the tools is verified by running ABL's suite with
the tools of the change**, as "Where this runs" says; `just test` and each
crate's tests run no ROM. It is the risk the study pointed out, and it is
the argument for not delaying phase 2. And a golden that moves because of a
change in the tools is looked at and committed in the ports, in its own
commit.

**Changing a golden is a deliberate act.** It goes to git, it is looked at,
and the commit explains why the render changed. If regenerating them were
automatic, or if the suite did it on its own, they would stop serving any
purpose. It is the same as any snapshot testing.

**A golden catches regressions, not birth defects.** A feature that comes
out wrong from day one bakes the bug into its golden and the test defends
it from then on. It is not theoretical: on 2026-09-15 **three goldens of
the walkthrough with a stuck tint** showed up, and two of them **passed**
—one with a 10.3% difference under a 15% cap—. What counterweighs this is
that taro plays.

**And there is a class of bug that no golden can see, because the emulator
that took it does not see it either.** That is what
`pruebas/rpgmaker/test_cores.py`, in the ports, is for: it runs the same
cartridge in **snes9x and in bsnes** and compares the two captures with
each other. bsnes starts WRAM with garbage and snes9x with zeros, so a
difference means the ROM depends on uninitialised memory. It goes red
**four out of five runs** with the bug in place —measured—, because the
garbage has to land on a value that breaks.

What **went away** with the reference: the obligation to move both sides
together, and the failure mode of "if both sides are wrong the same way,
the comparison gives zero" —which bit twice, with the doors' command codes
and with OAM priority—. There are no two sides any more.

What **is still whole** is its cousin, and it is the one that bit most
often: **a path no test executes**. That is how the three bugs of the event
interpreter survived, that is how the recipe that compared against `ca65`
was broken for months, and that is how a troops test read the wrong chunk
without ever failing.

**Saying "verified" requires naming what was run.** Commit `c64e4d9` said
"Verificado: mapas 7 y 4 en cero" over a path no test executed, and behind
it there were three chained bugs. If a new path is not covered by the
suite, the message has to say so in so many words.

## Where this runs

Inside a podman container that taro brings up with `box`, a nushell
function of his: Arch —same as the host—. **The four repos are cloned in
`~/`, inside the container** —`~/the-advocate-work`, `~/the-advocate`,
`~/the-advocate-ports`, `~/the-advocate-docs`—, and the CLI runs standing
in the first one. Since 2026-10-10 nothing of git is shared with the host:
what is committed here reaches GitHub with a `git push` from here, and
taro brings it from there. `~` is a named volume and survives the
container. Until that day the tools repo was mounted from the host at
`/host/abl-snes` and ABL's at `/abl-snes`: they are old checkouts and are
not used.

**Each repo has its own key for GitHub**, a deploy key with write access in
`~/.ssh/<repo>` —GitHub does not allow using the same one in two repos—.
`~/.gitconfig` picks it by the remote, with one `includeIf
"hasconfig:remote.*.url:…"` per repo pointing to
`~/.ssh/git/<repo>.gitconfig` and its `core.sshCommand`; that way it holds
for any clone or worktree, also the first `git clone`. `~/.ssh/config` only
says `IdentitiesOnly yes` for `github.com`: without it ssh offers another
key, GitHub accepts it, and answers a misleading "Repository not found". A
new repo is the key, its `.gitconfig` and one more `includeIf`.

`/shared` is something else: a CIFS mounted from taro's NAS —spinning
disk, slow, no symlinks, no execute bits and case-insensitive—, and it is
where the builds, the captures and the audio for taro go (see
"Sub-agents"). Until 2026-10-03 ABL lived there, in `/shared/abl-snes`, and
the old copy is still there but **is not used**.

**The tools are consumed from the PATH**: `just install` installs them,
from `~/the-advocate`, into `/usr/local/bin`, and from there they belong to
the system, like `python3` or a libretro core. **The runtime is assembled
by `rm2k-snes-cartridges` from the checkout it was installed from** —the
path is compiled into `project`—: reinstalling from another checkout
changes which runtime goes into the ROM. No script or test of the ports
calls `cargo` or names the path of `the-advocate`, and
`pruebas/herramientas/test_lado_de_abl.py` guards it: what the tools know
about the project —its paths, the `rm2k-snes.toml`— the harness asks
`rm2k-snes-project` (`pruebas/arnes/proyecto.py`).

**To run ABL with the tools of a checkout that changes them** —a worktree
of `the-advocate` that touches the runtime or the converter—: `just
install-local .local-tools <Rust projects>` in the worktree, and from
`abl/` in the ports `PATH=<worktree>/.local-tools/bin:$PATH just pruebas`.
ABL's `justfile` builds its PATH from the one it receives, and what is not
in that `bin/` comes from the global one. **But it builds in the `build/`
of the ports checkout where it runs**: the one in `~/the-advocate-ports` is
the one that gets played and the one of the main suite, so an agent that
needs it gets its own worktree (`git -C ~/the-advocate-ports worktree add
<dir>`).

The rest of the system is disposable, and that is why taro works in auto
mode and does not approve command by command; what he reviews is the `git
diff`.

What the container changes in practice:

* **There is no podman inside**, and since 2026-09-19 no recipe uses it:
  the Mega Drive port, `audio-validar` and the `rom/Containerfile` are
  gone.
* **There are no published ports.** Nothing served in here is visible from
  the host.
* **`~` survives the session**, as do the installed packages: `/root`,
  `/usr`, `/var` and `/etc` are named volumes, not layers of the image.
  `/tmp` does not: the container runs with `--rm --replace`, and it dies
  with it.

`~` is **free to use**, and that is the way to get reference material: it
is cloned or downloaded in here instead of mounting something from the
host, which reveals less and gives more leeway. Besides the four repos it
has:

    ~/juegos/      the RM2k originals: `<port>.zip` —`abl.zip` and the
                   seven from the survey— is each port's `GAME_DIR`, and
                   next to it the same game in a directory, for Wine
    ~/assets/      `rtp.zip`, Don Miguel's RTP, without which 22 assets
                   are missing —`rtp/` next to it is the same,
                   unzipped—; `rtpe/`, the extended RTP; `soundfonts/`,
                   where the samples come from; and `msu/`, the
                   replacements for the MSU-1 tracks
    ~/ref/         what was cloned to read: liblcf, easyrpg-player, the
                   emulators, Game-Decompilations; and `cc65/`, compiled
                   here, where `ca65` and `ld65` come from
    ~/wine/        the original ABL running with Wine: the recipe, in
                   `~/wine/abl/LEEME.txt`
    ~/scratch/     the temporary files, each agent in `<name>/`

**The games and the RTP are read from their `.zip`, and are not touched**:
a change to a game goes through its patches. It is taro's, from 2026-10-11
—"it forces us a bit not to modify them"—. The tools read a directory just
the same, and a copy retouched to measure something is unzipped into
`~/scratch/<name>/` and passed in `GAME_DIR`; the one in `~/juegos` is
never edited.

Until 2026-10-10 all that lived in `/extras`, another volume on the same
disk, with 75 GB of leftovers from other times; it was cleaned up and moved
here. What taro wants looked at he leaves in `/shared`.

The tools reach `~` and `/shared` through flags —`--game-dir`,
`--rtp-dir`, `--soundfont`, `--replacements`, `--shared`—, and know of no
value of this machine. They are set by `maquina.just`, at the root of the
ports, which each game's `justfile` imports: it translates `RTP_DIR`,
`SOUNDFONT`, `SHARED` and `JUEGOS` with the values from here by default,
and each game adds its `GAME_DIR`; they are exported, because ABL's tests
read them too. The MSU-1 replacements, which have no variable, are its
`reemplazos_msu`. If the environment changes, it is changed there. Until
2026-10-10 ABL called them `ABL_GAME_DIR`, `ABL_RTP_DIR` and
`ABL_SOUNDFONT`, and each game repeated its own. `ABL_CACHE` and
`CARTUCHOS` are translated too, in ABL's, but with no machine value: the
cache and the test cartridges live inside `build/`, and the variables only
move them.

The two tests of the tools that read a real SoundFont —those of
`rm2k-snes-audio`— receive it in `SOUNDFONT`, like Ditto its corpus in
`DITTO_CORPUS`: without the variable they are skipped. To run them here,
`SOUNDFONT="$HOME/assets/soundfonts/Microsoft GS Wavetable Synth.sf2" just
crate-test rm2k-snes-audio`, standing in `~/the-advocate`.

**`ca65` and `ld65` are compiled in here, and that was a decision.** They
are not packaged in Arch, and until 2026-09-15 the rule was not to compile
sources from the internet in the same box where the repo lives:
`audio-validar` ran `ca65` in a separate podman, from the host. taro
declared that rule expired —it came from when each command was wrapped in
its own container— so `cc65` was cloned and compiled in `~/ref/cc65`, and
the binaries are linked in `/usr/local/bin`. If the container is recreated
from the image, they are rebuilt with `git clone --depth 1
https://github.com/cc65/cc65.git` and `make -j8 bin`.

What was checked about the clone before using it, so that the next person
does not take it as carelessness nor repeat it: the repo **brings no
committed binaries** —those in `bin/` come from its 989 C sources—, the
build **downloads nothing from the internet** nor writes outside its
directory, and `ca65` uses **55 external symbols and none is about network
or execution** —it does not import `socket`, `connect`, `exec*`, `fork`,
`system`, `popen` or `dlopen`—. What was **not** checked: the project's
tags are not signed, the clone is `--depth 1` and has no history, and
nobody read the 989 files. And the build ran with network and as root:
auditing afterwards does not undo that.

**The defence that did not depend on the audit left with `w65`.** While it
existed, the output of `ca65` was compared byte for byte against ours; on
2026-09-16 the two reference ROMs came out identical and `w65` was deleted.
From then on `ca65` and `ld65` are the ones that build, and what would
catch an altered binary is the same thing that catches any regression: the
goldens and `test_cores.py`. Recompiling them without looking stops being
harmless.

**The repos in `~/ref` are cloned inside and are not the host's.** `liblcf`
is where Ditto's schema comes from —and with it the defaults that a game's
`data/` already brings applied and the names of RM2k's commands, against
which `codes.rs` of the event compiler holds up—: they come from there and
from nowhere else, because the first version of the doors filter put them
in from memory and three were wrong. If something is needed that cannot be
obtained from here, taro is asked to copy it to `~`.

**taro runs nothing on the host**: if he runs something by hand, he does it
in here, and asks first. It is his, from 2026-10-05. The only things that
belong to the host are the `git push`, the EverDrive over USB, and
**seeing and hearing the ROM for real** — in here it is captured with Xvfb
and the audio is recorded to a wav instead of playing.

## Recipes or throwaway scripts

The decision is not about security: it is the cost of maintaining the
script against what having it yields. One recipe per script would turn the
justfile into noise.

**A `just` recipe** when it is going to be run again: if it goes into a
verification chain, or if it is worth having written down how something
was built. `evento` was born that way, and along the way the hand-built ROM
that sent us to look at the wrong map ceased to exist.

**A throwaway script** when it answers a one-off question: how many maps
have such a thing, at what ROM offset such a byte falls. It goes to the
scratchpad and is thrown away.

## Environment traps

**`runtime/` is a single assembly split into many `.s` files.** `main.s`
glues them together with `.include`, and the order of that list is the
order in the ROM: splitting is free, moving is not. What that implies —each
file inherits the widths and the segment of the previous one, anonymous
labels are resolved over the glued text— is said by the header of
`main.s`, which is where whoever adds a file will see it. Until 2026-09-25
it was a single file; it was split byte for byte equal, and that is why
there are routines that stayed in the neighbour's file: moving them is a
ROM change, and goes in its own commit.

**A generated `.inc` never goes in `runtime/`.** `ca65` looks for
`.include`s first in the directory of the including file and only after
that in the `-I`s, so a `mapdata.inc` in `runtime/` would cover the
cartridge's without warning: the ROM would come out with someone else's
data. Until 2026-09-16 the `convert` recipe wrote right there —in
`rom/src/`, where the runtime lived until 2026-09-29; it was "global
state", and that is how map 6 ended up being looked at in the belief that
it was the demo of milestone 12—; today each cartridge writes its own in
its directory of the project's `build/`, and `rm2k-snes-assemble` refuses
to build if it finds one in `runtime/`. **ROMs come out of a recipe, not
of a loose `ca65`.**

**How much bank 0 has left depends on which cartridge is built.** The
tables the converter emits live there, so the number changes with the list
of maps: on 2026-09-13 the same question was answered **81**, **1** and
**85** bytes in the same afternoon, and all three were right —each with a
different `mapdata.inc`—. So when saying "N bytes are left" one has to say
with which one.

**The tightest one rules**: until 2026-09-25 the test cartridges carried
more maps than `abl`, and measuring only in it said there was room when
there was not. Since `abl` is also the suite's cartridge it carries all of
them, but `test-special` has its own flags. Which one is the tightest
changes, and twice it was written here and went stale: **it is not
written, it is measured**, and all of them have to be measured: `abl` and
the ones `cartuchos` builds.

**It is measured with `just espacio`, in `abl/` of the ports**, which runs
`rm2k-snes-space` and prints for each cartridge the free data banks and
the gaps, bank 0, bank 1, `BSS`, `ZEROPAGE` and the text block; with the
path of a ROM built separately, it measures that one. What counts is **how
many banks are left**, not a percentage: banks `$7E` and `$7F` are not
ROM. Until 2026-09-27 it was measured by hand, linking a `.res N` against
the recipe's `.o`; that still works for the only thing the recipe cannot
do, which is a ROM that does not link: there `ld65` says by how much it
overflows.

**`build/cache/`, in the port, is an on-disk cache** —which MSU-1 tracks
are already there— and its key carries the hash of the sources **and that
of the binaries that produce what is stored**, so it does not have to be
deleted when touching code. The only thing it asks is that any change in
what is cached be verified with `NO_CACHE=1`: both ROMs have to be byte for
byte equal. See `cache.rs` in `rm2k-project`.

**While the tests are running no source is touched**, not from the other
repo either. The fingerprint of `rm2k-snes-cartridges` covers all of
`runtime/` of the checkout the tools were installed from and the binaries
that build —`ca65`, `ld65`, `rm2k-snes-assemble` and the ones the converter
runs—: touching any of those while ABL's suite is running, or reinstalling
one, mixes two versions and the result says nothing.

What **is no longer needed** is isolating oneself in a worktree for that.
Until 2026-09-16 there was `just hitos-foto`, which took a snapshot of the
tree with `git stash create` because the suite ran recipes that overwrote
`rom/src/mapdata.inc` —the runtime lived there—, which was then global
state. Since 9f the tests build nothing: they run against the cartridges
that `just cartuchos` builds beforehand —`release` and those in
`build/tests/`—, and the harness refuses to run against a stale one. Two
runs at once only step on each other if both find a stale cartridge and
rebuild it together: with `just cartuchos` run once before, the only thing
they fight over is the CPU.

**The background tasks we launch, we can kill.**

What piles up the most are the **waits set up by the agents** —`until !
pgrep -f "pytest"; do sleep 30; done`— and they have two vices:

* **They never end on their own**, because their own command line contains
  the text the `pgrep` looks for, so they find themselves.
* When they finally wake up, they print results of suites that closed
  hours earlier, and that has already sent us to look at old numbers more
  than once.

When killing them, careful with `pkill`: if the pattern appears in its own
command line, it kills itself —code 144— and leaves half the job done.
Splitting the pattern is enough: `pgrep -f 'un[t]il ! pgrep'`, and then
`kill` one by one skipping `$$`.

## Sub-agents

**They are used, and they are the preferred way when two jobs do not step
on each other too much.** Always with `isolation: "worktree"`, which gives
them their copy **of this repo**: there they take, write and move their
task. **They work the code in worktrees of their own** of each repo they
touch —`git -C ~/the-advocate worktree add ~/scratch/<name>/the-advocate`,
and the same with the ports—, so `mapdata.inc` —which is global state— and
the suites do not get mixed. The one launching them brings their branches
in with `git merge` from those worktrees.

**They are a fixed roster, since 2026-10-04**: one file per agent in
`.claude/agents/`, with a name from Argentine flora or fauna, and what
applies to all of them in `.claude/agentes.md` —what used to be repeated in
every assignment—. They are launched by their name, not as
`general-purpose`, so the same agent comes back and finds itself: each task
carries in `agents` everyone who worked on it —the `assignee` becomes taro
in `testing`—, which `nu tasks/tasks.nu ls -a <name>` filters, and each
commit of theirs names them as its co-author. They still start from
scratch every time: continuity is what they leave written.

**The author of every commit is taro**, the agents' and Hornero's too, so
they count on his GitHub account; who wrote it goes at the end of the
message, as a trailer:

    Co-authored-by: Aguará <aguara@agents.taro.codes>

Hornero's own commits and merges carry `Hornero
<hornero@agents.taro.codes>`. The address is the name in ASCII and
lowercase —`chaja@`, `huron@`, `cardon@`—, and the domain has no mailbox
on purpose: nobody can verify those addresses on GitHub and claim the
commits. **No `Co-Authored-By` line for Claude**, not even the one the
tool suggests: taro's, from 2026-10-11. `git log --grep 'Co-authored-by:
Aguará'` finds an agent's commits, and `git shortlog -s
--group=trailer:co-authored-by` counts them. Before 2026-10-11 the trailer
was `Agente: <name>`, in Spanish in all four repos, and that is what `git
log --grep 'Agente: <name>'` finds. A merged commit without the trailer is
an agent that forgot it, and it is fixed when merging, before pushing.

What always has to be done:

* **Bring the builds to `/shared`, with `just entregar "<what to look
  at>"`, from the ports.** The worktrees live in `~`, which is not mounted
  on the host, and `/shared` is: it is where taro finds them. They go to
  `/shared/builds/<date>-<ABL commit>-<tools commit>/`, and the text passed
  to the recipe goes to the `LEEME.txt`: what changed, what to look at and
  which limitations were hit. Until 2026-09-24 they went to
  `pruebas-manuales/`, inside the repo, and until 2026-09-25 they were
  assembled by hand, which was repeated often and went wrong.

  **A single `.sfc` per build, and it is called `abl.sfc`**: the cartridge
  with a title screen, which is the one taro plays. The other demos are not
  copied; whoever wants them builds them. And **the last two directories
  are kept and nothing more**: the previous one is useful to compare with
  what was being played, and the older ones are rebuilt from their commit.
  It is taro's, from 2026-09-20, after the builds reached 4.3 GB in 51
  directories. The recipe deletes the rest and does not touch what taro
  leaves inside, like his emulator's save.

  **Next to it goes `abl.sfc.dbg`**, with which Mesen2 shows our routine
  names in the debugger, **and the commit's `runtime/`**, taken with `git
  archive`: Mesen2 looks for the source going up folders from the `.dbg`,
  so with `runtime/` next to it it shows it also from `/shared/builds/`.
  The `.inc` files the converter generates do not go —they weigh ~15 MB—
  and what falls in them is only seen disassembled. That is why the recipe
  **refuses when there are uncommitted changes** in what goes into the ROM,
  on both sides —the game and the runtime of the `the-advocate` checkout the
  tools were installed from—: the build is named after two commits and they
  have to be those. See "Debugging with Mesen2" in the book,
  `reference/snes/emulators.md`.

  **The rest of what taro has to look at or listen to goes to two folders
  and not to the root of `/shared`**: captures and goldens to
  `/shared/capturas/<date>-<topic>/`, audio to
  `/shared/audio/<date>-<topic>/`. It is taro's, from 2026-09-27, after
  cleaning up a dozen loose folders (`capturas-lashe-3`,
  `goldens-textos`…) and 2 GB of old audio. What is already in git or is
  rebuilt from a commit can be deleted once taro has declared it looked at.

  **The MSU-1 tracks do not go in the build: they go to `/shared/msu/`**, a
  single directory that is updated only when they change —its `LEEME.txt`
  says which fingerprint they are compared with—. They weigh half a gig,
  and copying them in every build would duplicate them for nothing. taro
  copies the `abl.sfc` next to them. It is taro's, from 2026-09-25, when
  `release` started carrying them always. `just entregar` warns if they do
  not match the build's, and copies them only with `--actualizar-msu`.

  **The `abl.msu` does go in the build, and also to `/shared/msu/`
  always.** Since 2026-09-25 it is not empty: it carries the battle
  backgrounds that the ROM reads through MSU-1 —see `internals/msu-datos.md`
  in the book—, so it changes with the converter and belongs to the build,
  not to the tracks; and it weighs 32 KB per background. With another
  build's `abl.sfc` nothing breaks: the ROM does not find its signature in
  the `.msu` and uses the backgrounds it carries.
* **And the ROM given to test comes from merged `main`, not from the
  agent's branch.** The agent's has its fix and **none of the others'**.
  The agent's is useful to isolate **its** change; the one that gets
  played, no.
* **Tell it which commit it starts from, and to merge `main` before
  delivering.** A worktree is taken from wherever `main` is when launching
  it, and `main` moves: on 2026-09-15 one worked four hours on a README
  **twelve commits old** and saw 5,499 lines where there were 4,717. The
  reconciliation afterwards is lost work that is avoided with one line in
  the assignment.
* **Pass the agent what is already measured**, so it does not find it out
  again and so it does not measure it differently.
* **Ask it for the measured limit and not the forced implementation.** When
  the point is to compare two paths, knowing where each one breaks is worth
  as much as the code.
* **Warn it that others are running**: two suites at once fight over CPU
  and take longer, and killing them out of impatience ruins the run.
* **Hand out the numbers to them in advance.** Everything that is chosen
  by taking "the next free one" —an opcode, an index in a tuple of ABL's
  `pruebas/*/test_*_golden.py`, a far RAM address— each agent is going to
  choose looking at its copy, and two are going to choose the same one
  without git seeing anything. It is cheaper to tell each one which it gets
  when launching it than to discover it when merging: on 2026-09-13 it
  happened with all three things at once, and an opcode collision travelled
  inside a merge that had already been declared verified. **Far RAM is no
  longer one of them** since 2026-10-11: a new variable goes with a `.res`
  in the `FARBSS` segment, in its subsystem's file, and the linker places
  it —see the top of `runtime/far_ram.s`—; an agent that writes a far
  address by hand gets ABL's `test_reservas_de_la_wram.py` red.
* **Tell it to namespace its temporary files.** The scratchpad is **shared
  among agents**, and two working in parallel pick the same obvious name:
  on 2026-09-15 two wrote a `comparar.sh` each in the same place. One
  overwrites the other and the overwritten one does not find out.
  `<scratchpad>/<what it does>/…` is enough.
* **That it runs `just install-local .local-tools` when starting, if it is
  going to modify the tools**, from the root of the worktree. The global
  one —`just install`— comes from `~/the-advocate`, and this builds a
  `bin/` in the destination with the Rust projects named to it —there are
  no Python scripts left, since 2026-10-02—; `justfile` puts it first in
  the PATH of its recipes, and ABL uses it if it is put first in its own
  (see "Where this runs"). **A Rust project is passed to it only if the
  agent is going to modify it** —`… install-local .local-tools lz2`—:
  compiling costs, and without names it compiles nothing. And **everything
  is run through `just`**: a loose command does not see that `bin/` and
  uses the global one. It is taro's, from 2026-09-29, and it replaced an
  implicit re-exec the scripts did on their own.
* **Ask it to leave nothing waiting when it finishes.** A sub-agent can
  launch its own, and those **do not show up** in the list of the one who
  sent it. The same with long `sleep`s to wait for a suite: on 2026-09-12
  one left five set up and they kept announcing it had finished long after
  it had delivered.

### What is verifiable and what is a matter of judgement do not share a commit

taro's, from 2026-09-16, and it works for any big cleanup: **first the
mechanical change alone, in its commit, verified; then the judgement one,
guided by the diff of the previous one.**

The case that showed it: deleting 784 lines of dead code and fixing the
comments that cited it. The deletion is verified by two nets —`just
pruebas` and the ROM byte for byte—; fixing the prose is verified by
nothing. Mixed, a judgement error travels inside a change that "passed the
tests" and there nobody looks at it any more.

And it has a second benefit, which was what decided it: **the diff of the
first commit is the list for the second**, complete by construction. The
handwritten list that was going to be used instead was missing eleven
dangling citations inside the file itself, two dead definitions from
others, and a dead parameter.

### A merge without conflicts is not a verified merge

Two branches that change **the same convention in different files or
lines** merge cleanly and git says nothing. It happened on 2026-09-13: one
branch made `package_load` read the map from `map_current` instead of A,
the other brought a caller that still passed it in A, and from that merge
on the battle loaded the map's audio package. The two tests that caught it
were red for a whole day and **three reports in a row took them as
"pre-existing"** —they were, but pre-existing does not mean unrelated—.

And it has a worse variant, which bit twice the same day: **git resolves
one end of the change on its own and leaves the other in conflict.** One
fixes what git marked, which is what is visible, and is left inconsistent
with what git already decided silently thirty lines above. Both times it
assembled and ran:

* one branch left the index in `Y` —`tay`— and the other in `comp_and`;
  git kept the `sta comp_and` of one, left the `tyx` of the other in
  conflict, and the code read a register nobody loaded any more;
* two branches added a field to a positional test tuple, so the indices
  shifted; git marked the uses in one area and auto-merged those in
  another, which ended up reading the neighbour's field.

The practical rule: **when a conflict is due to a change of convention, one
has to go and look by hand for the other uses of that convention**, with
grep, instead of trusting that git marked them all. If git marked one, it
probably resolved another one wrong.

So when merging a sub-agent's branch:

* **Run `just test` and ABL's suite on the merged tree**, with the merge's
  tools installed, not on the branches. That each one came green says
  nothing about the merge.
* **Reinstall into the global one only the Rust the branch touched**:
  `just install lz2`, from `~/the-advocate`. A branch that touches
  `rm2k-project` —`project`— changes all the binaries that compile it in,
  and everything is reinstalled. Until 2026-10-02 there were also Python
  scripts, installed as symlinks, and an `install-scripts` recipe to
  rebuild them: they left with the last script.
* **An inherited red is bisected, not inherited.** If a test is red and
  nobody broke it, it appeared somewhere: `git log -S` to know when it was
  born and run it on the parents of the suspicious merge. It costs twenty
  minutes.
* **Look by hand at the signatures both branches touched**: who passes what
  to whom and with how many bits.
* **And prose collides too, not only code.** When merging documentation
  from two branches one has to **read it**, not only resolve the conflicts
  git marked.
* **And the numbers each branch chose on its own.** A new opcode, an index
  in a test tuple, a far RAM address: each agent takes "the next free one"
  looking at its copy, so two branches choose the same one and git sees
  nothing. All three things happened the same day. The opcodes are now
  guarded by the declaration, which does not compile with a repeated
  number, and far RAM by the linker, since it stopped being chosen by hand;
  the rest has to be looked at.

### When a sub-agent gets cut off

**It can be written to, and with that it resumes from its transcript.**
When the cut is due to the session limit —the normal case— it is enough to
send it a message telling it where it was left and what is missing: it
continues with its whole context. Passing it what changed while it was away
—if `main` moved forward, if someone touched the same files, which numbers
are no longer valid— is worth as much as the request.

**Before writing to it, check whether it clashes with what one is doing.**
An agent whose branch is being merged at that moment is not resumed,
because they step on each other; one that was left halfway through
measuring or writing cases, yes.

And in any case, when resuming it is worth looking, in this order, at:

1. **Its branches and its worktrees**: `git log --oneline
   worktree-agent-<id>` here, for its task, and its `<name>-…` branches in
   `~/the-advocate` and `~/the-advocate-ports`, for the code. What is
   committed is whole; the rest does not exist.
2. **The logs it may have left**, before its report: a suite in the
   background may have finished after the cut, so its "left pending" may
   be stale.
3. **Its transcript**, in
   `~/.claude/projects/<project>/<session>/subagents/agent-<id>.jsonl`.
   They are megabytes: it is read **from the end backwards, one entry at a
   time**, looking at which tool it used last. Never whole.
4. **What it left running**: `pgrep -af "pytest|cartuchos"`, and `git
   worktree list` in each repo.

And for the new agent that replaces it: pass it what the previous one left
written —commits and its task— so it does not measure the same thing
again.

## The trap that bit most often

**`plx`, `ply` and `pla` leave N and Z from the value they pull off the
stack**, and `sep`/`rep` do not touch Z. So a `beq` or a `bpl` right after
a `pl*` is not looking at what one thinks: it looks at what came off the
stack.

It has happened four times, and all four looked like anything but what
they were:

* no route ever moved, because slot 0 always gave "blocked" (the `cmp #0`
  in `ev_route_frame`, with its comment);
* the title screen was left without music for a whole day, because the
  question "is this sample in ARAM?" always answered yes;
* `ConditionalBranch` by variable **always took the branch**, with the
  variable at 12 and the condition asking for `>= 99`;
* `IsActorInParty` said all actors are in the party.

The fix is always the same: an explicit `cmp #0` between the `pl*` and the
branch. Since 2026-10-02 Goombario —`snes/goombario/`— looks for it on
every built cartridge, in ABL's `pruebas/herramientas/test_linter.py`: a
conditional branch on a flag left by a `pl*` is red, except those that
look on purpose at what was pulled, which are in ABL's
`excepciones-del-linter.txt`, with their why. A new one of those goes
there, saying what it is that was pulled.

## Git

Commits go straight to `main`, in all four repos, **and are pushed**: since
2026-10-10 the repos only exist in here and on GitHub, so a commit not
pushed is a commit taro does not see. What is **never** done without
asking him is rewriting what is already on GitHub: `push --force`,
`rebase` of what was pushed, deleting a branch over there. Until that day
the push was done by taro, with a key on a YubiKey. Sub-agents do not
push: their work reaches `main` through the merge of the one who launched
them, who is the one who pushes.

Messages explain the why, not the what —the diff already says the what—.
They go in Spanish, except in the book and in this repo, which go in
English (see "The independent projects are in English"). Who wrote it is
said by the `Co-authored-by` trailer (see "Sub-agents").
