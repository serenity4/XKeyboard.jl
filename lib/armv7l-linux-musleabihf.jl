"""
Index of a keyboard layout.

The layout index is a state component which detemines which <em>keyboard layout</em> is active. These may be different alphabets, different key arrangements, etc.

Layout indices are consecutive. The first layout has index 0.

Each layout is not required to have a name, and the names are not guaranteed to be unique (though they are usually provided and unique). Therefore, it is not safe to use the name as a unique identifier for a layout. Layout names are case-sensitive.

Layout names are specified in the layout's definition, for example "English (US)". These are different from the (conventionally) short names which are used to locate the layout, for example "us" or "us(intl)". These names are not present in a compiled keymap.

If the user selects layouts from a list generated from the XKB registry (using libxkbregistry or directly), and this metadata is needed later on, it is recommended to store it along with the keymap.

Layouts are also called "groups" by XKB.

### See also
[`xkb_keymap_num_layouts`](@ref)() [`xkb_keymap_num_layouts_for_key`](@ref)()
"""
const xkb_layout_index_t = UInt32

"""
A mask of layout indices.
"""
const xkb_layout_mask_t = UInt32

"""
` xkb_context`

Opaque top level library context object.

The context contains various general library data and state, like logging level and include paths.

Objects are created in a specific context, and multiple contexts may coexist simultaneously. Objects from different contexts are completely separated and do not share any memory or state.
"""
const xkb_context = Cvoid

"""
    xkb_rule_names

Names to compile a keymap with, also known as RMLVO.

The names are the common configuration values by which a user picks a keymap.

If the entire struct is NULL, then each field is taken to be NULL. You should prefer passing NULL instead of choosing your own defaults.

| Field   | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| :------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| rules   | The rules file to use. The rules file describes how to interpret the values of the model, layout, variant and options fields.  If NULL or the empty string "", a default value is used. If the XKB\\_DEFAULT\\_RULES environment variable is set, it is used as the default. Otherwise the system default is used.                                                                                                                                                                                                                       |
| model   | The keyboard model by which to interpret keycodes and LEDs.  If NULL or the empty string "", a default value is used. If the XKB\\_DEFAULT\\_MODEL environment variable is set, it is used as the default. Otherwise the system default is used.                                                                                                                                                                                                                                                                                         |
| layout  | A comma separated list of layouts (languages) to include in the keymap.  If NULL or the empty string "", a default value is used. If the XKB\\_DEFAULT\\_LAYOUT environment variable is set, it is used as the default. Otherwise the system default is used.                                                                                                                                                                                                                                                                            |
| variant | A comma separated list of variants, one per layout, which may modify or augment the respective layout in various ways.  Generally, should either be empty or have the same number of values as the number of layouts. You may use empty values as in "intl,,neo".  If NULL or the empty string "", and a default value is also used for the layout, a default value is used. Otherwise no variant is used. If the XKB\\_DEFAULT\\_VARIANT environment variable is set, it is used as the default. Otherwise the system default is used.  |
| options | A comma separated list of options, through which the user specifies non-layout related preferences, like which key combinations are used for switching layouts, or which key is the Compose key.  If NULL, a default value is used. If the empty string "", no options are used. If the XKB\\_DEFAULT\\_OPTIONS environment variable is set, it is used as the default. Otherwise the system default is used.                                                                                                                            |
"""
struct xkb_rule_names
    rules::Ptr{Cchar}
    model::Ptr{Cchar}
    layout::Ptr{Cchar}
    variant::Ptr{Cchar}
    options::Ptr{Cchar}
end

"""
    xkb_keymap_compile_flags

Flags for keymap compilation.

| Enumerator                          | Note                     |
| :---------------------------------- | :----------------------- |
| XKB\\_KEYMAP\\_COMPILE\\_NO\\_FLAGS | Do not apply any flags.  |
"""
@enum xkb_keymap_compile_flags::UInt32 begin
    XKB_KEYMAP_COMPILE_NO_FLAGS = 0
end

"""
` xkb_keymap`

Opaque compiled keymap object.

The keymap object holds all of the static keyboard information obtained from compiling XKB files.

A keymap is immutable after it is created (besides reference counts, etc.); if you need to change it, you must create a new one.
"""
const xkb_keymap = Cvoid

"""
    xkb_keymap_new_from_names(context, names, flags)

Create a keymap from RMLVO names.

The primary keymap entry point: creates a new XKB keymap from a set of RMLVO (Rules + Model + Layouts + Variants + Options) names.

### Parameters
* `context`: The context in which to create the keymap.
* `names`: The RMLVO names to use. See [`xkb_rule_names`](@ref).
* `flags`: Optional flags for the keymap, or 0.
### Returns
A keymap compiled according to the RMLVO names, or NULL if the compilation failed.
### See also
[`xkb_rule_names`](@ref) xkb_keymap
"""
function xkb_keymap_new_from_names(context, names, flags)
    ccall((:xkb_keymap_new_from_names, libxkb), Ptr{xkb_keymap}, (Ptr{xkb_context}, Ptr{xkb_rule_names}, xkb_keymap_compile_flags), context, names, flags)
end

"""
    xkb_keymap_format

The possible keymap formats.

| Enumerator                        | Note                                                                |
| :-------------------------------- | :------------------------------------------------------------------ |
| XKB\\_KEYMAP\\_FORMAT\\_TEXT\\_V1 | The current/classic XKB text format, as generated by xkbcomp -xkb.  |
"""
@enum xkb_keymap_format::UInt32 begin
    XKB_KEYMAP_FORMAT_TEXT_V1 = 1
end

"""
    xkb_keymap_new_from_file(context, file, format, flags)

Create a keymap from a keymap file.

The file must contain a complete keymap. For example, in the XKB\\_KEYMAP\\_FORMAT\\_TEXT\\_V1 format, this means the file must contain one top level 'xkb\\_keymap' section, which in turn contains other required sections.

xkb_keymap

### Parameters
* `context`: The context in which to create the keymap.
* `file`: The keymap file to compile.
* `format`: The text format of the keymap file to compile.
* `flags`: Optional flags for the keymap, or 0.
### Returns
A keymap compiled from the given XKB keymap file, or NULL if the compilation failed.
"""
function xkb_keymap_new_from_file(context, file, format, flags)
    ccall((:xkb_keymap_new_from_file, libxkb), Ptr{xkb_keymap}, (Ptr{xkb_context}, Ptr{Libc.FILE}, xkb_keymap_format, xkb_keymap_compile_flags), context, file, format, flags)
end

"""
    xkb_keymap_new_from_string(context, string, format, flags)

Create a keymap from a keymap string.

This is just like [`xkb_keymap_new_from_file`](@ref)(), but instead of a file, gets the keymap as one enormous string.

### See also
[`xkb_keymap_new_from_file`](@ref)() xkb_keymap
"""
function xkb_keymap_new_from_string(context, string, format, flags)
    ccall((:xkb_keymap_new_from_string, libxkb), Ptr{xkb_keymap}, (Ptr{xkb_context}, Ptr{Cchar}, xkb_keymap_format, xkb_keymap_compile_flags), context, string, format, flags)
end

"""
    xkb_keymap_get_as_string(keymap, format)

Get the compiled keymap as a string.

The returned string may be fed back into [`xkb_keymap_new_from_string`](@ref)() to get the exact same keymap (possibly in another process, etc.).

The returned string is dynamically allocated and should be freed by the caller.

xkb_keymap

### Parameters
* `keymap`: The keymap to get as a string.
* `format`: The keymap format to use for the string. You can pass in the special value [`XKB_KEYMAP_USE_ORIGINAL_FORMAT`](@ref) to use the format from which the keymap was originally created.
### Returns
The keymap as a NUL-terminated string, or NULL if unsuccessful.
"""
function xkb_keymap_get_as_string(keymap, format)
    ccall((:xkb_keymap_get_as_string, libxkb), Ptr{Cchar}, (Ptr{xkb_keymap}, xkb_keymap_format), keymap, format)
end

"""
    xkb_keymap_ref(keymap)

Take a new reference on a keymap.

xkb_keymap

### Returns
The passed in keymap.
"""
function xkb_keymap_ref(keymap)
    ccall((:xkb_keymap_ref, libxkb), Ptr{xkb_keymap}, (Ptr{xkb_keymap},), keymap)
end

"""
    xkb_keymap_unref(keymap)

Release a reference on a keymap, and possibly free it.

xkb_keymap

### Parameters
* `keymap`: The keymap. If it is NULL, this function does nothing.
"""
function xkb_keymap_unref(keymap)
    ccall((:xkb_keymap_unref, libxkb), Cvoid, (Ptr{xkb_keymap},), keymap)
end

"""
Index of a modifier.

A *modifier* is a state component which changes the way keys are interpreted. A keymap defines a set of modifiers, such as Alt, Shift, Num Lock or Meta, and specifies which keys may *activate* which modifiers (in a many-to-many relationship, i.e. a key can activate several modifiers, and a modifier may be activated by several keys. Different keymaps do this differently).

When retrieving the keysyms for a key, the active modifier set is consulted; this detemines the correct shift level to use within the currently active layout (see [`xkb_level_index_t`](@ref)).

Modifier indices are consecutive. The first modifier has index 0.

Each modifier must have a name, and the names are unique. Therefore, it is safe to use the name as a unique identifier for a modifier. The names of some common modifiers are provided in the xkbcommon/xkbcommon-names.h header file. Modifier names are case-sensitive.

### See also
[`xkb_keymap_num_mods`](@ref)()
"""
const xkb_mod_index_t = UInt32

"""
    xkb_keymap_num_mods(keymap)

Get the number of modifiers in the keymap.

### See also
[`xkb_mod_index_t`](@ref) xkb_keymap
"""
function xkb_keymap_num_mods(keymap)
    ccall((:xkb_keymap_num_mods, libxkb), xkb_mod_index_t, (Ptr{xkb_keymap},), keymap)
end

"""
    xkb_keymap_mod_get_name(keymap, idx)

Get the name of a modifier by index.

### Returns
The name. If the index is invalid, returns NULL.
### See also
[`xkb_mod_index_t`](@ref) xkb_keymap
"""
function xkb_keymap_mod_get_name(keymap, idx)
    ccall((:xkb_keymap_mod_get_name, libxkb), Ptr{Cchar}, (Ptr{xkb_keymap}, xkb_mod_index_t), keymap, idx)
end

"""
    xkb_keymap_mod_get_index(keymap, name)

Get the index of a modifier by name.

### Returns
The index. If no modifier with this name exists, returns [`XKB_MOD_INVALID`](@ref).
### See also
[`xkb_mod_index_t`](@ref) xkb_keymap
"""
function xkb_keymap_mod_get_index(keymap, name)
    ccall((:xkb_keymap_mod_get_index, libxkb), xkb_mod_index_t, (Ptr{xkb_keymap}, Ptr{Cchar}), keymap, name)
end

"""
` xkb_state`

Opaque keyboard state object.

State objects contain the active state of a keyboard (or keyboards), such as the currently effective layout and the active modifiers. It acts as a simple state machine, wherein key presses and releases are the input, and key symbols (keysyms) are the output.
"""
const xkb_state = Cvoid

"""
A number used to represent a physical key on a keyboard.

A standard PC-compatible keyboard might have 102 keys. An appropriate keymap would assign each of them a keycode, by which the user should refer to the key throughout the library.

Historically, the X11 protocol, and consequentially the XKB protocol, assign only 8 bits for keycodes. This limits the number of different keys that can be used simultaneously in a single keymap to 256 (disregarding other limitations). This library does not share this limit; keycodes beyond 255 ('extended keycodes') are not treated specially. Keymaps and applications which are compatible with X11 should not use these keycodes.

The values of specific keycodes are determined by the keymap and the underlying input system. For example, with an X11-compatible keymap and Linux evdev scan codes (see linux/input.h), a fixed offset is used:

The keymap defines a canonical name for each key, plus possible aliases. Historically, the XKB protocol restricts these names to at most 4 (ASCII) characters, but this library does not share this limit.

```c++
 xkb_keycode_t keycode_A = KEY_A + 8;
```

### See also
[`xkb_keycode_is_legal_ext`](@ref)() [`xkb_keycode_is_legal_x11`](@ref)()
"""
const xkb_keycode_t = UInt32

"""
    xkb_state_mod_index_is_consumed(state, key, idx)

Same as [`xkb_state_mod_index_is_consumed2`](@ref)() with mode XKB\\_CONSUMED\\_MOD\\_XKB.

xkb_state

\\since 0.4.1
"""
function xkb_state_mod_index_is_consumed(state, key, idx)
    ccall((:xkb_state_mod_index_is_consumed, libxkb), Cint, (Ptr{xkb_state}, xkb_keycode_t, xkb_mod_index_t), state, key, idx)
end

"""
A mask of modifier indices.
"""
const xkb_mod_mask_t = UInt32

"""
    xkb_state_mod_mask_remove_consumed(state, key, mask)

Remove consumed modifiers from a modifier mask for a key.

\\deprecated Use [`xkb_state_key_get_consumed_mods2`](@ref)() instead.

Takes the given modifier mask, and removes all modifiers which are consumed for that particular key (as in [`xkb_state_mod_index_is_consumed`](@ref)()).

### See also
[`xkb_state_mod_index_is_consumed`](@ref)() xkb_state
"""
function xkb_state_mod_mask_remove_consumed(state, key, mask)
    ccall((:xkb_state_mod_mask_remove_consumed, libxkb), xkb_mod_mask_t, (Ptr{xkb_state}, xkb_keycode_t, xkb_mod_mask_t), state, key, mask)
end

"""
    xkb_keymap_num_layouts(keymap)

Get the number of layouts in the keymap.

### See also
[`xkb_layout_index_t`](@ref) [`xkb_rule_names`](@ref) [`xkb_keymap_num_layouts_for_key`](@ref)() xkb_keymap
"""
function xkb_keymap_num_layouts(keymap)
    ccall((:xkb_keymap_num_layouts, libxkb), xkb_layout_index_t, (Ptr{xkb_keymap},), keymap)
end

"""
    xkb_keymap_num_layouts_for_key(keymap, key)

Get the number of layouts for a specific key.

This number can be different from [`xkb_keymap_num_layouts`](@ref)(), but is always smaller. It is the appropriate value to use when iterating over the layouts of a key.

### See also
[`xkb_layout_index_t`](@ref) xkb_keymap
"""
function xkb_keymap_num_layouts_for_key(keymap, key)
    ccall((:xkb_keymap_num_layouts_for_key, libxkb), xkb_layout_index_t, (Ptr{xkb_keymap}, xkb_keycode_t), keymap, key)
end

"""
    xkb_keymap_layout_get_name(keymap, idx)

Get the name of a layout by index.

### Returns
The name. If the index is invalid, or the layout does not have a name, returns NULL.
### See also
[`xkb_layout_index_t`](@ref) For notes on layout names. xkb_keymap
"""
function xkb_keymap_layout_get_name(keymap, idx)
    ccall((:xkb_keymap_layout_get_name, libxkb), Ptr{Cchar}, (Ptr{xkb_keymap}, xkb_layout_index_t), keymap, idx)
end

"""
    xkb_keymap_layout_get_index(keymap, name)

Get the index of a layout by name.

### Returns
The index. If no layout exists with this name, returns [`XKB_LAYOUT_INVALID`](@ref). If more than one layout in the keymap has this name, returns the lowest index among them.
### See also
[`xkb_layout_index_t`](@ref) For notes on layout names. xkb_keymap
"""
function xkb_keymap_layout_get_index(keymap, name)
    ccall((:xkb_keymap_layout_get_index, libxkb), xkb_layout_index_t, (Ptr{xkb_keymap}, Ptr{Cchar}), keymap, name)
end

"""
Index of a keyboard LED.

LEDs are logical objects which may be *active* or *inactive*. They typically correspond to the lights on the keyboard. Their state is determined by the current keyboard state.

LED indices are non-consecutive. The first LED has index 0.

Each LED must have a name, and the names are unique. Therefore, it is safe to use the name as a unique identifier for a LED. The names of some common LEDs are provided in the xkbcommon/xkbcommon-names.h header file. LED names are case-sensitive.

!!! warning

    A given keymap may specify an exact index for a given LED. Therefore, LED indexing is not necessarily sequential, as opposed to modifiers and layouts. This means that when iterating over the LEDs in a keymap using e.g. [`xkb_keymap_num_leds`](@ref)(), some indices might be invalid. Given such an index, functions like [`xkb_keymap_led_get_name`](@ref)() will return NULL, and [`xkb_state_led_index_is_active`](@ref)() will return -1.

LEDs are also called "indicators" by XKB.

### See also
[`xkb_keymap_num_leds`](@ref)()
"""
const xkb_led_index_t = UInt32

"""
    xkb_keymap_num_leds(keymap)

Get the number of LEDs in the keymap.

!!! warning

    The range [ 0...[`xkb_keymap_num_leds`](@ref)() ) includes all of the LEDs in the keymap, but may also contain inactive LEDs. When iterating over this range, you need the handle this case when calling functions such as [`xkb_keymap_led_get_name`](@ref)() or [`xkb_state_led_index_is_active`](@ref)().

### See also
[`xkb_led_index_t`](@ref) xkb_keymap
"""
function xkb_keymap_num_leds(keymap)
    ccall((:xkb_keymap_num_leds, libxkb), xkb_led_index_t, (Ptr{xkb_keymap},), keymap)
end

"""
    xkb_keymap_led_get_name(keymap, idx)

Get the name of a LED by index.

xkb_keymap

### Returns
The name. If the index is invalid, returns NULL.
"""
function xkb_keymap_led_get_name(keymap, idx)
    ccall((:xkb_keymap_led_get_name, libxkb), Ptr{Cchar}, (Ptr{xkb_keymap}, xkb_led_index_t), keymap, idx)
end

"""
    xkb_keymap_led_get_index(keymap, name)

Get the index of a LED by name.

xkb_keymap

### Returns
The index. If no LED with this name exists, returns [`XKB_LED_INVALID`](@ref).
"""
function xkb_keymap_led_get_index(keymap, name)
    ccall((:xkb_keymap_led_get_index, libxkb), xkb_led_index_t, (Ptr{xkb_keymap}, Ptr{Cchar}), keymap, name)
end

"""
    xkb_keymap_key_repeats(keymap, key)

Determine whether a key should repeat or not.

A keymap may specify different repeat behaviors for different keys. Most keys should generally exhibit repeat behavior; for example, holding the 'a' key down in a text editor should normally insert a single 'a' character every few milliseconds, until the key is released. However, there are keys which should not or do not need to be repeated. For example, repeating modifier keys such as Left/Right Shift or Caps Lock is not generally useful or desired.

xkb_keymap

### Returns
1 if the key should repeat, 0 otherwise.
"""
function xkb_keymap_key_repeats(keymap, key)
    ccall((:xkb_keymap_key_repeats, libxkb), Cint, (Ptr{xkb_keymap}, xkb_keycode_t), keymap, key)
end

"""
A number used to represent the symbols generated from a key on a keyboard.

A key, represented by a keycode, may generate different symbols according to keyboard state. For example, on a QWERTY keyboard, pressing the key labled <A> generates the symbol 'a'. If the Shift key is held, it generates the symbol 'A'. If a different layout is used, say Greek, it generates the symbol 'α'. And so on.

Each such symbol is represented by a keysym. Note that keysyms are somewhat more general, in that they can also represent some "function", such as "Left" or "Right" for the arrow keys. For more information, see: https://www.x.org/releases/current/doc/xproto/x11protocol.html#keysym\\_encoding

Specifically named keysyms can be found in the xkbcommon/xkbcommon-keysyms.h header file. Their name does not include the XKB\\_KEY\\_ prefix.

Besides those, any Unicode/ISO 10646 character in the range U0100 to U10FFFF can be represented by a keysym value in the range 0x01000100 to 0x0110FFFF. The name of Unicode keysyms is "U<codepoint>", e.g. "UA1B2".

The name of other unnamed keysyms is the hexadecimal representation of their value, e.g. "0xabcd1234".

Keysym names are case-sensitive.
"""
const xkb_keysym_t = UInt32

"""
    xkb_state_key_get_syms(state, key, syms_out)

Get the keysyms obtained from pressing a particular key in a given keyboard state.

Get the keysyms for a key according to the current active layout, modifiers and shift level for the key, as determined by a keyboard state.

As an extension to XKB, this function can return more than one keysym. If you do not want to handle this case, you can use [`xkb_state_key_get_one_sym`](@ref)() for a simpler interface.

This function does not perform any keysym-transformations. (This might change).

xkb_state

### Parameters
* `state`:\\[in\\] The keyboard state object.
* `key`:\\[in\\] The keycode of the key.
* `syms_out`:\\[out\\] An immutable array of keysyms corresponding the key in the given keyboard state.
### Returns
The number of keysyms in the syms\\_out array. If no keysyms are produced by the key in the given keyboard state, returns 0 and sets syms\\_out to NULL.
"""
function xkb_state_key_get_syms(state, key, syms_out)
    ccall((:xkb_state_key_get_syms, libxkb), Cint, (Ptr{xkb_state}, xkb_keycode_t, Ptr{Ptr{xkb_keysym_t}}), state, key, syms_out)
end

"""
    xkb_state_component

Modifier and layout types for state objects. This enum is bitmaskable, e.g. (XKB\\_STATE\\_MODS\\_DEPRESSED | XKB\\_STATE\\_MODS\\_LATCHED) is valid to exclude locked modifiers.

In XKB, the DEPRESSED components are also known as 'base'.

| Enumerator                       | Note                                                                                                                                                                           |
| :------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| XKB\\_STATE\\_MODS\\_DEPRESSED   | Depressed modifiers, i.e. a key is physically holding them.                                                                                                                    |
| XKB\\_STATE\\_MODS\\_LATCHED     | Latched modifiers, i.e. will be unset after the next non-modifier key press.                                                                                                   |
| XKB\\_STATE\\_MODS\\_LOCKED      | Locked modifiers, i.e. will be unset after the key provoking the lock has been pressed again.                                                                                  |
| XKB\\_STATE\\_MODS\\_EFFECTIVE   | Effective modifiers, i.e. currently active and affect key processing (derived from the other state components). Use this unless you explicitly care how the state came about.  |
| XKB\\_STATE\\_LAYOUT\\_DEPRESSED | Depressed layout, i.e. a key is physically holding it.                                                                                                                         |
| XKB\\_STATE\\_LAYOUT\\_LATCHED   | Latched layout, i.e. will be unset after the next non-modifier key press.                                                                                                      |
| XKB\\_STATE\\_LAYOUT\\_LOCKED    | Locked layout, i.e. will be unset after the key provoking the lock has been pressed again.                                                                                     |
| XKB\\_STATE\\_LAYOUT\\_EFFECTIVE | Effective layout, i.e. currently active and affects key processing (derived from the other state components). Use this unless you explicitly care how the state came about.    |
| XKB\\_STATE\\_LEDS               | LEDs (derived from the other state components).                                                                                                                                |
"""
@bitmask xkb_state_component::UInt32 begin
    XKB_STATE_MODS_DEPRESSED = 1
    XKB_STATE_MODS_LATCHED = 2
    XKB_STATE_MODS_LOCKED = 4
    XKB_STATE_MODS_EFFECTIVE = 8
    XKB_STATE_LAYOUT_DEPRESSED = 16
    XKB_STATE_LAYOUT_LATCHED = 32
    XKB_STATE_LAYOUT_LOCKED = 64
    XKB_STATE_LAYOUT_EFFECTIVE = 128
    XKB_STATE_LEDS = 256
end

"""
    xkb_state_layout_name_is_active(state, name, type)

Test whether a layout is active in a given keyboard state by name.

If multiple layouts in the keymap have this name, the one with the lowest index is tested.

### Returns
1 if the layout is active, 0 if it is not. If no layout with this name exists in the keymap, return -1.
### See also
[`xkb_layout_index_t`](@ref) xkb_state
"""
function xkb_state_layout_name_is_active(state, name, type)
    ccall((:xkb_state_layout_name_is_active, libxkb), Cint, (Ptr{xkb_state}, Ptr{Cchar}, xkb_state_component), state, name, type)
end

"""
    xkb_state_layout_index_is_active(state, idx, type)

Test whether a layout is active in a given keyboard state by index.

### Returns
1 if the layout is active, 0 if it is not. If the layout index is not valid in the keymap, returns -1.
### See also
[`xkb_layout_index_t`](@ref) xkb_state
"""
function xkb_state_layout_index_is_active(state, idx, type)
    ccall((:xkb_state_layout_index_is_active, libxkb), Cint, (Ptr{xkb_state}, xkb_layout_index_t, xkb_state_component), state, idx, type)
end

"""
    xkb_state_serialize_layout(state, components)

The counterpart to [`xkb_state_update_mask`](@ref) for layouts, to be used on the server side of serialization.

This function should not be used in regular clients; please use the xkb\\_state\\_layout\\_*\\_is\\_active API instead.

xkb_state

### Parameters
* `state`: The keyboard state.
* `components`: A mask of the layout state components to serialize. State components other than XKB\\_STATE\\_LAYOUT\\_* are ignored. If XKB\\_STATE\\_LAYOUT\\_EFFECTIVE is included, all other state components are ignored.
### Returns
A layout index representing the given components of the layout state.
"""
function xkb_state_serialize_layout(state, components)
    ccall((:xkb_state_serialize_layout, libxkb), xkb_layout_index_t, (Ptr{xkb_state}, xkb_state_component), state, components)
end

"""
    xkb_state_get_keymap(state)

Get the keymap which a keyboard state object is using.

This function does not take a new reference on the keymap; you must explicitly reference it yourself if you plan to use it beyond the lifetime of the state.

xkb_state

### Returns
The keymap which was passed to [`xkb_state_new`](@ref)() when creating this state object.
"""
function xkb_state_get_keymap(state)
    ccall((:xkb_state_get_keymap, libxkb), Ptr{xkb_keymap}, (Ptr{xkb_state},), state)
end

"""
Index of a shift level.

Any key, in any layout, can have several <em>shift levels</em>. Each shift level can assign different keysyms to the key. The shift level to use is chosen according to the current keyboard state; for example, if no keys are pressed, the first level may be used; if the Left Shift key is pressed, the second; if Num Lock is pressed, the third; and many such combinations are possible (see [`xkb_mod_index_t`](@ref)).

Level indices are consecutive. The first level has index 0.
"""
const xkb_level_index_t = UInt32

"""
A mask of LED indices.
"""
const xkb_led_mask_t = UInt32

"""
    xkb_keysym_get_name(keysym, buffer, size)

Get the name of a keysym.

For a description of how keysyms are named, see xkb_keysym_t.

!!! warning

    If the buffer passed is too small, the string is truncated (though still NUL-terminated); a size of at least 64 bytes is recommended.

You may check if truncation has occurred by comparing the return value with the length of buffer, similarly to the snprintf(3) function.

### Parameters
* `keysym`:\\[in\\] The keysym.
* `buffer`:\\[out\\] A string buffer to write the name into.
* `size`:\\[in\\] Size of the buffer.
### Returns
The number of bytes in the name, excluding the NUL byte. If the keysym is invalid, returns -1.
### See also
[`xkb_keysym_t`](@ref)
"""
function xkb_keysym_get_name(keysym, buffer, size)
    ccall((:xkb_keysym_get_name, libxkb), Cint, (xkb_keysym_t, Ptr{Cchar}, Csize_t), keysym, buffer, size)
end

