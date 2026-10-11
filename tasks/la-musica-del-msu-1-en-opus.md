---
name: "La música del MSU-1, distribuida en Opus"
description: "Los .pcm de ABL pesan 1,4 GB; distribuidos en Opus a 160 kbps serían ~180 MB, y en FLAC ~550 MB, y se convierten a .pcm una vez al instalar"
type: feature
status: wishlist
agents: [Hornero]
---

taro, el 2026-10-11: los PCM "pesan un montón y eso va a complicar distribuirlos". El formato del MSU-1 es fijo —44,1 kHz, 16 bits, estéreo, sin compresión—, así que se achican sólo para distribuirlos. Medido sobre 6 de las 62 pistas de ABL (158 MB): FLAC al 39 %, Opus a 160 kbps al 13 %. A la wishlist por decisión de taro: "dejemos opus en la wishlist. no hagamos nada ahora". Sintetizar en la consola con el SoundFont en el `.msu` no sirve: el SPC700 sigue con 8 voces y 64 KB, y la CPU no le puede pasar muestras a ese ritmo.
