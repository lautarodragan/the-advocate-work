---
name: "El loop de la música, como RM2k"
description: "Ninguno de los dos caminos hace el loop como RPG_RT: el MSU-1 vuelve a 0 después de 2-6 s de cola de fluidsynth; sin MSU-1 se corta en la última nota; ninguno saltea el silencio inicial ni lee CC111"
type: bug
agents: [Hornero]
---

Medido el 2026-10-11 por Hornero, a pedido de taro ("tenemos pendiente el tema del loop de música en el msu, y no sé si ya lo hacemos bien sin msu o no"), con `abl.sfc` `24dd24ad…` y las herramientas de `6f933ff8`.

**Lo que hace RPG_RT**, según easyrpg-player (`src/midisequencer.cpp`, `audio_decoder_midi.cpp`): al terminar —el último evento del MIDI, no la última nota— vuelve a la marca de loop, un Control Change 111 en cualquier canal, o al principio si no hay. La primera vez se saltea el silencio del principio y arranca en la primera nota, salvo que haya un SysEx antes; al volver, no.

**Sin MSU-1** (`midi::timeline`, `stream::writes`, `music_frame` en `runtime/music.s`): el tema termina con su **última nota** y vuelve al principio, silencio incluido. Contra RM2k: no saltea el silencio inicial la primera vez, y los temas con un silencio entre la última nota y el fin de la pista lo pierden, así que el compás de la vuelta queda corto. No lee CC111.

**Con MSU-1** (`tracks.rs`): la pista es el MIDI entero renderizado con fluidsynth y el loop point es siempre 0. Las pistas de ABL duran **2 a 6 s más que sus notas**: la cola de release y reverb que agrega fluidsynth, que al volver queda como un hueco antes de que el tema empiece de nuevo. `escape_newyork` sobra 29 s, a mirar aparte. Tampoco saltea el silencio inicial ni lee CC111.

**Cuánto pesa en cada juego** (MIDIs con más de media negra de silencio al empezar / con más de una negra entre la última nota y el fin / con CC111):

    ABL              222   52   9   0
    Dooms 2           53   22   8   3
    Frozen World      73   23   8   0
    Book of Three     67   35  12   0
    Sunset             8    7   0   0
    El Dorado          3    2   0   0
    Desert Nightmare   1    0   1   0

Un MIDI de ABL, `dgate008.mid`, no lo pudo leer el script de la medición —el conversor sí lo lee—, y el de VD no se midió.

Lo que haría falta: el largo hasta el fin de la pista, no la última nota; CC111 como punto de vuelta en los dos caminos —en el stream, una vuelta a una posición en vez de al principio; en el MSU-1, el loop point en muestras—; saltear el silencio inicial la primera vez; y en el `.pcm`, cortar la cola de fluidsynth en el punto de vuelta. Recortar eso además achica los `.pcm`.

## Cómo va la cola en el `.pcm`, con taro

taro, el 2026-10-11: cortar la cola de golpe sonaría feo; "tendríamos que tener una versión del inicio del tema que tenga la cola del final y loopear desde 0 + len(cola)". Así se hace: renderizar la vuelta y, sin resetear el sintetizador, el comienzo de la siguiente —fluidsynth con el MIDI dos veces y `player.reset-synth=0`—, terminar la pista en E + D y poner el loop point en L + D, con E el fin de la primera vuelta, L el punto de vuelta (CC111, o 0) y D lo que dura la cola, con margen. Pasados D segundos la cola anterior ya se apagó, así que E + D y L + D suenan igual y el salto no se oye; la cola de la primera vuelta suena entera, pegada en el comienzo de la segunda. Con el silencio inicial salteado (largo S), el loop point es `max(L + D, S)` contado desde S. Sin MSU-1 no hace falta nada: el stream es de notas, y la reverb del DSP sigue a través de la vuelta.