"""
    xkb_keysym_flags

Flags for [`xkb_keysym_from_name`](@ref)().

| Enumerator                        | Note                                     |
| :-------------------------------- | :--------------------------------------- |
| XKB\\_KEYSYM\\_NO\\_FLAGS         | Do not apply any flags.                  |
| XKB\\_KEYSYM\\_CASE\\_INSENSITIVE | Find keysym by case-insensitive search.  |
"""
@enum xkb_keysym_flags::UInt32 begin
    XKB_KEYSYM_NO_FLAGS = 0
    XKB_KEYSYM_CASE_INSENSITIVE = 1
end

"""
    xkb_keysym_from_name(name, flags)

Get a keysym from its name.

If you use the XKB\\_KEYSYM\\_CASE\\_INSENSITIVE flag and two keysym names differ only by case, then the lower-case keysym is returned. For instance, for KEY\\_a and KEY\\_A, this function would return KEY\\_a for the case-insensitive search. If this functionality is needed, it is recommended to first call this function without this flag; and if that fails, only then to try with this flag, while possibly warning the user he had misspelled the name, and might get wrong results.

Case folding is done according to the C locale; the current locale is not consulted.

### Parameters
* `name`: The name of a keysym. See remarks in [`xkb_keysym_get_name`](@ref)(); this function will accept any name returned by that function.
* `flags`: A set of flags controlling how the search is done. If invalid flags are passed, this will fail with [`XKB_KEY_NoSymbol`](@ref).
### Returns
The keysym. If the name is invalid, returns [`XKB_KEY_NoSymbol`](@ref).
### See also
[`xkb_keysym_t`](@ref)
"""
function xkb_keysym_from_name(name, flags)
    ccall((:xkb_keysym_from_name, libxkb), xkb_keysym_t, (Ptr{Cchar}, xkb_keysym_flags), name, flags)
end

"""
    xkb_keysym_to_utf8(keysym, buffer, size)

Get the Unicode/UTF-8 representation of a keysym.

This function does not perform any keysym-transformations. Therefore, prefer to use [`xkb_state_key_get_utf8`](@ref)() if possible.

### Parameters
* `keysym`:\\[in\\] The keysym.
* `buffer`:\\[out\\] A buffer to write the UTF-8 string into.
* `size`:\\[in\\] The size of buffer. Must be at least 7.
### Returns
The number of bytes written to the buffer (including the terminating byte). If the keysym does not have a Unicode representation, returns 0. If the buffer is too small, returns -1.
### See also
[`xkb_state_key_get_utf8`](@ref)()
"""
function xkb_keysym_to_utf8(keysym, buffer, size)
    ccall((:xkb_keysym_to_utf8, libxkb), Cint, (xkb_keysym_t, Ptr{Cchar}, Csize_t), keysym, buffer, size)
end

"""
    xkb_keysym_to_utf32(keysym)

Get the Unicode/UTF-32 representation of a keysym.

This function does not perform any keysym-transformations. Therefore, prefer to use [`xkb_state_key_get_utf32`](@ref)() if possible.

### Returns
The Unicode/UTF-32 representation of keysym, which is also compatible with UCS-4. If the keysym does not have a Unicode representation, returns 0.
### See also
[`xkb_state_key_get_utf32`](@ref)()
"""
function xkb_keysym_to_utf32(keysym)
    ccall((:xkb_keysym_to_utf32, libxkb), UInt32, (xkb_keysym_t,), keysym)
end

"""
    xkb_utf32_to_keysym(ucs)

Get the keysym corresponding to a Unicode/UTF-32 codepoint.

This function is the inverse of xkb_keysym_to_utf32. In cases where a single codepoint corresponds to multiple keysyms, returns the keysym with the lowest value.

Unicode codepoints which do not have a special (legacy) keysym encoding use a direct encoding scheme. These keysyms don't usually have an associated keysym constant (XKB\\_KEY\\_*).

For noncharacter Unicode codepoints and codepoints outside of the defined Unicode planes this function returns [`XKB_KEY_NoSymbol`](@ref).

\\since 1.0.0

### Returns
The keysym corresponding to the specified Unicode codepoint, or [`XKB_KEY_NoSymbol`](@ref) if there is none.
### See also
[`xkb_keysym_to_utf32`](@ref)()
"""
function xkb_utf32_to_keysym(ucs)
    ccall((:xkb_utf32_to_keysym, libxkb), xkb_keysym_t, (UInt32,), ucs)
end

"""
    xkb_keysym_to_upper(ks)

Convert a keysym to its uppercase form.

If there is no such form, the keysym is returned unchanged.

The conversion rules may be incomplete; prefer to work with the Unicode representation instead, when possible.
"""
function xkb_keysym_to_upper(ks)
    ccall((:xkb_keysym_to_upper, libxkb), xkb_keysym_t, (xkb_keysym_t,), ks)
end

"""
    xkb_keysym_to_lower(ks)

Convert a keysym to its lowercase form.

The conversion rules may be incomplete; prefer to work with the Unicode representation instead, when possible.
"""
function xkb_keysym_to_lower(ks)
    ccall((:xkb_keysym_to_lower, libxkb), xkb_keysym_t, (xkb_keysym_t,), ks)
end

"""
    xkb_context_flags

Flags for context creation.

| Enumerator                               | Note                                                         |
| :--------------------------------------- | :----------------------------------------------------------- |
| XKB\\_CONTEXT\\_NO\\_FLAGS               | Do not apply any context flags.                              |
| XKB\\_CONTEXT\\_NO\\_DEFAULT\\_INCLUDES  | Create this context with an empty include path.              |
| XKB\\_CONTEXT\\_NO\\_ENVIRONMENT\\_NAMES | Don't take RMLVO names from the environment.  \\since 0.3.0  |
"""
@enum xkb_context_flags::UInt32 begin
    XKB_CONTEXT_NO_FLAGS = 0
    XKB_CONTEXT_NO_DEFAULT_INCLUDES = 1
    XKB_CONTEXT_NO_ENVIRONMENT_NAMES = 2
end

"""
    xkb_context_new(flags)

Create a new context.

xkb_context

### Parameters
* `flags`: Optional flags for the context, or 0.
### Returns
A new context, or NULL on failure.
"""
function xkb_context_new(flags)
    ccall((:xkb_context_new, libxkb), Ptr{xkb_context}, (xkb_context_flags,), flags)
end

"""
    xkb_context_ref(context)

Take a new reference on a context.

xkb_context

### Returns
The passed in context.
"""
function xkb_context_ref(context)
    ccall((:xkb_context_ref, libxkb), Ptr{xkb_context}, (Ptr{xkb_context},), context)
end

"""
    xkb_context_unref(context)

Release a reference on a context, and possibly free it.

xkb_context

### Parameters
* `context`: The context. If it is NULL, this function does nothing.
"""
function xkb_context_unref(context)
    ccall((:xkb_context_unref, libxkb), Cvoid, (Ptr{xkb_context},), context)
end

"""
    xkb_context_set_user_data(context, user_data)

Store custom user data in the context.

This may be useful in conjunction with [`xkb_context_set_log_fn`](@ref)() or other callbacks.

xkb_context
"""
function xkb_context_set_user_data(context, user_data)
    ccall((:xkb_context_set_user_data, libxkb), Cvoid, (Ptr{xkb_context}, Ptr{Cvoid}), context, user_data)
end

"""
    xkb_context_get_user_data(context)

Retrieves stored user data from the context.

This may be useful to access private user data from callbacks like a custom logging function.

xkb_context

### Returns
The stored user data. If the user data wasn't set, or the passed in context is NULL, returns NULL.
"""
function xkb_context_get_user_data(context)
    ccall((:xkb_context_get_user_data, libxkb), Ptr{Cvoid}, (Ptr{xkb_context},), context)
end

"""
    xkb_context_include_path_append(context, path)

Append a new entry to the context's include path.

xkb_context

### Returns
1 on success, or 0 if the include path could not be added or is inaccessible.
"""
function xkb_context_include_path_append(context, path)
    ccall((:xkb_context_include_path_append, libxkb), Cint, (Ptr{xkb_context}, Ptr{Cchar}), context, path)
end

"""
    xkb_context_include_path_append_default(context)

Append the default include paths to the context's include path.

xkb_context

### Returns
1 on success, or 0 if the primary include path could not be added.
"""
function xkb_context_include_path_append_default(context)
    ccall((:xkb_context_include_path_append_default, libxkb), Cint, (Ptr{xkb_context},), context)
end

"""
    xkb_context_include_path_reset_defaults(context)

Reset the context's include path to the default.

Removes all entries from the context's include path, and inserts the default paths.

xkb_context

### Returns
1 on success, or 0 if the primary include path could not be added.
"""
function xkb_context_include_path_reset_defaults(context)
    ccall((:xkb_context_include_path_reset_defaults, libxkb), Cint, (Ptr{xkb_context},), context)
end

"""
    xkb_context_include_path_clear(context)

Remove all entries from the context's include path.

xkb_context
"""
function xkb_context_include_path_clear(context)
    ccall((:xkb_context_include_path_clear, libxkb), Cvoid, (Ptr{xkb_context},), context)
end

"""
    xkb_context_num_include_paths(context)

Get the number of paths in the context's include path.

xkb_context
"""
function xkb_context_num_include_paths(context)
    ccall((:xkb_context_num_include_paths, libxkb), Cuint, (Ptr{xkb_context},), context)
end

"""
    xkb_context_include_path_get(context, index)

Get a specific include path from the context's include path.

xkb_context

### Returns
The include path at the specified index. If the index is invalid, returns NULL.
"""
function xkb_context_include_path_get(context, index)
    ccall((:xkb_context_include_path_get, libxkb), Ptr{Cchar}, (Ptr{xkb_context}, Cuint), context, index)
end

"""
    xkb_log_level

Specifies a logging level.

| Enumerator                   | Note                                    |
| :--------------------------- | :-------------------------------------- |
| XKB\\_LOG\\_LEVEL\\_CRITICAL | Log critical internal errors only.      |
| XKB\\_LOG\\_LEVEL\\_ERROR    | Log all errors.                         |
| XKB\\_LOG\\_LEVEL\\_WARNING  | Log warnings and errors.                |
| XKB\\_LOG\\_LEVEL\\_INFO     | Log information, warnings, and errors.  |
| XKB\\_LOG\\_LEVEL\\_DEBUG    | Log everything.                         |
"""
@enum xkb_log_level::UInt32 begin
    XKB_LOG_LEVEL_CRITICAL = 10
    XKB_LOG_LEVEL_ERROR = 20
    XKB_LOG_LEVEL_WARNING = 30
    XKB_LOG_LEVEL_INFO = 40
    XKB_LOG_LEVEL_DEBUG = 50
end

"""
    xkb_context_set_log_level(context, level)

Set the current logging level.

The default level is XKB\\_LOG\\_LEVEL\\_ERROR. The environment variable XKB\\_LOG\\_LEVEL, if set in the time the context was created, overrides the default value. It may be specified as a level number or name.

xkb_context

### Parameters
* `context`: The context in which to set the logging level.
* `level`: The logging level to use. Only messages from this level and below will be logged.
"""
function xkb_context_set_log_level(context, level)
    ccall((:xkb_context_set_log_level, libxkb), Cvoid, (Ptr{xkb_context}, xkb_log_level), context, level)
end

"""
    xkb_context_get_log_level(context)

Get the current logging level.

xkb_context
"""
function xkb_context_get_log_level(context)
    ccall((:xkb_context_get_log_level, libxkb), xkb_log_level, (Ptr{xkb_context},), context)
end

"""
    xkb_context_set_log_verbosity(context, verbosity)

Sets the current logging verbosity.

The library can generate a number of warnings which are not helpful to ordinary users of the library. The verbosity may be increased if more information is desired (e.g. when developing a new keymap).

The default verbosity is 0. The environment variable XKB\\_LOG\\_VERBOSITY, if set in the time the context was created, overrides the default value.

Most verbose messages are of level XKB\\_LOG\\_LEVEL\\_WARNING or lower.

xkb_context

### Parameters
* `context`: The context in which to use the set verbosity.
* `verbosity`: The verbosity to use. Currently used values are 1 to 10, higher values being more verbose. 0 would result in no verbose messages being logged.
"""
function xkb_context_set_log_verbosity(context, verbosity)
    ccall((:xkb_context_set_log_verbosity, libxkb), Cvoid, (Ptr{xkb_context}, Cint), context, verbosity)
end

"""
    xkb_context_get_log_verbosity(context)

Get the current logging verbosity of the context.

xkb_context
"""
function xkb_context_get_log_verbosity(context)
    ccall((:xkb_context_get_log_verbosity, libxkb), Cint, (Ptr{xkb_context},), context)
end

"""
    xkb_context_set_log_fn(context, log_fn)

Set a custom function to handle logging messages.

By default, log messages from this library are printed to stderr. This function allows you to replace the default behavior with a custom handler. The handler is only called with messages which match the current logging level and verbosity settings for the context. level is the logging level of the message. *format* and *args* are the same as in the vprintf(3) function.

You may use [`xkb_context_set_user_data`](@ref)() on the context, and then call [`xkb_context_get_user_data`](@ref)() from within the logging function to provide it with additional private context.

xkb_context

### Parameters
* `context`: The context in which to use the set logging function.
* `log_fn`: The function that will be called for logging messages. Passing NULL restores the default function, which logs to stderr.
"""
function xkb_context_set_log_fn(context, log_fn)
    ccall((:xkb_context_set_log_fn, libxkb), Cvoid, (Ptr{xkb_context}, Ptr{Cvoid}), context, log_fn)
end

"""
    xkb_keymap_new_from_buffer(context, buffer, length, format, flags)

Create a keymap from a memory buffer.

This is just like [`xkb_keymap_new_from_string`](@ref)(), but takes a length argument so the input string does not have to be zero-terminated.

\\since 0.3.0

### See also
[`xkb_keymap_new_from_string`](@ref)() xkb_keymap
"""
function xkb_keymap_new_from_buffer(context, buffer, length, format, flags)
    ccall((:xkb_keymap_new_from_buffer, libxkb), Ptr{xkb_keymap}, (Ptr{xkb_context}, Ptr{Cchar}, Csize_t, xkb_keymap_format, xkb_keymap_compile_flags), context, buffer, length, format, flags)
end

"""
    xkb_keymap_min_keycode(keymap)

Get the minimum keycode in the keymap.

\\since 0.3.1

### See also
[`xkb_keycode_t`](@ref) xkb_keymap
"""
function xkb_keymap_min_keycode(keymap)
    ccall((:xkb_keymap_min_keycode, libxkb), xkb_keycode_t, (Ptr{xkb_keymap},), keymap)
end

"""
    xkb_keymap_max_keycode(keymap)

Get the maximum keycode in the keymap.

\\since 0.3.1

### See also
[`xkb_keycode_t`](@ref) xkb_keymap
"""
function xkb_keymap_max_keycode(keymap)
    ccall((:xkb_keymap_max_keycode, libxkb), xkb_keycode_t, (Ptr{xkb_keymap},), keymap)
end

# typedef void ( * xkb_keymap_key_iter_t ) ( struct xkb_keymap * keymap , xkb_keycode_t key , void * data )
"""
The iterator used by [`xkb_keymap_key_for_each`](@ref)().

\\since 0.3.1

### See also
[`xkb_keymap_key_for_each`](@ref) xkb_keymap
"""
const xkb_keymap_key_iter_t = Ptr{Cvoid}

"""
    xkb_keymap_key_for_each(keymap, iter, data)

Run a specified function for every valid keycode in the keymap. If a keymap is sparse, this function may be called fewer than (max\\_keycode - min\\_keycode + 1) times.

\\since 0.3.1

### See also
[`xkb_keymap_min_keycode`](@ref)() [`xkb_keymap_max_keycode`](@ref)() [`xkb_keycode_t`](@ref) xkb_keymap
"""
function xkb_keymap_key_for_each(keymap, iter, data)
    ccall((:xkb_keymap_key_for_each, libxkb), Cvoid, (Ptr{xkb_keymap}, xkb_keymap_key_iter_t, Ptr{Cvoid}), keymap, iter, data)
end

"""
    xkb_keymap_key_get_name(keymap, key)

Find the name of the key with the given keycode.

This function always returns the canonical name of the key (see description in [`xkb_keycode_t`](@ref)).

\\since 0.6.0

### Returns
The key name. If no key with this keycode exists, returns NULL.
### See also
[`xkb_keycode_t`](@ref) xkb_keymap
"""
function xkb_keymap_key_get_name(keymap, key)
    ccall((:xkb_keymap_key_get_name, libxkb), Ptr{Cchar}, (Ptr{xkb_keymap}, xkb_keycode_t), keymap, key)
end

"""
    xkb_keymap_key_by_name(keymap, name)

Find the keycode of the key with the given name.

The name can be either a canonical name or an alias.

\\since 0.6.0

### Returns
The keycode. If no key with this name exists, returns [`XKB_KEYCODE_INVALID`](@ref).
### See also
[`xkb_keycode_t`](@ref) xkb_keymap
"""
function xkb_keymap_key_by_name(keymap, name)
    ccall((:xkb_keymap_key_by_name, libxkb), xkb_keycode_t, (Ptr{xkb_keymap}, Ptr{Cchar}), keymap, name)
end

"""
    xkb_keymap_num_levels_for_key(keymap, key, layout)

Get the number of shift levels for a specific key and layout.

If `layout` is out of range for this key (that is, larger or equal to the value returned by [`xkb_keymap_num_layouts_for_key`](@ref)()), it is brought back into range in a manner consistent with [`xkb_state_key_get_layout`](@ref)().

### See also
[`xkb_level_index_t`](@ref) xkb_keymap
"""
function xkb_keymap_num_levels_for_key(keymap, key, layout)
    ccall((:xkb_keymap_num_levels_for_key, libxkb), xkb_level_index_t, (Ptr{xkb_keymap}, xkb_keycode_t, xkb_layout_index_t), keymap, key, layout)
end

"""
    xkb_keymap_key_get_mods_for_level(keymap, key, layout, level, masks_out, masks_size)

Retrieves every possible modifier mask that produces the specified shift level for a specific key and layout.

This API is useful for inverse key transformation; i.e. finding out which modifiers need to be active in order to be able to type the keysym(s) corresponding to the specific key code, layout and level.

!!! warning

    It returns only up to masks\\_size modifier masks. If the buffer passed is too small, some of the possible modifier combinations will not be returned.

```c++
 xkb_keymap_num_levels_for_key(keymap, key) 
```

If `layout` is out of range for this key (that is, larger or equal to the value returned by [`xkb_keymap_num_layouts_for_key`](@ref)()), it is brought back into range in a manner consistent with [`xkb_state_key_get_layout`](@ref)().

\\since 1.0.0

### Parameters
* `keymap`:\\[in\\] The keymap.
* `key`:\\[in\\] The keycode of the key.
* `layout`:\\[in\\] The layout for which to get modifiers.
* `level`:\\[in\\] The shift level in the layout for which to get the modifiers. This should be smaller than:
* `masks_out`:\\[out\\] A buffer in which the requested masks should be stored.
* `masks_size`:\\[out\\] The number of elements in the buffer pointed to by masks\\_out.
### Returns
The number of modifier masks stored in the masks\\_out array. If the key is not in the keymap or if the specified shift level cannot be reached it returns 0 and does not modify the masks\\_out buffer.
### See also
[`xkb_level_index_t`](@ref), [`xkb_mod_mask_t`](@ref) xkb_keymap
"""
function xkb_keymap_key_get_mods_for_level(keymap, key, layout, level, masks_out, masks_size)
    ccall((:xkb_keymap_key_get_mods_for_level, libxkb), Csize_t, (Ptr{xkb_keymap}, xkb_keycode_t, xkb_layout_index_t, xkb_level_index_t, Ptr{xkb_mod_mask_t}, Csize_t), keymap, key, layout, level, masks_out, masks_size)
end

"""
    xkb_keymap_key_get_syms_by_level(keymap, key, layout, level, syms_out)

Get the keysyms obtained from pressing a key in a given layout and shift level.

This function is like [`xkb_state_key_get_syms`](@ref)(), only the layout and shift level are not derived from the keyboard state but are instead specified explicitly.

```c++
 xkb_keymap_num_levels_for_key(keymap, key) 
```

If `layout` is out of range for this key (that is, larger or equal to the value returned by [`xkb_keymap_num_layouts_for_key`](@ref)()), it is brought back into range in a manner consistent with [`xkb_state_key_get_layout`](@ref)().

### Parameters
* `keymap`:\\[in\\] The keymap.
* `key`:\\[in\\] The keycode of the key.
* `layout`:\\[in\\] The layout for which to get the keysyms.
* `level`:\\[in\\] The shift level in the layout for which to get the keysyms. This should be smaller than:
* `syms_out`:\\[out\\] An immutable array of keysyms corresponding to the key in the given layout and shift level.
### Returns
The number of keysyms in the syms\\_out array. If no keysyms are produced by the key in the given layout and shift level, returns 0 and sets syms\\_out to NULL.
### See also
[`xkb_state_key_get_syms`](@ref)() xkb_keymap
"""
function xkb_keymap_key_get_syms_by_level(keymap, key, layout, level, syms_out)
    ccall((:xkb_keymap_key_get_syms_by_level, libxkb), Cint, (Ptr{xkb_keymap}, xkb_keycode_t, xkb_layout_index_t, xkb_level_index_t, Ptr{Ptr{xkb_keysym_t}}), keymap, key, layout, level, syms_out)
end

"""
    xkb_state_new(keymap)

Create a new keyboard state object.

xkb_state

### Parameters
* `keymap`: The keymap which the state will use.
### Returns
A new keyboard state object, or NULL on failure.
"""
function xkb_state_new(keymap)
    ccall((:xkb_state_new, libxkb), Ptr{xkb_state}, (Ptr{xkb_keymap},), keymap)
end

"""
    xkb_state_ref(state)

Take a new reference on a keyboard state object.

xkb_state

### Returns
The passed in object.
"""
function xkb_state_ref(state)
    ccall((:xkb_state_ref, libxkb), Ptr{xkb_state}, (Ptr{xkb_state},), state)
end

"""
    xkb_state_unref(state)

Release a reference on a keybaord state object, and possibly free it.

xkb_state

### Parameters
* `state`: The state. If it is NULL, this function does nothing.
"""
function xkb_state_unref(state)
    ccall((:xkb_state_unref, libxkb), Cvoid, (Ptr{xkb_state},), state)
end

"""
    xkb_key_direction

Specifies the direction of the key (press / release).

| Enumerator       | Note                   |
| :--------------- | :--------------------- |
| XKB\\_KEY\\_UP   | The key was released.  |
| XKB\\_KEY\\_DOWN | The key was pressed.   |
"""
@enum xkb_key_direction::UInt32 begin
    XKB_KEY_UP = 0
    XKB_KEY_DOWN = 1
end

"""
    xkb_state_update_key(state, key, direction)

Update the keyboard state to reflect a given key being pressed or released.

This entry point is intended for programs which track the keyboard state explicitly (like an evdev client). If the state is serialized to you by a master process (like a Wayland compositor) using functions like [`xkb_state_serialize_mods`](@ref)(), you should use [`xkb_state_update_mask`](@ref)() instead. The two functions should not generally be used together.

A series of calls to this function should be consistent; that is, a call with XKB\\_KEY\\_DOWN for a key should be matched by an XKB\\_KEY\\_UP; if a key is pressed twice, it should be released twice; etc. Otherwise (e.g. due to missed input events), situations like "stuck modifiers" may occur.

This function is often used in conjunction with the function [`xkb_state_key_get_syms`](@ref)() (or [`xkb_state_key_get_one_sym`](@ref)()), for example, when handling a key event. In this case, you should prefer to get the keysyms *before* updating the key, such that the keysyms reported for the key event are not affected by the event itself. This is the conventional behavior.

xkb_state

### Returns
A mask of state components that have changed as a result of the update. If nothing in the state has changed, returns 0.
### See also
[`xkb_state_update_mask`](@ref)()
"""
function xkb_state_update_key(state, key, direction)
    ccall((:xkb_state_update_key, libxkb), xkb_state_component, (Ptr{xkb_state}, xkb_keycode_t, xkb_key_direction), state, key, direction)
end

"""
    xkb_state_update_mask(state, depressed_mods, latched_mods, locked_mods, depressed_layout, latched_layout, locked_layout)

Update a keyboard state from a set of explicit masks.

This entry point is intended for window systems and the like, where a master process holds an [`xkb_state`](@ref), then serializes it over a wire protocol, and clients then use the serialization to feed in to their own [`xkb_state`](@ref).

All parameters must always be passed, or the resulting state may be incoherent.

The serialization is lossy and will not survive round trips; it must only be used to feed slave state objects, and must not be used to update the master state.

If you do not fit the description above, you should use [`xkb_state_update_key`](@ref)() instead. The two functions should not generally be used together.

xkb_state

### Returns
A mask of state components that have changed as a result of the update. If nothing in the state has changed, returns 0.
### See also
[`xkb_state_component`](@ref), [`xkb_state_update_key`](@ref)
"""
function xkb_state_update_mask(state, depressed_mods, latched_mods, locked_mods, depressed_layout, latched_layout, locked_layout)
    ccall((:xkb_state_update_mask, libxkb), xkb_state_component, (Ptr{xkb_state}, xkb_mod_mask_t, xkb_mod_mask_t, xkb_mod_mask_t, xkb_layout_index_t, xkb_layout_index_t, xkb_layout_index_t), state, depressed_mods, latched_mods, locked_mods, depressed_layout, latched_layout, locked_layout)
end

"""
    xkb_state_key_get_utf8(state, key, buffer, size)

Get the Unicode/UTF-8 string obtained from pressing a particular key in a given keyboard state.

!!! warning

    If the buffer passed is too small, the string is truncated (though still NUL-terminated).

You may check if truncation has occurred by comparing the return value with the size of `buffer`, similarly to the snprintf(3) function. You may safely pass NULL and 0 to `buffer` and `size` to find the required size (without the NUL-byte).

This function performs Capitalization and Control keysym-transformations.

xkb_state

\\since 0.4.1

### Parameters
* `state`:\\[in\\] The keyboard state object.
* `key`:\\[in\\] The keycode of the key.
* `buffer`:\\[out\\] A buffer to write the string into.
* `size`:\\[in\\] Size of the buffer.
### Returns
The number of bytes required for the string, excluding the NUL byte. If there is nothing to write, returns 0.
"""
function xkb_state_key_get_utf8(state, key, buffer, size)
    ccall((:xkb_state_key_get_utf8, libxkb), Cint, (Ptr{xkb_state}, xkb_keycode_t, Ptr{Cchar}, Csize_t), state, key, buffer, size)
end

"""
    xkb_state_key_get_utf32(state, key)

Get the Unicode/UTF-32 codepoint obtained from pressing a particular key in a a given keyboard state.

This function performs Capitalization and Control keysym-transformations.

xkb_state

\\since 0.4.1

### Returns
The UTF-32 representation for the key, if it consists of only a single codepoint. Otherwise, returns 0.
"""
function xkb_state_key_get_utf32(state, key)
    ccall((:xkb_state_key_get_utf32, libxkb), UInt32, (Ptr{xkb_state}, xkb_keycode_t), state, key)
end

"""
    xkb_state_key_get_one_sym(state, key)

Get the single keysym obtained from pressing a particular key in a given keyboard state.

This function is similar to [`xkb_state_key_get_syms`](@ref)(), but intended for users which cannot or do not want to handle the case where multiple keysyms are returned (in which case this function is preferred).

This function performs Capitalization keysym-transformations.

### Returns
The keysym. If the key does not have exactly one keysym, returns [`XKB_KEY_NoSymbol`](@ref)
### See also
[`xkb_state_key_get_syms`](@ref)() xkb_state
"""
function xkb_state_key_get_one_sym(state, key)
    ccall((:xkb_state_key_get_one_sym, libxkb), xkb_keysym_t, (Ptr{xkb_state}, xkb_keycode_t), state, key)
