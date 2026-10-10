# Qué

`FlashScreen` **no le llega a una imagen** de `ShowPicture`. En la consola el
destello es una transformación de CGRAM: `flash_tick`, en
`tools/runtime/screen_flash.s`, recorre las paletas del mapa —el fondo, la capa
de arriba y los colores de los personajes, `M_SPRITE_CGRAM` desde la 128— y la
imagen vive en la paleta de sprites `7 - s` de su ranura (`pic_palette`, en
`picture.s`), que queda afuera de ese rango. En RM2k sí le llega, siempre: en easyrpg
`Game_Pictures::ShowParams` arranca con las banderas `1 | 32 | 64`, y la 32 es
`affected_by_flash`; sólo el `ShowPicture` de RM2k3 trae el parámetro que las
cambia.

La ventana de mensajes y el cronómetro tampoco reciben el destello, pero ésos
no son divergencia: en RM2k también quedan por encima (`Priority_Screen` es 90,
contra 130 de la ventana y 140 del cronómetro), y lo dice el encabezado de
`screen_flash.s`.

# Medido

Escrito por primera vez en el `ESTADO.md` de la raíz, congelado el 2026-09-23,
y vuelto a leer en el código el 2026-10-10: sigue igual. Entonces ninguna
página de A Blurred Line destellaba con una imagen puesta, así que no hay caso
de la tanda que lo vea, ni golden que lo hornee.

# Cuándo deja de alcanzar

Cuando un juego destelle con una imagen en pantalla. La salida es agregar las
paletas de las ranuras de imagen ocupadas al recorrido de `flash_sprites`;
cuesta tiempo de cuadro, y el destello ya se reparte en dos cuadros porque no
entra en uno.
