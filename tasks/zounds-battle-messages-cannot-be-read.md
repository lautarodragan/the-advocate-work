---
name: "Zounds: some battle messages cannot be read"
description: "Some lines of the battle's message window come out as garbage characters, as if the text were read from the wrong place or in the wrong encoding"
type: bug
status: doing
assignee: Chajá
agents: [Chajá]
---

Seen by taro on 2026-10-19, playing Zounds' delivery of that day (the ports `1182513`, the-advocate `2c350d8f`).

**What is seen**, in a capture taro sent, a battle in a cave against a
purple flower: the battle's window shows two lines that start with a name
and go on as garbage:

    Imaru|I'I?U0E'?I
    Kazar 3'I?_???[?W:dZo'-'1/2?I

(transcribed by eye; the first looks like a monster's name, the second
starts with Kazar's). Not every message: "some texts in the battle".
