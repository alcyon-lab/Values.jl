using AlcyonValue
using Documenter

DocMeta.setdocmeta!(AlcyonValue, :DocTestSetup, :(using AlcyonValue); recursive=true)

makedocs(;
    modules=[AlcyonValue],
    authors="Alcyon Lab",
    repo="https://github.com/alcyon-lab/AlcyonValue.jl/blob/{commit}{path}#{line}",
    sitename="AlcyonValue.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