end

"""
    xkb_state_key_get_layout(state, key)

Get the effective layout index for a key in a given keyboard state.

\\invariant If the returned layout is valid, the following always holds:

```c++
 xkb_state_key_get_layout(state, key) < xkb_keymap_num_layouts_for_key(keymap, key)
```

xkb_state

### Returns
The layout index for the key in the given keyboard state. If the given keycode is invalid, or if the key is not included in any layout at all, returns [`XKB_LAYOUT_INVALID`](@ref).
"""
function xkb_state_key_get_layout(state, key)
    ccall((:xkb_state_key_get_layout, libxkb), xkb_layout_index_t, (Ptr{xkb_state}, xkb_keycode_t), state, key)
end

"""
    xkb_state_key_get_level(state, key, layout)

Get the effective shift level for a key in a given keyboard state and layout.

```c++
 xkb_keymap_num_layouts_for_key(keymap, key) 
```

usually it would be:

```c++
 xkb_state_key_get_layout(state, key) 
```

\\invariant If the returned level is valid, the following always holds:

```c++
 xkb_state_key_get_level(state, key, layout) < xkb_keymap_num_levels_for_key(keymap, key, layout)
```

xkb_state

### Parameters
* `state`: The keyboard state.
* `key`: The keycode of the key.
* `layout`: The layout for which to get the shift level. This must be smaller than:
### Returns
The shift level index. If the key or layout are invalid, returns [`XKB_LEVEL_INVALID`](@ref).
"""
function xkb_state_key_get_level(state, key, layout)
    ccall((:xkb_state_key_get_level, libxkb), xkb_level_index_t, (Ptr{xkb_state}, xkb_keycode_t, xkb_layout_index_t), state, key, layout)
end

"""
    xkb_state_match

Match flags for [`xkb_state_mod_indices_are_active`](@ref)() and [`xkb_state_mod_names_are_active`](@ref)(), specifying the conditions for a successful match. XKB\\_STATE\\_MATCH\\_NON\\_EXCLUSIVE is bitmaskable with the other modes.

| Enumerator                            | Note                                                                                                              |
| :------------------------------------ | :---------------------------------------------------------------------------------------------------------------- |
| XKB\\_STATE\\_MATCH\\_ANY             | Returns true if any of the modifiers are active.                                                                  |
| XKB\\_STATE\\_MATCH\\_ALL             | Returns true if all of the modifiers are active.                                                                  |
| XKB\\_STATE\\_MATCH\\_NON\\_EXCLUSIVE | Makes matching non-exclusive, i.e. will not return false if a modifier not specified in the arguments is active.  |
"""
@bitmask xkb_state_match::UInt32 begin
    XKB_STATE_MATCH_ANY = 1
    XKB_STATE_MATCH_ALL = 2
    XKB_STATE_MATCH_NON_EXCLUSIVE = 65536
end

"""
    xkb_state_serialize_mods(state, components)

The counterpart to [`xkb_state_update_mask`](@ref) for modifiers, to be used on the server side of serialization.

This function should not be used in regular clients; please use the xkb\\_state\\_mod\\_*\\_is\\_active API instead.

xkb_state

### Parameters
* `state`: The keyboard state.
* `components`: A mask of the modifier state components to serialize. State components other than XKB\\_STATE\\_MODS\\_* are ignored. If XKB\\_STATE\\_MODS\\_EFFECTIVE is included, all other state components are ignored.
### Returns
A [`xkb_mod_mask_t`](@ref) representing the given components of the modifier state.
"""
function xkb_state_serialize_mods(state, components)
    ccall((:xkb_state_serialize_mods, libxkb), xkb_mod_mask_t, (Ptr{xkb_state}, xkb_state_component), state, components)
end

"""
    xkb_state_mod_name_is_active(state, name, type)

Test whether a modifier is active in a given keyboard state by name.

xkb_state

### Returns
1 if the modifier is active, 0 if it is not. If the modifier name does not exist in the keymap, returns -1.
"""
function xkb_state_mod_name_is_active(state, name, type)
    ccall((:xkb_state_mod_name_is_active, libxkb), Cint, (Ptr{xkb_state}, Ptr{Cchar}, xkb_state_component), state, name, type)
end

"""
    xkb_state_mod_index_is_active(state, idx, type)

Test whether a modifier is active in a given keyboard state by index.

xkb_state

### Returns
1 if the modifier is active, 0 if it is not. If the modifier index is invalid in the keymap, returns -1.
"""
function xkb_state_mod_index_is_active(state, idx, type)
    ccall((:xkb_state_mod_index_is_active, libxkb), Cint, (Ptr{xkb_state}, xkb_mod_index_t, xkb_state_component), state, idx, type)
end

"""
    xkb_consumed_mode

Consumed modifiers mode.

There are several possible methods for deciding which modifiers are consumed and which are not, each applicable for different systems or situations. The mode selects the method to use.

Keep in mind that in all methods, the keymap may decide to "preserve" a modifier, meaning it is not reported as consumed even if it would have otherwise.

| Enumerator                  | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| :-------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| XKB\\_CONSUMED\\_MODE\\_XKB | This is the mode defined in the XKB specification and used by libX11.  A modifier is consumed if and only if it *may affect* key translation.  For example, if `Control+Alt+<Backspace>` produces some assigned keysym, then when pressing just `<Backspace>`, `Control` and `Alt` are consumed, even though they are not active, since if they *were* active they would have affected key translation.                                                                                                                                                                                      |
| XKB\\_CONSUMED\\_MODE\\_GTK | This is the mode used by the GTK+ toolkit.  The mode consists of the following two independent heuristics:  - The currently active set of modifiers, excluding modifiers which do not affect the key (as described for XKB_CONSUMED_MODE_XKB), are considered consumed, if the keysyms produced when all of them are active are different from the keysyms produced when no modifiers are active.  - A single modifier is considered consumed if the keysyms produced for the key when it is the only active modifier are different from the keysyms produced when no modifiers are active.  |
"""
@enum xkb_consumed_mode::UInt32 begin
    XKB_CONSUMED_MODE_XKB = 0
    XKB_CONSUMED_MODE_GTK = 1
end

"""
    xkb_state_key_get_consumed_mods2(state, key, mode)

Get the mask of modifiers consumed by translating a given key.

xkb_state

\\since 0.7.0

### Parameters
* `state`: The keyboard state.
* `key`: The keycode of the key.
* `mode`: The consumed modifiers mode to use; see enum description.
### Returns
a mask of the consumed modifiers.
"""
function xkb_state_key_get_consumed_mods2(state, key, mode)
    ccall((:xkb_state_key_get_consumed_mods2, libxkb), xkb_mod_mask_t, (Ptr{xkb_state}, xkb_keycode_t, xkb_consumed_mode), state, key, mode)
end

"""
    xkb_state_key_get_consumed_mods(state, key)

Same as [`xkb_state_key_get_consumed_mods2`](@ref)() with mode XKB\\_CONSUMED\\_MODE\\_XKB.

xkb_state

\\since 0.4.1
"""
function xkb_state_key_get_consumed_mods(state, key)
    ccall((:xkb_state_key_get_consumed_mods, libxkb), xkb_mod_mask_t, (Ptr{xkb_state}, xkb_keycode_t), state, key)
end

"""
    xkb_state_mod_index_is_consumed2(state, key, idx, mode)

Test whether a modifier is consumed by keyboard state translation for a key.

\\since 0.7.0

### Parameters
* `state`: The keyboard state.
* `key`: The keycode of the key.
* `idx`: The index of the modifier to check.
* `mode`: The consumed modifiers mode to use; see enum description.
### Returns
1 if the modifier is consumed, 0 if it is not. If the modifier index is not valid in the keymap, returns -1.
### See also
[`xkb_state_mod_mask_remove_consumed`](@ref)(), [`xkb_state_key_get_consumed_mods`](@ref)() xkb_state
"""
function xkb_state_mod_index_is_consumed2(state, key, idx, mode)
    ccall((:xkb_state_mod_index_is_consumed2, libxkb), Cint, (Ptr{xkb_state}, xkb_keycode_t, xkb_mod_index_t, xkb_consumed_mode), state, key, idx, mode)
end

"""
    xkb_state_led_name_is_active(state, name)

Test whether a LED is active in a given keyboard state by name.

### Returns
1 if the LED is active, 0 if it not. If no LED with this name exists in the keymap, returns -1.
### See also
[`xkb_led_index_t`](@ref) xkb_state
"""
function xkb_state_led_name_is_active(state, name)
    ccall((:xkb_state_led_name_is_active, libxkb), Cint, (Ptr{xkb_state}, Ptr{Cchar}), state, name)
end

"""
    xkb_state_led_index_is_active(state, idx)

Test whether a LED is active in a given keyboard state by index.

### Returns
1 if the LED is active, 0 if it not. If the LED index is not valid in the keymap, returns -1.
### See also
[`xkb_led_index_t`](@ref) xkb_state
"""
function xkb_state_led_index_is_active(state, idx)
    ccall((:xkb_state_led_index_is_active, libxkb), Cint, (Ptr{xkb_state}, xkb_led_index_t), state, idx)
end

"""
    xkb_x11_setup_xkb_extension_flags

Flags for the [`xkb_x11_setup_xkb_extension`](@ref)() function.

| Enumerator                                       | Note                     |
| :----------------------------------------------- | :----------------------- |
| XKB\\_X11\\_SETUP\\_XKB\\_EXTENSION\\_NO\\_FLAGS | Do not apply any flags.  |
"""
@bitmask xkb_x11_setup_xkb_extension_flags::UInt32 begin
    XKB_X11_SETUP_XKB_EXTENSION_NO_FLAGS = 0
end

function xkb_x11_setup_xkb_extension(connection, major_xkb_version, minor_xkb_version, flags, major_xkb_version_out, minor_xkb_version_out, base_event_out, base_error_out)
    ccall((:xkb_x11_setup_xkb_extension, libxkb), Cint, (Ptr{Cint}, UInt16, UInt16, xkb_x11_setup_xkb_extension_flags, Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt8}, Ptr{UInt8}), connection, major_xkb_version, minor_xkb_version, flags, major_xkb_version_out, minor_xkb_version_out, base_event_out, base_error_out)
end

function xkb_x11_get_core_keyboard_device_id(connection)
    ccall((:xkb_x11_get_core_keyboard_device_id, libxkb), Int32, (Ptr{Cint},), connection)
end

function xkb_x11_keymap_new_from_device(context, connection, device_id, flags)
    ccall((:xkb_x11_keymap_new_from_device, libxkb), Ptr{xkb_keymap}, (Ptr{xkb_context}, Ptr{Cint}, Int32, xkb_keymap_compile_flags), context, connection, device_id, flags)
end

function xkb_x11_state_new_from_device(keymap, connection, device_id)
    ccall((:xkb_x11_state_new_from_device, libxkb), Ptr{xkb_state}, (Ptr{xkb_keymap}, Ptr{Cint}, Int32), keymap, connection, device_id)
end

const XKB_MOD_NAME_SHIFT = "Shift"

const XKB_MOD_NAME_CAPS = "Lock"

const XKB_MOD_NAME_CTRL = "Control"

const XKB_MOD_NAME_ALT = "Mod1"

const XKB_MOD_NAME_NUM = "Mod2"

const XKB_MOD_NAME_LOGO = "Mod4"

const XKB_LED_NAME_CAPS = "Caps Lock"

const XKB_LED_NAME_NUM = "Num Lock"

const XKB_LED_NAME_SCROLL = "Scroll Lock"

const XKB_KEY_NoSymbol = 0x00000000

const XKB_KEY_VoidSymbol = 0x00ffffff

const XKB_KEY_BackSpace = 0xff08

const XKB_KEY_Tab = 0xff09

const XKB_KEY_Linefeed = 0xff0a

const XKB_KEY_Clear = 0xff0b

const XKB_KEY_Return = 0xff0d

const XKB_KEY_Pause = 0xff13

const XKB_KEY_Scroll_Lock = 0xff14

const XKB_KEY_Sys_Req = 0xff15

const XKB_KEY_Escape = 0xff1b

const XKB_KEY_Delete = 0xffff

const XKB_KEY_Multi_key = 0xff20

const XKB_KEY_Codeinput = 0xff37

const XKB_KEY_SingleCandidate = 0xff3c

const XKB_KEY_MultipleCandidate = 0xff3d

const XKB_KEY_PreviousCandidate = 0xff3e

const XKB_KEY_Kanji = 0xff21

const XKB_KEY_Muhenkan = 0xff22

const XKB_KEY_Henkan_Mode = 0xff23

const XKB_KEY_Henkan = 0xff23

const XKB_KEY_Romaji = 0xff24

const XKB_KEY_Hiragana = 0xff25

const XKB_KEY_Katakana = 0xff26

const XKB_KEY_Hiragana_Katakana = 0xff27

const XKB_KEY_Zenkaku = 0xff28

const XKB_KEY_Hankaku = 0xff29

const XKB_KEY_Zenkaku_Hankaku = 0xff2a

const XKB_KEY_Touroku = 0xff2b

const XKB_KEY_Massyo = 0xff2c

const XKB_KEY_Kana_Lock = 0xff2d

const XKB_KEY_Kana_Shift = 0xff2e

const XKB_KEY_Eisu_Shift = 0xff2f

const XKB_KEY_Eisu_toggle = 0xff30

const XKB_KEY_Kanji_Bangou = 0xff37

const XKB_KEY_Zen_Koho = 0xff3d

const XKB_KEY_Mae_Koho = 0xff3e

const XKB_KEY_Home = 0xff50

const XKB_KEY_Left = 0xff51

const XKB_KEY_Up = 0xff52

const XKB_KEY_Right = 0xff53

const XKB_KEY_Down = 0xff54

const XKB_KEY_Prior = 0xff55

const XKB_KEY_Page_Up = 0xff55

const XKB_KEY_Next = 0xff56

const XKB_KEY_Page_Down = 0xff56

const XKB_KEY_End = 0xff57

const XKB_KEY_Begin = 0xff58

const XKB_KEY_Select = 0xff60

const XKB_KEY_Print = 0xff61

const XKB_KEY_Execute = 0xff62

const XKB_KEY_Insert = 0xff63

const XKB_KEY_Undo = 0xff65

const XKB_KEY_Redo = 0xff66

const XKB_KEY_Menu = 0xff67

const XKB_KEY_Find = 0xff68

const XKB_KEY_Cancel = 0xff69

const XKB_KEY_Help = 0xff6a

const XKB_KEY_Break = 0xff6b

const XKB_KEY_Mode_switch = 0xff7e

const XKB_KEY_script_switch = 0xff7e

const XKB_KEY_Num_Lock = 0xff7f

const XKB_KEY_KP_Space = 0xff80

const XKB_KEY_KP_Tab = 0xff89

const XKB_KEY_KP_Enter = 0xff8d

const XKB_KEY_KP_F1 = 0xff91

const XKB_KEY_KP_F2 = 0xff92

const XKB_KEY_KP_F3 = 0xff93

const XKB_KEY_KP_F4 = 0xff94

const XKB_KEY_KP_Home = 0xff95

const XKB_KEY_KP_Left = 0xff96

const XKB_KEY_KP_Up = 0xff97

const XKB_KEY_KP_Right = 0xff98

const XKB_KEY_KP_Down = 0xff99

const XKB_KEY_KP_Prior = 0xff9a

const XKB_KEY_KP_Page_Up = 0xff9a

const XKB_KEY_KP_Next = 0xff9b

const XKB_KEY_KP_Page_Down = 0xff9b

const XKB_KEY_KP_End = 0xff9c

const XKB_KEY_KP_Begin = 0xff9d

const XKB_KEY_KP_Insert = 0xff9e

const XKB_KEY_KP_Delete = 0xff9f

const XKB_KEY_KP_Equal = 0xffbd

const XKB_KEY_KP_Multiply = 0xffaa

const XKB_KEY_KP_Add = 0xffab

const XKB_KEY_KP_Separator = 0xffac

const XKB_KEY_KP_Subtract = 0xffad

const XKB_KEY_KP_Decimal = 0xffae

const XKB_KEY_KP_Divide = 0xffaf

const XKB_KEY_KP_0 = 0xffb0

const XKB_KEY_KP_1 = 0xffb1

const XKB_KEY_KP_2 = 0xffb2

const XKB_KEY_KP_3 = 0xffb3

const XKB_KEY_KP_4 = 0xffb4

const XKB_KEY_KP_5 = 0xffb5

const XKB_KEY_KP_6 = 0xffb6

const XKB_KEY_KP_7 = 0xffb7

const XKB_KEY_KP_8 = 0xffb8

const XKB_KEY_KP_9 = 0xffb9

const XKB_KEY_F1 = 0xffbe

const XKB_KEY_F2 = 0xffbf

const XKB_KEY_F3 = 0xffc0

const XKB_KEY_F4 = 0xffc1

const XKB_KEY_F5 = 0xffc2

const XKB_KEY_F6 = 0xffc3

const XKB_KEY_F7 = 0xffc4

const XKB_KEY_F8 = 0xffc5

const XKB_KEY_F9 = 0xffc6

const XKB_KEY_F10 = 0xffc7

const XKB_KEY_F11 = 0xffc8

const XKB_KEY_L1 = 0xffc8

const XKB_KEY_F12 = 0xffc9

const XKB_KEY_L2 = 0xffc9

const XKB_KEY_F13 = 0xffca

const XKB_KEY_L3 = 0xffca

const XKB_KEY_F14 = 0xffcb

const XKB_KEY_L4 = 0xffcb

const XKB_KEY_F15 = 0xffcc

const XKB_KEY_L5 = 0xffcc

const XKB_KEY_F16 = 0xffcd

const XKB_KEY_L6 = 0xffcd

const XKB_KEY_F17 = 0xffce

const XKB_KEY_L7 = 0xffce

const XKB_KEY_F18 = 0xffcf

const XKB_KEY_L8 = 0xffcf

const XKB_KEY_F19 = 0xffd0

const XKB_KEY_L9 = 0xffd0

const XKB_KEY_F20 = 0xffd1

const XKB_KEY_L10 = 0xffd1

const XKB_KEY_F21 = 0xffd2

const XKB_KEY_R1 = 0xffd2

const XKB_KEY_F22 = 0xffd3

const XKB_KEY_R2 = 0xffd3

const XKB_KEY_F23 = 0xffd4

const XKB_KEY_R3 = 0xffd4

const XKB_KEY_F24 = 0xffd5

const XKB_KEY_R4 = 0xffd5

const XKB_KEY_F25 = 0xffd6

const XKB_KEY_R5 = 0xffd6

const XKB_KEY_F26 = 0xffd7

const XKB_KEY_R6 = 0xffd7

const XKB_KEY_F27 = 0xffd8

const XKB_KEY_R7 = 0xffd8

const XKB_KEY_F28 = 0xffd9

const XKB_KEY_R8 = 0xffd9

const XKB_KEY_F29 = 0xffda

const XKB_KEY_R9 = 0xffda

const XKB_KEY_F30 = 0xffdb

const XKB_KEY_R10 = 0xffdb

const XKB_KEY_F31 = 0xffdc

const XKB_KEY_R11 = 0xffdc

const XKB_KEY_F32 = 0xffdd

const XKB_KEY_R12 = 0xffdd

const XKB_KEY_F33 = 0xffde

const XKB_KEY_R13 = 0xffde

const XKB_KEY_F34 = 0xffdf

const XKB_KEY_R14 = 0xffdf

const XKB_KEY_F35 = 0xffe0

const XKB_KEY_R15 = 0xffe0

const XKB_KEY_Shift_L = 0xffe1

const XKB_KEY_Shift_R = 0xffe2

const XKB_KEY_Control_L = 0xffe3

const XKB_KEY_Control_R = 0xffe4

const XKB_KEY_Caps_Lock = 0xffe5

const XKB_KEY_Shift_Lock = 0xffe6

const XKB_KEY_Meta_L = 0xffe7

const XKB_KEY_Meta_R = 0xffe8

const XKB_KEY_Alt_L = 0xffe9

const XKB_KEY_Alt_R = 0xffea

const XKB_KEY_Super_L = 0xffeb

const XKB_KEY_Super_R = 0xffec

const XKB_KEY_Hyper_L = 0xffed

const XKB_KEY_Hyper_R = 0xffee

const XKB_KEY_ISO_Lock = 0xfe01

const XKB_KEY_ISO_Level2_Latch = 0xfe02

const XKB_KEY_ISO_Level3_Shift = 0xfe03

const XKB_KEY_ISO_Level3_Latch = 0xfe04

const XKB_KEY_ISO_Level3_Lock = 0xfe05

const XKB_KEY_ISO_Level5_Shift = 0xfe11

const XKB_KEY_ISO_Level5_Latch = 0xfe12

const XKB_KEY_ISO_Level5_Lock = 0xfe13

const XKB_KEY_ISO_Group_Shift = 0xff7e

const XKB_KEY_ISO_Group_Latch = 0xfe06

const XKB_KEY_ISO_Group_Lock = 0xfe07

const XKB_KEY_ISO_Next_Group = 0xfe08

const XKB_KEY_ISO_Next_Group_Lock = 0xfe09

const XKB_KEY_ISO_Prev_Group = 0xfe0a

const XKB_KEY_ISO_Prev_Group_Lock = 0xfe0b

const XKB_KEY_ISO_First_Group = 0xfe0c

const XKB_KEY_ISO_First_Group_Lock = 0xfe0d

const XKB_KEY_ISO_Last_Group = 0xfe0e

const XKB_KEY_ISO_Last_Group_Lock = 0xfe0f

const XKB_KEY_ISO_Left_Tab = 0xfe20

const XKB_KEY_ISO_Move_Line_Up = 0xfe21

const XKB_KEY_ISO_Move_Line_Down = 0xfe22

const XKB_KEY_ISO_Partial_Line_Up = 0xfe23

const XKB_KEY_ISO_Partial_Line_Down = 0xfe24

const XKB_KEY_ISO_Partial_Space_Left = 0xfe25

const XKB_KEY_ISO_Partial_Space_Right = 0xfe26

const XKB_KEY_ISO_Set_Margin_Left = 0xfe27

const XKB_KEY_ISO_Set_Margin_Right = 0xfe28

const XKB_KEY_ISO_Release_Margin_Left = 0xfe29

const XKB_KEY_ISO_Release_Margin_Right = 0xfe2a

const XKB_KEY_ISO_Release_Both_Margins = 0xfe2b

const XKB_KEY_ISO_Fast_Cursor_Left = 0xfe2c

const XKB_KEY_ISO_Fast_Cursor_Right = 0xfe2d

const XKB_KEY_ISO_Fast_Cursor_Up = 0xfe2e

const XKB_KEY_ISO_Fast_Cursor_Down = 0xfe2f

const XKB_KEY_ISO_Continuous_Underline = 0xfe30

const XKB_KEY_ISO_Discontinuous_Underline = 0xfe31

const XKB_KEY_ISO_Emphasize = 0xfe32

const XKB_KEY_ISO_Center_Object = 0xfe33

const XKB_KEY_ISO_Enter = 0xfe34

const XKB_KEY_dead_grave = 0xfe50

const XKB_KEY_dead_acute = 0xfe51

const XKB_KEY_dead_circumflex = 0xfe52

const XKB_KEY_dead_tilde = 0xfe53

const XKB_KEY_dead_perispomeni = 0xfe53

const XKB_KEY_dead_macron = 0xfe54

const XKB_KEY_dead_breve = 0xfe55

const XKB_KEY_dead_abovedot = 0xfe56

const XKB_KEY_dead_diaeresis = 0xfe57

const XKB_KEY_dead_abovering = 0xfe58

const XKB_KEY_dead_doubleacute = 0xfe59

const XKB_KEY_dead_caron = 0xfe5a

const XKB_KEY_dead_cedilla = 0xfe5b

const XKB_KEY_dead_ogonek = 0xfe5c

const XKB_KEY_dead_iota = 0xfe5d

const XKB_KEY_dead_voiced_sound = 0xfe5e

const XKB_KEY_dead_semivoiced_sound = 0xfe5f

const XKB_KEY_dead_belowdot = 0xfe60

const XKB_KEY_dead_hook = 0xfe61

const XKB_KEY_dead_horn = 0xfe62

const XKB_KEY_dead_stroke = 0xfe63

const XKB_KEY_dead_abovecomma = 0xfe64

const XKB_KEY_dead_psili = 0xfe64

const XKB_KEY_dead_abovereversedcomma = 0xfe65

const XKB_KEY_dead_dasia = 0xfe65

const XKB_KEY_dead_doublegrave = 0xfe66

const XKB_KEY_dead_belowring = 0xfe67

const XKB_KEY_dead_belowmacron = 0xfe68

const XKB_KEY_dead_belowcircumflex = 0xfe69

const XKB_KEY_dead_belowtilde = 0xfe6a

const XKB_KEY_dead_belowbreve = 0xfe6b

const XKB_KEY_dead_belowdiaeresis = 0xfe6c

const XKB_KEY_dead_invertedbreve = 0xfe6d

const XKB_KEY_dead_belowcomma = 0xfe6e

const XKB_KEY_dead_currency = 0xfe6f

const XKB_KEY_dead_lowline = 0xfe90

const XKB_KEY_dead_aboveverticalline = 0xfe91

const XKB_KEY_dead_belowverticalline = 0xfe92

const XKB_KEY_dead_longsolidusoverlay = 0xfe93

const XKB_KEY_dead_a = 0xfe80

const XKB_KEY_dead_A = 0xfe81

const XKB_KEY_dead_e = 0xfe82

const XKB_KEY_dead_E = 0xfe83

const XKB_KEY_dead_i = 0xfe84

const XKB_KEY_dead_I = 0xfe85

const XKB_KEY_dead_o = 0xfe86

const XKB_KEY_dead_O = 0xfe87

const XKB_KEY_dead_u = 0xfe88

const XKB_KEY_dead_U = 0xfe89

const XKB_KEY_dead_small_schwa = 0xfe8a

const XKB_KEY_dead_capital_schwa = 0xfe8b

const XKB_KEY_dead_greek = 0xfe8c

const XKB_KEY_First_Virtual_Screen = 0xfed0

const XKB_KEY_Prev_Virtual_Screen = 0xfed1

const XKB_KEY_Next_Virtual_Screen = 0xfed2

const XKB_KEY_Last_Virtual_Screen = 0xfed4

const XKB_KEY_Terminate_Server = 0xfed5

const XKB_KEY_AccessX_Enable = 0xfe70

const XKB_KEY_AccessX_Feedback_Enable = 0xfe71

const XKB_KEY_RepeatKeys_Enable = 0xfe72

const XKB_KEY_SlowKeys_Enable = 0xfe73

const XKB_KEY_BounceKeys_Enable = 0xfe74

const XKB_KEY_StickyKeys_Enable = 0xfe75

const XKB_KEY_MouseKeys_Enable = 0xfe76

const XKB_KEY_MouseKeys_Accel_Enable = 0xfe77

const XKB_KEY_Overlay1_Enable = 0xfe78

const XKB_KEY_Overlay2_Enable = 0xfe79

const XKB_KEY_AudibleBell_Enable = 0xfe7a

const XKB_KEY_Pointer_Left = 0xfee0

const XKB_KEY_Pointer_Right = 0xfee1

const XKB_KEY_Pointer_Up = 0xfee2

const XKB_KEY_Pointer_Down = 0xfee3

