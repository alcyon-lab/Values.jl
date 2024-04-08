cd(@__DIR__)
using Aqua
using Test
using AlcyonValue



@testset "AlcyonValue.jl" begin
    @testset "Symbolics.Value gemnerators" begin
        a = Symbol("a")
        b = Symbol("b")
        @test typeof(Value(3)) == Value
        @test typeof(Value(a)) == Value
        @test typeof(Value(:(a + 3 * b))) == Value
    end

    @testset "Symbolics.Value equality" begin
        a = Symbol("a")
        b = Symbol("b")
        @test Value(3) == 3
        @test Value(a) == a
        @test 3 == Value(3)
        @test a == Value(a)
        @test a + b == Value(a + b)
    end

    @testset "Symbolics.Value unitary -" begin
        a = Symbol("a")
        b = Symbol("b")
        @test -Value(3) == -3
        @test -Value(a) == -a
        @test -Value(a + b) == -(a + b)
    end


    @testset "Symbolics.Value addition" begin
        a = Symbol("a")
        b = Symbol("b")
        @test Value(3) + 4 == 7
        @test -Value(a) + b == -a + b
        # @test Value(a+b)+ :(a+b) == 2*(a+b)
    end
end
@testset "AlcyonValue.jl Aqua" begin
    Aqua.test_all(AlcyonValue)
end
