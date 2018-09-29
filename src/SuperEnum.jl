module SuperEnum

export superenum

macro superenum(enumname, vals...)
    expr = quote
        module $(esc(enumname))
            Base.@enum(Enum, $(vals...))
        end
    end
    expr.head = :toplevel
    expr
end

end # module