const XKB_KEY_Pointer_UpLeft = 0xfee4

const XKB_KEY_Pointer_UpRight = 0xfee5

const XKB_KEY_Pointer_DownLeft = 0xfee6

const XKB_KEY_Pointer_DownRight = 0xfee7

const XKB_KEY_Pointer_Button_Dflt = 0xfee8

const XKB_KEY_Pointer_Button1 = 0xfee9

const XKB_KEY_Pointer_Button2 = 0xfeea

const XKB_KEY_Pointer_Button3 = 0xfeeb

const XKB_KEY_Pointer_Button4 = 0xfeec

const XKB_KEY_Pointer_Button5 = 0xfeed

const XKB_KEY_Pointer_DblClick_Dflt = 0xfeee

const XKB_KEY_Pointer_DblClick1 = 0xfeef

const XKB_KEY_Pointer_DblClick2 = 0xfef0

const XKB_KEY_Pointer_DblClick3 = 0xfef1

const XKB_KEY_Pointer_DblClick4 = 0xfef2

const XKB_KEY_Pointer_DblClick5 = 0xfef3

const XKB_KEY_Pointer_Drag_Dflt = 0xfef4

const XKB_KEY_Pointer_Drag1 = 0xfef5

const XKB_KEY_Pointer_Drag2 = 0xfef6

const XKB_KEY_Pointer_Drag3 = 0xfef7

const XKB_KEY_Pointer_Drag4 = 0xfef8

const XKB_KEY_Pointer_Drag5 = 0xfefd

const XKB_KEY_Pointer_EnableKeys = 0xfef9

const XKB_KEY_Pointer_Accelerate = 0xfefa

const XKB_KEY_Pointer_DfltBtnNext = 0xfefb

const XKB_KEY_Pointer_DfltBtnPrev = 0xfefc

const XKB_KEY_ch = 0xfea0

const XKB_KEY_Ch = 0xfea1

const XKB_KEY_CH = 0xfea2

const XKB_KEY_c_h = 0xfea3

const XKB_KEY_C_h = 0xfea4

const XKB_KEY_3270_Duplicate = 0xfd01

const XKB_KEY_3270_FieldMark = 0xfd02

const XKB_KEY_3270_Right2 = 0xfd03

const XKB_KEY_3270_Left2 = 0xfd04

const XKB_KEY_3270_BackTab = 0xfd05

const XKB_KEY_3270_EraseEOF = 0xfd06

const XKB_KEY_3270_EraseInput = 0xfd07

const XKB_KEY_3270_Reset = 0xfd08

const XKB_KEY_3270_Quit = 0xfd09

const XKB_KEY_3270_PA1 = 0xfd0a

const XKB_KEY_3270_PA2 = 0xfd0b

const XKB_KEY_3270_PA3 = 0xfd0c

const XKB_KEY_3270_Test = 0xfd0d

const XKB_KEY_3270_Attn = 0xfd0e

const XKB_KEY_3270_CursorBlink = 0xfd0f

const XKB_KEY_3270_AltCursor = 0xfd10

const XKB_KEY_3270_KeyClick = 0xfd11

const XKB_KEY_3270_Jump = 0xfd12

const XKB_KEY_3270_Ident = 0xfd13

const XKB_KEY_3270_Rule = 0xfd14

const XKB_KEY_3270_Copy = 0xfd15

const XKB_KEY_3270_Play = 0xfd16

const XKB_KEY_3270_Setup = 0xfd17

const XKB_KEY_3270_Record = 0xfd18

const XKB_KEY_3270_ChangeScreen = 0xfd19

const XKB_KEY_3270_DeleteWord = 0xfd1a

const XKB_KEY_3270_ExSelect = 0xfd1b

const XKB_KEY_3270_CursorSelect = 0xfd1c

const XKB_KEY_3270_PrintScreen = 0xfd1d

const XKB_KEY_3270_Enter = 0xfd1e

const XKB_KEY_space = 0x0020

const XKB_KEY_exclam = 0x0021

const XKB_KEY_quotedbl = 0x0022

const XKB_KEY_numbersign = 0x0023

const XKB_KEY_dollar = 0x0024

const XKB_KEY_percent = 0x0025

const XKB_KEY_ampersand = 0x0026

const XKB_KEY_apostrophe = 0x0027

const XKB_KEY_quoteright = 0x0027

const XKB_KEY_parenleft = 0x0028

const XKB_KEY_parenright = 0x0029

const XKB_KEY_asterisk = 0x002a

const XKB_KEY_plus = 0x002b

const XKB_KEY_comma = 0x002c

const XKB_KEY_minus = 0x002d

const XKB_KEY_period = 0x002e

const XKB_KEY_slash = 0x002f

const XKB_KEY_0 = 0x0030

const XKB_KEY_1 = 0x0031

const XKB_KEY_2 = 0x0032

const XKB_KEY_3 = 0x0033

const XKB_KEY_4 = 0x0034

const XKB_KEY_5 = 0x0035

const XKB_KEY_6 = 0x0036

const XKB_KEY_7 = 0x0037

const XKB_KEY_8 = 0x0038

const XKB_KEY_9 = 0x0039

const XKB_KEY_colon = 0x003a

const XKB_KEY_semicolon = 0x003b

const XKB_KEY_less = 0x003c

const XKB_KEY_equal = 0x003d

const XKB_KEY_greater = 0x003e

const XKB_KEY_question = 0x003f

const XKB_KEY_at = 0x0040

const XKB_KEY_A = 0x0041

const XKB_KEY_B = 0x0042

const XKB_KEY_C = 0x0043

const XKB_KEY_D = 0x0044

const XKB_KEY_E = 0x0045

const XKB_KEY_F = 0x0046

const XKB_KEY_G = 0x0047

const XKB_KEY_I = 0x0049

const XKB_KEY_J = 0x004a

const XKB_KEY_K = 0x004b

const XKB_KEY_L = 0x004c

const XKB_KEY_M = 0x004d

const XKB_KEY_N = 0x004e

const XKB_KEY_O = 0x004f

const XKB_KEY_P = 0x0050

const XKB_KEY_Q = 0x0051

const XKB_KEY_R = 0x0052

const XKB_KEY_S = 0x0053

const XKB_KEY_T = 0x0054

const XKB_KEY_U = 0x0055

const XKB_KEY_V = 0x0056

const XKB_KEY_W = 0x0057

const XKB_KEY_X = 0x0058

const XKB_KEY_Y = 0x0059

const XKB_KEY_Z = 0x005a

const XKB_KEY_bracketleft = 0x005b

const XKB_KEY_backslash = 0x005c

const XKB_KEY_bracketright = 0x005d

const XKB_KEY_asciicircum = 0x005e

const XKB_KEY_underscore = 0x005f

const XKB_KEY_grave = 0x0060

const XKB_KEY_quoteleft = 0x0060

const XKB_KEY_a = 0x0061

const XKB_KEY_b = 0x0062

const XKB_KEY_c = 0x0063

const XKB_KEY_d = 0x0064

const XKB_KEY_e = 0x0065

const XKB_KEY_f = 0x0066

const XKB_KEY_g = 0x0067

const XKB_KEY_h = 0x0068

const XKB_KEY_i = 0x0069

const XKB_KEY_j = 0x006a

const XKB_KEY_k = 0x006b

const XKB_KEY_l = 0x006c

const XKB_KEY_m = 0x006d

const XKB_KEY_n = 0x006e

const XKB_KEY_o = 0x006f

const XKB_KEY_p = 0x0070

const XKB_KEY_q = 0x0071

const XKB_KEY_r = 0x0072

const XKB_KEY_s = 0x0073

const XKB_KEY_t = 0x0074

const XKB_KEY_u = 0x0075

const XKB_KEY_v = 0x0076

const XKB_KEY_w = 0x0077

const XKB_KEY_x = 0x0078

const XKB_KEY_y = 0x0079

const XKB_KEY_z = 0x007a

const XKB_KEY_braceleft = 0x007b

const XKB_KEY_bar = 0x007c

const XKB_KEY_braceright = 0x007d

const XKB_KEY_asciitilde = 0x007e

const XKB_KEY_nobreakspace = 0x00a0

const XKB_KEY_exclamdown = 0x00a1

const XKB_KEY_cent = 0x00a2

const XKB_KEY_sterling = 0x00a3

const XKB_KEY_currency = 0x00a4

const XKB_KEY_yen = 0x00a5

const XKB_KEY_brokenbar = 0x00a6

const XKB_KEY_section = 0x00a7

const XKB_KEY_diaeresis = 0x00a8

const XKB_KEY_copyright = 0x00a9

const XKB_KEY_ordfeminine = 0x00aa

const XKB_KEY_guillemotleft = 0x00ab

const XKB_KEY_notsign = 0x00ac

const XKB_KEY_hyphen = 0x00ad

const XKB_KEY_registered = 0x00ae

const XKB_KEY_macron = 0x00af

const XKB_KEY_degree = 0x00b0

const XKB_KEY_plusminus = 0x00b1

const XKB_KEY_twosuperior = 0x00b2

const XKB_KEY_threesuperior = 0x00b3

const XKB_KEY_acute = 0x00b4

const XKB_KEY_mu = 0x00b5

const XKB_KEY_paragraph = 0x00b6

const XKB_KEY_periodcentered = 0x00b7

const XKB_KEY_cedilla = 0x00b8

const XKB_KEY_onesuperior = 0x00b9

const XKB_KEY_masculine = 0x00ba

const XKB_KEY_guillemotright = 0x00bb

const XKB_KEY_onequarter = 0x00bc

const XKB_KEY_onehalf = 0x00bd

const XKB_KEY_threequarters = 0x00be

const XKB_KEY_questiondown = 0x00bf

const XKB_KEY_Agrave = 0x00c0

const XKB_KEY_Aacute = 0x00c1

const XKB_KEY_Acircumflex = 0x00c2

const XKB_KEY_Atilde = 0x00c3

const XKB_KEY_Adiaeresis = 0x00c4

const XKB_KEY_Aring = 0x00c5

const XKB_KEY_AE = 0x00c6

const XKB_KEY_Ccedilla = 0x00c7

const XKB_KEY_Egrave = 0x00c8

const XKB_KEY_Eacute = 0x00c9

const XKB_KEY_Ecircumflex = 0x00ca

const XKB_KEY_Ediaeresis = 0x00cb

const XKB_KEY_Igrave = 0x00cc

const XKB_KEY_Iacute = 0x00cd

const XKB_KEY_Icircumflex = 0x00ce

const XKB_KEY_Idiaeresis = 0x00cf

const XKB_KEY_ETH = 0x00d0

const XKB_KEY_Eth = 0x00d0

const XKB_KEY_Ntilde = 0x00d1

const XKB_KEY_Ograve = 0x00d2

const XKB_KEY_Oacute = 0x00d3

const XKB_KEY_Ocircumflex = 0x00d4

const XKB_KEY_Otilde = 0x00d5

const XKB_KEY_Odiaeresis = 0x00d6

const XKB_KEY_multiply = 0x00d7

const XKB_KEY_Oslash = 0x00d8

const XKB_KEY_Ooblique = 0x00d8

const XKB_KEY_Ugrave = 0x00d9

const XKB_KEY_Uacute = 0x00da

const XKB_KEY_Ucircumflex = 0x00db

const XKB_KEY_Udiaeresis = 0x00dc

const XKB_KEY_Yacute = 0x00dd

const XKB_KEY_THORN = 0x00de

const XKB_KEY_Thorn = 0x00de

const XKB_KEY_ssharp = 0x00df

const XKB_KEY_agrave = 0x00e0

const XKB_KEY_aacute = 0x00e1

const XKB_KEY_acircumflex = 0x00e2

const XKB_KEY_atilde = 0x00e3

const XKB_KEY_adiaeresis = 0x00e4

const XKB_KEY_aring = 0x00e5

const XKB_KEY_ae = 0x00e6

const XKB_KEY_ccedilla = 0x00e7

const XKB_KEY_egrave = 0x00e8

const XKB_KEY_eacute = 0x00e9

const XKB_KEY_ecircumflex = 0x00ea

const XKB_KEY_ediaeresis = 0x00eb

const XKB_KEY_igrave = 0x00ec

const XKB_KEY_iacute = 0x00ed

const XKB_KEY_icircumflex = 0x00ee

const XKB_KEY_idiaeresis = 0x00ef

const XKB_KEY_eth = 0x00f0

const XKB_KEY_ntilde = 0x00f1

const XKB_KEY_ograve = 0x00f2

const XKB_KEY_oacute = 0x00f3

const XKB_KEY_ocircumflex = 0x00f4

const XKB_KEY_otilde = 0x00f5

const XKB_KEY_odiaeresis = 0x00f6

const XKB_KEY_division = 0x00f7

const XKB_KEY_oslash = 0x00f8

const XKB_KEY_ooblique = 0x00f8

const XKB_KEY_ugrave = 0x00f9

const XKB_KEY_uacute = 0x00fa

const XKB_KEY_ucircumflex = 0x00fb

const XKB_KEY_udiaeresis = 0x00fc

const XKB_KEY_yacute = 0x00fd

const XKB_KEY_thorn = 0x00fe

const XKB_KEY_ydiaeresis = 0x00ff

const XKB_KEY_Aogonek = 0x01a1

const XKB_KEY_breve = 0x01a2

const XKB_KEY_Lstroke = 0x01a3

const XKB_KEY_Lcaron = 0x01a5

const XKB_KEY_Sacute = 0x01a6

const XKB_KEY_Scaron = 0x01a9

const XKB_KEY_Scedilla = 0x01aa

const XKB_KEY_Tcaron = 0x01ab

const XKB_KEY_Zacute = 0x01ac

const XKB_KEY_Zcaron = 0x01ae

const XKB_KEY_Zabovedot = 0x01af

const XKB_KEY_aogonek = 0x01b1

const XKB_KEY_ogonek = 0x01b2

const XKB_KEY_lstroke = 0x01b3

const XKB_KEY_lcaron = 0x01b5

const XKB_KEY_sacute = 0x01b6

const XKB_KEY_caron = 0x01b7

const XKB_KEY_scaron = 0x01b9

const XKB_KEY_scedilla = 0x01ba

const XKB_KEY_tcaron = 0x01bb

const XKB_KEY_zacute = 0x01bc

const XKB_KEY_doubleacute = 0x01bd

const XKB_KEY_zcaron = 0x01be

const XKB_KEY_zabovedot = 0x01bf

const XKB_KEY_Racute = 0x01c0

const XKB_KEY_Abreve = 0x01c3

const XKB_KEY_Lacute = 0x01c5

const XKB_KEY_Cacute = 0x01c6

const XKB_KEY_Ccaron = 0x01c8

const XKB_KEY_Eogonek = 0x01ca

const XKB_KEY_Ecaron = 0x01cc

const XKB_KEY_Dcaron = 0x01cf

const XKB_KEY_Dstroke = 0x01d0

const XKB_KEY_Nacute = 0x01d1

const XKB_KEY_Ncaron = 0x01d2

const XKB_KEY_Odoubleacute = 0x01d5

const XKB_KEY_Rcaron = 0x01d8

const XKB_KEY_Uring = 0x01d9

const XKB_KEY_Udoubleacute = 0x01db

const XKB_KEY_Tcedilla = 0x01de

const XKB_KEY_racute = 0x01e0

const XKB_KEY_abreve = 0x01e3

const XKB_KEY_lacute = 0x01e5

const XKB_KEY_cacute = 0x01e6

const XKB_KEY_ccaron = 0x01e8

const XKB_KEY_eogonek = 0x01ea

const XKB_KEY_ecaron = 0x01ec

const XKB_KEY_dcaron = 0x01ef

const XKB_KEY_dstroke = 0x01f0

const XKB_KEY_nacute = 0x01f1

const XKB_KEY_ncaron = 0x01f2

const XKB_KEY_odoubleacute = 0x01f5

const XKB_KEY_rcaron = 0x01f8

const XKB_KEY_uring = 0x01f9

const XKB_KEY_udoubleacute = 0x01fb

const XKB_KEY_tcedilla = 0x01fe

const XKB_KEY_abovedot = 0x01ff

const XKB_KEY_Hstroke = 0x02a1

const XKB_KEY_Hcircumflex = 0x02a6

const XKB_KEY_Iabovedot = 0x02a9

const XKB_KEY_Gbreve = 0x02ab

const XKB_KEY_Jcircumflex = 0x02ac

const XKB_KEY_hstroke = 0x02b1

const XKB_KEY_hcircumflex = 0x02b6

const XKB_KEY_idotless = 0x02b9

const XKB_KEY_gbreve = 0x02bb

const XKB_KEY_jcircumflex = 0x02bc

const XKB_KEY_Cabovedot = 0x02c5

const XKB_KEY_Ccircumflex = 0x02c6

const XKB_KEY_Gabovedot = 0x02d5

const XKB_KEY_Gcircumflex = 0x02d8

const XKB_KEY_Ubreve = 0x02dd

const XKB_KEY_Scircumflex = 0x02de

const XKB_KEY_cabovedot = 0x02e5

const XKB_KEY_ccircumflex = 0x02e6

const XKB_KEY_gabovedot = 0x02f5

const XKB_KEY_gcircumflex = 0x02f8

const XKB_KEY_ubreve = 0x02fd

const XKB_KEY_scircumflex = 0x02fe

const XKB_KEY_kra = 0x03a2

const XKB_KEY_kappa = 0x03a2

const XKB_KEY_Rcedilla = 0x03a3

const XKB_KEY_Itilde = 0x03a5

const XKB_KEY_Lcedilla = 0x03a6

const XKB_KEY_Emacron = 0x03aa

const XKB_KEY_Gcedilla = 0x03ab

const XKB_KEY_Tslash = 0x03ac

const XKB_KEY_rcedilla = 0x03b3

const XKB_KEY_itilde = 0x03b5

const XKB_KEY_lcedilla = 0x03b6

const XKB_KEY_emacron = 0x03ba

const XKB_KEY_gcedilla = 0x03bb

const XKB_KEY_tslash = 0x03bc

const XKB_KEY_ENG = 0x03bd

const XKB_KEY_eng = 0x03bf

const XKB_KEY_Amacron = 0x03c0

const XKB_KEY_Iogonek = 0x03c7

const XKB_KEY_Eabovedot = 0x03cc

const XKB_KEY_Imacron = 0x03cf

const XKB_KEY_Ncedilla = 0x03d1

const XKB_KEY_Omacron = 0x03d2

const XKB_KEY_Kcedilla = 0x03d3

const XKB_KEY_Uogonek = 0x03d9

const XKB_KEY_Utilde = 0x03dd

const XKB_KEY_Umacron = 0x03de

const XKB_KEY_amacron = 0x03e0

const XKB_KEY_iogonek = 0x03e7

const XKB_KEY_eabovedot = 0x03ec

const XKB_KEY_imacron = 0x03ef

const XKB_KEY_ncedilla = 0x03f1

const XKB_KEY_omacron = 0x03f2

const XKB_KEY_kcedilla = 0x03f3

const XKB_KEY_uogonek = 0x03f9

const XKB_KEY_utilde = 0x03fd

const XKB_KEY_umacron = 0x03fe

const XKB_KEY_Wcircumflex = 0x01000174

const XKB_KEY_wcircumflex = 0x01000175

const XKB_KEY_Ycircumflex = 0x01000176

const XKB_KEY_ycircumflex = 0x01000177

const XKB_KEY_Babovedot = 0x01001e02

const XKB_KEY_babovedot = 0x01001e03

const XKB_KEY_Dabovedot = 0x01001e0a

const XKB_KEY_dabovedot = 0x01001e0b

const XKB_KEY_Fabovedot = 0x01001e1e

const XKB_KEY_fabovedot = 0x01001e1f

const XKB_KEY_Mabovedot = 0x01001e40

const XKB_KEY_mabovedot = 0x01001e41

const XKB_KEY_Pabovedot = 0x01001e56

const XKB_KEY_pabovedot = 0x01001e57

const XKB_KEY_Sabovedot = 0x01001e60

const XKB_KEY_sabovedot = 0x01001e61

const XKB_KEY_Tabovedot = 0x01001e6a

const XKB_KEY_tabovedot = 0x01001e6b

const XKB_KEY_Wgrave = 0x01001e80

const XKB_KEY_wgrave = 0x01001e81

const XKB_KEY_Wacute = 0x01001e82

const XKB_KEY_wacute = 0x01001e83

const XKB_KEY_Wdiaeresis = 0x01001e84

const XKB_KEY_wdiaeresis = 0x01001e85

const XKB_KEY_Ygrave = 0x01001ef2

const XKB_KEY_ygrave = 0x01001ef3

const XKB_KEY_OE = 0x13bc

const XKB_KEY_oe = 0x13bd

const XKB_KEY_Ydiaeresis = 0x13be

const XKB_KEY_overline = 0x047e

const XKB_KEY_kana_fullstop = 0x04a1

const XKB_KEY_kana_openingbracket = 0x04a2

const XKB_KEY_kana_closingbracket = 0x04a3

const XKB_KEY_kana_comma = 0x04a4

const XKB_KEY_kana_conjunctive = 0x04a5

const XKB_KEY_kana_middledot = 0x04a5

const XKB_KEY_kana_WO = 0x04a6

const XKB_KEY_kana_a = 0x04a7

const XKB_KEY_kana_i = 0x04a8

const XKB_KEY_kana_u = 0x04a9

const XKB_KEY_kana_e = 0x04aa

const XKB_KEY_kana_o = 0x04ab

const XKB_KEY_kana_ya = 0x04ac

const XKB_KEY_kana_yu = 0x04ad

const XKB_KEY_kana_yo = 0x04ae

const XKB_KEY_kana_tsu = 0x04af

const XKB_KEY_kana_tu = 0x04af

const XKB_KEY_prolongedsound = 0x04b0

const XKB_KEY_kana_A = 0x04b1

const XKB_KEY_kana_I = 0x04b2

const XKB_KEY_kana_U = 0x04b3

const XKB_KEY_kana_E = 0x04b4

const XKB_KEY_kana_O = 0x04b5

const XKB_KEY_kana_KA = 0x04b6

const XKB_KEY_kana_KI = 0x04b7

const XKB_KEY_kana_KU = 0x04b8

const XKB_KEY_kana_KE = 0x04b9

const XKB_KEY_kana_KO = 0x04ba

const XKB_KEY_kana_SA = 0x04bb

const XKB_KEY_kana_SHI = 0x04bc

const XKB_KEY_kana_SU = 0x04bd

const XKB_KEY_kana_SE = 0x04be

const XKB_KEY_kana_SO = 0x04bf

const XKB_KEY_kana_TA = 0x04c0

const XKB_KEY_kana_CHI = 0x04c1

const XKB_KEY_kana_TI = 0x04c1

const XKB_KEY_kana_TSU = 0x04c2

const XKB_KEY_kana_TU = 0x04c2

const XKB_KEY_kana_TE = 0x04c3

const XKB_KEY_kana_TO = 0x04c4

const XKB_KEY_kana_NA = 0x04c5

const XKB_KEY_kana_NI = 0x04c6

const XKB_KEY_kana_NU = 0x04c7

const XKB_KEY_kana_NE = 0x04c8

const XKB_KEY_kana_NO = 0x04c9

const XKB_KEY_kana_HA = 0x04ca

const XKB_KEY_kana_HI = 0x04cb

const XKB_KEY_kana_FU = 0x04cc

const XKB_KEY_kana_HU = 0x04cc

const XKB_KEY_kana_HE = 0x04cd

const XKB_KEY_kana_HO = 0x04ce

const XKB_KEY_kana_MA = 0x04cf

const XKB_KEY_kana_MI = 0x04d0

const XKB_KEY_kana_MU = 0x04d1

const XKB_KEY_kana_ME = 0x04d2

const XKB_KEY_kana_MO = 0x04d3

const XKB_KEY_kana_YA = 0x04d4

const XKB_KEY_kana_YU = 0x04d5

const XKB_KEY_kana_YO = 0x04d6

const XKB_KEY_kana_RA = 0x04d7

const XKB_KEY_kana_RI = 0x04d8

const XKB_KEY_kana_RU = 0x04d9

const XKB_KEY_kana_RE = 0x04da

const XKB_KEY_kana_RO = 0x04db

const XKB_KEY_kana_WA = 0x04dc

const XKB_KEY_kana_N = 0x04dd

const XKB_KEY_voicedsound = 0x04de

const XKB_KEY_semivoicedsound = 0x04df

const XKB_KEY_kana_switch = 0xff7e

const XKB_KEY_Farsi_0 = 0x010006f0

const XKB_KEY_Farsi_1 = 0x010006f1

const XKB_KEY_Farsi_2 = 0x010006f2

const XKB_KEY_Farsi_3 = 0x010006f3

const XKB_KEY_Farsi_4 = 0x010006f4

const XKB_KEY_Farsi_5 = 0x010006f5

const XKB_KEY_Farsi_6 = 0x010006f6

const XKB_KEY_Farsi_7 = 0x010006f7

const XKB_KEY_Farsi_8 = 0x010006f8

const XKB_KEY_Farsi_9 = 0x010006f9

const XKB_KEY_Arabic_percent = 0x0100066a

const XKB_KEY_Arabic_superscript_alef = 0x01000670

const XKB_KEY_Arabic_tteh = 0x01000679

const XKB_KEY_Arabic_peh = 0x0100067e

const XKB_KEY_Arabic_tcheh = 0x01000686

const XKB_KEY_Arabic_ddal = 0x01000688

const XKB_KEY_Arabic_rreh = 0x01000691

const XKB_KEY_Arabic_comma = 0x05ac

const XKB_KEY_Arabic_fullstop = 0x010006d4

const XKB_KEY_Arabic_0 = 0x01000660

const XKB_KEY_Arabic_1 = 0x01000661

const XKB_KEY_Arabic_2 = 0x01000662

const XKB_KEY_Arabic_3 = 0x01000663

const XKB_KEY_Arabic_4 = 0x01000664

const XKB_KEY_Arabic_5 = 0x01000665

const XKB_KEY_Arabic_6 = 0x01000666

const XKB_KEY_Arabic_7 = 0x01000667

const XKB_KEY_Arabic_8 = 0x01000668

const XKB_KEY_Arabic_9 = 0x01000669

const XKB_KEY_Arabic_semicolon = 0x05bb

const XKB_KEY_Arabic_question_mark = 0x05bf

const XKB_KEY_Arabic_hamza = 0x05c1

const XKB_KEY_Arabic_maddaonalef = 0x05c2

const XKB_KEY_Arabic_hamzaonalef = 0x05c3

const XKB_KEY_Arabic_hamzaonwaw = 0x05c4

const XKB_KEY_Arabic_hamzaunderalef = 0x05c5

const XKB_KEY_Arabic_hamzaonyeh = 0x05c6

const XKB_KEY_Arabic_alef = 0x05c7

const XKB_KEY_Arabic_beh = 0x05c8

const XKB_KEY_Arabic_tehmarbuta = 0x05c9

const XKB_KEY_Arabic_teh = 0x05ca

const XKB_KEY_Arabic_theh = 0x05cb

const XKB_KEY_Arabic_jeem = 0x05cc

const XKB_KEY_Arabic_hah = 0x05cd

const XKB_KEY_Arabic_khah = 0x05ce

const XKB_KEY_Arabic_dal = 0x05cf

const XKB_KEY_Arabic_thal = 0x05d0

const XKB_KEY_Arabic_ra = 0x05d1

const XKB_KEY_Arabic_zain = 0x05d2

const XKB_KEY_Arabic_seen = 0x05d3

const XKB_KEY_Arabic_sheen = 0x05d4

