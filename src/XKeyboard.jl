module XKeyboard

using Reexport

include("LibXKB.jl")
@reexport using .LibXKB

include("keymap.jl")

export Keymap,
  keymap_from_x11,
  PhysicalKey,
  Keysym,
  print_key_info

end
