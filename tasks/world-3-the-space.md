---
name: "World 3: the space"
description: "Milestone 3 of el-mundo-y-lo-que-sigue: bank packing with first-fit decreasing, the .msu's height table per package, the text block in four-byte steps and `just space`"
type: refactor
status: done
assignee: taro
---

# What

Milestone 3 of `world-and-what-follows.md`, which has what was measured
before (section "Espacio"). It starts from `2ca861a`, with milestones 1 and 2
already in `release`. One commit per thing, each one with its before and after
in the message:

1. **`just space`** (`tools/ensamblado/espacio.py`): it prints, for each
   cartridge or for the path of a ROM built separately, the data banks used
   and free, the gaps, bank 0, bank 1, BSS, ZEROPAGE and the text block. It
   reads the `.dbg` and `memory.cfg`; it does not relink. The texts come from
   two constants the converter emits next to `mensajes` (`MENSAJES_BYTES`,
   `MENSAJES_TOPE`). `test_space.py` compares it with the `.res` linked by
   hand, and AGENTS.md points to the recipe.
2. **Bank packing with first-fit decreasing** (`bancos.resolver`). The
   constraints are the ones the converter already declared: a `.bloque` of up
   to a whole bank in one; one larger (the text block) starting a bank and
   continuing into the following ones; a `.cruza` split only between
   consecutive banks (`spc_block`, `advance`), whole in a gap if it fits and
   otherwise in a chain at the end. No other ordering constraint was found
   (see the commit message: label subtractions, `*`, `#^` of another label).
   The banks are written at the end of `mapdata.inc`.
3. **`se_msu_altura` per package**: (index, height) pairs only for the
   package's sounds, sorted and closed with $FFFF; identical lists shared.
   `altura_msu` walks it. Splitting it across banks was discarded.
4. **The texts in four-byte steps**: `MENSAJES_PASO = 4`, and `msg_empezar`
   takes out the top two bits with `rol` so that the one beyond 128 KB runs
   the same code as the one beyond 64 KB. Step 3, a 24-bit operand and a
   second block with another opcode were measured (see the commit). `push`
   was measured again.

# What was measured

With `just space`, in data banks used (124 fit, from $02 to $7D). "Path" is
`release` plus the world's main path —85 to 95, 99 to 102 and 259; 74 and 255
were already there—, built separately and uncommitted. Before point 4 the path
does not convert because of the texts, so its first two rows were built with
step 4 set by hand only to measure.

    after                 release        test-special   path
    2ca861a               113 (312.9 KB  24 (66.1 KB    does not link: asks 125
                          of gaps)       of gaps)       (339.9 KB of gaps)
    first-fit decreasing  104 (18.0 KB)  22 (0.6 KB)    115
    .msu heights          103            22             114
    texts in 4s           103            22             114

    bank 0 (release)      175 -> 165 B (the new `msg_empezar`)
    bank 0 (path)         136 B
    bank 1 (release)      7,761 -> 7,744 B (`altura_msu`)
    BSS / ZEROPAGE        138 / 4 B, unchanged
    se_msu_altura         release 22,484 -> 1,614 B; path 29,202 -> 1,852 B
    texts (path)          137,822 of 262,144 B

**The main path has 10 banks left.** The optional parts, added one area at a
time on top of the path (67 without the timer digits, because with them it
does not convert —`args.timer_en`, see the plan—; that is not part of this
milestone):

    + Yun Town (67 71 72)            117 banks, 7 left, bank 0 100 B
    + Drust Camp (68 103 199-201)    119, 5 left, bank 0 56 B
    + Tangle Forest (310 to 313)     119, 5 left, bank 0 90 B
    + the three                      125: does not fit by one bank

So after this milestone the path and any one of the three areas fit, or two;
the three together, no. The next thing that gives space is in the plan: the
mirrored poses and the music.

# What to look at (taro)

The ROM moved almost all its data and the text block is read in another way,
so what is worth playing is what no golden covers entirely: **long texts from
the end of Lashe City and from Sorbe** (the ones that fall past the block's
64 KB) and **sound effects with MSU-1**, which now look up their height in a
list. The goldens and the suite pass (`just tests`, 878).

# What `just tests` does not cover

* The beyond-128 KB bit of `msg_empezar`: no cartridge of the suite reaches
  that offset. It runs the same instructions as the 64 KB one, which does get
  executed (with it broken eight goldens go red).
* The numbers of the path and of the optional areas: they are variants that no
  recipe builds.
