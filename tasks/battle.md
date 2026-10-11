---
name: "The battle"
description: "EnemyEncounter opens a turn-based battle"
type: feature
status: done
---

### The turn-based battle

`EnemyEncounter` opens a battle. The scope chosen was the mechanics —turns,
damage, HP, victory condition— before the drawing, so the screen is
text over black, the same 32 by 28 cell grid as the equipment and the shop,
and the background with the battlers came later (see below).

What is RM2k's are the words —all from the LDB— and **all the arithmetic**,
which comes from easyrpg-player and is written twice: in `main.s` and in
`tools/port/batalla.py`. That the two give the same is what lets
`pruebas/rpgmaker/test_batalla.py` predict **the exact number** each HP is going to have
after each turn, instead of settling for "it went down".

    damage          max(0, atk / 2 - def / 4), times 3 if critical, variance
                    of 4 —`adj = max(1, 4 * dmg / 10)`— and half for whoever
                    defends                         algo.cpp
    hit             90 the actor, 70 or 90 the enemy, adjusted by agility:
                    100 - (100 - hit) * (agiF + agiB) / (2 * agiF)
    turn order      agi + rand(0, agi / 4 + 3), highest to lowest and stable
    escape          clamp(150 - round(100 * agiE / agiG), 0, 100), and
                    goes up ten every time it fails

Three rolls per hit and **in this order**: hit, critical and variance, with
the critical roll made even if the probability is zero, which is what
`Normal::vExecute` does. Changing that order on one side throws off the other's randomness and it does not
show until a hit lands differently.

The randomness is the usual xorshift —that of `ControlVars`— but with **its own
seed**: fighting does not advance the map's randomness, which is what the pixel
reference assumes when it says a battle costs no tick.

`OP_BATTLE` carries the troop and **the three destinations**: victory, escape and
defeat, absolute within the page and patched when closing the block, just
like the options of a `ShowChoice`. The handler the page does not have
points to the end, which is what RM2k does with a sub-index without a branch. Like the
shop and like saving, the screen blocks inside the interpreter and `vueltas`
does not advance: both sides leave the opcode on the same tick however long
the player takes.

#### The battle without handlers, and the Game Over

There is a form of `EnemyEncounter` that carries no handler block: RM2k does not
emit it when `defeat_mode` is 0, because then losing is not a branch of the
page but `Scene_Gameover`. It is **24 commands in 15 triggerable pages** of the
game, three of them `EV0006` of map 26, that is, the boss of the Rat Tracks.
Compiling them was two pieces of work that only help together —the Game Over and the block
that does not close without `EndBattle`—: either one alone unblocks **+0**, and the
two, **+15**.

The compiler looks ahead, as with the options of a `ShowChoice`: if
the `EnemyEncounter` is not followed by a handler, it emits the `OP_BATTLE` right away,
with victory and escape at the command below and defeat at `BATALLA_PERDER`.

**`BATALLA_PERDER` is $FFFF**, that is, an impossible destination —all three are
absolute inside the page and none in the game reaches 64 KB—, so the
Game Over costs neither a new opcode nor one more byte in the other battles. The ROM
checks it in `op_battle` with an `iny`/`bne`, which is the cheap `cmp #$FFFF`, and
answers with `jml reset`: **Game Over is going back to startup**, that is, to the
title screen if the cartridge carries it, with the saved game waiting in
SRAM. It is what `Scene_Gameover` does at the end, minus the image and minus the
theme; both are declared in `assets/LIMITACIONES.md`.

That path **the pixel suite cannot see**: a defeat resets the
console, so there is no frame to compare against a golden.
It is enforced by `pruebas/rpgmaker/test_game_over.py`, which puts the whole party at zero HP —with
nobody standing `batalla_correr` answers defeat without opening the screen— and requires
the ROM to reset, with control of the same battle pointing to the page.

**And the random encounter loses through the same path.** A battle that starts
from the steps' randomness has no bytecode behind it —it is opened by `pelea_arrancar` from
`move_hero`— so there is no destination to resolve nor handlers to emit:
losing it is always `Scene_Gameover`, and the caller compares with `BA_DERROTA` and
does the same `jml reset`. Without that the defeat returns control to the map and, since
`modo_fin` stores the battle's HP in `FAR_HP`, the party stays at zero **forever**
and every following battle is lost on its own before opening. It is enforced by two
more cases of `test_game_over.py`, with map 21 and `--encuentros-de-prueba`.

