--
-- Constants
--

CONST_NOTWORKING     = 0
CONST_WAITINGFORTASK = 1
CONST_PICKINGUP      = 2
CONST_DELIVERING     = 3

--
-- Configuration
--

Config = {}

Config.AbortKey         = 167 -- (F6)
Config.TruckRentalPrice = 500
Config.TruckModel       = 'phantom'
Config.PayPerMeter      = 0.10

Config.JobStart = {
	Coordinates = vector3(1189.61, -3104.31, 4.7),
	Heading     = 0.0,
}

Config.Blip = {
	SpriteID = 477,
	ColorID  = 0,
	Scale    = 0.9,
}

Config.Marker = {
	DrawDistance = 100.0,
	Size = vector3(3.0, 3.0, 1.0),
	Color = {
		r = 102,
		g = 102,
		b = 204,
	},
	Type = 1,
}

Config.Routes = {
	{
		TrailerModel      = 'tr4',
		PickupCoordinates = vector3(508.94, -3047.27, 6.32),
		PickupHeading     = 0.0,
		Destinations = {
			vector3(-15.93, -1104.25, 25.67), -- PDM
			vector3(-810.84, -228.29, 36.21), -- Luxury Autos
			vector3(-868.27, -915.56, 25.03), -- Maibatsu Motors Factory
		}
	},
	{
		TrailerModel      = 'trailerlogs',
		PickupCoordinates = vector3(-843.92, 5416.16, 36.46),
		PickupHeading     = 79.30,
		Destinations = {
			vector3(985.74, -2523.91, 27.3), -- Cypress Warehouses
		}
	},
	{
		TrailerModel      = 'tanker',
		PickupCoordinates = vector3(518.88, -2156.75, 4.99),
		PickupHeading     = 172.43,
		Destinations = {
			vector3(264.38, -1244.98, 28.14), -- Xero 24 (Postal 4027)
			vector3(1780.95, 3330.17, 40.25), -- Gas (Postal 802)
			vector3(-97.66, 6422.26, 30.43), -- Xero (Postal 911)
			vector3(-1811.93, 810.2, 137.53), -- Xero (Postal 911)
		}
	},
}