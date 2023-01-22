module XKeyboard

using Reexport

include("LibXKB.jl")
@reexport using .LibXKB

end
