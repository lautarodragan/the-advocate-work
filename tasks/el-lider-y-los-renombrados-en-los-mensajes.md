---
name: "\\N[0] y los actores renombrados en los mensajes"
description: "Una caja con \\N[0] (el líder) o con el \\N[n] de un actor que algún ChangeHeroName renombra deja afuera su página entera"
type: feature
status: draft
---

Deuda que declaró Carpintero el 2026-10-05 al hornear los nombres
(`el-nombre-del-heroe-en-los-mensajes.md`): `with_names`, en
`rm2k-snes/events/src/compile.rs`, escribe el nombre de la base de datos
en cada `\N[n]` sólo si ningún `ChangeHeroName` del juego toca a ese
actor. `\N[0]` —el líder, que depende de quién esté en el grupo— y los
actores renombrables quedan como están, y una caja con eso no compila: la
página se cae entera. Sigue así en the-advocate `fc6f7456`; la prueba
`an_actors_name_is_baked_into_the_text_unless_it_can_change` lo fija.

Lo que se sabe de la causa: el compositor de la ROM no escribe un nombre
en tiempo de ejecución. `ChangeHeroName` tampoco compila hoy, así que una
página que renombra ya está afuera por su cuenta (la pantalla de
`EnterHeroName` es otra cosa: `la-pantalla-del-nombre-del-heroe.md`).

**No medido hoy**: cuántas páginas deja afuera en cada juego. El 2026-10-05
el `\N[n]` en general afectaba a cuatro juegos —The Frozen World cortaba
su cinemática inicial en el mapa 4— y lo horneado destrabó eso; lo que
queda es `\N[0]` y los renombrados. `rm2k-snes-events culprits
--every-map`, sobre el pedido de `compile` de cada juego, lo dice.
