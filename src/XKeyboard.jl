module XKeyboard

using Reexport

include("LibXKB.jl")
@reexport using .LibXKB

include("legacy.jl")
include("keymap.jl")

export Keymap,
  create_context,
  keymap_from_x11,
  PhysicalKey,
  Keysym,
  print_key_info

end
