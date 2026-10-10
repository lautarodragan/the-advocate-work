# Qué

**El día que el conversor emita los datos en binario** —`.incbin` en vez de
`.byte` y `.word` en el `.inc`— **sale con un sourcemap**: del offset del
`.bin` a qué campo de qué es, por ejemplo "el `trigger` de la página 2 del
evento 12 del mapa 8". No después: con el emisor.

# Por qué

De taro, cuando se planteó el emisor binario, en septiembre de 2026; hasta
el 2026-10-10 estaba escrito en `DITTO.md`, de `snes-rm2k`, que ese día se
borró.

Hoy los comentarios del `.inc` son lo que deja depurar un dato, y un
`.incbin` no tiene comentarios. Pero además esa información **ya se evapora
al ensamblar**, así que el mapa vale por sí mismo y no sólo como
compensación:

* que una prueba en rojo diga **qué dato** falla, y no sólo cuántos
  pixeles difieren: los errores que salían como "la pantalla se hizo
  basura" eran punteros leyendo donde no debían;
* traducir un puntero leído de la RAM a qué apunta, con el juego corriendo.

Tiene dos saltos —del JSON al `.bin`, y del `.bin` al offset de la ROM—, y
el segundo ya existe: `rm2k-snes-assemble` escribe un `.sym` con los
símbolos del código, y esto es su extensión a los datos.

**Nace con el emisor o no nace**: el serializador sabe en qué offset
escribió cada campo mientras lo escribe, y reconstruirlo después es
recorrer todo de nuevo.

Lo que no puede volverse binario se queda como texto: las constantes que
el runtime usa como símbolos y las referencias que sólo resuelve `ld65`.