And a declared approximation: the 24 battles of this form carry `escape_mode` 0,
that is, escaping forbidden, and the ROM lets you escape anyway because the permission does not travel in the
opcode. Escaping leaves through the same destination as winning.

**The battle's code does not live in bank 0.** It is some three kilobytes and
three hundred bytes were left there, so it lives in RODATA and is entered with `jsl`. From
there you cannot return with `jsr` —it does not change the program bank— so the
bank 0 routines it needs are called through seven-byte bridges that
also **restore the data bank**: inside the battle it is $7E, so as to be able to
use absolute addressing on its state, and in bank 0 it has to be
0 or `eq_parametro` would read its tables from WRAM.

**HP became state.** Until that day nobody went below the maximums and
`ChangeHP` compiled to nothing; now they live in `FAR_HP`, start full on
reset like `Game_Actor::Setup` and **travel in the save**, after the equipment.

What there is, and what there is not:

    attack, with a choosable target yes
    defend                          yes, and it counts only on its own turn
    escape                          yes, but it is each actor's order and not the
                                    party's, which is a declared simplification
    use an item                     yes: see below
    skills                          yes: see below
    statuses                        no
    experience and levelling up     yes, since 2026-09-21: see
                                    `experiencia-y-subida-de-nivel.md`
    gold on winning                 no
    music and sound effects         yes: see below
    drawn battlers                  yes; since 2026-09-21 composed on the
                                    console: `escena-de-pelea-compuesta-en-runtime.md`
    the background image            yes
    troop event pages               yes, since 2026-09-21, the switch and
                                    variable ones: `el-sistema-de-batalla-de-talan.md`
    random encounters               yes: see below

The screen shows the enemies' HP, which RM2k does not. It is on purpose:
what this round has to let you see is the mechanics, and without that a hit that
lands and one that misses look the same.

**Of the game's 51 battles, the only one the player reaches today is the
droid's on map 2.** The Lazer Teeth one on map 9 —troop 86, four
enemies— does not compile, and not because of the battle: it is cut by a `MoveEvent` with
route order 9, "towards the hero", which the ROM does not walk. That is why the troop of
four is exercised by `test_batalla` with the test page, which is the same
resource the slots screen cases use.

#### The menu: ABL's five orders

They are the original's five, on the message's two rows: three above and two
below, which is free while choosing. The words are the LDB's, and the width
is ten because that is what the longest order measures.

**The order is the original's**: Attack, the skill, Defend, Use Item. It is seen
in `pruebas-manuales/capturas-batalla/auto_20260912_123013.png`, where
Manta's menu says Attack / Slicing / Defend / Use Item. `Escape` is not there —escaping
is a party order, from an earlier menu— and here it goes fifth, which is the
declared simplification.

**And the second order does not say "Tech Skill"**: it says the `skill_name` of the actor
giving the order —"AgentTrain" with Kersh, "Telepathy" with Core, "Slicing" with
Manta, "Special" with Talan—, which is `Game_Actor::GetSkillName` with
`rename_skill` set. Its text comes from `actor_hab_txt`, which is by actor
number, and not from `ba_orden_txt`, which is fixed like that of the other four. The
column it goes in has to leave it **ten free cells**: "AgentTrain" and
"Tech Skill" measure exactly ten and leave no room for the next one's cursor, which
goes one cell before the text.

**Both tables are two bytes, and that is not decorative.** A text index
names a row of the block shared by the items, equipment,
shop and battle screens, and that block grows with the cartridge: with the 57 items of
`abl` the battle's texts start at 273, which does not fit in one
byte. The case that guards it is `batalla-textos-lejos`, and `ca65` **rejects** a
`.byte` that does not fit in a byte instead of truncating it.

`Use Item` works. It opens the list of what can be used **where the enemies'
list goes**, because when choosing what to use what needs to be seen is the party; you
choose the item, then whom, and with that the order of that actor is noted,
which runs on its turn like any other. B goes back one step.

What goes into the list and how much it heals comes from easyrpg-player:

