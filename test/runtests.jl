cd(@__DIR__)
using Aqua
using Test
using Values



@testset "Values.jl" begin
    @testset "Value generators" begin
        a = Symbol("a")
        b = Symbol("b")
        @test typeof(Value(3)) == Value
        @test typeof(Value(a)) == Value
        @test typeof(Value(:(a + 3 * b))) == Value
    end

    @testset "Value equality" begin
        a = Symbol("a")
        b = Symbol("b")
        @test Value(3) == 3
        @test Value(a) == a
        @test 3 == Value(3)
        @test a == Value(a)
        @test a + b == Value(a + b)
    end

    @testset "Value substitute" begin
        a = Symbol("a")
        @test substitute(3, Pair(a, 1)) == 3
        @test substitute(3, Pair(a, 2)) == 3
        @test substitute(Value(3), Pair(a, 1)) == 3
        @test substitute(Value(a), Pair(a, 3)) == 3
        @test substitute(Value(a), Pair(a, 1)) != 3
        @test substitute(Value(:(a + 2)), Pair(a, 1)) == :(1 + 2)
        @test eval(substitute(Value(:(a + 2)), Pair(a, 1))) == 3
    end

    @testset "Value unitary -" begin
        a = Symbol("a")
        b = Symbol("b")
        @test -Value(3) == -3
        @test -Value(a) == -a
        @test -Value(a + b) == -(a + b)
    end


    @testset "Value addition" begin
        a = Symbol("a")
        b = Symbol("b")
        pairs = Dict(a => 13, b => 17)
        @test Value(3) + 4 == 7
        @test -Value(a) + b == -a + b
        @test eval(substitute(Value(a + b) + :(a + b), pairs)) == eval(substitute(2 * (a + b), pairs))
    end

    @testset "Value power free vars" begin
        a = Symbol("a")
        b = Symbol("b")
        @test (Value(a)^Value(b)).free == Value(a^b).free
        @test (Value(a)^Value(b)).free == Set([a, b])
        @test (Value(a)^Value(a)).free == Set([a])
    end
end
@testset "Values.jl Aqua" begin
    Aqua.test_all(AlcyonValue)
end
