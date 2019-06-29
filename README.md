# SuperEnum

![https://ci.appveyor.com/api/projects/status/github/kindlychung/SuperEnum.jl?branch=master&svg=true&retina=true](https://ci.appveyor.com/api/projects/status/github/kindlychung/SuperEnum.jl?branch=master&svg=true&retina=true)

## Julia enum made nicer

## Usage

```julia
@superenum Vehicle plane train car truck

julia> Vehicle.VehicleEnum
Enum Main.Vehicle.VehicleEnum:
plane = 0
train = 1
car = 2
truck = 3

julia> Vehicle.car
car::VehicleEnum = 2
```
