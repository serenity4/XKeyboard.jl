var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = XKeyboard","category":"page"},{"location":"#XKeyboard","page":"Home","title":"XKeyboard","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for XKeyboard.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [XKeyboard]","category":"page"},{"location":"#Core.Char-Tuple{Keymap, PhysicalKey}","page":"Home","title":"Core.Char","text":"Char(keymap, key::PhysicalKey)\n\nRetrieve a UTF-8 character which corresponds to the printable input associated with the keysym obtained via the provided keycode and the keymap state.\n\nIf no printable input is defined for this keysym, the NUL character '\\0' is returned which, when printed, is a no-op.\n\n\n\n\n\n","category":"method"},{"location":"#Core.String-Tuple{Keymap, PhysicalKey}","page":"Home","title":"Core.String","text":"String(keymap, key::PhysicalKey)\n\nObtain the string representation of a physical key.\n\n\n\n\n\n","category":"method"},{"location":"#Core.String-Tuple{Keymap}","page":"Home","title":"Core.String","text":"Return a complete string representation of a Keymap.\n\ntip: Tip\nThe output is very large and may be better to redirect to a file than to print directly on a console.\n\n\n\n\n\n","category":"method"},{"location":"#Core.String-Tuple{Keysym}","page":"Home","title":"Core.String","text":"String(keysym; max_chars = 50)\n\nReturn a String representation of a Keysym with at most max_chars characters.\n\nThe size of the string is not known when querying XKB, so max_chars are reserved (50 by default) and the result will be truncated if not enough characters were reserved.\n\n\n\n\n\n","category":"method"},{"location":"#Core.Symbol-Tuple{Keymap, PhysicalKey}","page":"Home","title":"Core.Symbol","text":"Symbol(keymap, key::PhysicalKey)\n\nObtain the name of a physical key.\n\nString(keymap, key::PhysicalKey) can be used instead if you aim to consume a String instead of a Symbol.\n\n\n\n\n\n","category":"method"},{"location":"#XKeyboard.Keymap","page":"Home","title":"XKeyboard.Keymap","text":"Keymap used to encode information regarding keyboard layout, and country and language codes.\n\nA string representation can be obtained from a Keymap by using String(keymap).\n\n\n\n\n\n","category":"type"},{"location":"#XKeyboard.Keysym","page":"Home","title":"XKeyboard.Keysym","text":"Code used by XKB to represent symbols on a logical level.\n\nSuch codes differ from keycodes in that they keycodes are stateless: when a key is pressed, it always emits the same keycode.\n\nTo understand the difference, let's take the physical key AD01. When pressed, it emits an integer signal (keycode) representing that specific key on the keyboard (the name AD01 is just a label that is more friendly than an integer code). If pressed on a US keyboard (QWERTY layout), it may emit the character q. Or Q. This depends on whether a shift modifier or caps lock (without shift modifier) is active, among other things. If we were on a French keyboard, then the letter would be a (AZERTY layout), or A. if we had pressed the left or right shift key instead, we would not even have a printable character associated with the keystroke.\n\nq, Q, a, A, left_shift and right_shift are all semantic symbols, need not be printable (e.g. shifts) and their mapping from a physical key -if one exists- depends some external state, tracked inside a Keymap. Just like physical keys, these symbols are represented with an integer code, and have a more friendly string representation that one can obtain with String(keysym::Keysym).\n\nKeysyms are not physical keys, nor input characters.\n\n\n\n\n\n","category":"type"},{"location":"#XKeyboard.PhysicalKey","page":"Home","title":"XKeyboard.PhysicalKey","text":"Physical key, represented with a designated integer keycode.\n\n\n\n\n\n","category":"type"},{"location":"#XKeyboard.PhysicalKey-Tuple{Keymap, Symbol}","page":"Home","title":"XKeyboard.PhysicalKey","text":"PhysicalKey(keymap, name::Symbol)\n\nObtain a PhysicalKey from its string representation name using a keymap.\n\nUseful for simulating events which typically require the integer code of a physical key (keycode).\n\nA name of type AbstractString can be used instead if you have a string at the ready.\n\n\n\n\n\n","category":"method"},{"location":"#XKeyboard.keymap_from_x11-Tuple{Any}","page":"Home","title":"XKeyboard.keymap_from_x11","text":"Construct a Keymap via X11 using conn as the connection to an X Server.\n\nThis action uses XKB, the X Keyboard extension, which must be initialized for each X11 connection, typically when creating a keymap. If this is not your first call to this constructor with this connection, you should set setup_xkb to false.\n\n\n\n\n\n","category":"method"}]
}
