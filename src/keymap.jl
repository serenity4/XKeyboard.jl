"""
Keymap used to encode information regarding keyboard layout, and country and language codes.

A string representation can be obtained from a `Keymap` by using `String(keymap)`.
"""
mutable struct Keymap
  handle::Ptr{xkb_keymap}
  ctx::Ptr{xkb_context}
  state::Ptr{xkb_state}
  function Keymap(handle::Ptr{xkb_keymap}, ctx::Ptr{xkb_context}, state::Ptr{xkb_state})
    km = new(handle, ctx, state)

    finalizer(km) do x
      xkb_state_unref(x.state)
      xkb_keymap_unref(x.handle)
      xkb_context_unref(x.ctx)
    end
  end
end

Base.unsafe_convert(::Type{Ptr{xkb_keymap}}, keymap::Keymap) = keymap.handle

"""
Construct a `Keymap` via X11 using `conn` as the connection to an X Server.

This action uses XKB, the X Keyboard extension, which must be initialized for each X11 connection, typically when creating a keymap.
If this is not your first call to this constructor with this connection, you should set `setup_xkb` to `false`.

!!! warning
   Upon creation, the keymap state (e.g. active modifiers) is filled with the current state. That means, if you press
   shift down while executing this code, the keymap state will encode a state where the shift modifier is active.
   This is not a concern if the state is properly managed by the calling code, e.g. XCB.jl updating the keymap on key presses
   and key releases, but this is something to be aware of.
"""
function keymap_from_x11(conn; setup_xkb = true)
  if setup_xkb
    ret_code = xkb_x11_setup_xkb_extension(conn, 1, 0, XKB_X11_SETUP_XKB_EXTENSION_NO_FLAGS, C_NULL, C_NULL, C_NULL, C_NULL)
    ret_code == 0 && error("XKB extension setup failed")
  end
  ctx = create_context()
  device_id = xkb_x11_get_core_keyboard_device_id(conn)
  device_id == -1 && error("No keyboard device ID could be retrieved")
  keymap = xkb_x11_keymap_new_from_device(ctx, conn, device_id, XKB_KEYMAP_COMPILE_NO_FLAGS)
  state = xkb_x11_state_new_from_device(keymap, conn, device_id)
  state == C_NULL && error("State creation failed")
  Keymap(keymap, ctx, state)
end

function create_context()
  ctx = xkb_context_new(XKB_CONTEXT_NO_DEFAULT_INCLUDES)
  ctx == C_NULL && error("Context creation failed")
  ctx
end

"""
    String(keymap::Keymap)

Return a complete string representation of a [`Keymap`](@ref).

!!! tip
    The returned string is very large. You might prefer to redirect to a file than printing directly on a console.
"""
function Base.String(km::Keymap)
  km_name_ptr = xkb_keymap_get_as_string(km, XKB_KEYMAP_FORMAT_TEXT_V1)
  km_name_ptr == C_NULL && error("Failed to obtain a string from the keymap $km")
  unsafe_string(km_name_ptr)
end

"""
Physical key, represented with a designated integer keycode.
"""
struct PhysicalKey
  code::UInt32
end

"""
    String(keymap::Keymap, key::PhysicalKey)

Obtain the string representation of a physical key.
"""
function Base.String(km::Keymap, key::PhysicalKey)
  ptr = xkb_keymap_key_get_name(km, key.code)
  ptr == C_NULL && error("Failed to obtain a name for $key")
  unsafe_string(ptr)
end

"""
    Symbol(keymap::Keymap, key::PhysicalKey)

Obtain the name of a physical key.

`String(keymap::Keymap, key::PhysicalKey)` can be used instead if you aim to consume a `String` instead of a `Symbol`.
"""
Base.Symbol(km::Keymap, key::PhysicalKey) = Symbol(String(km, key))

function PhysicalKey(km::Keymap, name::AbstractString)
  keycode = xkb_keymap_key_by_name(km, name)
  keycode == typemax(UInt32) && error("Failed to obtain a keycode from the key name $name")
  PhysicalKey(keycode)
end

"""
    PhysicalKey(keymap::Keymap, name::Symbol)

Obtain a [`PhysicalKey`](@ref) from its string representation `name` using a keymap.

Useful for simulating events which typically require the integer code of a physical key (keycode).

A name of type `AbstractString` can be used instead if you have a string at the ready.
"""
PhysicalKey(km::Keymap, name::Symbol) = PhysicalKey(km, string(name))

