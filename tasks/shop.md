---
name: "The shop"
description: "OpenShop opens RM2k's shop"
status: done
---

### The shop

`OpenShop` opens `Scene_Shop`. It compiles to `OP_SHOP` —the
type, the message set and the list of what it sells, of variable length like
`OP_CHOICE`— and, like saving, the screen opens inside the interpreter and
costs no tick: on leaving, the map comes back and the page goes on. It is a
text screen, and each mode is RM2k's:

    main            the greeting —or the re-greeting on coming back— and Buy, Sell, Leave
    buy             what it sells with its price, greyed out what the gold
                    doesn't reach or is already held at 99; the gold, and how many
                    are held and how many the party has equipped of the one under the cursor
    how many        right and left by one, up and down by ten,
                    between 1 and what is possible; the total
    done            the "Done" or the "Thanks.", one second, and back
    sell            the inventory at half price, greyed out what is worth 0

With a single order —only buy or only sell— there is no main. The
messages come from the LDB's three term sets, split over two
lines; the "bought" and "didn't buy" branches don't compile, and no shop
in the game uses them. The suite's `tienda` case enters and leaves the one on map
10, and `pruebas/rpgmaker/test_tienda.py` walks through it entirely pixel by pixel against
`pantallas.pantalla_tienda`: buying, the gold cap, selling, the gold and the
inventory that remain.
