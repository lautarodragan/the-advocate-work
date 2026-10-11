---
name: "Pause menu"
description: "B opens the menu, which is RM2k's Scene_Menu"
type: feature
status: done
---

# The pause menu

**B opens the menu**, which is RM2k's `Scene_Menu`: the five commands on the
left —`Use Item`, `Tech Skill`, `Equipment`, `Save`, `End Game`, with the LDB's
terms—, the gold at the bottom and the party on the right, with the face, the
name, the level —that of their `initial_level`, as in the slots—, the status
and the HP. **Three commands do something** —`MENU_HECHAS` in `titulo.py`—:
the items, the equipment and saving. Saving opens the slots screen in save
mode and, whether one chooses or cancels, returns to the menu with the cursor
on Save, as `Scene_Save` returns to `Scene_Menu`. The other two go in the
system's colour 3, the "cannot" one, and A does nothing with them: the skills
are a step that follows, and ending the game asks for returning to the title
without resetting the SPC700.

**The geometry is ours**, not RM2k's: there it is 320x240 with windows, here
256x224 on a black background like the slots screen, without the actor's
title, the experience or the SP, and the gold with one digit per cell and not
at the font's 6 pixels, so that the ROM writes them one at a time without
building tiles. It is cosmetic and declared.

**The current HP are written at run time.** The row's block is drawn by the
converter once, so any number it carried inside would be the one from the day
it was converted: with the HP there the menu always shows the level's maximum
no matter how much a battle lowers them, and the pixel comparison does not see
it because `render_menu` bakes the same number. The three digits are written
by `menu_hp_escribir` from `FAR_HP`, with the same one-cell-per-digit layout as
the gold and for the same reason. The "/maximum" next to it has not been baked
since 2026-09-20 either, but for another reason: it changes from one actor to
another, and everything that changes with the actor is composed with glyphs.
It holds for the two screens that share the panel, the menu and the actor
choice, because both go through `menu_grupo_pintar`.

The digits land aligned with the gold's without touching anything: both lines
are drawn two pixels from the top edge of their cell. And the price of the
8-pixel cells is the same one already paid for the gold. Everything else comes
from `titulo.py`: `render_menu` is the reference and the converter emits **the
same cell blocks**, in the same tile bank and the same palette as the slots
screen —the faces are the same and saving opens from the menu—. The grey
commands carry their own BG2 palette: colour 3 is a gradient and with the
text's they added up to 18 colours, so the faces are left with six palettes.

### What depends on the actor is composed with glyphs

**The name, the level and the maximum HP are not baked**: the ROM writes them
one letter per cell with the glyphs of `ranura_glifo_celdas`, which are the
same two cells per character that the gold and the current HP already used. It
is a budget decision, measured: the tile bank of these two screens is **a
single one and it is deduplicated**, so what is baked per actor is shared with
nobody, and an actor's text was some seven marginal tiles each. With 12 actors
the bank gathered 446 of the 448 that fit in VRAM; with actor 21 inside, 462
—that is why its cases lived in a separate cartridge—; and the whole game's 52
actors with a face, 751. Composing, what is paid once are the letters the names
use and the only thing that still costs per actor is their face: the same 12
actors gather 364 tiles, and 21 fits.

Uploading the text **on demand** instead of composing it was measured and did
not work: a resident face costs 8.4 marginal tiles against 13 for an on-demand
slot, and an actor's loose text is 22 to 39 tiles against the 7 it costs being
inside the deduplicated bank.

What is paid, and it is declared as cosmetic: the composed letters go at an
8-pixel step and not at the font's 6, so the name, the level and the maximum
come out a little wider than if they were baked. It is the same price the gold,
the HP and the items, equipment and shop screens already paid. What does not
depend on the actor —"File 1", "- Empty -", the level term, "Normal", "HP",
the commands— is still baked with the font, and that is why on making the
change only the menu's two goldens moved.

What each strip comes from: `ranura_actor_texto` is a row of 32 ASCII bytes
per actor —the name, the level's two digits and the maximum behind its slash—,
emitted by the converter outside bank 0. `ranura_texto_de` builds the pointer
and `ranura_texto_escribir` writes first the upper cells of all the letters,
which go consecutively in VRAM, and then the lower ones, which is the same
thing `texto_escribir` does on the items screen with its own glyph table.

**The seventh face hangs from a borrowed palette.** The list of faces is not
the party's but that of everyone some `ChangePartyMembers` of the ROM's maps
can bring in, and with the whole of Lashe City there are eight: the four from
the intro plus Arden, Saldra, the Rat Tracks' Gang Member and AG7-17. Each
colour of the leftover face goes to the closest by luma of the palette missing
the fewest colours, which is what `cabe` does with the sprites and for the
same reason: a character with odd colours is a visible error and a map that
does not fit is one map less. It is seen in the converter's report, which
names them.

**When it opens is RM2k's behaviour.** `Game_Player::Update` notes the request
—`menu_calling`— if B is pressed with the menu allowed, without a message and
without a page running; `UpdateNextMovementAction` serves it with the hero
still: with a page running it drops it, with a message it leaves it waiting,
and otherwise it opens the menu before looking at the D-pad. That is, B in the
middle of a step opens the menu on finishing it. In the ROM the request is bit
7 of `FAR_ACCESO`, `pedir_menu` notes it after `move_hero` and `move_hero`
serves it; a teleport drops it, like `MoveTo`. And the B that cancels a choice
is consumed right there: in RM2k the window processes the key after the hero,
and here the choice runs before `pedir_menu`. The same on closing the menu and
the slots screen: the B that closed reaches nobody else.

