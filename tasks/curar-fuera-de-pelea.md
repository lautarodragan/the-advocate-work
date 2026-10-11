---
name: "Healing outside battle"
description: "Medicines from the menu, and the selection that broke"
status: done
---

**Using a healing item from the menu, outside battle.**

taro's report from 2026-09-21: the `Cold Sandwich-HP` (medicine, restores 30 HP)
heals in battle and not outside it. And after trying it, if one goes back to the
previous screen and enters the character selection again without closing the
menu, the graphics break; closing and opening the menu fixes it.

Probably on the same side: the `Pungent Elixir-LIFE` (`ko_only`) could not be
used on Arden at 0 HP, neither outside nor inside battle. The suspicion,
unverified, is that reaching 0 HP doesn't set the knocked-out state, and the
item looks for the state.

Done is: both items do outside battle what they do in RM2k, the character
selection is drawn correctly on coming back, and there are tests that check it.

## Where it stood, 2026-09-21

The "done is" part is there, with cases that run the ROM in
`pruebas/rpgmaker/test_curar_menu.py`. The causes:

- **The sandwich**: the actor choice did nothing with A on a medicine, on
  purpose, since before HP were state. Now it's `medicina_usar`, which is
  `Game_Party::UseItem` in full.
- **The elixir**, the same. The suspicion about the knocked-out state was
  discarded: easyrpg's `IsDead` looks at HP, so a knocked-out actor is an actor
  at zero HP and no state needs to be stored. The saved game didn't change.
- **The graphics**: `ranura_rect_subir` read the row width in 16 bits and
  `menu_grupo_pintar` wrote it in 8. It broke with a greyed-out item at the end
  of the list.

What was left out:

- **The elixir in battle**: battle doesn't offer `ko_only` items
  (`batalla.item_usable_en_batalla`), so there taro still can't use it. Doing
  it needs the item's target cursor to be able to stop on a knocked-out ally,
  the revived one to ask for orders again the next turn and collect the
  experience on winning, and moving `batalla.py` the same way, which is what
  `test_batalla.py` predicts HP against. It's battle's, not the menu's.
- **The left column of the choice**, which in RM2k shows the item and how
  many are left: it's still empty, as declared in `titulo.py`.
- **Uses of a multi-use item**: one is spent per use, as with the switch ones.
  This game's medicines are all single-use.
