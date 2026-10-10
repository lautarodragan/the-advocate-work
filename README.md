# Estado del Trabajo

Este repo es una especie de Jira casero: las tareas de todos los repos, y
desde dónde se trabaja —el `AGENTS.md` y `.claude/`—.

- `tasks/todo/` tareas no empezadas
- `tasks/doing/` tareas en progreso: quien la toma la pasa acá antes que nada
- `tasks/testing/` hechas y a la espera de que taro las pruebe jugando
- `tasks/done/` tareas terminadas
- `tasks/wishlist/` es lo que nos gustaría hacer y nadie está haciendo

**Las decisiones, las divergencias y los research no están acá**: viven en
el libro, `snes-rm2k-docs`, en inglés, desde el 2026-10-10 —"el libro es
para personas y para IAs", de taro—. Hasta ese día `decisiones/` y
`divergencias/` eran carpetas de este repo, y los research estaban en
`docs/research/` de las herramientas y de ABL. Los nombres de archivo se
conservaron, así que una cita vieja se encuentra por nombre:

* `decisiones/x.md` es `src/decisions/x.md` del libro, salvo dos de ABL,
  que están en `src/ports/abl/decisions/`;
* `divergencias/x.md` es `src/divergences/x.md`;
* `docs/research/x.md` de las herramientas es `src/research/x.md`, y el de
  ABL, `src/ports/abl/research/x.md`;
* `docs/port/x.md` es `src/internals/x.md`.

## El frontmatter de una tarea

    ---
    name: "Título corto"
    description: "Una línea: qué es, para la lista"
    type: bug | feature | refactor | test | docs
    assignee: taro
    ---

`type` va siempre. `assignee` dice quién la tiene: `taro` para las suyas y para
las que esperan algo de él —jugar, mirar unas goldens—, y el nombre del agente
para las de `doing/`. Ver "Tomar una tarea" en `AGENTS.md`. En `todo/`, sin
`assignee`, la toma quien llegue. Las de `done/` son de antes de estos campos y no los llevan.

**Acá se trackea todo**: las herramientas y el runtime (`snes-rm2k`), los
ports (`snes-rm2k-ports`: A Blurred Line y los otros juegos) y el libro
(`snes-rm2k-docs`). Es de taro, el 2026-10-10, "para trackear todo en un
solo lugar".

Hasta ese día esto era la carpeta `workflow/` de `snes-rm2k`, y de ahí
salió con su historia (`git subtree split`). Así que:

* **un `workflow/…` escrito en otro repo es la ruta de acá**, sin el
  `workflow/`: `workflow/tasks/todo/x.md` es `tasks/todo/x.md`;
* **los hashes que citan las tareas y los mensajes de commit son de
  `snes-rm2k`**, o de `snes-rm2k-ports` cuando hablan de ABL: los commits
  de acá son copias con otro hash y el mismo mensaje.

Del 2026-10-02 al 2026-10-10 las tareas y decisiones de ABL vivieron en su
repo; ese día volvieron a `snes-rm2k`, y desde ahí vinieron con todo lo
demás.