const XKB_KEY_Arabic_sad = 0x05d5

const XKB_KEY_Arabic_dad = 0x05d6

const XKB_KEY_Arabic_tah = 0x05d7

const XKB_KEY_Arabic_zah = 0x05d8

const XKB_KEY_Arabic_ain = 0x05d9

const XKB_KEY_Arabic_ghain = 0x05da

const XKB_KEY_Arabic_tatweel = 0x05e0

const XKB_KEY_Arabic_feh = 0x05e1

const XKB_KEY_Arabic_qaf = 0x05e2

const XKB_KEY_Arabic_kaf = 0x05e3

const XKB_KEY_Arabic_lam = 0x05e4

const XKB_KEY_Arabic_meem = 0x05e5

const XKB_KEY_Arabic_noon = 0x05e6

const XKB_KEY_Arabic_ha = 0x05e7

const XKB_KEY_Arabic_heh = 0x05e7

const XKB_KEY_Arabic_waw = 0x05e8

const XKB_KEY_Arabic_alefmaksura = 0x05e9

const XKB_KEY_Arabic_yeh = 0x05ea

const XKB_KEY_Arabic_fathatan = 0x05eb

const XKB_KEY_Arabic_dammatan = 0x05ec

const XKB_KEY_Arabic_kasratan = 0x05ed

const XKB_KEY_Arabic_fatha = 0x05ee

const XKB_KEY_Arabic_damma = 0x05ef

const XKB_KEY_Arabic_kasra = 0x05f0

const XKB_KEY_Arabic_shadda = 0x05f1

const XKB_KEY_Arabic_sukun = 0x05f2

const XKB_KEY_Arabic_madda_above = 0x01000653

const XKB_KEY_Arabic_hamza_above = 0x01000654

const XKB_KEY_Arabic_hamza_below = 0x01000655

const XKB_KEY_Arabic_jeh = 0x01000698

const XKB_KEY_Arabic_veh = 0x010006a4

const XKB_KEY_Arabic_keheh = 0x010006a9

const XKB_KEY_Arabic_gaf = 0x010006af

const XKB_KEY_Arabic_noon_ghunna = 0x010006ba

const XKB_KEY_Arabic_heh_doachashmee = 0x010006be

const XKB_KEY_Farsi_yeh = 0x010006cc

const XKB_KEY_Arabic_farsi_yeh = 0x010006cc

const XKB_KEY_Arabic_yeh_baree = 0x010006d2

const XKB_KEY_Arabic_heh_goal = 0x010006c1

const XKB_KEY_Arabic_switch = 0xff7e

const XKB_KEY_Cyrillic_GHE_bar = 0x01000492

const XKB_KEY_Cyrillic_ghe_bar = 0x01000493

const XKB_KEY_Cyrillic_ZHE_descender = 0x01000496

const XKB_KEY_Cyrillic_zhe_descender = 0x01000497

const XKB_KEY_Cyrillic_KA_descender = 0x0100049a

const XKB_KEY_Cyrillic_ka_descender = 0x0100049b

const XKB_KEY_Cyrillic_KA_vertstroke = 0x0100049c

const XKB_KEY_Cyrillic_ka_vertstroke = 0x0100049d

const XKB_KEY_Cyrillic_EN_descender = 0x010004a2

const XKB_KEY_Cyrillic_en_descender = 0x010004a3

const XKB_KEY_Cyrillic_U_straight = 0x010004ae

const XKB_KEY_Cyrillic_u_straight = 0x010004af

const XKB_KEY_Cyrillic_U_straight_bar = 0x010004b0

const XKB_KEY_Cyrillic_u_straight_bar = 0x010004b1

const XKB_KEY_Cyrillic_HA_descender = 0x010004b2

const XKB_KEY_Cyrillic_ha_descender = 0x010004b3

const XKB_KEY_Cyrillic_CHE_descender = 0x010004b6

const XKB_KEY_Cyrillic_che_descender = 0x010004b7

const XKB_KEY_Cyrillic_CHE_vertstroke = 0x010004b8

const XKB_KEY_Cyrillic_che_vertstroke = 0x010004b9

const XKB_KEY_Cyrillic_SHHA = 0x010004ba

const XKB_KEY_Cyrillic_shha = 0x010004bb

const XKB_KEY_Cyrillic_SCHWA = 0x010004d8

const XKB_KEY_Cyrillic_schwa = 0x010004d9

const XKB_KEY_Cyrillic_I_macron = 0x010004e2

const XKB_KEY_Cyrillic_i_macron = 0x010004e3

const XKB_KEY_Cyrillic_O_bar = 0x010004e8

const XKB_KEY_Cyrillic_o_bar = 0x010004e9

const XKB_KEY_Cyrillic_U_macron = 0x010004ee

const XKB_KEY_Cyrillic_u_macron = 0x010004ef

const XKB_KEY_Serbian_dje = 0x06a1

const XKB_KEY_Macedonia_gje = 0x06a2

const XKB_KEY_Cyrillic_io = 0x06a3

const XKB_KEY_Ukrainian_ie = 0x06a4

const XKB_KEY_Ukranian_je = 0x06a4

const XKB_KEY_Macedonia_dse = 0x06a5

const XKB_KEY_Ukrainian_i = 0x06a6

const XKB_KEY_Ukranian_i = 0x06a6

const XKB_KEY_Ukrainian_yi = 0x06a7

const XKB_KEY_Ukranian_yi = 0x06a7

const XKB_KEY_Cyrillic_je = 0x06a8

const XKB_KEY_Serbian_je = 0x06a8

const XKB_KEY_Cyrillic_lje = 0x06a9

const XKB_KEY_Serbian_lje = 0x06a9

const XKB_KEY_Cyrillic_nje = 0x06aa

const XKB_KEY_Serbian_nje = 0x06aa

const XKB_KEY_Serbian_tshe = 0x06ab

const XKB_KEY_Macedonia_kje = 0x06ac

const XKB_KEY_Ukrainian_ghe_with_upturn = 0x06ad

const XKB_KEY_Byelorussian_shortu = 0x06ae

const XKB_KEY_Cyrillic_dzhe = 0x06af

const XKB_KEY_Serbian_dze = 0x06af

const XKB_KEY_numerosign = 0x06b0

const XKB_KEY_Serbian_DJE = 0x06b1

const XKB_KEY_Macedonia_GJE = 0x06b2

const XKB_KEY_Cyrillic_IO = 0x06b3

const XKB_KEY_Ukrainian_IE = 0x06b4

const XKB_KEY_Ukranian_JE = 0x06b4

const XKB_KEY_Macedonia_DSE = 0x06b5

const XKB_KEY_Ukrainian_I = 0x06b6

const XKB_KEY_Ukranian_I = 0x06b6

const XKB_KEY_Ukrainian_YI = 0x06b7

const XKB_KEY_Ukranian_YI = 0x06b7

const XKB_KEY_Cyrillic_JE = 0x06b8

const XKB_KEY_Serbian_JE = 0x06b8

const XKB_KEY_Cyrillic_LJE = 0x06b9

const XKB_KEY_Serbian_LJE = 0x06b9

const XKB_KEY_Cyrillic_NJE = 0x06ba

const XKB_KEY_Serbian_NJE = 0x06ba

const XKB_KEY_Serbian_TSHE = 0x06bb

const XKB_KEY_Macedonia_KJE = 0x06bc

const XKB_KEY_Ukrainian_GHE_WITH_UPTURN = 0x06bd

const XKB_KEY_Byelorussian_SHORTU = 0x06be

const XKB_KEY_Cyrillic_DZHE = 0x06bf

const XKB_KEY_Serbian_DZE = 0x06bf

const XKB_KEY_Cyrillic_yu = 0x06c0

const XKB_KEY_Cyrillic_a = 0x06c1

const XKB_KEY_Cyrillic_be = 0x06c2

const XKB_KEY_Cyrillic_tse = 0x06c3

const XKB_KEY_Cyrillic_de = 0x06c4

const XKB_KEY_Cyrillic_ie = 0x06c5

const XKB_KEY_Cyrillic_ef = 0x06c6

const XKB_KEY_Cyrillic_ghe = 0x06c7

const XKB_KEY_Cyrillic_ha = 0x06c8

const XKB_KEY_Cyrillic_i = 0x06c9

const XKB_KEY_Cyrillic_shorti = 0x06ca

const XKB_KEY_Cyrillic_ka = 0x06cb

const XKB_KEY_Cyrillic_el = 0x06cc

const XKB_KEY_Cyrillic_em = 0x06cd

const XKB_KEY_Cyrillic_en = 0x06ce

const XKB_KEY_Cyrillic_o = 0x06cf

const XKB_KEY_Cyrillic_pe = 0x06d0

const XKB_KEY_Cyrillic_ya = 0x06d1

const XKB_KEY_Cyrillic_er = 0x06d2

const XKB_KEY_Cyrillic_es = 0x06d3

const XKB_KEY_Cyrillic_te = 0x06d4

const XKB_KEY_Cyrillic_u = 0x06d5

const XKB_KEY_Cyrillic_zhe = 0x06d6

const XKB_KEY_Cyrillic_ve = 0x06d7

const XKB_KEY_Cyrillic_softsign = 0x06d8

const XKB_KEY_Cyrillic_yeru = 0x06d9

const XKB_KEY_Cyrillic_ze = 0x06da

const XKB_KEY_Cyrillic_sha = 0x06db

const XKB_KEY_Cyrillic_e = 0x06dc

const XKB_KEY_Cyrillic_shcha = 0x06dd

const XKB_KEY_Cyrillic_che = 0x06de

const XKB_KEY_Cyrillic_hardsign = 0x06df

const XKB_KEY_Cyrillic_YU = 0x06e0

const XKB_KEY_Cyrillic_A = 0x06e1

const XKB_KEY_Cyrillic_BE = 0x06e2

const XKB_KEY_Cyrillic_TSE = 0x06e3

const XKB_KEY_Cyrillic_DE = 0x06e4

const XKB_KEY_Cyrillic_IE = 0x06e5

const XKB_KEY_Cyrillic_EF = 0x06e6

const XKB_KEY_Cyrillic_GHE = 0x06e7

const XKB_KEY_Cyrillic_HA = 0x06e8

const XKB_KEY_Cyrillic_I = 0x06e9

const XKB_KEY_Cyrillic_SHORTI = 0x06ea

const XKB_KEY_Cyrillic_KA = 0x06eb

const XKB_KEY_Cyrillic_EL = 0x06ec

const XKB_KEY_Cyrillic_EM = 0x06ed

const XKB_KEY_Cyrillic_EN = 0x06ee

const XKB_KEY_Cyrillic_O = 0x06ef

const XKB_KEY_Cyrillic_PE = 0x06f0

const XKB_KEY_Cyrillic_YA = 0x06f1

const XKB_KEY_Cyrillic_ER = 0x06f2

const XKB_KEY_Cyrillic_ES = 0x06f3

const XKB_KEY_Cyrillic_TE = 0x06f4

const XKB_KEY_Cyrillic_U = 0x06f5

const XKB_KEY_Cyrillic_ZHE = 0x06f6

const XKB_KEY_Cyrillic_VE = 0x06f7

const XKB_KEY_Cyrillic_SOFTSIGN = 0x06f8

const XKB_KEY_Cyrillic_YERU = 0x06f9

const XKB_KEY_Cyrillic_ZE = 0x06fa

const XKB_KEY_Cyrillic_SHA = 0x06fb

const XKB_KEY_Cyrillic_E = 0x06fc

const XKB_KEY_Cyrillic_SHCHA = 0x06fd

const XKB_KEY_Cyrillic_CHE = 0x06fe

const XKB_KEY_Cyrillic_HARDSIGN = 0x06ff

const XKB_KEY_Greek_ALPHAaccent = 0x07a1

const XKB_KEY_Greek_EPSILONaccent = 0x07a2

const XKB_KEY_Greek_ETAaccent = 0x07a3

const XKB_KEY_Greek_IOTAaccent = 0x07a4

const XKB_KEY_Greek_IOTAdieresis = 0x07a5

const XKB_KEY_Greek_IOTAdiaeresis = 0x07a5

const XKB_KEY_Greek_OMICRONaccent = 0x07a7

const XKB_KEY_Greek_UPSILONaccent = 0x07a8

const XKB_KEY_Greek_UPSILONdieresis = 0x07a9

const XKB_KEY_Greek_OMEGAaccent = 0x07ab

const XKB_KEY_Greek_accentdieresis = 0x07ae

const XKB_KEY_Greek_horizbar = 0x07af

const XKB_KEY_Greek_alphaaccent = 0x07b1

const XKB_KEY_Greek_epsilonaccent = 0x07b2

const XKB_KEY_Greek_etaaccent = 0x07b3

const XKB_KEY_Greek_iotaaccent = 0x07b4

const XKB_KEY_Greek_iotadieresis = 0x07b5

const XKB_KEY_Greek_iotaaccentdieresis = 0x07b6

const XKB_KEY_Greek_omicronaccent = 0x07b7

const XKB_KEY_Greek_upsilonaccent = 0x07b8

const XKB_KEY_Greek_upsilondieresis = 0x07b9

const XKB_KEY_Greek_upsilonaccentdieresis = 0x07ba

const XKB_KEY_Greek_omegaaccent = 0x07bb

const XKB_KEY_Greek_ALPHA = 0x07c1

const XKB_KEY_Greek_BETA = 0x07c2

const XKB_KEY_Greek_GAMMA = 0x07c3

const XKB_KEY_Greek_DELTA = 0x07c4

const XKB_KEY_Greek_EPSILON = 0x07c5

const XKB_KEY_Greek_ZETA = 0x07c6

const XKB_KEY_Greek_ETA = 0x07c7

const XKB_KEY_Greek_THETA = 0x07c8

const XKB_KEY_Greek_IOTA = 0x07c9

const XKB_KEY_Greek_KAPPA = 0x07ca

const XKB_KEY_Greek_LAMDA = 0x07cb

const XKB_KEY_Greek_LAMBDA = 0x07cb

const XKB_KEY_Greek_MU = 0x07cc

const XKB_KEY_Greek_NU = 0x07cd

const XKB_KEY_Greek_XI = 0x07ce

const XKB_KEY_Greek_OMICRON = 0x07cf

const XKB_KEY_Greek_PI = 0x07d0

const XKB_KEY_Greek_RHO = 0x07d1

const XKB_KEY_Greek_SIGMA = 0x07d2

const XKB_KEY_Greek_TAU = 0x07d4

const XKB_KEY_Greek_UPSILON = 0x07d5

const XKB_KEY_Greek_PHI = 0x07d6

const XKB_KEY_Greek_CHI = 0x07d7

const XKB_KEY_Greek_PSI = 0x07d8

const XKB_KEY_Greek_OMEGA = 0x07d9

const XKB_KEY_Greek_alpha = 0x07e1

const XKB_KEY_Greek_beta = 0x07e2

const XKB_KEY_Greek_gamma = 0x07e3

const XKB_KEY_Greek_delta = 0x07e4

const XKB_KEY_Greek_epsilon = 0x07e5

const XKB_KEY_Greek_zeta = 0x07e6

const XKB_KEY_Greek_eta = 0x07e7

const XKB_KEY_Greek_theta = 0x07e8

const XKB_KEY_Greek_iota = 0x07e9

const XKB_KEY_Greek_kappa = 0x07ea

const XKB_KEY_Greek_lamda = 0x07eb

const XKB_KEY_Greek_lambda = 0x07eb

const XKB_KEY_Greek_mu = 0x07ec

const XKB_KEY_Greek_nu = 0x07ed

const XKB_KEY_Greek_xi = 0x07ee

const XKB_KEY_Greek_omicron = 0x07ef

const XKB_KEY_Greek_pi = 0x07f0

const XKB_KEY_Greek_rho = 0x07f1

const XKB_KEY_Greek_sigma = 0x07f2

const XKB_KEY_Greek_finalsmallsigma = 0x07f3

const XKB_KEY_Greek_tau = 0x07f4

const XKB_KEY_Greek_upsilon = 0x07f5

const XKB_KEY_Greek_phi = 0x07f6

const XKB_KEY_Greek_chi = 0x07f7

const XKB_KEY_Greek_psi = 0x07f8

const XKB_KEY_Greek_omega = 0x07f9

const XKB_KEY_Greek_switch = 0xff7e

const XKB_KEY_leftradical = 0x08a1

const XKB_KEY_topleftradical = 0x08a2

const XKB_KEY_horizconnector = 0x08a3

const XKB_KEY_topintegral = 0x08a4

const XKB_KEY_botintegral = 0x08a5

const XKB_KEY_vertconnector = 0x08a6

const XKB_KEY_topleftsqbracket = 0x08a7

const XKB_KEY_botleftsqbracket = 0x08a8

const XKB_KEY_toprightsqbracket = 0x08a9

const XKB_KEY_botrightsqbracket = 0x08aa

const XKB_KEY_topleftparens = 0x08ab

const XKB_KEY_botleftparens = 0x08ac

const XKB_KEY_toprightparens = 0x08ad

const XKB_KEY_botrightparens = 0x08ae

const XKB_KEY_leftmiddlecurlybrace = 0x08af

const XKB_KEY_rightmiddlecurlybrace = 0x08b0

const XKB_KEY_topleftsummation = 0x08b1

const XKB_KEY_botleftsummation = 0x08b2

const XKB_KEY_topvertsummationconnector = 0x08b3

const XKB_KEY_botvertsummationconnector = 0x08b4

const XKB_KEY_toprightsummation = 0x08b5

const XKB_KEY_botrightsummation = 0x08b6

const XKB_KEY_rightmiddlesummation = 0x08b7

const XKB_KEY_lessthanequal = 0x08bc

const XKB_KEY_notequal = 0x08bd

const XKB_KEY_greaterthanequal = 0x08be

const XKB_KEY_integral = 0x08bf

const XKB_KEY_therefore = 0x08c0

const XKB_KEY_variation = 0x08c1

const XKB_KEY_infinity = 0x08c2

const XKB_KEY_nabla = 0x08c5

const XKB_KEY_approximate = 0x08c8

const XKB_KEY_similarequal = 0x08c9

const XKB_KEY_ifonlyif = 0x08cd

const XKB_KEY_implies = 0x08ce

const XKB_KEY_identical = 0x08cf

const XKB_KEY_radical = 0x08d6

const XKB_KEY_includedin = 0x08da

const XKB_KEY_includes = 0x08db

const XKB_KEY_intersection = 0x08dc

const XKB_KEY_union = 0x08dd

const XKB_KEY_logicaland = 0x08de

const XKB_KEY_logicalor = 0x08df

const XKB_KEY_partialderivative = 0x08ef

const XKB_KEY_function = 0x08f6

const XKB_KEY_leftarrow = 0x08fb

const XKB_KEY_uparrow = 0x08fc

const XKB_KEY_rightarrow = 0x08fd

const XKB_KEY_downarrow = 0x08fe

const XKB_KEY_blank = 0x09df

const XKB_KEY_soliddiamond = 0x09e0

const XKB_KEY_checkerboard = 0x09e1

const XKB_KEY_ht = 0x09e2

const XKB_KEY_ff = 0x09e3

const XKB_KEY_cr = 0x09e4

const XKB_KEY_lf = 0x09e5

const XKB_KEY_nl = 0x09e8

const XKB_KEY_vt = 0x09e9

const XKB_KEY_lowrightcorner = 0x09ea

const XKB_KEY_uprightcorner = 0x09eb

const XKB_KEY_upleftcorner = 0x09ec

const XKB_KEY_lowleftcorner = 0x09ed

const XKB_KEY_crossinglines = 0x09ee

const XKB_KEY_horizlinescan1 = 0x09ef

const XKB_KEY_horizlinescan3 = 0x09f0

const XKB_KEY_horizlinescan5 = 0x09f1

const XKB_KEY_horizlinescan7 = 0x09f2

const XKB_KEY_horizlinescan9 = 0x09f3

const XKB_KEY_leftt = 0x09f4

const XKB_KEY_rightt = 0x09f5

const XKB_KEY_bott = 0x09f6

const XKB_KEY_topt = 0x09f7

const XKB_KEY_vertbar = 0x09f8

const XKB_KEY_emspace = 0x0aa1

const XKB_KEY_enspace = 0x0aa2

const XKB_KEY_em3space = 0x0aa3

const XKB_KEY_em4space = 0x0aa4

const XKB_KEY_digitspace = 0x0aa5

const XKB_KEY_punctspace = 0x0aa6

const XKB_KEY_thinspace = 0x0aa7

const XKB_KEY_hairspace = 0x0aa8

const XKB_KEY_emdash = 0x0aa9

const XKB_KEY_endash = 0x0aaa

const XKB_KEY_signifblank = 0x0aac

const XKB_KEY_ellipsis = 0x0aae

const XKB_KEY_doubbaselinedot = 0x0aaf

const XKB_KEY_onethird = 0x0ab0

const XKB_KEY_twothirds = 0x0ab1

const XKB_KEY_onefifth = 0x0ab2

const XKB_KEY_twofifths = 0x0ab3

const XKB_KEY_threefifths = 0x0ab4

const XKB_KEY_fourfifths = 0x0ab5

const XKB_KEY_onesixth = 0x0ab6

const XKB_KEY_fivesixths = 0x0ab7

const XKB_KEY_careof = 0x0ab8

const XKB_KEY_figdash = 0x0abb

const XKB_KEY_leftanglebracket = 0x0abc

const XKB_KEY_decimalpoint = 0x0abd

const XKB_KEY_rightanglebracket = 0x0abe

const XKB_KEY_marker = 0x0abf

const XKB_KEY_oneeighth = 0x0ac3

const XKB_KEY_threeeighths = 0x0ac4

const XKB_KEY_fiveeighths = 0x0ac5

const XKB_KEY_seveneighths = 0x0ac6

const XKB_KEY_trademark = 0x0ac9

const XKB_KEY_signaturemark = 0x0aca

const XKB_KEY_trademarkincircle = 0x0acb

const XKB_KEY_leftopentriangle = 0x0acc

const XKB_KEY_rightopentriangle = 0x0acd

const XKB_KEY_emopencircle = 0x0ace

const XKB_KEY_emopenrectangle = 0x0acf

const XKB_KEY_leftsinglequotemark = 0x0ad0

const XKB_KEY_rightsinglequotemark = 0x0ad1

const XKB_KEY_leftdoublequotemark = 0x0ad2

const XKB_KEY_rightdoublequotemark = 0x0ad3

const XKB_KEY_prescription = 0x0ad4

const XKB_KEY_permille = 0x0ad5

const XKB_KEY_minutes = 0x0ad6

const XKB_KEY_seconds = 0x0ad7

const XKB_KEY_latincross = 0x0ad9

const XKB_KEY_hexagram = 0x0ada

const XKB_KEY_filledrectbullet = 0x0adb

const XKB_KEY_filledlefttribullet = 0x0adc

const XKB_KEY_filledrighttribullet = 0x0add

const XKB_KEY_emfilledcircle = 0x0ade

const XKB_KEY_emfilledrect = 0x0adf

const XKB_KEY_enopencircbullet = 0x0ae0

const XKB_KEY_enopensquarebullet = 0x0ae1

const XKB_KEY_openrectbullet = 0x0ae2

const XKB_KEY_opentribulletup = 0x0ae3

const XKB_KEY_opentribulletdown = 0x0ae4

const XKB_KEY_openstar = 0x0ae5

const XKB_KEY_enfilledcircbullet = 0x0ae6

const XKB_KEY_enfilledsqbullet = 0x0ae7

const XKB_KEY_filledtribulletup = 0x0ae8

const XKB_KEY_filledtribulletdown = 0x0ae9

const XKB_KEY_leftpointer = 0x0aea

const XKB_KEY_rightpointer = 0x0aeb

const XKB_KEY_club = 0x0aec

const XKB_KEY_diamond = 0x0aed

const XKB_KEY_heart = 0x0aee

const XKB_KEY_maltesecross = 0x0af0

const XKB_KEY_dagger = 0x0af1

const XKB_KEY_doubledagger = 0x0af2

const XKB_KEY_checkmark = 0x0af3

const XKB_KEY_ballotcross = 0x0af4

const XKB_KEY_musicalsharp = 0x0af5

const XKB_KEY_musicalflat = 0x0af6

const XKB_KEY_malesymbol = 0x0af7

const XKB_KEY_femalesymbol = 0x0af8

const XKB_KEY_telephone = 0x0af9

const XKB_KEY_telephonerecorder = 0x0afa

const XKB_KEY_phonographcopyright = 0x0afb

const XKB_KEY_caret = 0x0afc

const XKB_KEY_singlelowquotemark = 0x0afd

const XKB_KEY_doublelowquotemark = 0x0afe

const XKB_KEY_cursor = 0x0aff

const XKB_KEY_leftcaret = 0x0ba3

const XKB_KEY_rightcaret = 0x0ba6

const XKB_KEY_downcaret = 0x0ba8

const XKB_KEY_upcaret = 0x0ba9

const XKB_KEY_overbar = 0x0bc0

const XKB_KEY_downtack = 0x0bc2

const XKB_KEY_upshoe = 0x0bc3

const XKB_KEY_downstile = 0x0bc4

const XKB_KEY_underbar = 0x0bc6

const XKB_KEY_jot = 0x0bca

const XKB_KEY_quad = 0x0bcc

const XKB_KEY_uptack = 0x0bce

const XKB_KEY_circle = 0x0bcf

const XKB_KEY_upstile = 0x0bd3

const XKB_KEY_downshoe = 0x0bd6

const XKB_KEY_rightshoe = 0x0bd8

const XKB_KEY_leftshoe = 0x0bda

const XKB_KEY_lefttack = 0x0bdc

const XKB_KEY_righttack = 0x0bfc

const XKB_KEY_hebrew_doublelowline = 0x0cdf

const XKB_KEY_hebrew_aleph = 0x0ce0

const XKB_KEY_hebrew_bet = 0x0ce1

const XKB_KEY_hebrew_beth = 0x0ce1

const XKB_KEY_hebrew_gimel = 0x0ce2

const XKB_KEY_hebrew_gimmel = 0x0ce2

const XKB_KEY_hebrew_dalet = 0x0ce3

const XKB_KEY_hebrew_daleth = 0x0ce3

const XKB_KEY_hebrew_he = 0x0ce4

const XKB_KEY_hebrew_waw = 0x0ce5

const XKB_KEY_hebrew_zain = 0x0ce6

const XKB_KEY_hebrew_zayin = 0x0ce6

const XKB_KEY_hebrew_chet = 0x0ce7

const XKB_KEY_hebrew_het = 0x0ce7

const XKB_KEY_hebrew_tet = 0x0ce8

const XKB_KEY_hebrew_teth = 0x0ce8

const XKB_KEY_hebrew_yod = 0x0ce9

const XKB_KEY_hebrew_finalkaph = 0x0cea

const XKB_KEY_hebrew_kaph = 0x0ceb

const XKB_KEY_hebrew_lamed = 0x0cec

const XKB_KEY_hebrew_finalmem = 0x0ced

const XKB_KEY_hebrew_mem = 0x0cee

const XKB_KEY_hebrew_finalnun = 0x0cef

const XKB_KEY_hebrew_nun = 0x0cf0

const XKB_KEY_hebrew_samech = 0x0cf1

const XKB_KEY_hebrew_samekh = 0x0cf1

const XKB_KEY_hebrew_ayin = 0x0cf2

const XKB_KEY_hebrew_finalpe = 0x0cf3

const XKB_KEY_hebrew_pe = 0x0cf4

const XKB_KEY_hebrew_finalzade = 0x0cf5

const XKB_KEY_hebrew_finalzadi = 0x0cf5