`ChangeSaveAccess` and `ChangeMainMenuAccess` **are honoured**: they stopped
being among the ignored commands, they compile to `OP_ACCESS` and turn bits 0
and 1 of `FAR_ACCESO` off or on, which travels in the save. Saving forbidden
puts Save in grey; the menu forbidden makes B not ask for it. The save point
does not look at the permission, like `OpenSaveMenu`.

While the menu is shown **the game clock does not run**, same as with the
slots screen, so the menu costs no tick and the map continues from the frame it
was on. It is enforced by `test_menu` and `test_menu_vuelve` of
`pruebas/rpgmaker/test_tanda_pantallas.py`: the menu as it opens, with the
cursor moved, and the map after closing. What compares it against a Python
reference —`titulo.render_menu`, which is still alive— is
`pruebas/rpgmaker/test_menu.py`, and it is also what looks at what the suite
does not reach: the menu with a party and gold set, saving from the menu, both
permissions set by the bytecode, B in the middle of a step, and the permissions
coming back from SRAM.

### The items screen

"Use Item" opens `Scene_Item`: at the top the description of the selected item
and below the inventory list with how many there are of each, in number order
like `Game_Party`. In grey goes what A does not use, like `Window_Item`. Today
A uses **the switch items**, which in the demo are a single one, the Portable
Console: it turns on its switch —710—, spends one if it has uses —`uses` at
zero is infinite—, asks for the page refresh and returns straight to the map,
which is RM2k's `PopUntil(Scene::Map)`. B returns to the menu. The medicines
stay in grey: they ask for HP that change, and on the demo's maps the only way
to lose them is a battle. Switch 710 triggers common event 39,
"NewMenuActivated", which is the game's own menu made with pictures: 568
commands, and common events do not run yet.

**The medicines go in white and open the actor choice**, which is the menu's
party panel with a cursor at the side —`render_objetivo`—. A did nothing
—**solved on 2026-09-21**, see `healing-outside-battle.md`—, and that was a
debt: `UseItem` only spends the medicine if something goes up, and since there
are battles the HP go down, so using it would have something to do. Until
2026-09-12 it did not, because outside battle nobody ever went below the
maximum and the three commands that touch HP or statuses compiled to nothing;
today `FullHeal` and the `ChangeHP` that adds are OP_HEAL and really heal.
Books, materials and specials stay in grey.

**The text goes one letter per cell.** The screen has its own tile bank with
each character of the font in two cells, in white and in grey —307 tiles,
which do not depend on how many items there are—, and the names and the
descriptions go in ASCII in the cartridge; writing a letter is two words of
the tilemap. It goes this way and not with each item's text already drawn, like
the faces, because that grows with the inventory and with a dozen items it no
longer fits in VRAM. The price is that the letters go at 8 pixels and not at
the font's 6, like the gold's digits. In RM2k the list goes in two columns of
144 pixels; here in one, with the quantity on the right, and the description
in two lines of 30 letters. It is cosmetic and declared.

The description is composed in `texto_buf` —the message composer's buffer,
free with the menu open— and is uploaded with one DMA at the start of each
frame: writing it letter by letter on moving the cursor did not fit in the
vblank and the second line came out cut. When the cursor goes out of the
eleven rows, the list is repainted whole with the screen off, which is one
frame of black.

It is enforced by `test_items` and `test_items_vuelve` of
`pruebas/rpgmaker/test_tanda_pantallas.py` —the screen as it is entered, with
the cursor on the console, and the map after using it— and
`pruebas/rpgmaker/test_items_pantalla.py`, which compares it against
`titulo.render_items`: the console turns on 710 and is not spent, an item in
grey does nothing, fourteen items in eleven rows scroll and come back, and the
empty list.

### The equipment, and the text screens

"Equipment" opens the actor choice in choose mode and then `Scene_Equip` of
that one: their name, the four parameters —those of the level, mocked at 1,
plus what the equipped items add—, and the five slots. A on a slot shows the
list of what the actor can wear there, with the parameters that would result;
the empty line at the end is taking off what they have. What is taken off goes
back to the inventory and the new one comes out of there; a two-handed weapon
takes off the shield and a shield takes off the two-handed weapon, which is
`Game_Actor::ChangeEquipment`. In RM2k the list and the slots are seen at the
same time; here the list replaces them while choosing. Cosmetic and declared.

The equipment is state: five words per LDB actor in `FAR_EQUIPO`, which starts
with the database's initial equipment —a DMA of the converter's table on
reset— and travels in the save. It is 610 more bytes, and with them the save
went past the slot's 1024: **the SRAM is 32 KB** and the slots go every 2048.
`ChangeEquipment` did not compile —the game uses it on two maps that are in the
demo today—: **since 2026-09-21 it compiles** the form that removes a slot, see
`equipment-skills-and-game-over.md`.

The equipment screen —and the shop, which follows— are **text screens**: they
carry no drawn blocks but the items screen's font, and they are composed whole
in `texto_buf` —the tilemap of 32 by 28 cells, 1792 bytes— which is uploaded
with one DMA per frame. Composing is in no hurry, and `pantallas.py` is the
reference with the same cell composer. The DMA goes **after** reading the
controller: the other way round, its ten lines made `read_pad` arrive with the
automatic read finished, each iteration lasted two frames and half the presses
were lost. `equipo` caught it.

It is enforced by `test_equipo` and `test_equipo_vuelve` of
`pruebas/rpgmaker/test_tanda_pantallas.py` —Kersh's slots with his initial
equipment, the weapon list with the parameters that would result, and the map
after returning— and `pruebas/rpgmaker/test_equipo.py`: the initial equipment
in RAM, equipping from the menu, the two-handed spear that takes off the
shield, the empty line, and the equipment in the save.
