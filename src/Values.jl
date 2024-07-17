module Values

using MacroTools
using TermInterface

export Value
export substitute

# updated form of
# https://discourse.julialang.org/t/get-a-symbol-vector-of-all-variable-names-in-an-expr/39391/3
function symbols(ex)
    list = Symbol[]
    function walk!(ex)
        if ex isa Symbol
            push!(list, ex)
        elseif ex isa Expr
            if ex.head == :call
                for arg in ex.args[2:end]
                    walk!(arg)
                end
            elseif ex.head isa Symbol && isempty(ex.args)
                push!(list, ex.head)
            end
        end
    end
    walk!(ex)
    return Set{Symbol}(list)
end

mutable struct Value
    val::Union{Number,Expr,Symbol}
    free::Set{Base.Symbol}
    bound::Set{Base.Symbol}
end
function Value(a::T) where {T<:Number}
    return Value(a, Set{Symbol}([]), Set{Symbol}([]))
end
function Value(a::Expr)
    return Value(a, symbols(a), Set{Symbol}([]))
end
function Value(a::Symbol)
    return Value(a, Set{Symbol}([a]), Set{Symbol}([]))
end
function Base.string(v::Value)
    return string(v.val)
end
function Base.summary(io::IO, v::Value)
    summary(io, v.val)
end

function Base.show(io::IO, v::Value)
    show(io, v.val)
end
Base.convert(::Type{Value}, x::Number) = Value(x)
Base.convert(::Type{Value}, x::Expr) = Value(x)
Base.convert(::Type{Value}, x::Symbol) = Value(x)
Base.promote_rule(::Type{Value}, ::Type{<:Number}) = Value
Base.promote_rule(::Type{Value}, ::Type{<:Expr}) = Value
Base.promote_rule(::Type{Value}, ::Type{<:Symbol}) = Value
function Base.convert(::Type{Number}, x::Value)
    if isa(x.val, Number)
        return x.val
    else
        throw(error("Value is not a number"))
    end
end

# Misc
Base.zero(::Type{Value}) = zero(Number)
Base.one(::Type{Value}) = one(Number)

function Base.length(::Value)
    return 1
end

function Base.iterate(::Value, nothing)
    return nothing
end

function Base.iterate(x::Value)
    return (x, nothing)
end

function Base.isinteger(::Union{Symbol,Expr})
    return false
end

function Base.isinteger(x::Value)
    return isinteger(x.val)
end

function Base.Integer(x::Value)
    return Integer(x.val)
end

function Base.Number(x::Value)
    return Number(x.val)
end

function Base.transpose(x::Union{Value,Symbol,Expr})
    return x
end

# For TermInterface
function isexpr(x::Value)
    return isexpr(x.val)
end

function head(x::Value)
    return head(x.val)
end

function children(x::Value)
    return children(x.val)
end

function iscall(x::Value)
    return iscall(x.val)
end

function operation(x::Value)
    return operation(x.val)
end

function arguments(x::Value)
    return arguments(x)
end

function maketerm(Value, head, children, type=nothing, metadata=nothing)
    expr = maketerm(Expr, head, children)
    return Value(expr)
end

# Equality - Comparison
function Base.:(==)(b::Value, a::Value)
    return a.val == b.val
end
function Base.:(==)(a::Value, b::Any)
    return a.val == b
end
function Base.:(==)(b::Any, a::Value)
    return a.val == b
end

function Base.isless(a::Value, b::Value)
    return isless(a.val, b.val)
end
function Base.isless(a::Value, b::Union{Number,Expr,Symbol})
    return isless(a.val, b)
end
function Base.isless(a::Union{Number,Expr,Symbol}, b::Value)
    return isless(a, b.val)
end

# Expr Arithmetics
function Base.:-(a::Union{Expr,Symbol})::Expr
    return :(-$a)
end
function Base.:+(a::Union{Expr,Symbol,Number}, b::Union{Expr,Symbol,Number})::Expr
    return :($a + $b)
