using XKeyboard
using Test

@testset "XKeyboard.jl" begin
    @testset "Presence of common wrapper & X11 extension" begin
        @test in(:xkb_keymap_new_from_file, names(XKeyboard)) && isdefined(XKeyboard, :xkb_keymap_new_from_file)
        @test in(:xkb_x11_keymap_new_from_device, names(XKeyboard)) && isdefined(XKeyboard, :xkb_x11_keymap_new_from_device)
    end
end
