using XKeyboard
using Xorg_libxcb_jll: libxcb
using Test

@testset "XKeyboard.jl" begin
  @testset "Presence of common wrapper & X11 extension" begin
    @test in(:xkb_keymap_new_from_file, names(XKeyboard)) && isdefined(XKeyboard, :xkb_keymap_new_from_file)
    @test in(:xkb_x11_keymap_new_from_device, names(XKeyboard)) && isdefined(XKeyboard, :xkb_x11_keymap_new_from_device)
  end

  conn = @ccall libxcb.xcb_connect(get(ENV, "DISPLAY", C_NULL)::Cstring, C_NULL::Ptr{Cint})::Ptr{Cvoid}
  code = @ccall libxcb.xcb_connection_has_error(conn::Ptr{Cvoid})::Cint
  @assert iszero(code) "XCB connection not successful (error code: $code)"
  @test conn ≠ C_NULL
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

  print("\nPrinting a few keys:")
  for key in [:AD01, :AD02, :RTSH, :LALT, :RALT, :LCTL, :TAB, :AE01, :ESC, :KP5]
    print("\n  ")
    print_key_info(stdout, km, PhysicalKey(km, key))
  end
  println('\n')

  @test length(String(km)) > 10_000

  finalize(km)
end;
