module SuperEnum

export @superenum

macro superenum(enumname, vals...)
    typename = Symbol(enumname, "Enum")
    expr = quote
        module $(esc(enumname))
            Base.@enum($typename, $(vals...))
        end
    end
    expr.head = :toplevel
    expr
end

end # module
