---
name: "The ExFont is an image in the port, not the game's exe"
description: "`[text] exfont` names a PNG in the port's directory; the tools stop reading `RPG_RT.exe`; each game that has icons today keeps them from a sheet extracted once; without the key, the codes are dropped"
type: feature
status: testing
assignee: taro
agents: [Hurón]
---

taro, on 2026-11-02, in their words, translated:

> Either way, I don't want The Advocate to depend on the .exe the games
> bring, but I'd like to be able to apply a setting to choose the
> ExFont, but keep the ExFont's image in the repo, and have The Advocate
> look it up by file name, with a default if none is specified.

And, on the plan below ("c, with b as the default for now, and a as a
wishlist item"):

> hmm, sounds good, yes.

## What was found before

[`rm2k-s-exfont-icons-in-names-and-texts`](rm2k-s-exfont-icons-in-names-and-texts.md)
draws the icons since 2026-11-02. `rm2k_render::exfont::find` looks in
the game's directory (`GAME_DIR`): the file `[text] exfont` names —an
image or an exe—, else `Font/ExFont.png`, `ExFont.png`, `ExFont.bmp`, and
last the `EXFONT` resource of `RPG_RT.exe`.

Zounds brings two exes. Hornero measured them on 2026-11-02:

* `RPG_RT.exe` (md5 `ff0fb3b0…`) runs the game under Wine, to its title
  screen. Its ExFont is RPG Maker's stock one, the zodiac.
* `RPG_RT_a.exe` (md5 `4ca428fe…`) is a Spanish-translated RM2k3 runtime
  whose ExFont has the icons the descriptions count on —`$N` is "Hp"—.
  It does **not** load Zounds: its code looks for the signatures
  `NFOXLHCTGVN` where the stock one looks for `LcfDataBase`,
  `LcfMapTree` and `LcfMapUnit`, and Zounds' files carry the stock ones
  (also in the 2017 commit). Under Wine it stops on "Event script
  referenced a "shigunichi" that does not exist". taro remembers seeing
  the right icons; it may have been an experiment.

## The plan

1. `[text] exfont = "<file>"` names an **image** —PNG, BMP— **in the
   port's directory** in the-advocate-ports, not in `GAME_DIR`. The tools
   no longer open any `.exe`, and no longer look in `GAME_DIR` for one.
2. **Without the key, there is no ExFont**: the codes are dropped, as
   before 2026-11-02 (`[text] exfont = false` already does that for a
   cartridge without room). The default is not RM2k's stock sheet
   (Enterbrain's) nor EasyRPG's (GPLv3): the-advocate is public.
3. **Every game that draws icons today keeps them**: its exe's sheet,
   extracted once and committed in its port's directory, with the key
   naming it. Zounds' from `RPG_RT_a.exe` (the Hp one). The ports repo is
   private.
4. A free ExFont of our own as the default is a wishlist item, apart.

## Log

### 2026-11-02, Hurón

Starting at the-advocate `ac986e8d`, ports `bda2103`, docs `ac4e70b`, on
`huron-exfont-image` in each.

**The sheets, extracted once** with a throwaway script that mirrors what
`ExFont::from_exe` did at `ac986e8d` —the `EXFONT` bitmap resource, the
BMP file header put back— and writes it as an indexed PNG with the same
indices (checked pixel by pixel against the BMP). What came out:

* the eight `RPG_RT.exe` of the RM2k games —ABL, The Book of Three, Desert
  Nightmare, Dooms2, El Dorado, Frozen World, Sunset over Imdahl, Vampires
  Dawn— carry **the same bytes**, RPG Maker's stock sheet; so does Zounds'
  `RPG_RT.exe`;
* Zounds' `RPG_RT_a.exe` carries the other one, the Hp/Mp one.
* No game has a `Font/ExFont` or `ExFont` sheet of its own, so `find`
  answered each game's `RPG_RT.exe` —Zounds', the one its key named— and
  all nine draw icons today. None sets `exfont = false`.

Each port gets its `exfont.png` next to `advocate.toml`, one copy per port,
and `[text] exfont = "exfont.png"`.

**The tools**: `rm2k_render::exfont` reads a sheet and nothing else
—`find`, `from_exe` and the PE reader are gone, and `bmp_from_bytes` went
back into `read_bmp`—; `[text] exfont` is a path relative to the project
file, the same as a font's sheet (`settings.project.directory()`), and a
missing file stops the conversion. Without the key, or with `false`, no
icons. `rm2k-snes-convert` no longer depends on `rm2k-render`. The sheet
goes into the cartridges' fingerprint, like a font's: the executable never
did, so retouching it left the ROM stale.

The book has no reference page for `advocate.toml` keys —each port's file
and ABL's comments are it—: what changed is in "What ExFont icons do not
model", Zounds' page and the fingerprint list in `internals/pipeline.md`.

**No ROM changed.** The release `.sfc` of the nine games, built with
`just cartridges release` in each game's directory: before, in a clean
ports worktree at `bda2103` with the global tools (installed from
`ac986e8d`); after, in the branch's ports worktree with
`.local-tools` from the branch (`convert cartridge screens battle`), all
nine rebuilt ("release: built", the runtime of the branch's worktree).
The sha256 of each pair is the same: ABL `082139c3…`, The Book of Three
`c9e577c9…`, Desert Nightmare `5d38bf9f…`, Dooms2 `5a7909c1…`, El Dorado
`0af0e975…`, Frozen World `d89ae6db…`, Sunset `97390d16…`, Vampires Dawn
`cc6d7706…`, Zounds `a80046e5…`.

And that the sheet is what carries them: Zounds at `bda2103` with the new
tools and its old key, `exfont = "RPG_RT_a.exe"`, stops —the file is not
in the port's directory—; without the key it builds, and its ROM is
another (`2285310e…`). `rm2k-snes-cartridges --list --json` lists
`zounds/exfont.png` among the fingerprint's files.

Crates' tests: `just crate-test` of `rm2k-render`, `text`, `convert`,
`cartridge`, `screens` and `battle`, green; `just test`, 29 passed.
`cargo fmt --all --check` complains of `rules/src/skill.rs`,
`battle/src/rules.rs`, `events/src/compile.rs` and
`screens/src/debug_screen.rs`, none of them touched here: they come from
`ac986e8d`.

**Suites**, with `.local-tools` first in the PATH: ABL's `just tests`,
1637 passed and 2 skipped; `just boot` at the ports' root, 136 passed
—`test_zounds_exfont.py` among them, its goldens unmoved—. `cargo clippy
-D warnings` over the touched crates complains of three `&*` in
`screens/src/convert.rs` and `mapdata/src/emit.rs`, files this does not
touch; the local toolchain is not CI's pinned one, and the same may go
for the `cargo fmt` complaints above.

Branches `huron-exfont-image`: the-advocate `1e7cce31`, ports `3ca1a4f`,
docs `34a2bb4`; none of the three mains had moved.

**When merging, reinstall** `convert cartridge screens battle`
—`rm2k-render` and `text` are libraries inside them—: `just install
convert cartridge screens battle` in the-advocate. The ports' and the
tools' branches go together: the new tools refuse Zounds' old key, since
the `.exe` is not in the port's directory, and the old tools look for
`exfont.png` in the game's directory and stop.