* **What goes in**: `Game_Party::IsItemUsable` with the battle open, that is, a
  medicine not marked "only outside battle". Of those, this port
  offers the ones that **recover HP and are not `ko_only`**: the SP ones are left out
  because the list still only knows how to heal HP —SP **is** state, so
  that went from impossible to debt—, and the reviving ones because reviving is removing the
  dead status and statuses do not exist. (That last part was not true: EasyRPG
  decides whether someone is down by HP, and that is how it was solved in the menu; in the
  battle it is still pending in `el-elixir-en-la-pelea.md`.) It is 12 of the game's 22
  medicines, from the Potion of 50 to the Miracle Drop, which heals everything.
* **How much it heals**: `Game_BattleAlgorithm::Item::vExecute`, that is
  `recover_hp_rate * GetMaxHp() / 100 + recover_hp`, capped against what the
  target is missing, which is the `ChangeHp`. The arithmetic is written twice
  —`main.s` and `batalla.curacion`— like everything else in the battle, and that is why
  `test_batalla.py` can require the exact number. The product fits in a
  word: the converter stops if any actor goes over 655 HP.

Two things that are RM2k's and are better not "fixed": **the item is spent when
choosing it** and not when using it —otherwise, the last one of an item could be shared between
two actors on the same turn— and **a dead target is not re-targeted**, which is the
opposite of what an attack does: the item is spent anyway.

Five cases enforce it. Two from the suite —the item list and the choice of
target, pixel by pixel against `pantallas.py`— and three of state: that the list
is the right one (with an unusable item in the inventory, or it would measure
nothing), that the potion leaves the exact HP the model says capping against the
maximum, and that the menu goes through the five orders in the original's order.
All verified red with their defect in place.

#### The skills

What unblocks them is not the screen but reading the LDB's `initial_level` instead
of mocking the level at 1. With the real levels —Kersh 20, Core and Manta 15—
the three know theirs from the first battle: seven among the three, 131 and 146
Kersh, 129 and 150 Core, and 130, 143, 144 and 150 Manta.

**What each one knows**: `Game_Actor::LearnLevelSkills` goes through the actor's
learning table and learns those of a level lower than or equal to theirs, and
`LearnSkill` puts them in `data.skills` **sorted by number**. That is the order
in which the list shows them, and the original's capture confirms it: Manta's four
come out Mental Hack and MindShield above, MindProbe and MindBlast below, that
is 130, 143, 144, 150 read **by rows** in two columns.

**SP is state**, for the same reason as HP since there are battles: each
skill costs its `sp_cost` and `Skill::vStart` deducts it from the user.
They live in `FAR_SP`, start full from `actor_spmax` and travel in the save,
after the HP.

**The screen** is that of the capture `auto_20260912_123023.png`: where the
enemies' list goes, the description of the one the cursor marks at the very top and
below two columns with the name on the left and the SP cost on the right,
with a dash in front. In grey the one that cannot be paid for, and the whole list
in grey while the target is being chosen, which is what the items one already did.

**What each one does**, from `Game_BattleAlgorithm::Skill::vExecute`:

* one of type `switch` turns on its `switch_id` and **ends there**, without rolling
  any die. Three of the seven are of that kind —MindShield, MindProbe and
  MindBlast— and in the original game they are the ones that open a plot branch later
  on: here they turn on the switch and the event that looks at it is missing.
* the rest compute `Algo::CalcSkillEffect`:
  `power + physical_rate * atk / 20 + magical_rate * spi / 40`, minus
  `physical_rate * def / 40 + magical_rate * spi / 80` of the target when it targets
  enemies, and then the variance with the skill's `variance`.
* and they apply it to what the skill marks: HP —Fury Punch and Healing Syringe—
  or **the target's parameter modifiers** —Agency Badge lowers attack,
  defence and agility; Mental Hack, defence and spirit—.

The modifiers are the only thing that asked for new state per combatant, and it is not
the modifier alone: `CanChangeAtkModifier` caps the drop at half of the
**base** parameter, so the base and the modifier are needed separately
—a modifier that survived the clipping cannot be recovered from the subtraction—. That is why
`BA_BYTES` went from 18 to 40, with the four bases, the four modifiers and
the SP; the effective value the arithmetic reads is `clamp(base + mod, 1, 999)`, which is
`AdjustParam` of game_battler.cpp.

**The order in which it consumes randomness is the contract with `batalla.py`**, and it comes from
reading `vExecute` top to bottom: the switch returns before any roll; the
critical is **always** rolled, even if the chance is zero —and for an LDB skill
it always is, because `CalcCriticalHitChance` receives
`easyrpg_critical_hit_chance`, which defaults to 0 and not -1—; then the
variance; and then a roll against the hit for each thing the skill
affects, in the order HP, SP, attack, defence, spirit, agility.

