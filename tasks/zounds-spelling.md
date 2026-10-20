---
name: "Zounds: the spelling of its Spanish text"
description: "The game's messages, choices and names carry many spelling mistakes —\"save\" for \"sabe\", missing h's, \"uy\"/\"ay\" written wrong—; fixed in the game's own data"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

taro, on 2026-10-20: "podrías arreglar los infinitos errores de
ortografía del Zounds? Tiene cosas básicas como 'save' en vez de 'sabe',
creo que falta alguna que otra 'h', expresiones como 'uy' o 'ay' mal
escritas, y seguramente otros horrores que en este momento olvido".

**Where**: in the game's own data, in `~/juegos/zounds` —taro's repo,
retouched with their approval like the cave's doorways and its song—,
written with `ditto read`/`write`: the messages, the choices and the
database's names and terms.

**What is fixed**: spelling —letters, accents, the h, `¿`/`¡`—, not the
style: the author's voice, their slang and their jokes stay. A doubtful
case is left as it is and listed for taro. Every change goes in a list
taro can read (before → after, map and event), so they review it without
playing everything.

Waits for
[`zounds-the-cave-plays-the-mountains-song`](zounds-the-cave-plays-the-mountains-song.md)
(Calandria), which edits the same repo.

## What was done (Calandria, 2026-10-20)

**The game**: `calandria-spelling` in `~/juegos/zounds`, from master at
`02aa303`. One commit, 72 files (71 maps and `RPG_RT.ldb`); only string
values change. Written with `ditto read`/`write`: the round trip of all
190 files alone was byte for byte equal before editing, and each edited
file read back equal to the JSON written.

**What was read**: every string the player sees —`ShowMessage` and its
continuation lines, `ShowChoice` and its options, the database's actor,
class, battle command, skill, item, enemy, state and attribute names and
descriptions, the terms, and the messages of common events and troop
pages—, 8,069 strings of which 2,380 are different, all of them read by
hand. The corrections are regular expressions applied to every one of
those strings, so the same sign or box copied across maps gets the same
fix; the list of what they changed was read whole afterwards, and a
Spanish dictionary (hunspell, `es_AR`) was run over the result to catch
what reading missed (it found one: `$LAbsorver`, a skill name).

**How much**: 307 different lines, in 892 places —maps 47 and 51 alone,
with their rows of copied signs, carry 160 each—. By kind, counting each
line once under every kind it has: letters 105 (*save*/*sabe*,
*deve*/*debe*, *vever*/*beber*, *autorisación*, *mounstro*, *pezca*…),
accents 121 (*tú*, *mí*, *qué* in questions and exclamations, *esto*
never accented, the demonstrative before a noun without one), typos 66 (a
missing or doubled letter or word: *Requepera*, *vvo*, *Voy a a decir*),
opening `¿`/`¡` 15, interjections 6 (*Hay* → *Ay*, *A* → *Ah*, *He* →
*Eh*, *Aja* → *Ajá*).

**What stays**: voseo, slang (*posta*, *gil*, *chavón*, *mandar fruta*),
the guards' parody of Spanish from Spain, the queen's put-on accent, the
stranger's broken Spanish and the invented languages, onomatopoeia,
names, and the accent on demonstrative **pronouns** (*Ésta es la
habitación de Rumiel*), the norm when the game was written. Doubtful
lines were left as they were: the list, with where each is, in
`doubts.md` (below). The main ones: *¡Unäne!* shouted from the ship,
*"derotar"* in quotes, *le herra* (a pun with *herrero*?), *Piedra
Vilaícea* and the state *Nevlinado* (invented or mistyped?), *Kieres una
botella?* on the BackUp map, *Wisky*, and grammar that is not spelling
(*cuando más* for *cuanto más*, *seguro que*). Also seen while reading,
not spelling and not touched: a broken colour code (`\c[6]Trabajo\[4]`,
map 139), a `\v[20]` that surely meant `\s[20]` (Madamme Lessier, map
161), and three names that do not match their item.

**Line width**: RPG_RT does not wrap a message line, so a fix that adds
letters could push one past the window. The lines that grew are at most
38 characters in a box with a face —the game has 29 lines of 38 or
longer with a face already— and 40 without one, where the game reaches
48. Skill 15's *Parliz.* was left for that reason. The console's port
re-flows the boxes to its window on its own.

**The lists for taro**, before → after with map, event and page, or the
database entry: `/shared/captures/2026-10-20-zounds-spelling/changes.md`
and `doubts.md`.

**The ports**: `calandria-spelling`, the new `zounds/data/` dumped from
the game's branch (892 string values, nothing else). No test, case, patch
or `advocate.toml` quotes a line that changed; `test_zounds_battle_text.py`
reads the port's own battle terms, which this does not touch.

**The book**: one bullet in the Zounds page's "What is fixed in the game
itself".

Not run in RPG_RT: the data changes are strings only, and ditto reads
every file back.

**Run**: `just boot -k zounds` in the ports' branch, with `GAME_DIR` at
the game's branch: green, every Zounds test. Its build's
`converter.log` against `main`'s, same tools: the same warnings; what
changed is the message window's text (three boxes fewer, 64 B less), two
more composed tiles of names in the menu bank, and *Taza de Café* in the
list of medicine names cut in the actor choice, where *Tasa de Café* was.
`degradations.json` differs in that line alone.

**When merging**: nothing to install. The game's `calandria-spelling`
goes to its master (taro's repo, like the cave's fixes), the ports' and
the book's to their `main`.
