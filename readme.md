# SuperEnum

## Julia enum made nicer

## Usage

	@superenum Vehical plane train car truck

	julia> Vehical.VehicalEnum
	Enum Main.Vehical.VehicalEnum:
	plane = 0
	train = 1
	car = 2
	truck = 3

	julia> Vehical.car
	car::VehicalEnum = 2
