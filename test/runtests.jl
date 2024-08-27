using XKeyboard
using Xorg_libxcb_jll: libxcb
using Test

# These tests must be run with an English QWERTY keyboard layout to pass.

@testset "XKeyboard.jl" begin
  @testset "Presence of common wrapper & X11 extension" begin
    @test in(:xkb_keymap_new_from_file, names(XKeyboard)) && isdefined(XKeyboard, :xkb_keymap_new_from_file)
    @test in(:xkb_x11_keymap_new_from_device, names(XKeyboard)) && isdefined(XKeyboard, :xkb_x11_keymap_new_from_device)
  end

  @testset "Keysym to Char" begin
    @test Char(Keysym(:A)) == 'A'
    @test Char(Keysym(:underscore)) == '_'
    @test Char(Keysym(:U0EC6)) == 'ໆ'
    @test Char(Keysym(:ampersand)) == '&'
    @test Char(Keysym(:KP_5)) == '5'
    @test Char(Keysym(:Shift_R)) == '\0'
  end

  conn = @ccall libxcb.xcb_connect(get(ENV, "DISPLAY", C_NULL)::Cstring, C_NULL::Ptr{Cint})::Ptr{Cvoid}
  code = @ccall libxcb.xcb_connection_has_error(conn::Ptr{Cvoid})::Cint
  @assert iszero(code) "XCB connection not successful (error code: $code)"
  @test conn ≠ C_NULL
  # Beware: the modifiers pressed during execution of this code will be encoded into the keymap state.
  km = keymap_from_x11(conn)
  @test all(≠(C_NULL), (km.handle, km.ctx, km.state))

  test_physical_key(km, name) = @test Symbol(km, PhysicalKey(km, name)) == name
  test_physical_key(km, :AD01)
  test_physical_key(km, :AC01)
  test_physical_key(km, :AD05)
  @test_throws "Failed to obtain a keycode" PhysicalKey(km, :foo)

  test_keysym(name) = @test Symbol(Keysym(name)) == name
  test_keysym(:a)
  test_keysym(:A)
  test_keysym(:Shift_R)
  @test Symbol(Keysym(:foo)) == :NoSymbol
  name = @test_logs (:error, r"Failed to obtain a keysym string") Symbol(Keysym(typemax(UInt32)))
  @test name == :Invalid

  test_keysym(key::PhysicalKey, name) = @test Symbol(Keysym(km, key)) == name
  test_keysym(key, name) = test_keysym(PhysicalKey(km, key), name)

  rshift = PhysicalKey(km, :RTSH)
  xkb_state_update_key(km.state, rshift.code, XKB_KEY_DOWN)
  test_keysym(:AD01, :Q)
  test_keysym(:AE05, :percent)
  xkb_state_update_key(km.state, rshift.code, XKB_KEY_UP)
  test_keysym(:AD01, :q)
  test_keysym(:AE05, Symbol(5))
  test_keysym(:RTSH, :Shift_R)
  test_keysym(:LALT, :Alt_L)

  print("\nPrinting a few keys:")
  for key in [:AD01, :AD02, :RTSH, :LALT, :RALT, :LCTL, :TAB, :AE01, :ESC, :KP5]
    print("\n  ")
    print_key_info(stdout, km, PhysicalKey(km, key))
  end
  println('\n')

  @test length(String(km)) > 10_000

  finalize(km)
end;
