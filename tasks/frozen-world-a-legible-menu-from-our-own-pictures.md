---
name: "Frozen World: a legible menu, from pictures of our own"
description: "The custom menu is three pictures (one per highlighted row) whose gradient does not survive the console; redraw them flat in three colours, and let a port's patches carry files that replace the game's by name"
type: feature
status: testing
assignee: taro
agents: [Aguará]
---

Asked by taro on 2026-10-19: Frozen World's menu "always has to be seen,
and always has to be seen *well*". The cheapest step first, before the
custom windows: no runtime change.

**What there is**: the menu is three pictures, `Picture/MenuEquipPlates.png`,
`MenuItemManage.png` and `MenuPartyStats.png`, the same window with a
different row highlighted, shown by events. Their vertical blue gradient
and anti-aliased text come out of the colour reduction hard to read.

**What taro asked for**:

* New pictures, drawn from scratch rather than retouched, with the
  originals' colours: the blue of the background —the middle tone,
  vertically— flat; the white of the border and the text, with a black
  shadow 1 px down and right; the border in that same white and black.
  Three colours.
* Width and height multiples of 8.
* Square corners if a rounded one would share an 8 px tile with another
  layer; if the layer the picture goes on gives the rounded corner for
  free, better, but not worth complexity (about 6 px a corner).
* The build prefers a port's own files over the game's: the same folder
  structure as RM2k's, merged, a file of ours replacing the game's of the
  same name. Taro's proposal for where: `frozen-world/patches/manual/`.

The `.zip` of the game is never edited (AGENTS.md).

## Aguará's work (2026-10-19)

Branches `aguara-fw-menu` in the-advocate (from `9592b88b`) and in the
ports (from `c420032`).

**Where the files go**: `patches/manual/files/`, RM2k's own tree
—`files/Picture/MenuEquipPlates.png`—, as Hornero asked: the lowercase
folders of `manual/` are our formats (`forks/`, `new/`, `chipsets/`), and
`files/` is the game's tree, replaced by name. Not `manual/Picture/`
straight: `ChipSet/` next to `chipsets/` would read as the same thing.

**How**: one place, `Environment::unpack` in `rm2k-project`, which already
turns a `.zip` game into a directory. With `files/` it builds one more
directory in the cache, `own-files/<game>-<key>`, links to the game's files
with ours copied on top, and from then on `--game-dir` is that directory for
every tool and every stage: the lookups —three functions in three crates and
a few joined paths, see `game_files` in `rm2k-snes-cartridges`— see our file
without knowing it exists. Named by the game's identity and our files' names
and content. A file of ours replaces the game's with the same folder and name
without extension, ignoring case, which is how RM2k looks them up; one the
game lacks has to be in the RTP. A misspelled name, a folder that is not
RM2k's, a file outside a folder or two of ours with one name are errors. The
directory carries a record, `.rm2k-own-files.json`, so a tool that receives
it already built —the converter, from `cartridges`— keeps it and can say what
changed: `converter.log` prints "The port's own files, in front of the
game's", one line each.

**Not unified with `build/patches-manual/ChipSet/`** (the added ChipSets'
built images): those are built by the converter from the dump's forks, after
`unpack`, and the merged directory is shared by every process and named by
its content, so writing into it would make it mutable. Instead a ChipSet the
project adds may not take a name the game —our files included— or the RTP
already has: it stops the build. ABL's three pass.

**The scaling.** The pictures are shown with the screen, so the converter
scales them from RM2k's 320x240 to 256x224 with Lanczos: 109x64 becomes
88x59, and text one pixel wide does not survive four fifths, flat colours or
not (simulated: blurred letters). So the pictures are drawn at the console's
resolution, 88x56, and a project names them in `[graphics]
console_pictures`: shown unscaled, with the corner the runtime already
computes from the centre and the half size, taking as RM2k size the one that
scales to theirs (88x56 → 110x60, corner (84, 84), the original's (84, 82)).
No runtime change. Both the objects and the big-picture layer honour it.

**The pictures**, drawn by a script, `~/scratch/aguara/fw-menu/draw/menu.py`
(Python with PIL, reading the console's `low-variable.png`): 88x56, the
original's window and text where it has them —rows 15 console pixels apart,
the original's 16 scaled—, flat in its colours: blue (0,0,80) —its
gradient's middle row—, cream white (248,248,216), black, and a lighter blue
bar (48,48,176) under the lit row. The border is the original's: white
outside, black inside, its rounded corner copied pixel by pixel. The events
show them without their transparent colour (`ShowPicture`'s parameter 7 is
0), so the original's window is opaque, corners included: a rounded corner
over the map is not free, and the corners stay black like the original's.
Index 0 is a key colour nothing is drawn with. Layer: the sprites (a small
picture), 18 objects in 320 tiles per map, as before.

Alternatives, composited in the captures: the lit row's text in yellow (a
fifth colour), and an inverted row (cream bar, blue text). The four-colour
bar is the one committed; switching is redrawing with `--variant` and
replacing the three goldens.

**Verified**, with `just install-local .local-tools project cartridge
convert images` in the-advocate's worktree:

* `just test` (29 passed), `just lint`, and the crate tests of `project`
  (7 new, in `tests/own_files.rs`), `images` (2 new), `convert` (1 new) and
  `cartridge`.
* ABL: `just cartridges` and `just tests`, 1581 passed and 2 skipped; and
  its `release` byte for byte equal to the global tools' (sha256
  `0bb7056e…`).
* Frozen World: the `release` with `NO_CACHE=1` and the merged game deleted
  from the cache, byte for byte equal (sha256 `24c66058…`); changing one of
  the pictures makes `release` stale, and restoring it, up to date again.
  `converter.log` lists the three replacements.
* `test_b_draws_the_menu` with three new goldens, one per lit row, cropped
  to the picture's box; red without them. The captures match the source
  pictures pixel for pixel at 15 bits.
* Captures, before and after for each lit row, the original picture and the
  two alternatives, with a contact sheet:
  `/shared/captures/2026-10-19-frozen-world-menu/`. **Not compared under
  Wine**: reaching the menu needs the intro played to the first plate; the
  original's picture is shown as RPG_RT draws it, 1:1.

**What the suite does not cover**: no test changes a picture and checks the
cartridge rebuilds (done by hand, above); the RTP side of `files/` (a file
the game lacks) and the case-insensitive replacement are covered by the
crate's tests on invented trees, not by a game; the big-picture layer with
`console_pictures` has a unit test but no game shows such a picture there; the 22 maps where the
menu is still blind are a draft of their own.

**When merging**: the branch touches `rm2k-project`, so every binary that
compiles it in is reinstalled —`just install`, all of it—; besides,
`convert`, `cartridge` and `images` changed on their own. What taro looks
at: the B menu on the beach (map 11) with each row lit, and which highlight
to keep —the captures in `/shared/captures/2026-10-19-frozen-world-menu/`—.

**For `manual-patches-one-folder-per-kind-of-asset`**, decided while this
ran: `files/` moves to `manual/<RM2k folder>/` then. The merge here is not in
`search_dirs` but in `Environment::unpack`, so every stage —and Ditto, and
a game's tests through `rm2k-snes-project --unpacked`— sees the port's
files without taking them from a list; what that task says about a stage
that reads `GAME_DIR` on its own skipping the patches does not happen with
it. The collision check between an added ChipSet's recipe and a file lying
there by hand is already in `chipsets.rs`.
