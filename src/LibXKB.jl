module LibXKB

using BitMasks: @bitmask

const IS_LIBC_MUSL = occursin("musl", Base.BUILD_TRIPLET)

if Sys.isapple() && Sys.ARCH === :aarch64
  include("../lib/aarch64-apple-darwin20.jl")
elseif Sys.islinux() && Sys.ARCH === :aarch64 && !IS_LIBC_MUSL
  include("../lib/aarch64-linux-gnu.jl")
elseif Sys.islinux() && Sys.ARCH === :aarch64 && IS_LIBC_MUSL
  include("../lib/aarch64-linux-musl.jl")
elseif Sys.islinux() && startswith(string(Sys.ARCH), "arm") && !IS_LIBC_MUSL
  include("../lib/armv7l-linux-gnueabihf.jl")
elseif Sys.islinux() && startswith(string(Sys.ARCH), "arm") && IS_LIBC_MUSL
  include("../lib/armv7l-linux-musleabihf.jl")
elseif Sys.islinux() && Sys.ARCH === :i686 && !IS_LIBC_MUSL
  include("../lib/i686-linux-gnu.jl")
elseif Sys.islinux() && Sys.ARCH === :i686 && IS_LIBC_MUSL
  include("../lib/i686-linux-musl.jl")
elseif Sys.iswindows() && Sys.ARCH === :i686
  include("../lib/i686-w64-mingw32.jl")
elseif Sys.islinux() && Sys.ARCH === :powerpc64le
  include("../lib/powerpc64le-linux-gnu.jl")
elseif Sys.isapple() && Sys.ARCH === :x86_64
  include("../lib/x86_64-apple-darwin14.jl")
elseif Sys.islinux() && Sys.ARCH === :x86_64 && !IS_LIBC_MUSL
  include("../lib/x86_64-linux-gnu.jl")
elseif Sys.islinux() && Sys.ARCH === :x86_64 && IS_LIBC_MUSL
  include("../lib/x86_64-linux-musl.jl")
elseif Sys.isbsd() && !Sys.isapple()
  include("../lib/x86_64-unknown-freebsd11.1.jl")
elseif Sys.iswindows() && Sys.ARCH === :x86_64
  include("../lib/x86_64-w64-mingw32.jl")
else
  error("Unknown platform: $(Base.BUILD_TRIPLET)")
end

# export everything
foreach(names(@__MODULE__, all=true)) do s
  if startswith(string(s), r"(?:X|XKB|xkb)")
      @eval export $s
  end
end

end
