# Estado del Trabajo

Este repo es una especie de Jira casero: las tareas de todos los repos, y
desde dónde se trabaja —el `AGENTS.md` y `.claude/`—.

Las tareas viven todas en `tasks/`, un archivo por tarea, y su estado es
el `status` del frontmatter:

- `draft`: hallazgos y cosas que todavía no son una tarea: se vio algo,
  pero falta definir qué hacer
- `todo`: tareas no empezadas
- `doing`: tareas en progreso: quien la toma la pasa acá antes que nada
- `testing`: hechas y a la espera de que taro las pruebe jugando
- `done`: tareas terminadas
- `wishlist`: lo que nos gustaría hacer y nadie está haciendo

**El nombre de archivo de una tarea no cambia nunca**, aunque su título
cambie: es su dirección, y se la enlaza desde los otros repos y desde el
libro —`tasks/<nombre>.md` en GitHub—. Es de taro, el 2026-10-11, el mismo
día que este repo se hizo público. Hasta ese día había una carpeta por
estado, y cada tarea que se movía rompía las citas a ella; las citas
viejas con carpeta —`testing/x.md`, `tasks/todo/x.md`— son `tasks/x.md`.
`nu tasks/tasks.nu ls -s <estado>` las lista.

**Este repo es público**: nada de lo que se escribe acá puede ser privado.

**Un draft no está listo para tomarse.** Es lo que un agente encuentra y no
arregla —un error que no es de su tarea, un camino que no cubrió, "lo
siguiente, medido"—: un archivo corto con qué se vio, en qué juego, en qué
commit y cómo reproducirlo, sin `assignee` y sin decir cómo se arregla.
Sale de ahí cuando alguien lo define —a `todo` o a `wishlist`— o se
borra si otra cosa lo arregló. La diferencia con `wishlist`: una tarea de
la lista de deseos está definida y sólo falta priorizarla; un draft no
está definido. Es de taro, el 2026-10-11: hasta ese día los hallazgos
quedaban en la sección "Hallazgos" de la tarea del agente y se enterraban
con ella.

**Las decisiones, las divergencias y los research no están acá**: viven en
el libro, `the-advocate-docs`, en inglés, desde el 2026-10-10 —"el libro es
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
    status: draft | todo | doing | testing | done | wishlist
    assignee: taro
    ---

`type` y `status` van siempre. `assignee` dice quién la tiene: `taro` para las suyas y para
las que esperan algo de él —jugar, mirar unas goldens—, y el nombre del agente
para las que están en `doing`. Ver "Tomar una tarea" en `AGENTS.md`. En
`todo`, sin `assignee`, la toma quien llegue. Muchas de las que están en
`done` son de antes de estos campos y no llevan `assignee`.

**Acá se trackea todo**: las herramientas y el runtime (`the-advocate`), los
ports (`the-advocate-ports`: A Blurred Line y los otros juegos) y el libro
(`the-advocate-docs`). Es de taro, el 2026-10-10, "para trackear todo en un
solo lugar".

Hasta ese día esto era la carpeta `workflow/` de `the-advocate`, y de ahí
salió con su historia (`git subtree split`). Así que:

* **un `workflow/…` escrito en otro repo es la ruta de acá**, sin el
  `workflow/`: `workflow/tasks/todo/x.md` es `tasks/todo/x.md`, que hoy
  es `tasks/x.md`;
* **los hashes que citan las tareas y los mensajes de commit son de
  `the-advocate`**, o de `the-advocate-ports` cuando hablan de ABL: los commits
  de acá son copias con otro hash y el mismo mensaje.

Del 2026-10-02 al 2026-10-10 las tareas y decisiones de ABL vivieron en su
repo; ese día volvieron a `the-advocate`, y desde ahí vinieron con todo lo
demás.
