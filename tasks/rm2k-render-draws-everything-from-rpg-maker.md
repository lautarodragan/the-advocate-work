---
name: "rm2k-render draws everything from RPG Maker"
description: "Move into rm2k-render what the converter draws in Python today: CharSets, battle animations, enemies and backgrounds, FaceSets, System and the ShowPicture sign"
type: refactor
status: done
assignee: taro
---

Decided with taro on 2026-09-29 (see
`workflow/decisiones/las-herramientas-se-separan-de-abl.md`): `rm2k-render`
owns drawing RPG Maker graphics, without knowing about the SNES.

Today the converter's Python draws:

- the CharSets —poses, baked translucent ones, the ones made from a tile—:
  `tools/port/sprites.py` and `render_map.Charsets`;
- the battle animations: `battle_animations.py` and `animation.py`;
- the battle backgrounds and the enemies: `battle_scenes.py` and `scene.py`;
- the FaceSets (`menus.py`), the System (`window.py`) and the
  `ShowPicture` sign (`picture.py`);
- the base of it all: `render_map.load_image`, which already has its
  counterpart in `picture.rs`.

It goes in parts, one subcommand per asset type, each with the ROMs byte
for byte identical, same as the map layers. Anything that is deciding
colors or cutting into 8x8 stays on Adeleine's and `voodoo`'s side.

## Done, on 2026-09-30

In three parts, each with the ROMs byte for byte identical and everything
it draws compared pixel by pixel against the Python:

- the CharSets: `rm2k-render-draws-the-charsets.md` (Yaguarundí);
- the battle —animations, enemies, backgrounds—: `rm2k-render-draws-the-battle.md`
  (Coatí);
- the screens —faces, System, `ShowPicture` sign—:
  `rm2k-render-draws-the-screens.md` (Hurra).

`load_image` is gone. What the port does with those images for the console
—shrinking, cutting into 8x8, the dithering, the baking, the colors— stays
in the converter and in Adeleine.