const XKB_KEY_hebrew_zade = 0x0cf6

const XKB_KEY_hebrew_zadi = 0x0cf6

const XKB_KEY_hebrew_qoph = 0x0cf7

const XKB_KEY_hebrew_kuf = 0x0cf7

const XKB_KEY_hebrew_resh = 0x0cf8

const XKB_KEY_hebrew_shin = 0x0cf9

const XKB_KEY_hebrew_taw = 0x0cfa

const XKB_KEY_hebrew_taf = 0x0cfa

const XKB_KEY_Hebrew_switch = 0xff7e

const XKB_KEY_Thai_kokai = 0x0da1

const XKB_KEY_Thai_khokhai = 0x0da2

const XKB_KEY_Thai_khokhuat = 0x0da3

const XKB_KEY_Thai_khokhwai = 0x0da4

const XKB_KEY_Thai_khokhon = 0x0da5

const XKB_KEY_Thai_khorakhang = 0x0da6

const XKB_KEY_Thai_ngongu = 0x0da7

const XKB_KEY_Thai_chochan = 0x0da8

const XKB_KEY_Thai_choching = 0x0da9

const XKB_KEY_Thai_chochang = 0x0daa

const XKB_KEY_Thai_soso = 0x0dab

const XKB_KEY_Thai_chochoe = 0x0dac

const XKB_KEY_Thai_yoying = 0x0dad

const XKB_KEY_Thai_dochada = 0x0dae

const XKB_KEY_Thai_topatak = 0x0daf

const XKB_KEY_Thai_thothan = 0x0db0

const XKB_KEY_Thai_thonangmontho = 0x0db1

const XKB_KEY_Thai_thophuthao = 0x0db2

const XKB_KEY_Thai_nonen = 0x0db3

const XKB_KEY_Thai_dodek = 0x0db4

const XKB_KEY_Thai_totao = 0x0db5

const XKB_KEY_Thai_thothung = 0x0db6

const XKB_KEY_Thai_thothahan = 0x0db7

const XKB_KEY_Thai_thothong = 0x0db8

const XKB_KEY_Thai_nonu = 0x0db9

const XKB_KEY_Thai_bobaimai = 0x0dba

const XKB_KEY_Thai_popla = 0x0dbb

const XKB_KEY_Thai_phophung = 0x0dbc

const XKB_KEY_Thai_fofa = 0x0dbd

const XKB_KEY_Thai_phophan = 0x0dbe

const XKB_KEY_Thai_fofan = 0x0dbf

const XKB_KEY_Thai_phosamphao = 0x0dc0

const XKB_KEY_Thai_moma = 0x0dc1

const XKB_KEY_Thai_yoyak = 0x0dc2

const XKB_KEY_Thai_rorua = 0x0dc3

const XKB_KEY_Thai_ru = 0x0dc4

const XKB_KEY_Thai_loling = 0x0dc5

const XKB_KEY_Thai_lu = 0x0dc6

const XKB_KEY_Thai_wowaen = 0x0dc7

const XKB_KEY_Thai_sosala = 0x0dc8

const XKB_KEY_Thai_sorusi = 0x0dc9

const XKB_KEY_Thai_sosua = 0x0dca

const XKB_KEY_Thai_hohip = 0x0dcb

const XKB_KEY_Thai_lochula = 0x0dcc

const XKB_KEY_Thai_oang = 0x0dcd

const XKB_KEY_Thai_honokhuk = 0x0dce

const XKB_KEY_Thai_paiyannoi = 0x0dcf

const XKB_KEY_Thai_saraa = 0x0dd0

const XKB_KEY_Thai_maihanakat = 0x0dd1

const XKB_KEY_Thai_saraaa = 0x0dd2

const XKB_KEY_Thai_saraam = 0x0dd3

const XKB_KEY_Thai_sarai = 0x0dd4

const XKB_KEY_Thai_saraii = 0x0dd5

const XKB_KEY_Thai_saraue = 0x0dd6

const XKB_KEY_Thai_sarauee = 0x0dd7

const XKB_KEY_Thai_sarau = 0x0dd8

const XKB_KEY_Thai_sarauu = 0x0dd9

const XKB_KEY_Thai_phinthu = 0x0dda

const XKB_KEY_Thai_maihanakat_maitho = 0x0dde

const XKB_KEY_Thai_baht = 0x0ddf

const XKB_KEY_Thai_sarae = 0x0de0

const XKB_KEY_Thai_saraae = 0x0de1

const XKB_KEY_Thai_sarao = 0x0de2

const XKB_KEY_Thai_saraaimaimuan = 0x0de3

const XKB_KEY_Thai_saraaimaimalai = 0x0de4

const XKB_KEY_Thai_lakkhangyao = 0x0de5

const XKB_KEY_Thai_maiyamok = 0x0de6

const XKB_KEY_Thai_maitaikhu = 0x0de7

const XKB_KEY_Thai_maiek = 0x0de8

const XKB_KEY_Thai_maitho = 0x0de9

const XKB_KEY_Thai_maitri = 0x0dea

const XKB_KEY_Thai_maichattawa = 0x0deb

const XKB_KEY_Thai_thanthakhat = 0x0dec

const XKB_KEY_Thai_nikhahit = 0x0ded

const XKB_KEY_Thai_leksun = 0x0df0

const XKB_KEY_Thai_leknung = 0x0df1

const XKB_KEY_Thai_leksong = 0x0df2

const XKB_KEY_Thai_leksam = 0x0df3

const XKB_KEY_Thai_leksi = 0x0df4

const XKB_KEY_Thai_lekha = 0x0df5

const XKB_KEY_Thai_lekhok = 0x0df6

const XKB_KEY_Thai_lekchet = 0x0df7

const XKB_KEY_Thai_lekpaet = 0x0df8

const XKB_KEY_Thai_lekkao = 0x0df9

const XKB_KEY_Hangul = 0xff31

const XKB_KEY_Hangul_Start = 0xff32

const XKB_KEY_Hangul_End = 0xff33

const XKB_KEY_Hangul_Hanja = 0xff34

const XKB_KEY_Hangul_Jamo = 0xff35

const XKB_KEY_Hangul_Romaja = 0xff36

const XKB_KEY_Hangul_Codeinput = 0xff37

const XKB_KEY_Hangul_Jeonja = 0xff38

const XKB_KEY_Hangul_Banja = 0xff39

const XKB_KEY_Hangul_PreHanja = 0xff3a

const XKB_KEY_Hangul_PostHanja = 0xff3b

const XKB_KEY_Hangul_SingleCandidate = 0xff3c

const XKB_KEY_Hangul_MultipleCandidate = 0xff3d

const XKB_KEY_Hangul_PreviousCandidate = 0xff3e

const XKB_KEY_Hangul_Special = 0xff3f

const XKB_KEY_Hangul_switch = 0xff7e

const XKB_KEY_Hangul_Kiyeog = 0x0ea1

const XKB_KEY_Hangul_SsangKiyeog = 0x0ea2

const XKB_KEY_Hangul_KiyeogSios = 0x0ea3

const XKB_KEY_Hangul_Nieun = 0x0ea4

const XKB_KEY_Hangul_NieunJieuj = 0x0ea5

const XKB_KEY_Hangul_NieunHieuh = 0x0ea6

const XKB_KEY_Hangul_Dikeud = 0x0ea7

const XKB_KEY_Hangul_SsangDikeud = 0x0ea8

const XKB_KEY_Hangul_Rieul = 0x0ea9

const XKB_KEY_Hangul_RieulKiyeog = 0x0eaa

const XKB_KEY_Hangul_RieulMieum = 0x0eab

const XKB_KEY_Hangul_RieulPieub = 0x0eac

const XKB_KEY_Hangul_RieulSios = 0x0ead

const XKB_KEY_Hangul_RieulTieut = 0x0eae

const XKB_KEY_Hangul_RieulPhieuf = 0x0eaf

const XKB_KEY_Hangul_RieulHieuh = 0x0eb0

const XKB_KEY_Hangul_Mieum = 0x0eb1

const XKB_KEY_Hangul_Pieub = 0x0eb2

const XKB_KEY_Hangul_SsangPieub = 0x0eb3

const XKB_KEY_Hangul_PieubSios = 0x0eb4

const XKB_KEY_Hangul_Sios = 0x0eb5

const XKB_KEY_Hangul_SsangSios = 0x0eb6

const XKB_KEY_Hangul_Ieung = 0x0eb7

const XKB_KEY_Hangul_Jieuj = 0x0eb8

const XKB_KEY_Hangul_SsangJieuj = 0x0eb9

const XKB_KEY_Hangul_Cieuc = 0x0eba

const XKB_KEY_Hangul_Khieuq = 0x0ebb

const XKB_KEY_Hangul_Tieut = 0x0ebc

const XKB_KEY_Hangul_Phieuf = 0x0ebd

const XKB_KEY_Hangul_Hieuh = 0x0ebe

const XKB_KEY_Hangul_A = 0x0ebf

const XKB_KEY_Hangul_AE = 0x0ec0

const XKB_KEY_Hangul_YA = 0x0ec1

const XKB_KEY_Hangul_YAE = 0x0ec2

const XKB_KEY_Hangul_EO = 0x0ec3

const XKB_KEY_Hangul_E = 0x0ec4

const XKB_KEY_Hangul_YEO = 0x0ec5

const XKB_KEY_Hangul_YE = 0x0ec6

const XKB_KEY_Hangul_O = 0x0ec7

const XKB_KEY_Hangul_WA = 0x0ec8

const XKB_KEY_Hangul_WAE = 0x0ec9

const XKB_KEY_Hangul_OE = 0x0eca

const XKB_KEY_Hangul_YO = 0x0ecb

const XKB_KEY_Hangul_U = 0x0ecc

const XKB_KEY_Hangul_WEO = 0x0ecd

const XKB_KEY_Hangul_WE = 0x0ece

const XKB_KEY_Hangul_WI = 0x0ecf

const XKB_KEY_Hangul_YU = 0x0ed0

const XKB_KEY_Hangul_EU = 0x0ed1

const XKB_KEY_Hangul_YI = 0x0ed2

const XKB_KEY_Hangul_I = 0x0ed3

const XKB_KEY_Hangul_J_Kiyeog = 0x0ed4

const XKB_KEY_Hangul_J_SsangKiyeog = 0x0ed5

const XKB_KEY_Hangul_J_KiyeogSios = 0x0ed6

const XKB_KEY_Hangul_J_Nieun = 0x0ed7

const XKB_KEY_Hangul_J_NieunJieuj = 0x0ed8

const XKB_KEY_Hangul_J_NieunHieuh = 0x0ed9

const XKB_KEY_Hangul_J_Dikeud = 0x0eda

const XKB_KEY_Hangul_J_Rieul = 0x0edb

const XKB_KEY_Hangul_J_RieulKiyeog = 0x0edc

const XKB_KEY_Hangul_J_RieulMieum = 0x0edd

const XKB_KEY_Hangul_J_RieulPieub = 0x0ede

const XKB_KEY_Hangul_J_RieulSios = 0x0edf

const XKB_KEY_Hangul_J_RieulTieut = 0x0ee0

const XKB_KEY_Hangul_J_RieulPhieuf = 0x0ee1

const XKB_KEY_Hangul_J_RieulHieuh = 0x0ee2

const XKB_KEY_Hangul_J_Mieum = 0x0ee3

const XKB_KEY_Hangul_J_Pieub = 0x0ee4

const XKB_KEY_Hangul_J_PieubSios = 0x0ee5

const XKB_KEY_Hangul_J_Sios = 0x0ee6

const XKB_KEY_Hangul_J_SsangSios = 0x0ee7

const XKB_KEY_Hangul_J_Ieung = 0x0ee8

const XKB_KEY_Hangul_J_Jieuj = 0x0ee9

const XKB_KEY_Hangul_J_Cieuc = 0x0eea

const XKB_KEY_Hangul_J_Khieuq = 0x0eeb

const XKB_KEY_Hangul_J_Tieut = 0x0eec

const XKB_KEY_Hangul_J_Phieuf = 0x0eed

const XKB_KEY_Hangul_J_Hieuh = 0x0eee

const XKB_KEY_Hangul_RieulYeorinHieuh = 0x0eef

const XKB_KEY_Hangul_SunkyeongeumMieum = 0x0ef0

const XKB_KEY_Hangul_SunkyeongeumPieub = 0x0ef1

const XKB_KEY_Hangul_PanSios = 0x0ef2

const XKB_KEY_Hangul_KkogjiDalrinIeung = 0x0ef3

const XKB_KEY_Hangul_SunkyeongeumPhieuf = 0x0ef4

const XKB_KEY_Hangul_YeorinHieuh = 0x0ef5

const XKB_KEY_Hangul_AraeA = 0x0ef6

const XKB_KEY_Hangul_AraeAE = 0x0ef7

const XKB_KEY_Hangul_J_PanSios = 0x0ef8

const XKB_KEY_Hangul_J_KkogjiDalrinIeung = 0x0ef9

const XKB_KEY_Hangul_J_YeorinHieuh = 0x0efa

const XKB_KEY_Korean_Won = 0x0eff

const XKB_KEY_Armenian_ligature_ew = 0x01000587

const XKB_KEY_Armenian_full_stop = 0x01000589

const XKB_KEY_Armenian_verjaket = 0x01000589

const XKB_KEY_Armenian_separation_mark = 0x0100055d

const XKB_KEY_Armenian_but = 0x0100055d

const XKB_KEY_Armenian_hyphen = 0x0100058a

const XKB_KEY_Armenian_yentamna = 0x0100058a

const XKB_KEY_Armenian_exclam = 0x0100055c

const XKB_KEY_Armenian_amanak = 0x0100055c

const XKB_KEY_Armenian_accent = 0x0100055b

const XKB_KEY_Armenian_shesht = 0x0100055b

const XKB_KEY_Armenian_question = 0x0100055e

const XKB_KEY_Armenian_paruyk = 0x0100055e

const XKB_KEY_Armenian_AYB = 0x01000531

const XKB_KEY_Armenian_ayb = 0x01000561

const XKB_KEY_Armenian_BEN = 0x01000532

const XKB_KEY_Armenian_ben = 0x01000562

const XKB_KEY_Armenian_GIM = 0x01000533

const XKB_KEY_Armenian_gim = 0x01000563

const XKB_KEY_Armenian_DA = 0x01000534

const XKB_KEY_Armenian_da = 0x01000564

const XKB_KEY_Armenian_YECH = 0x01000535

const XKB_KEY_Armenian_yech = 0x01000565

const XKB_KEY_Armenian_ZA = 0x01000536

const XKB_KEY_Armenian_za = 0x01000566

const XKB_KEY_Armenian_E = 0x01000537

const XKB_KEY_Armenian_e = 0x01000567

const XKB_KEY_Armenian_AT = 0x01000538

const XKB_KEY_Armenian_at = 0x01000568

const XKB_KEY_Armenian_TO = 0x01000539

const XKB_KEY_Armenian_to = 0x01000569

const XKB_KEY_Armenian_ZHE = 0x0100053a

const XKB_KEY_Armenian_zhe = 0x0100056a

const XKB_KEY_Armenian_INI = 0x0100053b

const XKB_KEY_Armenian_ini = 0x0100056b

const XKB_KEY_Armenian_LYUN = 0x0100053c

const XKB_KEY_Armenian_lyun = 0x0100056c

const XKB_KEY_Armenian_KHE = 0x0100053d

const XKB_KEY_Armenian_khe = 0x0100056d

const XKB_KEY_Armenian_TSA = 0x0100053e

const XKB_KEY_Armenian_tsa = 0x0100056e

const XKB_KEY_Armenian_KEN = 0x0100053f

const XKB_KEY_Armenian_ken = 0x0100056f

const XKB_KEY_Armenian_HO = 0x01000540

const XKB_KEY_Armenian_ho = 0x01000570

const XKB_KEY_Armenian_DZA = 0x01000541

const XKB_KEY_Armenian_dza = 0x01000571

const XKB_KEY_Armenian_GHAT = 0x01000542

const XKB_KEY_Armenian_ghat = 0x01000572

const XKB_KEY_Armenian_TCHE = 0x01000543

const XKB_KEY_Armenian_tche = 0x01000573

const XKB_KEY_Armenian_MEN = 0x01000544

const XKB_KEY_Armenian_men = 0x01000574

const XKB_KEY_Armenian_HI = 0x01000545

const XKB_KEY_Armenian_hi = 0x01000575

const XKB_KEY_Armenian_NU = 0x01000546

const XKB_KEY_Armenian_nu = 0x01000576

const XKB_KEY_Armenian_SHA = 0x01000547

const XKB_KEY_Armenian_sha = 0x01000577

const XKB_KEY_Armenian_VO = 0x01000548

const XKB_KEY_Armenian_vo = 0x01000578

const XKB_KEY_Armenian_CHA = 0x01000549

const XKB_KEY_Armenian_cha = 0x01000579

const XKB_KEY_Armenian_PE = 0x0100054a

const XKB_KEY_Armenian_pe = 0x0100057a

const XKB_KEY_Armenian_JE = 0x0100054b

const XKB_KEY_Armenian_je = 0x0100057b

const XKB_KEY_Armenian_RA = 0x0100054c

const XKB_KEY_Armenian_ra = 0x0100057c

const XKB_KEY_Armenian_SE = 0x0100054d

const XKB_KEY_Armenian_se = 0x0100057d

const XKB_KEY_Armenian_VEV = 0x0100054e

const XKB_KEY_Armenian_vev = 0x0100057e

const XKB_KEY_Armenian_TYUN = 0x0100054f

const XKB_KEY_Armenian_tyun = 0x0100057f

const XKB_KEY_Armenian_RE = 0x01000550

const XKB_KEY_Armenian_re = 0x01000580

const XKB_KEY_Armenian_TSO = 0x01000551

const XKB_KEY_Armenian_tso = 0x01000581

const XKB_KEY_Armenian_VYUN = 0x01000552

const XKB_KEY_Armenian_vyun = 0x01000582

const XKB_KEY_Armenian_PYUR = 0x01000553

const XKB_KEY_Armenian_pyur = 0x01000583

const XKB_KEY_Armenian_KE = 0x01000554

const XKB_KEY_Armenian_ke = 0x01000584

const XKB_KEY_Armenian_O = 0x01000555

const XKB_KEY_Armenian_o = 0x01000585

const XKB_KEY_Armenian_FE = 0x01000556

const XKB_KEY_Armenian_fe = 0x01000586

const XKB_KEY_Armenian_apostrophe = 0x0100055a

const XKB_KEY_Georgian_an = 0x010010d0

const XKB_KEY_Georgian_ban = 0x010010d1

const XKB_KEY_Georgian_gan = 0x010010d2

const XKB_KEY_Georgian_don = 0x010010d3

const XKB_KEY_Georgian_en = 0x010010d4

const XKB_KEY_Georgian_vin = 0x010010d5

const XKB_KEY_Georgian_zen = 0x010010d6

const XKB_KEY_Georgian_tan = 0x010010d7

const XKB_KEY_Georgian_in = 0x010010d8

const XKB_KEY_Georgian_kan = 0x010010d9

const XKB_KEY_Georgian_las = 0x010010da

const XKB_KEY_Georgian_man = 0x010010db

const XKB_KEY_Georgian_nar = 0x010010dc

const XKB_KEY_Georgian_on = 0x010010dd

const XKB_KEY_Georgian_par = 0x010010de

const XKB_KEY_Georgian_zhar = 0x010010df

const XKB_KEY_Georgian_rae = 0x010010e0

const XKB_KEY_Georgian_san = 0x010010e1

const XKB_KEY_Georgian_tar = 0x010010e2

const XKB_KEY_Georgian_un = 0x010010e3

const XKB_KEY_Georgian_phar = 0x010010e4

const XKB_KEY_Georgian_khar = 0x010010e5

const XKB_KEY_Georgian_ghan = 0x010010e6

const XKB_KEY_Georgian_qar = 0x010010e7

const XKB_KEY_Georgian_shin = 0x010010e8

const XKB_KEY_Georgian_chin = 0x010010e9

const XKB_KEY_Georgian_can = 0x010010ea

const XKB_KEY_Georgian_jil = 0x010010eb

const XKB_KEY_Georgian_cil = 0x010010ec

const XKB_KEY_Georgian_char = 0x010010ed

const XKB_KEY_Georgian_xan = 0x010010ee

const XKB_KEY_Georgian_jhan = 0x010010ef

const XKB_KEY_Georgian_hae = 0x010010f0

const XKB_KEY_Georgian_he = 0x010010f1

const XKB_KEY_Georgian_hie = 0x010010f2

const XKB_KEY_Georgian_we = 0x010010f3

const XKB_KEY_Georgian_har = 0x010010f4

const XKB_KEY_Georgian_hoe = 0x010010f5

const XKB_KEY_Georgian_fi = 0x010010f6

const XKB_KEY_Xabovedot = 0x01001e8a

const XKB_KEY_Ibreve = 0x0100012c

const XKB_KEY_Zstroke = 0x010001b5

const XKB_KEY_Gcaron = 0x010001e6

const XKB_KEY_Ocaron = 0x010001d1

const XKB_KEY_Obarred = 0x0100019f

const XKB_KEY_xabovedot = 0x01001e8b

const XKB_KEY_ibreve = 0x0100012d

const XKB_KEY_zstroke = 0x010001b6

const XKB_KEY_gcaron = 0x010001e7

const XKB_KEY_ocaron = 0x010001d2

const XKB_KEY_obarred = 0x01000275

const XKB_KEY_SCHWA = 0x0100018f

const XKB_KEY_schwa = 0x01000259

const XKB_KEY_EZH = 0x010001b7

const XKB_KEY_ezh = 0x01000292

const XKB_KEY_Lbelowdot = 0x01001e36

const XKB_KEY_lbelowdot = 0x01001e37

const XKB_KEY_Abelowdot = 0x01001ea0

const XKB_KEY_abelowdot = 0x01001ea1

const XKB_KEY_Ahook = 0x01001ea2

const XKB_KEY_ahook = 0x01001ea3

const XKB_KEY_Acircumflexacute = 0x01001ea4

const XKB_KEY_acircumflexacute = 0x01001ea5

const XKB_KEY_Acircumflexgrave = 0x01001ea6

const XKB_KEY_acircumflexgrave = 0x01001ea7

const XKB_KEY_Acircumflexhook = 0x01001ea8

const XKB_KEY_acircumflexhook = 0x01001ea9

const XKB_KEY_Acircumflextilde = 0x01001eaa

const XKB_KEY_acircumflextilde = 0x01001eab

const XKB_KEY_Acircumflexbelowdot = 0x01001eac

const XKB_KEY_acircumflexbelowdot = 0x01001ead

const XKB_KEY_Abreveacute = 0x01001eae

const XKB_KEY_abreveacute = 0x01001eaf

const XKB_KEY_Abrevegrave = 0x01001eb0

const XKB_KEY_abrevegrave = 0x01001eb1

const XKB_KEY_Abrevehook = 0x01001eb2

const XKB_KEY_abrevehook = 0x01001eb3

const XKB_KEY_Abrevetilde = 0x01001eb4

const XKB_KEY_abrevetilde = 0x01001eb5

const XKB_KEY_Abrevebelowdot = 0x01001eb6

const XKB_KEY_abrevebelowdot = 0x01001eb7

const XKB_KEY_Ebelowdot = 0x01001eb8

const XKB_KEY_ebelowdot = 0x01001eb9

const XKB_KEY_Ehook = 0x01001eba

const XKB_KEY_ehook = 0x01001ebb

const XKB_KEY_Etilde = 0x01001ebc

const XKB_KEY_etilde = 0x01001ebd

const XKB_KEY_Ecircumflexacute = 0x01001ebe

const XKB_KEY_ecircumflexacute = 0x01001ebf

const XKB_KEY_Ecircumflexgrave = 0x01001ec0

const XKB_KEY_ecircumflexgrave = 0x01001ec1

const XKB_KEY_Ecircumflexhook = 0x01001ec2

const XKB_KEY_ecircumflexhook = 0x01001ec3

const XKB_KEY_Ecircumflextilde = 0x01001ec4

const XKB_KEY_ecircumflextilde = 0x01001ec5

const XKB_KEY_Ecircumflexbelowdot = 0x01001ec6

const XKB_KEY_ecircumflexbelowdot = 0x01001ec7

const XKB_KEY_Ihook = 0x01001ec8

const XKB_KEY_ihook = 0x01001ec9

const XKB_KEY_Ibelowdot = 0x01001eca

const XKB_KEY_ibelowdot = 0x01001ecb

const XKB_KEY_Obelowdot = 0x01001ecc

const XKB_KEY_obelowdot = 0x01001ecd

const XKB_KEY_Ohook = 0x01001ece

const XKB_KEY_ohook = 0x01001ecf

const XKB_KEY_Ocircumflexacute = 0x01001ed0

const XKB_KEY_ocircumflexacute = 0x01001ed1

const XKB_KEY_Ocircumflexgrave = 0x01001ed2

const XKB_KEY_ocircumflexgrave = 0x01001ed3

const XKB_KEY_Ocircumflexhook = 0x01001ed4

const XKB_KEY_ocircumflexhook = 0x01001ed5

const XKB_KEY_Ocircumflextilde = 0x01001ed6

const XKB_KEY_ocircumflextilde = 0x01001ed7

const XKB_KEY_Ocircumflexbelowdot = 0x01001ed8

const XKB_KEY_ocircumflexbelowdot = 0x01001ed9

const XKB_KEY_Ohornacute = 0x01001eda

const XKB_KEY_ohornacute = 0x01001edb

const XKB_KEY_Ohorngrave = 0x01001edc

const XKB_KEY_ohorngrave = 0x01001edd

const XKB_KEY_Ohornhook = 0x01001ede

const XKB_KEY_ohornhook = 0x01001edf

const XKB_KEY_Ohorntilde = 0x01001ee0

const XKB_KEY_ohorntilde = 0x01001ee1

const XKB_KEY_Ohornbelowdot = 0x01001ee2

const XKB_KEY_ohornbelowdot = 0x01001ee3

const XKB_KEY_Ubelowdot = 0x01001ee4

const XKB_KEY_ubelowdot = 0x01001ee5

const XKB_KEY_Uhook = 0x01001ee6

const XKB_KEY_uhook = 0x01001ee7

const XKB_KEY_Uhornacute = 0x01001ee8

const XKB_KEY_uhornacute = 0x01001ee9

const XKB_KEY_Uhorngrave = 0x01001eea

const XKB_KEY_uhorngrave = 0x01001eeb

const XKB_KEY_Uhornhook = 0x01001eec

const XKB_KEY_uhornhook = 0x01001eed

const XKB_KEY_Uhorntilde = 0x01001eee

const XKB_KEY_uhorntilde = 0x01001eef

const XKB_KEY_Uhornbelowdot = 0x01001ef0

const XKB_KEY_uhornbelowdot = 0x01001ef1

const XKB_KEY_Ybelowdot = 0x01001ef4

const XKB_KEY_ybelowdot = 0x01001ef5

const XKB_KEY_Yhook = 0x01001ef6

const XKB_KEY_yhook = 0x01001ef7

const XKB_KEY_Ytilde = 0x01001ef8

const XKB_KEY_ytilde = 0x01001ef9

const XKB_KEY_Ohorn = 0x010001a0

const XKB_KEY_ohorn = 0x010001a1

const XKB_KEY_Uhorn = 0x010001af

const XKB_KEY_uhorn = 0x010001b0

const XKB_KEY_combining_tilde = 0x01000303

const XKB_KEY_combining_grave = 0x01000300

