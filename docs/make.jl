using XKeyboard
using Documenter

DocMeta.setdocmeta!(XKeyboard, :DocTestSetup, :(using XKeyboard); recursive=true)

makedocs(;
    modules=[XKeyboard],
    authors="Cédric BELMANT",
    repo="https://github.com/serenity4/XKeyboard.jl/blob/{commit}{path}#{line}",
    sitename="XKeyboard.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://serenity4.github.io/XKeyboard.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/serenity4/XKeyboard.jl",
    devbranch="main",
)
