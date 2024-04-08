using Aqua
using Test
using AlcyonValue

@testset "Aqua.jl" begin
    Aqua.test_all(
        AlcyonValue;
    )
    @test length(Aqua.detect_unbound_args_recursively(Oscar)) <= 16
end
