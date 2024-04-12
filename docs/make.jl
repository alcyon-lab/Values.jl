using Values
using Documenter

DocMeta.setdocmeta!(Values, :DocTestSetup, :(using Values); recursive=true)

makedocs(;
    modules=[Values],
    authors="Alcyon Lab",
    repo="https://github.com/alcyon-lab/Values.jl/blob/{commit}{path}#{line}",
    sitename="Values.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
