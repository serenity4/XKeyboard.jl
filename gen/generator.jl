using Pkg
cd(@__DIR__)
Pkg.activate(".")

using Clang.Generators
using Clang.Generators.JLLEnvs
using xkbcommon_jll

add_include!(args, include::String) = push!(args, "-I$INCLUDE")
add_include!(args, includes::AbstractVector) = foreach(x -> add_include!(args, x), includes)

bitmasks = [:xkb_keysym_flags, :xkb_context_flags, :xkb_keymap_compile_flags, :xkb_state_component, :xkb_state_match, :xkb_x11_setup_xkb_extension_flags]

# get include directory
INCLUDE = joinpath(xkbcommon_jll.artifact_dir, "include")
HEADERS = joinpath.(INCLUDE, "xkbcommon", ["xkbcommon.h", "xkbcommon-x11.h"])

function postprocess(target)
    final = ""
    bitmasks_regex = Regex(string("@enum (", join(bitmasks, '|'), ')'))
    for line in split(read(target, String), '\n')
        # Turn `@enum` into `@bitmask` for bitmaskable enums.
        is_bitmask = startswith(line, bitmasks_regex)
        is_bitmask && (line = replace(line, bitmasks_regex => s"@bitmask \1"))
        final *= line * '\n'
    end
    write(target, final)
end

for target in JLLEnvs.JLL_ENV_TRIPLES
# for target in ["x86_64-linux-gnu"]
    @info "processing $target"

    # programmatically add options
    general = Dict{String,Any}()
    codegen = Dict{String,Any}()
    options = Dict{String,Any}(
        "general" => general,
        "codegen" => codegen,
        )
    general["library_name"] = "libxkb"
    general["library_names"] = Dict(
        "xkbcommon.h" => "libxkbcommon",
        "xkbcommon-x11.h" => "libxkbcommon_x11",
    )
    general["output_file_path"] = joinpath(dirname(@__DIR__), "lib", "$target.jl")
    general["use_deterministic_symbol"] = true
    general["use_julia_native_enum_type"] = true
    general["extract_c_comment_style"] = "doxygen"
    general["struct_field_comment_style"] = "outofline"
    general["enumerator_comment_style"] = "outofline"
    codegen["add_record_constructors"] = true
    codegen["union_single_constructor"] = true
    codegen["opaque_as_mutable_struct"] = false

    # add compiler flags
    args = get_default_args(target)
    add_include!(args, INCLUDE)
    ctx = create_context(HEADERS, args, options)

    build!(ctx)
    postprocess(general["output_file_path"])
end