What is **not** there, declared in `batalla.habilidad_usable`: the scopes of
many —`enemies`, `party`, `self`—, which would require repeating the effect on each
target and with that the order of the randomness on both sides. In the intro's party there are
none; in a cartridge with more actors `Gamble for Credits` comes up, Arden's
only one, and Arden appears without skills. Nor is there a battle animation when
using them: the `animation_id` travels in the LDB and the port already knows how to draw
animations, but nobody connected them.

**And the SP are not seen on the battle screen.** The party's rows are
name, HP and maximum, and in the 32 cells "SP nnn" does not fit as well without shrinking the
name column, which they share with the enemies —"GangMember LT" measures
thirteen—. The original shows them. Today the only thing that warns that someone ran out of
SP is that the skill turns grey.

Ten cases enforce it. Three from the suite —the list, the list with the cursor on
another skill and the list in grey while choosing whom to heal, pixel by
pixel against `pantallas.py`— and seven of state, which compare against
`batalla.Batalla.usar_habilidad` requiring the exact number: HP and SP
turn by turn with Fury Punch, the switch MindShield turns on —and that the randomness
did **not** move—, Healing Syringe's healing on a hurt ally,
the three parameters Agency Badge lowers on the droid, that each
actor's list is the one the LDB says, that the menu goes through the five orders, and that an
actor without any —Talan, who is level 1— does not open the list.

#### The background and the monsters: a single image

The background and the battlers go together **because they are the same drawing**: the converter
composes the battle background with the troop's battlers
on top and the cartridge carries the result as an 8bpp layer of
256x128, the seven rows of text above. The console does not draw
battlers: it uploads an image. The long why, the budget and what is lost
are in `tools/port/escena.py`; the headline:

* **The background comes from the `EnemyEncounter` itself**, which carries the name in its
  string: `SJBackdropABL04` for the droid on map 2 and `ABLBackdropSJ03` for
  the Lazer Teeth on 9.
* **Everything at 80%.** RM2k's background measures 320x160 on a 320x240 screen and
  here the screen is 256x224, so it fits scaled to 256x128. The
  battlers go at the same 80%, so the LDB's positions —which are
  the centre of each one— are mapped by multiplying by the same. The only thing that
  is not RM2k's is the clipping: a tall battler is capped inside the scene,
  because there it has another eighty pixels of screen below and here it does not.
* **512 tiles, 32,768 B of VRAM and 96 colours**, entries 32 to 127 of
  CGRAM: 0 to 31 are the text's two palettes and from 128 upwards are
  the objects'. The tiles are not deduplicated —a photo does not repeat: 490 and 503 of
  512 in the game's two backgrounds— and that is why the number is fixed.
* **It fits without fighting anything** because the battle runs over half the
  map's VRAM and what it takes is rebuilt on leaving. The text lives at $2000, its
  tilemap at $3C00, the scene's at $3800 and the scene's tiles at
  $4000, which are the last 16,384 words of VRAM.

  **Rebuilding it is not `volver_al_mapa`.** That one restores what the shop, the
  menu and the slots overwrite, which write nothing but `RANURA_VRAM` and `RANURA_MAP`
  —chosen to fall inside BG1's tile bank in the four allocations,
  and the converter checks it—. The scene's 32 KB go outside that box: they
  also take the map's tilemap ($5800), the upper layer's ($7800),
  the message window's tiles ($6800) and the sprite bank. Returning from
  a battle is `volver_de_batalla`, which restores that with `load_sprite`,
  `load_ventana` and `fill_window` before calling the other. It is enforced by
  `vuelta-ventana`; without the fix, 77% of the pixels.

Two non-obvious things about the PPU —the text's priority bit and tile
512 with which what is left below is covered— are noted above `escena_subir`
in `main.s`, which is where they bite.

**What it cost, declared** —solved on 2026-09-21: the scene is composed on
the console and the dead one disappears, see `escena-de-pelea-compuesta-en-runtime.md`—:
a dead enemy was still visible. In RM2k it disappears; here what says it died is its row —the name in grey and the
HP at zero—, which is the same reason why this screen shows the
enemies' HP and RM2k does not. And a scene is **per troop** and not per background: two
troops with the same background carry both scenes, at 32 KB each.

