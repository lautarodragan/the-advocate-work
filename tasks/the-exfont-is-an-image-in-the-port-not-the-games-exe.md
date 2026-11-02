---
name: "The ExFont is an image in the port, not the game's exe"
description: "`[text] exfont` names a PNG in the port's directory; the tools stop reading `RPG_RT.exe`; each game that has icons today keeps them from a sheet extracted once; without the key, the codes are dropped"
type: feature
status: doing
assignee: Hurón
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
