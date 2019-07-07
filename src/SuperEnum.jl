module SuperEnum

__version__ = "0.1.5"

import Core.Intrinsics.bitcast

function basetype end

abstract type Enum{T<:Integer} end

(::Type{T})(x::Enum{T2}) where {T<:Integer,T2<:Integer} = T(bitcast(T2, x))::T
Base.cconvert(::Type{T}, x::Enum{T2}) where {T<:Integer,T2<:Integer} = T(x)
Base.write(io::IO, x::Enum{T}) where {T<:Integer} = write(io, T(x))
Base.read(io::IO, ::Type{T}) where {T<:Enum} = T(read(io, SuperEnum.basetype(T)))

# generate code to test whether expr is in the given set of values
function membershiptest(expr, values)
    lo, hi = extrema(values)
    if length(values) == hi - lo + 1
        :($lo <= $expr <= $hi)
    elseif length(values) < 20
        foldl((x1,x2)->:($x1 || ($expr == $x2)), values[2:end]; init=:($expr == $(values[1])))
    else
        :($expr in $(Set(values)))
    end
end

@noinline enum_argument_error(typename, x) = throw(ArgumentError(string("invalid value for Enum $(typename): $x")))

"""
    @se EnumName[::BaseType] value1[=x] value2[=y]
    @se EnumName[::BaseType] value1[=>string1] value2[=>string2]

Create an `Enum{BaseType}` subtype with name `EnumName` and enum member values of
`value1` and `value2` with optional assigned values of `x` and `y`, respectively,
or with `type=>description` pairs.
`EnumName` will be defined as `EnumName.EnumNameEnum`, where `EnumName` is a module, and `EnumNameEnum` is the type. 
This type can be used just like other types and enum member values as regular values.

# Examples
```jldoctest fruitenum
julia> @se Fruit apple=1 orange=2 kiwi=3
julia> f(x::Fruit) = "I'm a Fruit with value: \$(Int(x))"
f (generic function with 1 method)
julia> f(apple)
"I'm a Fruit with value: 1"
julia> Fruit(1)
apple::Fruit = 1
julia> SuperEnum.@se Lang zh=>"中文" en=>"English" ja=>"日本语"
WARNING: replacing module Lang.
Main.Lang
julia> string(Lang.zh)
"中文"
julia> string(Lang.en)
"English"
julia> string(Lang.ja)
"日本语"
julia> Lang.LangEnum
Enum Main.Lang.LangEnum:
zh = 0
en = 1
ja = 2
```

Values can also be specified inside a `begin` block, e.g.
```julia
@se EnumName begin
    value1
    value2
end
```

`BaseType`, which defaults to [`Int32`](@ref), must be a primitive subtype of `Integer`.
Member values can be converted between the enum type and `BaseType`. `read` and `write`
perform these conversions automatically.
To list all the instances of an enum use `instances`, e.g.
```jldoctest fruitenum
julia> instances(Fruit)
(apple, orange, kiwi)
```
"""
macro se(T, syms...)
    if isempty(syms)
        throw(ArgumentError("no arguments given for Enum $T"))
    end

    basetype = Int32
    modname = T
    typename = Symbol(modname, "Enum")
    # allow T to be an expr like Car::Int64
    if isa(T, Expr) && T.head == :(::) && length(T.args) == 2 && isa(T.args[1], Symbol)
        typename = T.args[1]
        basetype = Core.eval(__module__, T.args[2])
        if !isa(basetype, DataType) || !(basetype <: Integer) || !isbitstype(basetype)
            throw(ArgumentError("invalid base type for Enum $typename, $T=::$basetype; base type must be an integer primitive type"))
        end
    elseif !isa(T, Symbol)
        throw(ArgumentError("invalid type expression for enum $T"))
    end
    vals = Vector{Tuple{Symbol,Integer,String}}()
    lo = hi = 0
    i = zero(basetype)
    str = ""
    hasexpr = false
    # allow syms to be a code block
    if length(syms) == 1 && syms[1] isa Expr && syms[1].head == :block
        syms = syms[1].args
    end
    for s in syms
        s isa LineNumberNode && continue
        if isa(s, Symbol)
            if i == typemin(basetype) && !isempty(vals)
                throw(ArgumentError("overflow in value \"$s\" of Enum $typename"))
            end
            str = string(s)
        elseif isa(s, Expr) 
            if (s.head == :(=) || s.head == :kw) &&
               length(s.args) == 2 && isa(s.args[1], Symbol)
                i = Core.eval(__module__, s.args[2]) # allow exprs, e.g. uint128"1"
                if !isa(i, Integer)
                    throw(ArgumentError("invalid value for Enum $typename, $s; values must be integers"))
                end
                i = convert(basetype, i)
                s = s.args[1]
                str = string(s)
                hasexpr = true
            elseif (s.head == :call) && length(s.args) == 3 && s.args[1] == :(=>) && isa(s.args[2], Symbol)
                str = string(Core.eval(__module__, s.args[3]))
                s = s.args[2]
            else
                throw(ArgumentError(string("invalid expr for Enum ", typename, ": ", s)))
            end
        elseif s isa String
            str = s
            s = Symbol(Base.replace(s, r"[^a-zA-Z]" => ""))
        else
            throw(ArgumentError(string("invalid argument for Enum ", typename, ": ", s)))
        end
        push!(vals, (s,i, str))
        if length(vals) == 1
            lo = hi = i
        else
            lo = min(lo, i)
            hi = max(hi, i)
        end
        i += oneunit(i)
    end
    values = basetype[i[2] for i in vals]
    if hasexpr && values != unique(values)
        throw(ArgumentError("values for Enum $typename are not unique"))
    end
    blk = quote
        module $(esc(modname))
        ## 
        # Base.@__doc__(primitive type $(esc(typename)) <: Enum{$(basetype)} $(sizeof(basetype) * 8) end)
        primitive type $(esc(typename)) <: Enum{$(basetype)} $(sizeof(basetype) * 8) end
        function $(esc(typename))(x::Integer)
            $(membershiptest(:x, values)) || enum_argument_error($(Expr(:quote, typename)), x)
            return bitcast($(esc(typename)), convert($(basetype), x))
        end
        SuperEnum.basetype(::Type{$(esc(typename))}) = $(esc(basetype))
        Base.typemin(x::Type{$(esc(typename))}) = $(esc(typename))($lo)
        Base.typemax(x::Type{$(esc(typename))}) = $(esc(typename))($hi)
        Base.isless(x::$(esc(typename)), y::$(esc(typename))) = isless($basetype(x), $basetype(y))
        import Base: == 
        $(esc(:(==)))(x::$(esc(typename)), y::$(esc(typename))) = ($basetype(x) == $basetype(y))
        let insts = ntuple(i->$(esc(typename))($values[i]), $(length(values)))
            Base.instances(::Type{$(esc(typename))}) = insts
        end
        function Base.string(x::$(esc(typename)))
            for (sym, i, str) in $vals
                if i == $(basetype)(x)
                    return str
                end
            end
        end
        function $(esc(:fromstr))(s::AbstractString)
            for (sym, i, str) in $vals
                if str == s
                    return $(esc(typename))(i)
                end
            end
            return nothing
        end
        function Base.print(io::IO, x::$(esc(typename)))
            for (sym, i, str) in $vals
                if i == $(basetype)(x)
                    Base.print(io, sym); break
                end
            end
        end
        function Base.show(io::IO, x::$(esc(typename)))
            if get(io, :compact, false)
                print(io, x)
            else
                print(io, x, "::")
                show(IOContext(io, :compact => true), typeof(x))
                print(io, " = ")
                show(io, $basetype(x))
            end
        end
        function Base.show(io::IO, ::MIME"text/plain", t::Type{$(esc(typename))})
            print(io, "Enum ")
            Base.show_datatype(io, t)
            print(io, ":")
            for (sym, i) in $vals
                print(io, "\n", sym, " = ")
                show(io, i)
            end
        end
        end
    end
    for node in blk.args
        if node isa LineNumberNode
            continue
        end
        if node isa Expr && node.head == :module
            for modnode in node.args
                if modnode isa Expr
                    for (sym,i,strrep) in vals
                        push!(modnode.args, :(const $(esc(sym)) = $(esc(typename))($i)))
                        push!(modnode.args, :(export $(esc(sym))))
                    end
                end
            end
            break
        end
    end
    blk.head = :toplevel
    return blk
end


# backward compatibility
@eval $(Symbol("@superenum")) = $(Symbol("@se"))

export Enum, @se, @superenum

end #module

