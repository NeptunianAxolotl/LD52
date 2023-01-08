
local def = {
	gravity = 20,
	asteroidTimeMin = 4,
	asteroidTimeRand = 2,
	planets = {
		{
			pos = {-1000, 0},
			radius = 95,
			density = 150,
			age = "stone",
			maxAge = "space",
			ageSpeed = 1/20,
			guySpeed = 1/6,
			guyGap = 8,
			guyAgeBoost = 1.5,
			fillLastAge = false,
		},
	},
	sun = {
		alignX = 0.5,
		alignY = 0.5,
		radius = 200,
		image = "sun",
	},
	asteroids = {
		{
			pos = {1100, -750},
			orbitMult = 0.65,
			typeName = "asteroid_big",
		},
		{
			pos = {500, 360},
			orbitMult = -1.15,
			typeName = "asteroid_big",
		},
	},
	player = {
		pos = {-300, -500},
		orbitMult = -0.95,
	},
}

return def
