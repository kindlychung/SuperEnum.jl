using SuperEnum
expr = @macroexpand SuperEnum.@superenum Vehical car truck
dump(expr)
SuperEnum.@superenum Vehical car truck