end
function Base.:-(a::Union{Expr,Symbol,Number}, b::Union{Expr,Symbol,Number})::Expr
    return :($a - $b)
end
function Base.:*(a::Union{Expr,Symbol,Number}, b::Union{Expr,Symbol,Number})::Expr
    return :($a * $b)
end
function Base.:/(a::Union{Expr,Symbol,Number}, b::Union{Expr,Symbol,Number})::Expr
    return :($a / $b)
end
function Base.://(a::Union{Expr,Symbol,Number}, b::Union{Expr,Symbol,Number})::Expr
    return :($a // $b)
end
function Base.:^(a::Union{Expr,Symbol,Number}, b::Union{Expr,Symbol,Number})::Expr
    return :($a^$b)
end

# Value Arithmetics
function Base.:-(a::Value)::Value
    return Value(-a.val, a.free, a.bound)
end
function Base.:+(a::Value, b::Union{Number,Expr,Symbol})::Value
    return Value(a.val + b, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:-(a::Value, b::Union{Number,Expr,Symbol})::Value
    return Value(a.val - b, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:*(a::Value, b::Union{Number,Expr,Symbol})::Value
    return Value(a.val * b, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:/(a::Value, b::Union{Number,Expr,Symbol})::Value
    return Value(a.val / b, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.://(a::Value, b::Union{Number,Expr,Symbol})::Value
    return Value(a.val // b, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:^(a::Value, b::Union{Number,Expr,Symbol})::Value
    return Value(a.val^b, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end

function Base.:+(b::Union{Number,Expr,Symbol}, a::Value)::Value
    return Value(b + a.val, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:-(b::Union{Number,Expr,Symbol}, a::Value)::Value
    return Value(b - a.val, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:*(b::Union{Number,Expr,Symbol}, a::Value)::Value
    return Value(b * a.val, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:/(b::Union{Number,Expr,Symbol}, a::Value)::Value
    return Value(b / a.val, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.://(b::Union{Number,Expr,Symbol}, a::Value)::Value
    return Value(b // a.val, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end
function Base.:^(b::Union{Number,Expr,Symbol}, a::Value)::Value
    return Value(b^a.val, union(a.free, Set{Symbol}(symbols(b))), a.bound)
end

# TODO: still not sure about taking the union of bounds
function Base.:+(a::Value, b::Value)::Value
    return Value(a.val + b.val, union(a.free, b.free), union(a.bound, b.bound))
end
function Base.:-(a::Value, b::Value)::Value
    return Value(a.val - b.val, union(a.free, b.free), union(a.bound, b.bound))
end
function Base.:*(a::Value, b::Value)::Value
    return Value(a.val * b.val, union(a.free, b.free), union(a.bound, b.bound))
end
function Base.:/(a::Value, b::Value)::Value
    return Value(a.val / b.val, union(a.free, b.free), union(a.bound, b.bound))
end
function Base.://(a::Value, b::Value)::Value
    return Value(a.val // b.val, union(a.free, b.free), union(a.bound, b.bound))
end
function Base.:^(a::Value, b::Value)::Value
    return Value(a.val^b.val, union(a.free, b.free), union(a.bound, b.bound))
end

# Substitution


function substitute(e::Union{Value,Expr,Symbol,Number}, pairs::Vector{Pair})
    res = e
    for pair in pairs
        res = substitute(res, pair)
    end
    return res
end

function substitute(e::Union{Value,Expr,Symbol,Number}, pairs::Dict)
    res = e
    for pair in pairs
        res = substitute(res, pair)
    end
    return res
end

function substitute(e::Value, pair::Pair)
    return substitute(e.val, pair)
end

function substitute(e::Symbol, pair::Pair)
    if e == pair[1]
        return pair[2]
    end
    return e
end

function substitute(e::Number, ::Pair)
    return e
end

function substitute(e::Expr, pair::Pair)
    MacroTools.postwalk(e) do s
        if s == pair.first
            return pair.second
        elseif s isa Expr && s.head isa Symbol && isempty(s.args) && s.head == pair.first
            return pair.second
        else
            return s
        end
    end
end

end
