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

@se Lang zh=>"中文"*"Chinese" en=>"English" ja=>"日本语"
@test string(Lang.zh) ==  "中文Chinese"
@test string(Lang.en) ==  "English"
@test string(Lang.ja) ==  "日本语"
@test Lang.fromstr("中文Chinese") == Lang.zh



end
