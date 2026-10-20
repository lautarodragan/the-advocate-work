---
name: "An inventory of the pictures that may be windows"
description: "A tool that lists every ShowPicture of a game with its context and a tentative class —a menu with a cursor, a message frame, a HUD, a scene—, so that an agent sorts the doubtful ones and taro picks which to turn into windows"
type: feature
status: todo
---

taro, on 2026-10-20:

> tal vez podemos detectar qué cosas podrían reemplazarse por el sistema
> de ventanas, no? El de la consola salió mucho mejor de lo que esperaba,
> y luego empezaron a aparecer patrones que podemos detectar bastante
> bien — el problema original es ShowPicture, así que creo que podríamos
> analizar estáticamente los ShowPicture e intentar inferir cuáles son
> ventanas custom.
>
> Deberíamos poder
> - tener un binario (o funcionalidad de uno existente) que analice y
>   liste los ShowPicture, junto a algo de contexto relevante
> - alimentarle esa lista a un agente para que decida los casos que no
>   son obvios, pero sin tener que partir de cero
>
> Eso solo nos daría la lista, pero no implementaría nada.
>
> Aún no me animo a asumir que podemos inventar una solución general que
> cubra muchos casos, pero podríamos inferir un patrón de los sistemas
> que hayamos convertido (cuando los tengamos) y ver si podemos dejar una
> combinación de scripts tradicionales y recetas para IA.

And, the same day, on when:

> no lanzaría nada por ahora — solo crearía la tarea. Por ahora prefiero
> seguir a mano con los casos que ya conocemos, y luego invertir en esto.

So it waits in `todo` until the known cases are converted by hand.

**The plan** (Hornero, agreed with taro the same day):

1. **This task**: the inventory. For each `ShowPicture`, in maps and
   common events: where (map or common event, event, page, its trigger),
   the picture (name, size, whether it covers the screen, position,
   transparency), the pictures shown with it in the same block, and its
   surroundings in the code —a `Key Input Processing` loop with branches
   per key, a `MovePicture`/`ShowPicture` of a cursor in fixed steps, the
   variable that holds the cursor, a `ShowMessage` or `ShowChoice` next
   to it, where it is erased—. And a tentative class: a menu with a
   cursor, a message frame, a HUD, a scene, unknown. JSON for agents and
   a table to read. It knows nothing about the console, so it belongs in
   `rm2k/`, preferably as a subcommand of a tool that already walks the
   event commands rather than a new binary.
2. Run it over the nine games; an agent sorts the doubtful ones and
   leaves one report per game with the candidates, ranked first by
   whether the console loses the picture today (`degradations.json`,
   `pictures-not-drawn`) —that join is the recipe's, not the tool's—.
3. taro picks which to convert —the target is
   [`show-window-a-window-command-of-our-own`](show-window-a-window-command-of-our-own.md)—,
   and with two or three converted besides ABL's console, we see what of
   the pattern can be automated.

**Done** for this task: the tool, with tests over small fixtures and
over the two known menus —ABL's portable console and The Book of
Three's three-option menu both come out as a menu with a cursor—, its
output for the nine games in `/shared/captures/`, and step 2's reports.
Nothing is implemented in the console.