It is enforced by the suite, with the game's two backgrounds: `batalla` with troop
86 —four identical battlers, one of them capped against the edge— and with 82
—a single one—, both at zero. Verified that it goes red by shifting the ROM's
`BG1VOFS` by one scanline.

And there is a third case that does not look at the drawing but at **the index**: the same troop
86 in a cartridge that also carries map 2, that is, with two troops and two
scenes. It is the only one where the battle is not troop 0, and for it to exist one
line had to be moved: the test page's troop is requested **at the end** and not
before compiling the maps, just as `temas_de_la_rom` adds the map's theme
at the end. Requested earlier it always got index 0 and `escena_de` and
`tropa_id` were right without indexing anything. Verified that it goes red —53% of the
pixels— with `escena_subir` pinned to scene 0.

#### The random encounters

**The data is not in the `.lmu`, it is in the tree.** `RPG_RT.lmt` stores per
node —map or area— three fields this port did not read: `encounters`, the list of
troops; `encounter_steps`, every how many steps; and `area_rect`. An **area** is a
type 2 node: it has no `.lmu`, it hangs from a map and covers a rectangle of it —it is
not an editor folder, which is what it looks like—.

Measured over the whole game:

    23 areas, hanging from 20 maps
    33 maps with their own troops, none of them with an area
    53 maps where an encounter can come out, of 328
    5 of the 29 of `abl`: 20, 21, 26, 28 and 32
    129 distinct troops

**How it triggers**, from `Game_Player::UpdateEncounterSteps`. Each step of the
hero **with the pad** adds the terrain's `encounter_rate` to an accumulator; the
quotient between the accumulator and `encounter_steps` chooses a row of a table of
eight, and the row gives a multiplier `pmod` that goes from 1/16 to 16. The step's
chance is `pmod / encounter_steps`, and the row **never goes down** until an
encounter comes out: that is why in the first fifty steps of a map almost nothing happens and
then things speed up.

The steps of a **forced route do not count**: there `UpdateNextMovementAction`
returns before `IncSteps` if the route is in command. And every teleport clears the
accumulator, because `Game_Player::MoveTo` calls `SetTotalEncounterRate(0)`.

When it comes out, it stays **pending** and is collected on the next frame, with the
hero already stopped and with no page or message: there `PrepareEncounter` gathers the
map's troops plus those of each area that covers the cell and chooses one at random. If
none covers it —the hero is outside the rectangle— nothing happens.

**Two simplifications, both measured and both enforced by
`pruebas/herramientas/test_encuentros.py`:**

* **the terrain changes nothing.** The eleven tags stepped on in the 53 maps with
  encounters have `encounter_rate` 100, so the accumulator goes up by 100 and
  the formula's `rate / 100` factor is 1. Reading the terrain cell by cell
  would be one more layer of data per map to always multiply by one;
* **no troop filters by terrain.** All 129 have an empty `terrain_set`,
  and in RM2k empty means "on all".

If either of the two stopped being true, the model would become a lie
**without any pixel moving**. That is why a data test enforces it and not the
suite.

**All the arithmetic is integer**, which is what the console can do. The
converter precomputes two things per map: `1 / encounter_steps` in 1/65536
—`enc_base`— and at which step each row is crossed —`enc_umbral_n`—, which comes from
rewriting `acumulado / pasos >= fila` as `n >= ceil(fila * pasos / 100)`.
With that the console never divides: the chance is a word shift
and the comparison is against an xorshift. `test_encuentros.py` checks both
rewrites against the arithmetic over there, for all of the game's `encounter_steps`.

**The randomness is the usual one but with its own seed** —`ENC_SEMILLA`—, like the
battle with `BATALLA_SEMILLA`: walking does not advance the map's randomness, so a
random `ControlVars` gives the same with encounters and without them, and
`eventos.Encuentros` can still predict both. One number is consumed per
step and one more to choose the troop, and that is the contract with that class.

**Where each thing lives.** The state is nine bytes in far RAM,
`FAR_ENCUENTRO` at `$7E3900`: they did not fit in bank 0 —the BSS is full, and
measuring how much is missing is putting a `.res N` in it and reading by how much it overflows, which `ld65`
says—. The tables and the three routines live **outside bank 0**, in `FAR`, and
on that side only four `jsl` and the bridge to the battle remain, 43
bytes. Not even those fit, so `item_switch` went down to RODATA —124 bytes, the
biggest table among those read with X and not in a per-frame loop—. And
the battle is started with `pelea_arrancar`, which is the body of `op_battle`
taken out into a separate routine: a random encounter fights **without bytecode**, so
it has no cursor to save nor handlers to jump to.

