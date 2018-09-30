using SuperEnum
using Test

@testset  "superenum.macro" begin
expr = @macroexpand SuperEnum.@superenum Vehical car truck
@test expr.head == :toplevel
eval(expr)
@test typeof(Vehical) == Module
@test typeof(Vehical.VehicalEnum) == DataType
@test Int(Vehical.car) == 0
@test Int(Vehical.truck) == 1
end