"""
Code used by XKB to represent symbols on a logical level.

Such codes differ from keycodes in that they keycodes are stateless: when a key
is pressed, it always emits the same keycode.

To understand the difference, let's take the physical key `AD01`.
When pressed, it emits an integer signal (keycode) representing that specific key on the keyboard
(the name `AD01` is just a label that is more friendly than an integer code). If pressed
on a US keyboard (QWERTY layout), it may emit the character `q`. Or `Q`. This depends on whether a shift modifier
or caps lock (without shift modifier) is active, among other things. If we were on a French keyboard,
then the letter would be `a` (AZERTY layout), or `A`. if we had pressed the left or right shift key instead,
we would not even have a printable character associated with the keystroke.

`q`, `Q`, `a`, `A`, `left_shift` and `right_shift` are all semantic symbols, need not be printable (e.g. shifts)
and their mapping from a physical key -if one exists- depends on some external state, tracked inside a [`Keymap`](@ref).
Just like physical keys, these symbols are represented with an integer code, and have a more friendly string representation
that one can obtain with `String(keysym::Keysym)`.

Keysyms are not physical keys, nor input characters.
"""
struct Keysym
  code::UInt32
  function Keysym(code)
    iszero(code) && error("Null code not allowed in Keysym")
    new(get(legacy_codes, code, code))
  end
end

"""
    Keysym(keymap::Keymap, key::PhysicalKey)

Obtain the [`Keysym`](@ref) corresponding to the pressed `key` given a `keymap` state.
"""
Keysym(km::Keymap, key::PhysicalKey) = Keysym(xkb_state_key_get_one_sym(km.state, key.code))
"""
    Keysym(str::AbstractString)

Get the [`Keysym`](@ref) represented by the string `str`.
"""
function Keysym(str::AbstractString)
  code = xkb_keysym_from_name(str, XKB_KEYSYM_NO_FLAGS)
  iszero(code) && error("No keysym matches the name $(repr(str))")
  Keysym(code)
end
"""
    Keysym(name::Symbol)

Get the [`Keysym`](@ref) named `name`. Equivalent to `Keysym(string(name))`.
"""
Keysym(name::Symbol) = Keysym(string(name))

const UNICODE_BIT = 0x01000000

function Keysym(char::Char)
  code = codepoint(char)
  code < 0x20 && error("No keysym corresponds to the character $(repr(char))")
  code ≤ 0xff && return Keysym(code)
  Keysym(UNICODE_BIT | code)
end

"""
    String(keysym::Keysym)

Return a `String` representation of a [`Keysym`](@ref).
"""
function Base.String(keysym::Keysym) # TODO: see if we can query the number of strings with a null pointer.
  size = xkb_keysym_get_name(keysym.code, C_NULL, 0)
  if size == -1
    @error "Failed to obtain a keysym string for $(repr(keysym.code))"
    size = 50 # make sure we get enough chars to hold whatever string is used as placeholder
  end
  cchars = zeros(Cchar, size + 1)
  cchars_ptr = pointer(cchars)
  GC.@preserve cchars begin
    val = xkb_keysym_get_name(keysym.code, cchars_ptr, size + 1)
    unsafe_string(cchars_ptr)
  end
end

"""
    Symbol(keysym::Keysym)

Return the name of a [`Keysym`](@ref). Equivalent to `Symbol(String(keysym))`.
"""
Base.Symbol(keysym::Keysym) = Symbol(String(keysym))

"""
    Char(keysym::Keysym)

Return the printable character of a [`Keysym`](@ref) (`'\\0'` if not printable).
"""
Base.Char(keysym::Keysym) = Char(xkb_keysym_to_utf32(keysym.code))

"""
    Char(keymap::Keymap, key::PhysicalKey)

Retrieve a UTF-8 character which corresponds to the printable input associated with the keysym obtained via the provided `keycode` and the `keymap` state.

If no printable input is defined for this keysym, the NUL character `'\\0'` is returned which, when printed, is a no-op.
"""
Base.Char(km::Keymap, key::PhysicalKey) = Char(xkb_state_key_get_utf32(km.state, key.code))

function print_key_info(io::IO, km::Keymap, key::PhysicalKey)
  key_name = String(km, key)
  input = Char(km, key)
  keysym_name = String(Keysym(km, key))
  print_key_info(io, key_name, key.code, input, keysym_name)
end

function print_key_info(io::IO, key_name::AbstractString, keycode::Integer, input::Char, keysym_name::AbstractString)
  char = repr(input)
  str = replace(string(input), '\r' => '↵')
  print(io, "Key \e[31m$key_name\e[m (code \e[33m$(keycode)\e[m): input \"\e[32m$str\e[m\" (char: \e[36m$char\e[m) from symbol \e[34m$keysym_name\e[m")
end
