
local def = {
	name = "Tutorial?",
	prevLevel = "testLevel",
	nextLevel = "drainCircling",
	gravity = 20,
	asteroidSpawn = {
		{
			timeMin = 4,
			timeRand = 2,
			speedMin = 80,
			speedMax = 350,
			typeName = {"asteroid_big"},
		},
	},
	planets = {
		{
			name = "Planet 1",
			pos = {-1000, 0},
			radius = 95,
			density = 150,
			age = "classical",
			maxAge = "space",
			ageSpeed = 1/20,
			guySpeed = 1/6,
			guyGap = 0,
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
		}
	},
	goal = {
		["Planet 1"] = {
			philosopher = 2,
		}
	},
	player = {
		pos = {-300, -500},
		orbitMult = -0.95,
	},
}

return def