const XKB_KEY_combining_acute = 0x01000301

const XKB_KEY_combining_hook = 0x01000309

const XKB_KEY_combining_belowdot = 0x01000323

const XKB_KEY_EcuSign = 0x010020a0

const XKB_KEY_ColonSign = 0x010020a1

const XKB_KEY_CruzeiroSign = 0x010020a2

const XKB_KEY_FFrancSign = 0x010020a3

const XKB_KEY_LiraSign = 0x010020a4

const XKB_KEY_MillSign = 0x010020a5

const XKB_KEY_NairaSign = 0x010020a6

const XKB_KEY_PesetaSign = 0x010020a7

const XKB_KEY_RupeeSign = 0x010020a8

const XKB_KEY_WonSign = 0x010020a9

const XKB_KEY_NewSheqelSign = 0x010020aa

const XKB_KEY_DongSign = 0x010020ab

const XKB_KEY_EuroSign = 0x20ac

const XKB_KEY_zerosuperior = 0x01002070

const XKB_KEY_foursuperior = 0x01002074

const XKB_KEY_fivesuperior = 0x01002075

const XKB_KEY_sixsuperior = 0x01002076

const XKB_KEY_sevensuperior = 0x01002077

const XKB_KEY_eightsuperior = 0x01002078

const XKB_KEY_ninesuperior = 0x01002079

const XKB_KEY_zerosubscript = 0x01002080

const XKB_KEY_onesubscript = 0x01002081

const XKB_KEY_twosubscript = 0x01002082

const XKB_KEY_threesubscript = 0x01002083

const XKB_KEY_foursubscript = 0x01002084

const XKB_KEY_fivesubscript = 0x01002085

const XKB_KEY_sixsubscript = 0x01002086

const XKB_KEY_sevensubscript = 0x01002087

const XKB_KEY_eightsubscript = 0x01002088

const XKB_KEY_ninesubscript = 0x01002089

const XKB_KEY_partdifferential = 0x01002202

const XKB_KEY_emptyset = 0x01002205

const XKB_KEY_elementof = 0x01002208

const XKB_KEY_notelementof = 0x01002209

const XKB_KEY_containsas = 0x0100220b

const XKB_KEY_squareroot = 0x0100221a

const XKB_KEY_cuberoot = 0x0100221b

const XKB_KEY_fourthroot = 0x0100221c

const XKB_KEY_dintegral = 0x0100222c

const XKB_KEY_tintegral = 0x0100222d

const XKB_KEY_because = 0x01002235

const XKB_KEY_approxeq = 0x01002248

const XKB_KEY_notapproxeq = 0x01002247

const XKB_KEY_notidentical = 0x01002262

const XKB_KEY_stricteq = 0x01002263

const XKB_KEY_braille_dot_1 = 0xfff1

const XKB_KEY_braille_dot_2 = 0xfff2

const XKB_KEY_braille_dot_3 = 0xfff3

const XKB_KEY_braille_dot_4 = 0xfff4

const XKB_KEY_braille_dot_5 = 0xfff5

const XKB_KEY_braille_dot_6 = 0xfff6

const XKB_KEY_braille_dot_7 = 0xfff7

const XKB_KEY_braille_dot_8 = 0xfff8

const XKB_KEY_braille_dot_9 = 0xfff9

const XKB_KEY_braille_dot_10 = 0xfffa

const XKB_KEY_braille_blank = 0x01002800

const XKB_KEY_braille_dots_1 = 0x01002801

const XKB_KEY_braille_dots_2 = 0x01002802

const XKB_KEY_braille_dots_12 = 0x01002803

const XKB_KEY_braille_dots_3 = 0x01002804

const XKB_KEY_braille_dots_13 = 0x01002805

const XKB_KEY_braille_dots_23 = 0x01002806

const XKB_KEY_braille_dots_123 = 0x01002807

const XKB_KEY_braille_dots_4 = 0x01002808

const XKB_KEY_braille_dots_14 = 0x01002809

const XKB_KEY_braille_dots_24 = 0x0100280a

const XKB_KEY_braille_dots_124 = 0x0100280b

const XKB_KEY_braille_dots_34 = 0x0100280c

const XKB_KEY_braille_dots_134 = 0x0100280d

const XKB_KEY_braille_dots_234 = 0x0100280e

const XKB_KEY_braille_dots_1234 = 0x0100280f

const XKB_KEY_braille_dots_5 = 0x01002810

const XKB_KEY_braille_dots_15 = 0x01002811

const XKB_KEY_braille_dots_25 = 0x01002812

const XKB_KEY_braille_dots_125 = 0x01002813

const XKB_KEY_braille_dots_35 = 0x01002814

const XKB_KEY_braille_dots_135 = 0x01002815

const XKB_KEY_braille_dots_235 = 0x01002816

const XKB_KEY_braille_dots_1235 = 0x01002817

const XKB_KEY_braille_dots_45 = 0x01002818

const XKB_KEY_braille_dots_145 = 0x01002819

const XKB_KEY_braille_dots_245 = 0x0100281a

const XKB_KEY_braille_dots_1245 = 0x0100281b

const XKB_KEY_braille_dots_345 = 0x0100281c

const XKB_KEY_braille_dots_1345 = 0x0100281d

const XKB_KEY_braille_dots_2345 = 0x0100281e

const XKB_KEY_braille_dots_12345 = 0x0100281f

const XKB_KEY_braille_dots_6 = 0x01002820

const XKB_KEY_braille_dots_16 = 0x01002821

const XKB_KEY_braille_dots_26 = 0x01002822

const XKB_KEY_braille_dots_126 = 0x01002823

const XKB_KEY_braille_dots_36 = 0x01002824

const XKB_KEY_braille_dots_136 = 0x01002825

const XKB_KEY_braille_dots_236 = 0x01002826

const XKB_KEY_braille_dots_1236 = 0x01002827

const XKB_KEY_braille_dots_46 = 0x01002828

const XKB_KEY_braille_dots_146 = 0x01002829

const XKB_KEY_braille_dots_246 = 0x0100282a

const XKB_KEY_braille_dots_1246 = 0x0100282b

const XKB_KEY_braille_dots_346 = 0x0100282c

const XKB_KEY_braille_dots_1346 = 0x0100282d

const XKB_KEY_braille_dots_2346 = 0x0100282e

const XKB_KEY_braille_dots_12346 = 0x0100282f

const XKB_KEY_braille_dots_56 = 0x01002830

const XKB_KEY_braille_dots_156 = 0x01002831

const XKB_KEY_braille_dots_256 = 0x01002832

const XKB_KEY_braille_dots_1256 = 0x01002833

const XKB_KEY_braille_dots_356 = 0x01002834

const XKB_KEY_braille_dots_1356 = 0x01002835

const XKB_KEY_braille_dots_2356 = 0x01002836

const XKB_KEY_braille_dots_12356 = 0x01002837

const XKB_KEY_braille_dots_456 = 0x01002838

const XKB_KEY_braille_dots_1456 = 0x01002839

const XKB_KEY_braille_dots_2456 = 0x0100283a

const XKB_KEY_braille_dots_12456 = 0x0100283b

const XKB_KEY_braille_dots_3456 = 0x0100283c

const XKB_KEY_braille_dots_13456 = 0x0100283d

const XKB_KEY_braille_dots_23456 = 0x0100283e

const XKB_KEY_braille_dots_123456 = 0x0100283f

const XKB_KEY_braille_dots_7 = 0x01002840

const XKB_KEY_braille_dots_17 = 0x01002841

const XKB_KEY_braille_dots_27 = 0x01002842

const XKB_KEY_braille_dots_127 = 0x01002843

const XKB_KEY_braille_dots_37 = 0x01002844

const XKB_KEY_braille_dots_137 = 0x01002845

const XKB_KEY_braille_dots_237 = 0x01002846

const XKB_KEY_braille_dots_1237 = 0x01002847

const XKB_KEY_braille_dots_47 = 0x01002848

const XKB_KEY_braille_dots_147 = 0x01002849

const XKB_KEY_braille_dots_247 = 0x0100284a

const XKB_KEY_braille_dots_1247 = 0x0100284b

const XKB_KEY_braille_dots_347 = 0x0100284c

const XKB_KEY_braille_dots_1347 = 0x0100284d

const XKB_KEY_braille_dots_2347 = 0x0100284e

const XKB_KEY_braille_dots_12347 = 0x0100284f

const XKB_KEY_braille_dots_57 = 0x01002850

const XKB_KEY_braille_dots_157 = 0x01002851

const XKB_KEY_braille_dots_257 = 0x01002852

const XKB_KEY_braille_dots_1257 = 0x01002853

const XKB_KEY_braille_dots_357 = 0x01002854

const XKB_KEY_braille_dots_1357 = 0x01002855

const XKB_KEY_braille_dots_2357 = 0x01002856

const XKB_KEY_braille_dots_12357 = 0x01002857

const XKB_KEY_braille_dots_457 = 0x01002858

const XKB_KEY_braille_dots_1457 = 0x01002859

const XKB_KEY_braille_dots_2457 = 0x0100285a

const XKB_KEY_braille_dots_12457 = 0x0100285b

const XKB_KEY_braille_dots_3457 = 0x0100285c

const XKB_KEY_braille_dots_13457 = 0x0100285d

const XKB_KEY_braille_dots_23457 = 0x0100285e

const XKB_KEY_braille_dots_123457 = 0x0100285f

const XKB_KEY_braille_dots_67 = 0x01002860

const XKB_KEY_braille_dots_167 = 0x01002861

const XKB_KEY_braille_dots_267 = 0x01002862

const XKB_KEY_braille_dots_1267 = 0x01002863

const XKB_KEY_braille_dots_367 = 0x01002864

const XKB_KEY_braille_dots_1367 = 0x01002865

const XKB_KEY_braille_dots_2367 = 0x01002866

const XKB_KEY_braille_dots_12367 = 0x01002867

const XKB_KEY_braille_dots_467 = 0x01002868

const XKB_KEY_braille_dots_1467 = 0x01002869

const XKB_KEY_braille_dots_2467 = 0x0100286a

const XKB_KEY_braille_dots_12467 = 0x0100286b

const XKB_KEY_braille_dots_3467 = 0x0100286c

const XKB_KEY_braille_dots_13467 = 0x0100286d

const XKB_KEY_braille_dots_23467 = 0x0100286e

const XKB_KEY_braille_dots_123467 = 0x0100286f

const XKB_KEY_braille_dots_567 = 0x01002870

const XKB_KEY_braille_dots_1567 = 0x01002871

const XKB_KEY_braille_dots_2567 = 0x01002872

const XKB_KEY_braille_dots_12567 = 0x01002873

const XKB_KEY_braille_dots_3567 = 0x01002874

const XKB_KEY_braille_dots_13567 = 0x01002875

const XKB_KEY_braille_dots_23567 = 0x01002876

const XKB_KEY_braille_dots_123567 = 0x01002877

const XKB_KEY_braille_dots_4567 = 0x01002878

const XKB_KEY_braille_dots_14567 = 0x01002879

const XKB_KEY_braille_dots_24567 = 0x0100287a

const XKB_KEY_braille_dots_124567 = 0x0100287b

const XKB_KEY_braille_dots_34567 = 0x0100287c

const XKB_KEY_braille_dots_134567 = 0x0100287d

const XKB_KEY_braille_dots_234567 = 0x0100287e

const XKB_KEY_braille_dots_1234567 = 0x0100287f

const XKB_KEY_braille_dots_8 = 0x01002880

const XKB_KEY_braille_dots_18 = 0x01002881

const XKB_KEY_braille_dots_28 = 0x01002882

const XKB_KEY_braille_dots_128 = 0x01002883

const XKB_KEY_braille_dots_38 = 0x01002884

const XKB_KEY_braille_dots_138 = 0x01002885

const XKB_KEY_braille_dots_238 = 0x01002886

const XKB_KEY_braille_dots_1238 = 0x01002887

const XKB_KEY_braille_dots_48 = 0x01002888

const XKB_KEY_braille_dots_148 = 0x01002889

const XKB_KEY_braille_dots_248 = 0x0100288a

const XKB_KEY_braille_dots_1248 = 0x0100288b

const XKB_KEY_braille_dots_348 = 0x0100288c

const XKB_KEY_braille_dots_1348 = 0x0100288d

const XKB_KEY_braille_dots_2348 = 0x0100288e

const XKB_KEY_braille_dots_12348 = 0x0100288f

const XKB_KEY_braille_dots_58 = 0x01002890

const XKB_KEY_braille_dots_158 = 0x01002891

const XKB_KEY_braille_dots_258 = 0x01002892

const XKB_KEY_braille_dots_1258 = 0x01002893

const XKB_KEY_braille_dots_358 = 0x01002894

const XKB_KEY_braille_dots_1358 = 0x01002895

const XKB_KEY_braille_dots_2358 = 0x01002896

const XKB_KEY_braille_dots_12358 = 0x01002897

const XKB_KEY_braille_dots_458 = 0x01002898

const XKB_KEY_braille_dots_1458 = 0x01002899

const XKB_KEY_braille_dots_2458 = 0x0100289a

const XKB_KEY_braille_dots_12458 = 0x0100289b

const XKB_KEY_braille_dots_3458 = 0x0100289c

const XKB_KEY_braille_dots_13458 = 0x0100289d

const XKB_KEY_braille_dots_23458 = 0x0100289e

const XKB_KEY_braille_dots_123458 = 0x0100289f

const XKB_KEY_braille_dots_68 = 0x010028a0

const XKB_KEY_braille_dots_168 = 0x010028a1

const XKB_KEY_braille_dots_268 = 0x010028a2

const XKB_KEY_braille_dots_1268 = 0x010028a3

const XKB_KEY_braille_dots_368 = 0x010028a4

const XKB_KEY_braille_dots_1368 = 0x010028a5

const XKB_KEY_braille_dots_2368 = 0x010028a6

const XKB_KEY_braille_dots_12368 = 0x010028a7

const XKB_KEY_braille_dots_468 = 0x010028a8

const XKB_KEY_braille_dots_1468 = 0x010028a9

const XKB_KEY_braille_dots_2468 = 0x010028aa

const XKB_KEY_braille_dots_12468 = 0x010028ab

const XKB_KEY_braille_dots_3468 = 0x010028ac

const XKB_KEY_braille_dots_13468 = 0x010028ad

const XKB_KEY_braille_dots_23468 = 0x010028ae

const XKB_KEY_braille_dots_123468 = 0x010028af

const XKB_KEY_braille_dots_568 = 0x010028b0

const XKB_KEY_braille_dots_1568 = 0x010028b1

const XKB_KEY_braille_dots_2568 = 0x010028b2

const XKB_KEY_braille_dots_12568 = 0x010028b3

const XKB_KEY_braille_dots_3568 = 0x010028b4

const XKB_KEY_braille_dots_13568 = 0x010028b5

const XKB_KEY_braille_dots_23568 = 0x010028b6

const XKB_KEY_braille_dots_123568 = 0x010028b7

const XKB_KEY_braille_dots_4568 = 0x010028b8

const XKB_KEY_braille_dots_14568 = 0x010028b9

const XKB_KEY_braille_dots_24568 = 0x010028ba

const XKB_KEY_braille_dots_124568 = 0x010028bb

const XKB_KEY_braille_dots_34568 = 0x010028bc

const XKB_KEY_braille_dots_134568 = 0x010028bd

const XKB_KEY_braille_dots_234568 = 0x010028be

const XKB_KEY_braille_dots_1234568 = 0x010028bf

const XKB_KEY_braille_dots_78 = 0x010028c0

const XKB_KEY_braille_dots_178 = 0x010028c1

const XKB_KEY_braille_dots_278 = 0x010028c2

const XKB_KEY_braille_dots_1278 = 0x010028c3

const XKB_KEY_braille_dots_378 = 0x010028c4

const XKB_KEY_braille_dots_1378 = 0x010028c5

const XKB_KEY_braille_dots_2378 = 0x010028c6

const XKB_KEY_braille_dots_12378 = 0x010028c7

const XKB_KEY_braille_dots_478 = 0x010028c8

const XKB_KEY_braille_dots_1478 = 0x010028c9

const XKB_KEY_braille_dots_2478 = 0x010028ca

const XKB_KEY_braille_dots_12478 = 0x010028cb

const XKB_KEY_braille_dots_3478 = 0x010028cc

const XKB_KEY_braille_dots_13478 = 0x010028cd

const XKB_KEY_braille_dots_23478 = 0x010028ce

const XKB_KEY_braille_dots_123478 = 0x010028cf

const XKB_KEY_braille_dots_578 = 0x010028d0

const XKB_KEY_braille_dots_1578 = 0x010028d1

const XKB_KEY_braille_dots_2578 = 0x010028d2

const XKB_KEY_braille_dots_12578 = 0x010028d3

const XKB_KEY_braille_dots_3578 = 0x010028d4

const XKB_KEY_braille_dots_13578 = 0x010028d5

const XKB_KEY_braille_dots_23578 = 0x010028d6

const XKB_KEY_braille_dots_123578 = 0x010028d7

const XKB_KEY_braille_dots_4578 = 0x010028d8

const XKB_KEY_braille_dots_14578 = 0x010028d9

const XKB_KEY_braille_dots_24578 = 0x010028da

const XKB_KEY_braille_dots_124578 = 0x010028db

const XKB_KEY_braille_dots_34578 = 0x010028dc

const XKB_KEY_braille_dots_134578 = 0x010028dd

const XKB_KEY_braille_dots_234578 = 0x010028de

const XKB_KEY_braille_dots_1234578 = 0x010028df

const XKB_KEY_braille_dots_678 = 0x010028e0

const XKB_KEY_braille_dots_1678 = 0x010028e1

const XKB_KEY_braille_dots_2678 = 0x010028e2

const XKB_KEY_braille_dots_12678 = 0x010028e3

const XKB_KEY_braille_dots_3678 = 0x010028e4

const XKB_KEY_braille_dots_13678 = 0x010028e5

const XKB_KEY_braille_dots_23678 = 0x010028e6

const XKB_KEY_braille_dots_123678 = 0x010028e7

const XKB_KEY_braille_dots_4678 = 0x010028e8

const XKB_KEY_braille_dots_14678 = 0x010028e9

const XKB_KEY_braille_dots_24678 = 0x010028ea

const XKB_KEY_braille_dots_124678 = 0x010028eb

const XKB_KEY_braille_dots_34678 = 0x010028ec

const XKB_KEY_braille_dots_134678 = 0x010028ed

const XKB_KEY_braille_dots_234678 = 0x010028ee

const XKB_KEY_braille_dots_1234678 = 0x010028ef

const XKB_KEY_braille_dots_5678 = 0x010028f0

const XKB_KEY_braille_dots_15678 = 0x010028f1

const XKB_KEY_braille_dots_25678 = 0x010028f2

const XKB_KEY_braille_dots_125678 = 0x010028f3

const XKB_KEY_braille_dots_35678 = 0x010028f4

const XKB_KEY_braille_dots_135678 = 0x010028f5

const XKB_KEY_braille_dots_235678 = 0x010028f6

const XKB_KEY_braille_dots_1235678 = 0x010028f7

const XKB_KEY_braille_dots_45678 = 0x010028f8

const XKB_KEY_braille_dots_145678 = 0x010028f9

const XKB_KEY_braille_dots_245678 = 0x010028fa

const XKB_KEY_braille_dots_1245678 = 0x010028fb

const XKB_KEY_braille_dots_345678 = 0x010028fc

const XKB_KEY_braille_dots_1345678 = 0x010028fd

const XKB_KEY_braille_dots_2345678 = 0x010028fe

const XKB_KEY_braille_dots_12345678 = 0x010028ff

const XKB_KEY_Sinh_ng = 0x01000d82

const XKB_KEY_Sinh_h2 = 0x01000d83

const XKB_KEY_Sinh_a = 0x01000d85

const XKB_KEY_Sinh_aa = 0x01000d86

const XKB_KEY_Sinh_ae = 0x01000d87

const XKB_KEY_Sinh_aee = 0x01000d88

const XKB_KEY_Sinh_i = 0x01000d89

const XKB_KEY_Sinh_ii = 0x01000d8a

const XKB_KEY_Sinh_u = 0x01000d8b

const XKB_KEY_Sinh_uu = 0x01000d8c

const XKB_KEY_Sinh_ri = 0x01000d8d

const XKB_KEY_Sinh_rii = 0x01000d8e

const XKB_KEY_Sinh_lu = 0x01000d8f

const XKB_KEY_Sinh_luu = 0x01000d90

const XKB_KEY_Sinh_e = 0x01000d91

const XKB_KEY_Sinh_ee = 0x01000d92

const XKB_KEY_Sinh_ai = 0x01000d93

const XKB_KEY_Sinh_o = 0x01000d94

const XKB_KEY_Sinh_oo = 0x01000d95

const XKB_KEY_Sinh_au = 0x01000d96

const XKB_KEY_Sinh_ka = 0x01000d9a

const XKB_KEY_Sinh_kha = 0x01000d9b

const XKB_KEY_Sinh_ga = 0x01000d9c

const XKB_KEY_Sinh_gha = 0x01000d9d

const XKB_KEY_Sinh_ng2 = 0x01000d9e

const XKB_KEY_Sinh_nga = 0x01000d9f

const XKB_KEY_Sinh_ca = 0x01000da0

const XKB_KEY_Sinh_cha = 0x01000da1

const XKB_KEY_Sinh_ja = 0x01000da2

const XKB_KEY_Sinh_jha = 0x01000da3

const XKB_KEY_Sinh_nya = 0x01000da4

const XKB_KEY_Sinh_jnya = 0x01000da5

const XKB_KEY_Sinh_nja = 0x01000da6

const XKB_KEY_Sinh_tta = 0x01000da7

const XKB_KEY_Sinh_ttha = 0x01000da8

const XKB_KEY_Sinh_dda = 0x01000da9

const XKB_KEY_Sinh_ddha = 0x01000daa

const XKB_KEY_Sinh_nna = 0x01000dab

const XKB_KEY_Sinh_ndda = 0x01000dac

const XKB_KEY_Sinh_tha = 0x01000dad

const XKB_KEY_Sinh_thha = 0x01000dae

const XKB_KEY_Sinh_dha = 0x01000daf

const XKB_KEY_Sinh_dhha = 0x01000db0

const XKB_KEY_Sinh_na = 0x01000db1

const XKB_KEY_Sinh_ndha = 0x01000db3

const XKB_KEY_Sinh_pa = 0x01000db4

const XKB_KEY_Sinh_pha = 0x01000db5

const XKB_KEY_Sinh_ba = 0x01000db6

const XKB_KEY_Sinh_bha = 0x01000db7

const XKB_KEY_Sinh_ma = 0x01000db8

const XKB_KEY_Sinh_mba = 0x01000db9

const XKB_KEY_Sinh_ya = 0x01000dba

const XKB_KEY_Sinh_ra = 0x01000dbb

const XKB_KEY_Sinh_la = 0x01000dbd

const XKB_KEY_Sinh_va = 0x01000dc0

const XKB_KEY_Sinh_sha = 0x01000dc1

const XKB_KEY_Sinh_ssha = 0x01000dc2

const XKB_KEY_Sinh_sa = 0x01000dc3

const XKB_KEY_Sinh_ha = 0x01000dc4

const XKB_KEY_Sinh_lla = 0x01000dc5

const XKB_KEY_Sinh_fa = 0x01000dc6

const XKB_KEY_Sinh_al = 0x01000dca

const XKB_KEY_Sinh_aa2 = 0x01000dcf

const XKB_KEY_Sinh_ae2 = 0x01000dd0

const XKB_KEY_Sinh_aee2 = 0x01000dd1

const XKB_KEY_Sinh_i2 = 0x01000dd2

const XKB_KEY_Sinh_ii2 = 0x01000dd3

const XKB_KEY_Sinh_u2 = 0x01000dd4

const XKB_KEY_Sinh_uu2 = 0x01000dd6

const XKB_KEY_Sinh_ru2 = 0x01000dd8

const XKB_KEY_Sinh_e2 = 0x01000dd9

const XKB_KEY_Sinh_ee2 = 0x01000dda

const XKB_KEY_Sinh_ai2 = 0x01000ddb

const XKB_KEY_Sinh_o2 = 0x01000ddc

const XKB_KEY_Sinh_oo2 = 0x01000ddd

const XKB_KEY_Sinh_au2 = 0x01000dde

const XKB_KEY_Sinh_lu2 = 0x01000ddf

const XKB_KEY_Sinh_ruu2 = 0x01000df2

const XKB_KEY_Sinh_luu2 = 0x01000df3

const XKB_KEY_Sinh_kunddaliya = 0x01000df4

const XKB_KEY_XF86ModeLock = 0x1008ff01

const XKB_KEY_XF86MonBrightnessUp = 0x1008ff02

const XKB_KEY_XF86MonBrightnessDown = 0x1008ff03

const XKB_KEY_XF86KbdLightOnOff = 0x1008ff04

const XKB_KEY_XF86KbdBrightnessUp = 0x1008ff05

const XKB_KEY_XF86KbdBrightnessDown = 0x1008ff06

const XKB_KEY_XF86MonBrightnessCycle = 0x1008ff07

const XKB_KEY_XF86Standby = 0x1008ff10

const XKB_KEY_XF86AudioLowerVolume = 0x1008ff11

const XKB_KEY_XF86AudioMute = 0x1008ff12

const XKB_KEY_XF86AudioRaiseVolume = 0x1008ff13

const XKB_KEY_XF86AudioPlay = 0x1008ff14

const XKB_KEY_XF86AudioStop = 0x1008ff15

const XKB_KEY_XF86AudioPrev = 0x1008ff16

const XKB_KEY_XF86AudioNext = 0x1008ff17

const XKB_KEY_XF86HomePage = 0x1008ff18

const XKB_KEY_XF86Mail = 0x1008ff19

const XKB_KEY_XF86Start = 0x1008ff1a

const XKB_KEY_XF86Search = 0x1008ff1b

const XKB_KEY_XF86AudioRecord = 0x1008ff1c

const XKB_KEY_XF86Calculator = 0x1008ff1d

const XKB_KEY_XF86Memo = 0x1008ff1e

const XKB_KEY_XF86ToDoList = 0x1008ff1f

const XKB_KEY_XF86Calendar = 0x1008ff20

const XKB_KEY_XF86PowerDown = 0x1008ff21

const XKB_KEY_XF86ContrastAdjust = 0x1008ff22

const XKB_KEY_XF86RockerUp = 0x1008ff23

const XKB_KEY_XF86RockerDown = 0x1008ff24

const XKB_KEY_XF86RockerEnter = 0x1008ff25

const XKB_KEY_XF86Back = 0x1008ff26

const XKB_KEY_XF86Forward = 0x1008ff27

const XKB_KEY_XF86Stop = 0x1008ff28

const XKB_KEY_XF86Refresh = 0x1008ff29

const XKB_KEY_XF86PowerOff = 0x1008ff2a

const XKB_KEY_XF86WakeUp = 0x1008ff2b

const XKB_KEY_XF86Eject = 0x1008ff2c

const XKB_KEY_XF86ScreenSaver = 0x1008ff2d

const XKB_KEY_XF86WWW = 0x1008ff2e

const XKB_KEY_XF86Sleep = 0x1008ff2f

const XKB_KEY_XF86Favorites = 0x1008ff30

const XKB_KEY_XF86AudioPause = 0x1008ff31

const XKB_KEY_XF86AudioMedia = 0x1008ff32

const XKB_KEY_XF86MyComputer = 0x1008ff33

const XKB_KEY_XF86VendorHome = 0x1008ff34

