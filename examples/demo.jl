using SuperEnum
expr = @macroexpand SuperEnum.@superenum Vehicle car truck
dump(expr)
SuperEnum.@superenum Vehicle car truck
