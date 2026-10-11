---
name: "Las imágenes que van sobre el mapa, fuera de Sunset"
description: "En el baño de la estación de Desert Nightmare (mapa 7) una máscara de luz al 35% sale como imagen grande y tapa el cuarto unos 8 segundos; la perilla map_pictures que lo resuelve en Sunset no está prendida en otros juegos"
type: bug
status: draft
---

Visto por Hurón el 2026-10-06 (`testing/eraseevent-de-verdad.md`): en la
escena del WC de Desert Nightmare (mapa 7), el evento 4 es una paralela
que muestra `Lichteffekt_Tankstelle_WC` y se borra. En RM2k es una
máscara oscura al 35% sobre el cuarto; en la ROM "sale opaca y tapa el
cuarto durante ~480 cuadros: parece que se cuelga, pero sigue. Es la
transparencia de las imágenes, no el borrado". Capturas de ese día en
`/shared/capturas/2026-10-06-eraseevent/`.

Lo que se sabe de la causa: es una imagen grande, y una imagen grande
saca el mapa de la pantalla; su transparencia oscurece hacia el negro de
atrás (`divergences/lo-que-las-imagenes-grandes-no-modelan.md` del libro).
Es lo mismo que tenía Sunset con sus techos y nieblas, que desde el
2026-10-11 se dibujan adentro del mapa con `[graphics] map_pictures`
(`testing/sunset-las-imagenes-sobre-el-mapa.md`); esa perilla está
prendida sólo en Sunset.

**No comprobado hoy en la consola.** Armado hoy (the-advocate `fc6f7456`,
ports `a85b7e3`), el release de Desert lleva 304 imágenes grandes y no
nombra a ésta entre las que no dibuja, así que lo esperable es que siga
igual. Cuántas otras imágenes de los otros juegos van sobre el mapa no se
contó.

**Cómo verlo**: `just cartuchos release` en `desert-nightmare/`, jugar
hasta el baño de la estación (mapa 7) y comparar con el original en Wine.
