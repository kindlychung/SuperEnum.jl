# SuperEnum

![https://ci.appveyor.com/api/projects/status/github/kindlychung/SuperEnum.jl?branch=master&svg=true&retina=true](https://ci.appveyor.com/api/projects/status/github/kindlychung/SuperEnum.jl?branch=master&svg=true&retina=true)

## Julia enum made nicer

## Usage

```julia
@se Vehicle plane train car truck

julia> Vehicle.VehicleEnum
Enum Main.Vehicle.VehicleEnum:
plane = 0
train = 1
car = 2
truck = 3

julia> Vehicle.car
car::VehicleEnum = 2

julia> @se Lang zh=>"中文"*"Chinese" en=>"English" ja=>"日本语"
Main.Lang

julia> string(Lang.zh)
"中文Chinese"

julia> Lang.fromstr("中文Chinese") == Lang.zh
true

julia> @se Team Barcelona=>(country="Spain", revenue=840.8)  RealMadrid=>(id=3,country="Spain", revenue=757.3) ManchesterUnited=>(country="England", revenue=711.5)
julia> string(Team.RealMadrid).revenue
757.3
```
