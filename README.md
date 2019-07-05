# SuperEnum

![https://ci.appveyor.com/api/projects/status/github/kindlychung/SuperEnum.jl?branch=master&svg=true&retina=true](https://ci.appveyor.com/api/projects/status/github/kindlychung/SuperEnum.jl?branch=master&svg=true&retina=true)

## Julia enum made nicer

## Usage

```julia
@se Vehical plane train car truck

julia> Vehical.VehicalEnum
Enum Main.Vehical.VehicalEnum:
plane = 0
train = 1
car = 2
truck = 3

julia> Vehical.car
car::VehicalEnum = 2

julia> @se Lang zh=>"中文"*"Chinese" en=>"English" ja=>"日本语"
Main.Lang

julia> string(Lang.zh)
"中文Chinese"

julia> Lang.fromstr("中文Chinese") == Lang.zh
true
```