**What it costs, declared:**

* **the battle background.** An `EnemyEncounter` carries the name of its own in
  the command's string; a random encounter carries none —in RM2k it comes from the
  terrain— so it fights over the flat colour, like any battle without a
  background. That is 32 KB of cartridge per troop saved, and with 129 troops
  that is not a detail.
* **losing leads nowhere.** In RM2k a lost encounter is Game
  Over, and this port does not have that screen: the battle returns to the map. It is the same
  debt `EnemyEncounter` already had with `defeat_mode` 0.
* **the accumulator does not travel in the save.** On loading it starts at zero, as on
  entering a map. In RM2k it is saved.
* **`ChangeEncounterSteps` still does not compile.** It is 19 appearances in nine
  maps —thirteen of them turning encounters off— and none of those maps is
  near the first ten minutes. What holds it back is not the arithmetic, which
  is now there. What held it back was the test cartridge of map 66, which
  went on 2026-09-17; see the comment of `ChangeEncounterSteps`, above
  `ACEPTADOS_SIN_HACER` in eventos.py.

**It is enforced by `encuentro`**, the suite's case: map 21 —Rat Tracks B1—
walking upwards, with
`--encuentros-de-prueba 8` so the encounter comes out on step 8 and not on
130. It compares two frames: the map one step before, and the battle screen
against `pantallas.py --batalla`, with the troop the reference says. Both
at zero. Verified red in three ways: with the encounters turned off only
on the ROM's side it is 100% of the pixels; against another troop of the same
area, 338; and the frame before is the one that does not let it come out too early.

#### The battle's music and sound effects

Everything comes from the LDB —`system.json`— and **who sounds at what moment comes from
easyrpg-player**, not from memory: it is written with its function of
origin in `eventos.AUDIO_BATALLA`.

    battle_music      T_VGFighterMAX_Masako   `Scene_Battle`, when constructed
    battle_end_music  T_VGFighterMAX_Masako   `BGM_Victory`, on winning
    dodge_se          Evasion1                `AlgorithmBase::GetFailureSe`
    enemy_attack_se   Attack2                 `Normal::GetStartSe`, enemy source
    enemy_damaged_se  Damage1                 the hit's message, enemy target
    actor_damaged_se  Bite                    same, party target
    enemy_death_se    Monster1                `ProcessBattleActionDeath`
    escape_se         Escape                  when the party escapes

`battle_se` —the one for starting the battle— is `(OFF)` in this game, so it is not
registered: it would be a mute entry forever.

Three non-obvious things:

* **The battle theme and the victory theme are the same**, and that is why winning does not
  change theme but restarts it. That they are two constants and not one is
  because the data belongs to the game: another LDB could have two.
* **A hit plays two sound effects and here there is a single voice.** RM2k plays the
  attack's when the action starts and the damage's in the message, with a wait in
  between. Here the second stays pending in `BA_SE2` and comes out twenty-four
  frames later; together they would be a single one, because a new sound effect steals
  the previous one's voice. When the one hitting is from the party there is no first —RM2k does not
  give the actor an attack sound effect— and the damage one comes out right away.
* **The battle has its own audio package**, and that is measured: the battle
  theme is 18 samples and 51,480 B of ARAM's 64,512. Putting it into the
  package of map 2, the 24 sound effects of that map —49,068 B, which today all
  fit— would drop almost entirely. With a separate package the map pays nothing
  while there is no fighting: `op_battle` loads `BA_PAQUETE` on entering and the map's
  on leaving. It costs **65 measured frames** of frozen picture on returning,
  and as many on entering; it is the same price every map change pays, with
  the difference that there a fade hides it.

What enforces it is `pruebas/rpgmaker/test_batalla.py`, and **not the pixel suite**: the
silence does not change a pixel, which is the same argument as
`test_musica_paquete.py`. It is four cases —the theme on entering with its samples
in ARAM, the victory one, the map's on returning, and which of the five sound effects
comes out on each hit— and all four are verified red with their defect
in place.
