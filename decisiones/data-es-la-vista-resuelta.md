# Qué

`data/` es la **vista resuelta** del juego —todos los campos escritos y los
enums en número— y el volcado exacto **no se versiona**.

# Por qué

Del 2026-09-20. `ditto unpack` emite las dos en la misma corrida: `data/` y
`build/ditto-exacto/` de ABL, con la forma del binario. Con eso
`tools/rpgmaker/lcf.py` no sabe ninguna regla del formato, que era lo que se
buscaba.

Perder los nombres en `data/` es aceptado: vuelven el día que el pipeline sea
Rust y Ditto sea una lib.

No versionar el exacto es lo que hace que **la única fuente del binario sea el
juego**, que es lo que `ditto pack` ya necesitaba tener al lado para comparar.

Y el porqué de leer el volcado y no el binario, que es la decisión de la
que ésta cuelga: el formato **no guarda un campo cuando vale su default**,
así que quien lo lee tiene que saber todos los defaults. Hasta el
2026-09-14 había dos lectores del mismo formato, cada uno con los suyos
escritos a mano, y los dos se equivocaban igual: el `max_hp` de un enemigo
llegaba en 1 donde el formato dice 10, el enemigo moría de un golpe, y no
había con qué comparar. Desde ahí el formato lo lee sólo Ditto, con los
defaults del esquema de liblcf, y todo lo demás lee lo que él vuelca.

Hasta el 2026-10-10 esto, con la historia de cómo se llegó, estaba en
`DITTO.md` de `snes-rm2k`; ese día se borró, y lo que vale para afuera
quedó en el libro, en "From a game to a ROM".