const XKB_KEY_XF86LightBulb = 0x1008ff35

const XKB_KEY_XF86Shop = 0x1008ff36

const XKB_KEY_XF86History = 0x1008ff37

const XKB_KEY_XF86OpenURL = 0x1008ff38

const XKB_KEY_XF86AddFavorite = 0x1008ff39

const XKB_KEY_XF86HotLinks = 0x1008ff3a

const XKB_KEY_XF86BrightnessAdjust = 0x1008ff3b

const XKB_KEY_XF86Finance = 0x1008ff3c

const XKB_KEY_XF86Community = 0x1008ff3d

const XKB_KEY_XF86AudioRewind = 0x1008ff3e

const XKB_KEY_XF86BackForward = 0x1008ff3f

const XKB_KEY_XF86Launch0 = 0x1008ff40

const XKB_KEY_XF86Launch1 = 0x1008ff41

const XKB_KEY_XF86Launch2 = 0x1008ff42

const XKB_KEY_XF86Launch3 = 0x1008ff43

const XKB_KEY_XF86Launch4 = 0x1008ff44

const XKB_KEY_XF86Launch5 = 0x1008ff45

const XKB_KEY_XF86Launch6 = 0x1008ff46

const XKB_KEY_XF86Launch7 = 0x1008ff47

const XKB_KEY_XF86Launch8 = 0x1008ff48

const XKB_KEY_XF86Launch9 = 0x1008ff49

const XKB_KEY_XF86LaunchA = 0x1008ff4a

const XKB_KEY_XF86LaunchB = 0x1008ff4b

const XKB_KEY_XF86LaunchC = 0x1008ff4c

const XKB_KEY_XF86LaunchD = 0x1008ff4d

const XKB_KEY_XF86LaunchE = 0x1008ff4e

const XKB_KEY_XF86LaunchF = 0x1008ff4f

const XKB_KEY_XF86ApplicationLeft = 0x1008ff50

const XKB_KEY_XF86ApplicationRight = 0x1008ff51

const XKB_KEY_XF86Book = 0x1008ff52

const XKB_KEY_XF86CD = 0x1008ff53

const XKB_KEY_XF86Calculater = 0x1008ff54

const XKB_KEY_XF86Clear = 0x1008ff55

const XKB_KEY_XF86Close = 0x1008ff56

const XKB_KEY_XF86Copy = 0x1008ff57

const XKB_KEY_XF86Cut = 0x1008ff58

const XKB_KEY_XF86Display = 0x1008ff59

const XKB_KEY_XF86DOS = 0x1008ff5a

const XKB_KEY_XF86Documents = 0x1008ff5b

const XKB_KEY_XF86Excel = 0x1008ff5c

const XKB_KEY_XF86Explorer = 0x1008ff5d

const XKB_KEY_XF86Game = 0x1008ff5e

const XKB_KEY_XF86Go = 0x1008ff5f

const XKB_KEY_XF86iTouch = 0x1008ff60

const XKB_KEY_XF86LogOff = 0x1008ff61

const XKB_KEY_XF86Market = 0x1008ff62

const XKB_KEY_XF86Meeting = 0x1008ff63

const XKB_KEY_XF86MenuKB = 0x1008ff65

const XKB_KEY_XF86MenuPB = 0x1008ff66

const XKB_KEY_XF86MySites = 0x1008ff67

const XKB_KEY_XF86New = 0x1008ff68

const XKB_KEY_XF86News = 0x1008ff69

const XKB_KEY_XF86OfficeHome = 0x1008ff6a

const XKB_KEY_XF86Open = 0x1008ff6b

const XKB_KEY_XF86Option = 0x1008ff6c

const XKB_KEY_XF86Paste = 0x1008ff6d

const XKB_KEY_XF86Phone = 0x1008ff6e

const XKB_KEY_XF86Q = 0x1008ff70

const XKB_KEY_XF86Reply = 0x1008ff72

const XKB_KEY_XF86Reload = 0x1008ff73

const XKB_KEY_XF86RotateWindows = 0x1008ff74

const XKB_KEY_XF86RotationPB = 0x1008ff75

const XKB_KEY_XF86RotationKB = 0x1008ff76

const XKB_KEY_XF86Save = 0x1008ff77

const XKB_KEY_XF86ScrollUp = 0x1008ff78

const XKB_KEY_XF86ScrollDown = 0x1008ff79

const XKB_KEY_XF86ScrollClick = 0x1008ff7a

const XKB_KEY_XF86Send = 0x1008ff7b

const XKB_KEY_XF86Spell = 0x1008ff7c

const XKB_KEY_XF86SplitScreen = 0x1008ff7d

const XKB_KEY_XF86Support = 0x1008ff7e

const XKB_KEY_XF86TaskPane = 0x1008ff7f

const XKB_KEY_XF86Terminal = 0x1008ff80

const XKB_KEY_XF86Tools = 0x1008ff81

const XKB_KEY_XF86Travel = 0x1008ff82

const XKB_KEY_XF86UserPB = 0x1008ff84

const XKB_KEY_XF86User1KB = 0x1008ff85

const XKB_KEY_XF86User2KB = 0x1008ff86

const XKB_KEY_XF86Video = 0x1008ff87

const XKB_KEY_XF86WheelButton = 0x1008ff88

const XKB_KEY_XF86Word = 0x1008ff89

const XKB_KEY_XF86Xfer = 0x1008ff8a

const XKB_KEY_XF86ZoomIn = 0x1008ff8b

const XKB_KEY_XF86ZoomOut = 0x1008ff8c

const XKB_KEY_XF86Away = 0x1008ff8d

const XKB_KEY_XF86Messenger = 0x1008ff8e

const XKB_KEY_XF86WebCam = 0x1008ff8f

const XKB_KEY_XF86MailForward = 0x1008ff90

const XKB_KEY_XF86Pictures = 0x1008ff91

const XKB_KEY_XF86Music = 0x1008ff92

const XKB_KEY_XF86Battery = 0x1008ff93

const XKB_KEY_XF86Bluetooth = 0x1008ff94

const XKB_KEY_XF86WLAN = 0x1008ff95

const XKB_KEY_XF86UWB = 0x1008ff96

const XKB_KEY_XF86AudioForward = 0x1008ff97

const XKB_KEY_XF86AudioRepeat = 0x1008ff98

const XKB_KEY_XF86AudioRandomPlay = 0x1008ff99

const XKB_KEY_XF86Subtitle = 0x1008ff9a

const XKB_KEY_XF86AudioCycleTrack = 0x1008ff9b

const XKB_KEY_XF86CycleAngle = 0x1008ff9c

const XKB_KEY_XF86FrameBack = 0x1008ff9d

const XKB_KEY_XF86FrameForward = 0x1008ff9e

const XKB_KEY_XF86Time = 0x1008ff9f

const XKB_KEY_XF86Select = 0x1008ffa0

const XKB_KEY_XF86View = 0x1008ffa1

const XKB_KEY_XF86TopMenu = 0x1008ffa2

const XKB_KEY_XF86Red = 0x1008ffa3

const XKB_KEY_XF86Green = 0x1008ffa4

const XKB_KEY_XF86Yellow = 0x1008ffa5

const XKB_KEY_XF86Blue = 0x1008ffa6

const XKB_KEY_XF86Suspend = 0x1008ffa7

const XKB_KEY_XF86Hibernate = 0x1008ffa8

const XKB_KEY_XF86TouchpadToggle = 0x1008ffa9

const XKB_KEY_XF86TouchpadOn = 0x1008ffb0

const XKB_KEY_XF86TouchpadOff = 0x1008ffb1

const XKB_KEY_XF86AudioMicMute = 0x1008ffb2

const XKB_KEY_XF86Keyboard = 0x1008ffb3

const XKB_KEY_XF86WWAN = 0x1008ffb4

const XKB_KEY_XF86RFKill = 0x1008ffb5

const XKB_KEY_XF86AudioPreset = 0x1008ffb6

const XKB_KEY_XF86RotationLockToggle = 0x1008ffb7

const XKB_KEY_XF86FullScreen = 0x1008ffb8

const XKB_KEY_XF86Switch_VT_1 = 0x1008fe01

const XKB_KEY_XF86Switch_VT_2 = 0x1008fe02

const XKB_KEY_XF86Switch_VT_3 = 0x1008fe03

const XKB_KEY_XF86Switch_VT_4 = 0x1008fe04

const XKB_KEY_XF86Switch_VT_5 = 0x1008fe05

const XKB_KEY_XF86Switch_VT_6 = 0x1008fe06

const XKB_KEY_XF86Switch_VT_7 = 0x1008fe07

const XKB_KEY_XF86Switch_VT_8 = 0x1008fe08

const XKB_KEY_XF86Switch_VT_9 = 0x1008fe09

const XKB_KEY_XF86Switch_VT_10 = 0x1008fe0a

const XKB_KEY_XF86Switch_VT_11 = 0x1008fe0b

const XKB_KEY_XF86Switch_VT_12 = 0x1008fe0c

const XKB_KEY_XF86Ungrab = 0x1008fe20

const XKB_KEY_XF86ClearGrab = 0x1008fe21

const XKB_KEY_XF86Next_VMode = 0x1008fe22

const XKB_KEY_XF86Prev_VMode = 0x1008fe23

const XKB_KEY_XF86LogWindowTree = 0x1008fe24

const XKB_KEY_XF86LogGrabInfo = 0x1008fe25

const XKB_KEY_XF86BrightnessAuto = 0x100810f4

const XKB_KEY_XF86DisplayOff = 0x100810f5

const XKB_KEY_XF86Info = 0x10081166

const XKB_KEY_XF86AspectRatio = 0x10081177

const XKB_KEY_XF86DVD = 0x10081185

const XKB_KEY_XF86Audio = 0x10081188

const XKB_KEY_XF86ChannelUp = 0x10081192

const XKB_KEY_XF86ChannelDown = 0x10081193

const XKB_KEY_XF86Break = 0x1008119b

const XKB_KEY_XF86VideoPhone = 0x100811a0

const XKB_KEY_XF86ZoomReset = 0x100811a4

const XKB_KEY_XF86Editor = 0x100811a6

const XKB_KEY_XF86GraphicsEditor = 0x100811a8

const XKB_KEY_XF86Presentation = 0x100811a9

const XKB_KEY_XF86Database = 0x100811aa

const XKB_KEY_XF86Voicemail = 0x100811ac

const XKB_KEY_XF86Addressbook = 0x100811ad

const XKB_KEY_XF86DisplayToggle = 0x100811af

const XKB_KEY_XF86SpellCheck = 0x100811b0

const XKB_KEY_XF86ContextMenu = 0x100811b6

const XKB_KEY_XF86MediaRepeat = 0x100811b7

const XKB_KEY_XF8610ChannelsUp = 0x100811b8

const XKB_KEY_XF8610ChannelsDown = 0x100811b9

const XKB_KEY_XF86Images = 0x100811ba

const XKB_KEY_XF86NotificationCenter = 0x100811bc

const XKB_KEY_XF86PickupPhone = 0x100811bd

const XKB_KEY_XF86HangupPhone = 0x100811be

const XKB_KEY_XF86Fn = 0x100811d0

const XKB_KEY_XF86Fn_Esc = 0x100811d1

const XKB_KEY_XF86FnRightShift = 0x100811e5

const XKB_KEY_XF86Numeric0 = 0x10081200

const XKB_KEY_XF86Numeric1 = 0x10081201

const XKB_KEY_XF86Numeric2 = 0x10081202

const XKB_KEY_XF86Numeric3 = 0x10081203

const XKB_KEY_XF86Numeric4 = 0x10081204

const XKB_KEY_XF86Numeric5 = 0x10081205

const XKB_KEY_XF86Numeric6 = 0x10081206

const XKB_KEY_XF86Numeric7 = 0x10081207

const XKB_KEY_XF86Numeric8 = 0x10081208

const XKB_KEY_XF86Numeric9 = 0x10081209

const XKB_KEY_XF86NumericStar = 0x1008120a

const XKB_KEY_XF86NumericPound = 0x1008120b

const XKB_KEY_XF86NumericA = 0x1008120c

const XKB_KEY_XF86NumericB = 0x1008120d

const XKB_KEY_XF86NumericC = 0x1008120e

const XKB_KEY_XF86NumericD = 0x1008120f

const XKB_KEY_XF86CameraFocus = 0x10081210

const XKB_KEY_XF86WPSButton = 0x10081211

const XKB_KEY_XF86CameraZoomIn = 0x10081215

const XKB_KEY_XF86CameraZoomOut = 0x10081216

const XKB_KEY_XF86CameraUp = 0x10081217

const XKB_KEY_XF86CameraDown = 0x10081218

const XKB_KEY_XF86CameraLeft = 0x10081219

const XKB_KEY_XF86CameraRight = 0x1008121a

const XKB_KEY_XF86AttendantOn = 0x1008121b

const XKB_KEY_XF86AttendantOff = 0x1008121c

const XKB_KEY_XF86AttendantToggle = 0x1008121d

const XKB_KEY_XF86LightsToggle = 0x1008121e

const XKB_KEY_XF86ALSToggle = 0x10081230

const XKB_KEY_XF86Buttonconfig = 0x10081240

const XKB_KEY_XF86Taskmanager = 0x10081241

const XKB_KEY_XF86Journal = 0x10081242

const XKB_KEY_XF86ControlPanel = 0x10081243

const XKB_KEY_XF86AppSelect = 0x10081244

const XKB_KEY_XF86Screensaver = 0x10081245

const XKB_KEY_XF86VoiceCommand = 0x10081246

const XKB_KEY_XF86Assistant = 0x10081247

const XKB_KEY_XF86BrightnessMin = 0x10081250

const XKB_KEY_XF86BrightnessMax = 0x10081251

const XKB_KEY_XF86KbdInputAssistPrev = 0x10081260

const XKB_KEY_XF86KbdInputAssistNext = 0x10081261

const XKB_KEY_XF86KbdInputAssistPrevgroup = 0x10081262

const XKB_KEY_XF86KbdInputAssistNextgroup = 0x10081263

const XKB_KEY_XF86KbdInputAssistAccept = 0x10081264

const XKB_KEY_XF86KbdInputAssistCancel = 0x10081265

const XKB_KEY_XF86RightUp = 0x10081266

const XKB_KEY_XF86RightDown = 0x10081267

const XKB_KEY_XF86LeftUp = 0x10081268

const XKB_KEY_XF86LeftDown = 0x10081269

const XKB_KEY_XF86RootMenu = 0x1008126a

const XKB_KEY_XF86MediaTopMenu = 0x1008126b

const XKB_KEY_XF86Numeric11 = 0x1008126c

const XKB_KEY_XF86Numeric12 = 0x1008126d

const XKB_KEY_XF86AudioDesc = 0x1008126e

const XKB_KEY_XF863DMode = 0x1008126f

const XKB_KEY_XF86NextFavorite = 0x10081270

const XKB_KEY_XF86StopRecord = 0x10081271

const XKB_KEY_XF86PauseRecord = 0x10081272

const XKB_KEY_XF86VOD = 0x10081273

const XKB_KEY_XF86Unmute = 0x10081274

const XKB_KEY_XF86FastReverse = 0x10081275

const XKB_KEY_XF86SlowReverse = 0x10081276

const XKB_KEY_XF86Data = 0x10081277

const XKB_KEY_XF86OnScreenKeyboard = 0x10081278

const XKB_KEY_XF86PrivacyScreenToggle = 0x10081279

const XKB_KEY_XF86SelectiveScreenshot = 0x1008127a

const XKB_KEY_XF86Macro1 = 0x10081290

const XKB_KEY_XF86Macro2 = 0x10081291

const XKB_KEY_XF86Macro3 = 0x10081292

const XKB_KEY_XF86Macro4 = 0x10081293

const XKB_KEY_XF86Macro5 = 0x10081294

const XKB_KEY_XF86Macro6 = 0x10081295

const XKB_KEY_XF86Macro7 = 0x10081296

const XKB_KEY_XF86Macro8 = 0x10081297

const XKB_KEY_XF86Macro9 = 0x10081298

const XKB_KEY_XF86Macro10 = 0x10081299

const XKB_KEY_XF86Macro11 = 0x1008129a

const XKB_KEY_XF86Macro12 = 0x1008129b

const XKB_KEY_XF86Macro13 = 0x1008129c

const XKB_KEY_XF86Macro14 = 0x1008129d

const XKB_KEY_XF86Macro15 = 0x1008129e

const XKB_KEY_XF86Macro16 = 0x1008129f

const XKB_KEY_XF86Macro17 = 0x100812a0

const XKB_KEY_XF86Macro18 = 0x100812a1

const XKB_KEY_XF86Macro19 = 0x100812a2

const XKB_KEY_XF86Macro20 = 0x100812a3

const XKB_KEY_XF86Macro21 = 0x100812a4

const XKB_KEY_XF86Macro22 = 0x100812a5

const XKB_KEY_XF86Macro23 = 0x100812a6

const XKB_KEY_XF86Macro24 = 0x100812a7

const XKB_KEY_XF86Macro25 = 0x100812a8

const XKB_KEY_XF86Macro26 = 0x100812a9

const XKB_KEY_XF86Macro27 = 0x100812aa

const XKB_KEY_XF86Macro28 = 0x100812ab

const XKB_KEY_XF86Macro29 = 0x100812ac

const XKB_KEY_XF86Macro30 = 0x100812ad

const XKB_KEY_XF86MacroRecordStart = 0x100812b0

const XKB_KEY_XF86MacroRecordStop = 0x100812b1

const XKB_KEY_XF86MacroPresetCycle = 0x100812b2

const XKB_KEY_XF86MacroPreset1 = 0x100812b3

const XKB_KEY_XF86MacroPreset2 = 0x100812b4

const XKB_KEY_XF86MacroPreset3 = 0x100812b5

const XKB_KEY_XF86KbdLcdMenu1 = 0x100812b8

const XKB_KEY_XF86KbdLcdMenu2 = 0x100812b9

const XKB_KEY_XF86KbdLcdMenu3 = 0x100812ba

const XKB_KEY_XF86KbdLcdMenu4 = 0x100812bb

const XKB_KEY_XF86KbdLcdMenu5 = 0x100812bc

const XKB_KEY_SunFA_Grave = 0x1005ff00

const XKB_KEY_SunFA_Circum = 0x1005ff01

const XKB_KEY_SunFA_Tilde = 0x1005ff02

const XKB_KEY_SunFA_Acute = 0x1005ff03

const XKB_KEY_SunFA_Diaeresis = 0x1005ff04

const XKB_KEY_SunFA_Cedilla = 0x1005ff05

const XKB_KEY_SunF36 = 0x1005ff10

const XKB_KEY_SunF37 = 0x1005ff11

const XKB_KEY_SunSys_Req = 0x1005ff60

const XKB_KEY_SunPrint_Screen = 0x0000ff61

const XKB_KEY_SunCompose = 0x0000ff20

const XKB_KEY_SunAltGraph = 0x0000ff7e

const XKB_KEY_SunPageUp = 0x0000ff55

const XKB_KEY_SunPageDown = 0x0000ff56

const XKB_KEY_SunUndo = 0x0000ff65

const XKB_KEY_SunAgain = 0x0000ff66

const XKB_KEY_SunFind = 0x0000ff68

const XKB_KEY_SunStop = 0x0000ff69

const XKB_KEY_SunProps = 0x1005ff70

const XKB_KEY_SunFront = 0x1005ff71

const XKB_KEY_SunCopy = 0x1005ff72

const XKB_KEY_SunOpen = 0x1005ff73

const XKB_KEY_SunPaste = 0x1005ff74

const XKB_KEY_SunCut = 0x1005ff75

const XKB_KEY_SunPowerSwitch = 0x1005ff76

const XKB_KEY_SunAudioLowerVolume = 0x1005ff77

const XKB_KEY_SunAudioMute = 0x1005ff78

const XKB_KEY_SunAudioRaiseVolume = 0x1005ff79

const XKB_KEY_SunVideoDegauss = 0x1005ff7a

const XKB_KEY_SunVideoLowerBrightness = 0x1005ff7b

const XKB_KEY_SunVideoRaiseBrightness = 0x1005ff7c

const XKB_KEY_SunPowerSwitchShift = 0x1005ff7d

const XKB_KEY_Dring_accent = 0x1000feb0

const XKB_KEY_Dcircumflex_accent = 0x1000fe5e

const XKB_KEY_Dcedilla_accent = 0x1000fe2c

const XKB_KEY_Dacute_accent = 0x1000fe27

const XKB_KEY_Dgrave_accent = 0x1000fe60

const XKB_KEY_Dtilde = 0x1000fe7e

const XKB_KEY_Ddiaeresis = 0x1000fe22

const XKB_KEY_DRemove = 0x1000ff00

const XKB_KEY_hpClearLine = 0x1000ff6f

const XKB_KEY_hpInsertLine = 0x1000ff70

const XKB_KEY_hpDeleteLine = 0x1000ff71

const XKB_KEY_hpInsertChar = 0x1000ff72

const XKB_KEY_hpDeleteChar = 0x1000ff73

const XKB_KEY_hpBackTab = 0x1000ff74

const XKB_KEY_hpKP_BackTab = 0x1000ff75

const XKB_KEY_hpModelock1 = 0x1000ff48

const XKB_KEY_hpModelock2 = 0x1000ff49

const XKB_KEY_hpReset = 0x1000ff6c

const XKB_KEY_hpSystem = 0x1000ff6d

const XKB_KEY_hpUser = 0x1000ff6e

const XKB_KEY_hpmute_acute = 0x100000a8

const XKB_KEY_hpmute_grave = 0x100000a9

const XKB_KEY_hpmute_asciicircum = 0x100000aa

const XKB_KEY_hpmute_diaeresis = 0x100000ab

const XKB_KEY_hpmute_asciitilde = 0x100000ac

const XKB_KEY_hplira = 0x100000af

const XKB_KEY_hpguilder = 0x100000be

const XKB_KEY_hpYdiaeresis = 0x100000ee

const XKB_KEY_hpIO = 0x100000ee

const XKB_KEY_hplongminus = 0x100000f6

const XKB_KEY_hpblock = 0x100000fc

const XKB_KEY_osfCopy = 0x1004ff02

const XKB_KEY_osfCut = 0x1004ff03

const XKB_KEY_osfPaste = 0x1004ff04

const XKB_KEY_osfBackTab = 0x1004ff07

const XKB_KEY_osfBackSpace = 0x1004ff08

const XKB_KEY_osfClear = 0x1004ff0b

const XKB_KEY_osfEscape = 0x1004ff1b

const XKB_KEY_osfAddMode = 0x1004ff31

const XKB_KEY_osfPrimaryPaste = 0x1004ff32

const XKB_KEY_osfQuickPaste = 0x1004ff33

const XKB_KEY_osfPageLeft = 0x1004ff40

const XKB_KEY_osfPageUp = 0x1004ff41

const XKB_KEY_osfPageDown = 0x1004ff42

const XKB_KEY_osfPageRight = 0x1004ff43

const XKB_KEY_osfActivate = 0x1004ff44

const XKB_KEY_osfMenuBar = 0x1004ff45

const XKB_KEY_osfLeft = 0x1004ff51

const XKB_KEY_osfUp = 0x1004ff52

const XKB_KEY_osfRight = 0x1004ff53

const XKB_KEY_osfDown = 0x1004ff54

const XKB_KEY_osfEndLine = 0x1004ff57

const XKB_KEY_osfBeginLine = 0x1004ff58

const XKB_KEY_osfEndData = 0x1004ff59

const XKB_KEY_osfBeginData = 0x1004ff5a

const XKB_KEY_osfPrevMenu = 0x1004ff5b

const XKB_KEY_osfNextMenu = 0x1004ff5c

const XKB_KEY_osfPrevField = 0x1004ff5d

const XKB_KEY_osfNextField = 0x1004ff5e

const XKB_KEY_osfSelect = 0x1004ff60

const XKB_KEY_osfInsert = 0x1004ff63

const XKB_KEY_osfUndo = 0x1004ff65

const XKB_KEY_osfMenu = 0x1004ff67

const XKB_KEY_osfCancel = 0x1004ff69

const XKB_KEY_osfHelp = 0x1004ff6a

const XKB_KEY_osfSelectAll = 0x1004ff71

const XKB_KEY_osfDeselectAll = 0x1004ff72

const XKB_KEY_osfReselect = 0x1004ff73

const XKB_KEY_osfExtend = 0x1004ff74

const XKB_KEY_osfRestore = 0x1004ff78

const XKB_KEY_osfDelete = 0x1004ffff

const XKB_KEY_Reset = 0x1000ff6c

const XKB_KEY_System = 0x1000ff6d

const XKB_KEY_User = 0x1000ff6e

const XKB_KEY_ClearLine = 0x1000ff6f

const XKB_KEY_InsertLine = 0x1000ff70

const XKB_KEY_DeleteLine = 0x1000ff71

const XKB_KEY_InsertChar = 0x1000ff72

const XKB_KEY_DeleteChar = 0x1000ff73

const XKB_KEY_BackTab = 0x1000ff74

const XKB_KEY_KP_BackTab = 0x1000ff75

const XKB_KEY_Ext16bit_L = 0x1000ff76

const XKB_KEY_Ext16bit_R = 0x1000ff77

const XKB_KEY_mute_acute = 0x100000a8

const XKB_KEY_mute_grave = 0x100000a9

const XKB_KEY_mute_asciicircum = 0x100000aa

const XKB_KEY_mute_diaeresis = 0x100000ab

const XKB_KEY_mute_asciitilde = 0x100000ac

const XKB_KEY_lira = 0x100000af

const XKB_KEY_guilder = 0x100000be

const XKB_KEY_IO = 0x100000ee

const XKB_KEY_longminus = 0x100000f6

const XKB_KEY_block = 0x100000fc

const XKB_KEYCODE_INVALID = 0xffffffff

const XKB_LAYOUT_INVALID = 0xffffffff

const XKB_LEVEL_INVALID = 0xffffffff

const XKB_MOD_INVALID = 0xffffffff

const XKB_LED_INVALID = 0xffffffff

const XKB_KEYCODE_MAX = 0xffffffff - 1

# Skipping MacroDefinition: XKB_KEYMAP_USE_ORIGINAL_FORMAT ( ( enum xkb_keymap_format ) - 1 )

const xkb_group_index_t = xkb_layout_index_t

const xkb_group_mask_t = xkb_layout_mask_t

const xkb_map_compile_flags = xkb_keymap_compile_flags

const XKB_GROUP_INVALID = XKB_LAYOUT_INVALID

const XKB_STATE_DEPRESSED = XKB_STATE_MODS_DEPRESSED | XKB_STATE_LAYOUT_DEPRESSED

const XKB_STATE_LATCHED = XKB_STATE_MODS_LATCHED | XKB_STATE_LAYOUT_LATCHED

const XKB_STATE_LOCKED = XKB_STATE_MODS_LOCKED | XKB_STATE_LAYOUT_LOCKED

const XKB_STATE_EFFECTIVE = (((XKB_STATE_DEPRESSED | XKB_STATE_LATCHED) | XKB_STATE_LOCKED) | XKB_STATE_MODS_EFFECTIVE) | XKB_STATE_LAYOUT_EFFECTIVE

const XKB_MAP_COMPILE_PLACEHOLDER = XKB_KEYMAP_COMPILE_NO_FLAGS

const XKB_MAP_COMPILE_NO_FLAGS = XKB_KEYMAP_COMPILE_NO_FLAGS

const XKB_X11_MIN_MAJOR_XKB_VERSION = 1

const XKB_X11_MIN_MINOR_XKB_VERSION = 0


